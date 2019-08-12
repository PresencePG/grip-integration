println("Julia server is getting up and running...")
using ZMQ
using JSON

include("islanding.jl")
include("read_payload.jl")

ctx = Context()

connection_uri = ENV["SERVER_LISTEN_URI"]

receiver = Socket(ctx, PAIR)
ZMQ.bind(receiver, connection_uri)

println("Julia ready . . .")

while true
    raw_msq = recv(receiver, String)
    msg = JSON.parse(raw_msq)
    # Do work here
    sent_at = msg["at"]
    message = msg["message"]
    #print(message)
    if message == "ping"
        send(receiver, "pong")
    elseif haskey(msg,"branch_id")
        (branch,T,F,R,X,brst,switchable,G,Pg0,Pg_min,Pg_max,ge_st,D,Pd0) = read_payload(msg)
        println("payload received.")

        # outages
        br_failures = [1,5,6] # permanent outages
        br_outages  = [2]   # temporary outages
        gen_outages = [2]
        baseMVA = 1

        n_bus = size(unique(vcat(T,F)),1)
        nbr = size(branch,1)
        ## manipulate the case data
        #brst .= true # DEBUG: all of them
        #switchable .= false # DEBUG: just for testing purposes
        # implement line failures
        switchable[br_failures] .= false
        brst[br_failures] .= false
        brst[br_outages] .= false
        # branch indices for loops in the graph
        loops = ([2,5,6,11,8,7,3],
                 [2,5,6,11,12,10,9,4],
                 [3,7,8,12,10,9,4]
                )
        ge_st[gen_outages] .= false

        println(". . . optimizing islanding case.")
        (br_status,R,Pd,dPd,Pg,dPg,flow,ud) =
            islanding_core(n_bus,baseMVA, # general case data
                            F,T,R,X,brst,switchable,loops, # data about branches
                            G,Pg0,Pg_min,Pg_max,D,Pd0 # data about generators and loads
                            )
        println("R = $R")
        println("Pd = $Pd")
        println("dPd = $dPd")
        println("Pg = $Pg")
        println("dPg = $dPg")
        println("st0 = $brst")
        println("st = $br_status")
        println("flow = $flow")
        println("ud = $ud")
        branch_results = DataFrame(id=1:nbr, st0=brst, st1=br_status)
        send(receiver, JSON.json(branch_results))
        continue
    end
    #send(receiver, "Recieved message sent at '$(sent_at)'")
    #println("$(sent_at): $(message)")
end
