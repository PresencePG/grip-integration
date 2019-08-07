# tools for separating a power system into islands
#using Gurobi
using JuMP
using Cbc
using DataFrames
using CSV
using SparseArrays

# random number generator
#rng = MersenneTwister(1);

"""
function find_islands(ps)
    Determine how to divide the system described in the structure ps into islands
"""
function find_islands(ps)
    # get information about the problem
    # call the core solver
end

"""
islanding_core(
        n_bus,baseMVA, # general case data
        F,T,R,X,br_status0,switchable,loops, # data about branches
        G,Pg0,Pg_min,Pg_max,D,Pd0 # data about generators and loads
        )
  inputs:
    baseMVA is the baseMVA value for per unit calcs
    F,T,R,X are standard transmission line parameters.
        F,T are the node indices of branch end points (starting at 1)
        R,X are in per unit on the MVA base
    switchable is a vector of bools indicating if the line segment is switchable
    G,Pg,Pg_min,Pg_max are standard generation parameters. For batteries, set Pg_min to a negative value
    D,Pd are the node indices and amount of load at each node
    All power units should be in MW unless otherwise specified
  outputs:
    br_status, which will indicate where switching events need to occur
"""
function islanding_core(
    n_bus,baseMVA, # general case data
    F,T,R,X,br_status0,switchable,loops, # data about branches
    G,Pg0,Pg_min,Pg_max,D,Pd0 # data about generators and loads
    )
    # check things
    @assert(length(F)==length(T))==length(X)==length(br_status0)
    @assert(length(Pd0)==length(D))
    @assert(length(Pg0)==length(G))
    # count things
    nbr = length(F)
    n   = n_bus
    nd  = length(Pd0)
    ng  = length(Pg0)
    # how many switches do we have?
    n_switches = sum(switchable)
    can_switch_on  = switchable .& br_status0 .== false
    can_switch_off = switchable .& br_status0 .== true
    # constants
    bigM = 100
    load_value = 10000 # TODO: Make this an input parameter
    Cd = load_value.*ones(nd) + (rand(nd) .- 0.5).*(load_value/2)
    C_R = sum(Cd)/nd * 0.1 # TODO: Make this an input parameter
    # initiate the model
    m = Model(with_optimizer(Cbc.Optimizer))
    ## set up the variables
    @variable(m,switch_on[1:nbr])
    @variable(m,switch_off[1:nbr])
    # fix the variables that we don't need
    for i=1:nbr
        if switchable[i] && br_status0[i]==false
            fix(switch_off[i],0)
            set_binary(switch_on[i])
        elseif switchable[i] && br_status0[i]==true
            fix(switch_on[i],0)
            set_binary(switch_off[i])
        else
            fix(switch_off[i],0)
            fix(switch_on[i],0)
        end
    end
    # power generation
    @variable(m,Pg[1:ng])
    @constraint(m, Pg_min .<= Pg .<= Pg_max)
    @variable(m,dPg[1:ng])
    @constraint(m, Pg_min .<= Pg + dPg .<= Pg_max)
    # load
    @variable(m,Pd[1:nd])
    @constraint(m, 0. .<= Pd .<= Pd0)
    @variable(m, dPd[1:nd] )
    @constraint(m, dPd .>= 0)
    @variable(m,ud[1:nd],Bin) # binary variable for loads
    @constraint(m, sum(ud)>=1) # need at least one of the loads on
    @constraint(m, dPd .<= bigM.*ud) # delta-load is zero if ud=0
    # branch-flow variable
    @variable(m,flow[1:nbr])
    @variable(m,d_flow[1:nbr])
    # reserve margin variable
    @variable(m,R)
    ## objective(s)
    @objective( m, Max, sum(Cd.*Pd) # value of load served
                        + C_R*R  # value of reserves
                        #+ sum(C_R.*dPd) # value of additional load??? < do we need this?
                        - (sum(switch_on) + sum(switch_off)) # minimize switching operations
                        - sum(ud) # reducethe number of locations where we are counting reserves
                    )
    ## constraints
    # branch flow limits (control for switches)
    for i=1:nbr
        @constraint(m,-bigM*(br_status0[i] + switch_on[i] - switch_off[i]) .<= flow[i])
        @constraint(m,flow[i] .<= bigM*(br_status0[i] + switch_on[i] - switch_off[i]))
        @constraint(m,-bigM*(br_status0[i] + switch_on[i] - switch_off[i]) .<= d_flow[i])
        @constraint(m,d_flow[i] .<= bigM*(br_status0[i] + switch_on[i] - switch_off[i]))
    end
    # power balance
    Imat = incidence_matrix(n_bus,F,T)
    Fmat = Imat' # transpose
    Gmat = sparse(G,collect(1:ng),1,n_bus,ng)
    Dmat = sparse(D,collect(1:nd),1,n_bus,nd)
    @constraint(m,Gmat*Pg - Dmat*Pd .== Fmat*flow)
    @constraint(m,Gmat*(Pg+dPg) - Dmat*(Pd+dPd) .== Fmat*(flow+d_flow))
    # loop constraint
    for li = 1:length(loops)
        #is_switchable = switchable[loops[li]]
        ix = loops[li] # an index to use locally
        @constraint(m,sum(br_status0[ix] + switch_on[ix] - switch_off[ix]) <= length(ix)-1)
    end
    # reserve margin constraint
    for i = 1:nd
        @constraint(m,(1-ud[i])*bigM + dPd[i] >= R)
    end
    # DEBUG: print the model
    println(m)
    ## solve the model
    optimize!(m)
    ## extract the results
    stat = termination_status(m)
    if stat==MOI.OPTIMAL || stat==MOI.LOCALLY_SOLVED
        R_star = value(R)
        br_status = (br_status0 + value.(switch_on) - value.(switch_off)) .> 0.9
        Pd   = value.(Pd)
        Pg   = value.(Pg)
        dPg  = value.(dPg)
        flow = value.(flow)
        dPd  = value.(dPd)
        ud   = value.(ud) .> 0.9
        return (br_status,R_star,Pd,dPd,Pg,dPg,flow,ud)
    else
        error("Failed to find an optimal solution to the islanding problem")
    end
    return "Error in islanding_core() - should not reach this state"
end

function incidence_matrix(n,F,T)
    m = length(F)
    Imat = sparse(collect(1:m),F,1,m,n) + sparse(collect(1:m),T,-1,m,n)
end
