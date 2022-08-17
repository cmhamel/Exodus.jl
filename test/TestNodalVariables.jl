@exodus_unit_test_set "Test NodalVariables.jl - number of nodal variables" begin
    exo = Exodus.ExodusDatabase("../example_output/output.e", "r")

    Exodus.close(exo)
end