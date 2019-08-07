
function read_payload(msg)

    branch = [parse(Int, ss) for ss in split(msg["branch_id"])]
    T = [parse(Int, ss) for ss in split(msg["branch_t"])]
    F = [parse(Int, ss) for ss in split(msg["branch_f"])]
    R = [parse(Float64, ss) for ss in split(msg["branch_R"])]
    X = [parse(Float64, ss) for ss in split(msg["branch_X"])]
    brst = [ss==1 for ss in split(msg["branch_status"])]
    switchable = [ss=="switch" for ss in split(msg["branch_kind"])]
    # get generator data
    G = [parse(Int, ss) for ss in split(msg["gen_bus"])]
    Pg0 = [parse(Float64, ss) for ss in split(msg["gen_P"])]
    Pg_min = [parse(Float64, ss) for ss in split(msg["gen_Pmin"])]
    ge_st = [parse(Float64, ss) for ss in split(msg["gen_status"])].>0.9
    Pg_max = [parse(Float64, ss) for ss in split(msg["gen_Pmax"])].*ge_st
    # get load data
    D = [parse(Float64, ss) for ss in split(msg["shunt_bus"])]
    Pd0 = [parse(Float64, ss) for ss in split(msg["shunt_P"])]

    return (branch,T,F,R,X,brst,switchable,G,Pg0,Pg_min,Pg_max,ge_st,D,Pd0)

end
