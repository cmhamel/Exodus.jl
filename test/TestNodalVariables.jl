@exodus_unit_test_set "Test NodalVariables.jl - number of nodal variables" begin
    exo = ExodusDatabase("./example_output/output.gold", "r")
    nvars = Exodus.read_number_of_nodal_variables(exo)
    @test nvars == 1
    close(exo)
end

@exodus_unit_test_set "Test NodalVariables.jl - nodal variable names" begin
    exo = ExodusDatabase("./example_output/output.gold", "r")
    var_names = Exodus.read_nodal_variable_names(exo)
    @test var_names == ["u"]
    close(exo)
end

@exodus_unit_test_set "Test NodalVariables.jl - read nodal variable" begin
    exo = ExodusDatabase("./example_output/output.gold", "r")
    init = Initialization(exo)
    u = Exodus.read_nodal_variable_values(exo, 1, 1, init.num_nodes)
    @test length(u) == init.num_nodes
    close(exo)
end