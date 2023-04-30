@exodus_unit_test_set "Test NodalVariables.jl - number of nodal variables" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  nvars = read_number_of_nodal_variables(exo)
  @test nvars == 1
  close(exo)
end

@exodus_unit_test_set "Test NodalVariables.jl - nodal variable names" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  var_names = read_nodal_variable_names(exo)
  @test var_names == ["u"]
  close(exo)
end

@exodus_unit_test_set "Test NodalVariables.jl - read nodal variable" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  u = read_nodal_variable_values(exo, 1, 1)
  @test length(u) == exo.init.num_nodes
  close(exo)
end