using Pkg

Pkg.update()

Pkg.add("JSON")
Pkg.add("ZMQ")
Pkg.add("JuMP")
Pkg.add("Cbc")
Pkg.add("GLPK")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Test")
Pkg.add("SparseArrays")

using JSON
using ZMQ
using JuMP
using Cbc
using GLPK
using CSV
using DataFrames
using Test
using SparseArrays

println("Julia package installation complete.")
