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

@exodus_unit_test_set "Test NodalVariables.jl - write number of ndoal variables" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp.e")
  close(exo_old)
  exo = ExodusDatabase("./temp.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_nodal_variables(exo, 5)
  n_vars = read_number_of_nodal_variables(exo)
  @test n_vars == 5
  close(exo)
end

@exodus_unit_test_set "Test NodalVariables.jl - write nodal variable names" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp.e")
  close(exo_old)
  exo = ExodusDatabase("./temp.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_nodal_variables(exo, 2)
  write_nodal_variable_names(exo, [1, 2], ["displ_x", "displ_y"])

  var_names = read_nodal_variable_names(exo)
  @test var_names == ["displ_x", "displ_y"]
  close(exo)
end

@exodus_unit_test_set "Test NodalVariables.jl - write nodal variable values" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp.e")
  close(exo_old)
  exo = ExodusDatabase("./temp.e", "rw")
  coords = read_coordinates(exo)

  write_time(exo, 1, 0.0)
  write_number_of_nodal_variables(exo, 2)

  u = randn(size(coords, 1))
  write_nodal_variable_values(exo, 1, 1, u)
  u_read = read_nodal_variable_values(exo, 1, 1)
  @test u ≈ u_read
  close(exo)
end