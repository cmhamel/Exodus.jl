# Reading Mesh Topology

Example for reading coordinates
<!-- ```jldoctest; filter = [r"(Array{[a-zA-Z0-9]+,\s?2}|Matrix{[a-zA-Z0-9]+})", r"{([a-zA-Z0-9]+,\s?)+[a-zA-Z0-9]+}"]
using Exodus
exo    = ExodusDatabase("../test/example_output/output.gold", "r")
coords = read_coordinates(exo)

# output

2×16641 Matrix{Float64}:
 0.5  0.492188  0.492188  0.5       0.484375  0.484375  …  -0.46875  -0.476562  -0.484375  -0.492188  -0.5
 0.5  0.5       0.492188  0.492188  0.5       0.492188     -0.5      -0.5       -0.5       -0.5       -0.5

``` -->