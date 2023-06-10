@exodus_unit_test_set "Test SideSetVariables - write/read number of variables" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_side_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_side_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_side_set_variables(exo, 5)

  n_vars = read_number_of_side_set_variables(exo)
  @test n_vars == 5
  close(exo)
  rm("./temp_side_set_variables.e", force=true)
end

@exodus_unit_test_set "Test SideSetVariables - write/read sideset names" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_side_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_side_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_side_set_variables(exo, 2)
  write_side_set_variable_names(exo, [1, 2], ["sset_displ_x", "sset_displ_y"])

  var_names = read_side_set_variable_names(exo)
  @test var_names == ["sset_displ_x", "sset_displ_y"]

  close(exo)
  rm("./temp_side_set_variables.e", force=true)
end

@exodus_unit_test_set "Test SideSetVariables - write/read sideset values" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_side_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_side_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_side_set_variables(exo, 1)

  for sset_id in [1, 2, 3, 4]
    num_nodes, _ = read_side_set_parameters(exo, sset_id)
    u = randn(num_nodes)
    write_side_set_variable_values(exo, 1, 1, sset_id, u)
    u_read = read_side_set_variable_values(exo, 1, 1, sset_id)
    @test u ≈ u_read
  end

  close(exo)
  rm("./temp_side_set_variables.e", force=true)
end

@exodus_unit_test_set "Test SideSetVariables - write/read sideset values by name" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_side_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_side_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_side_set_variables(exo, 1)
  write_side_set_variable_names(exo, [1], ["sset_displ_x"])

  sset_names = read_side_set_names(exo)
  for sset_id in [1, 2, 3, 4]
    num_nodes, _ = read_side_set_parameters(exo, sset_id)
    u = randn(num_nodes)
    write_side_set_variable_values(exo, 1, "sset_displ_x", sset_names[sset_id], u)
    u_read = read_side_set_variable_values(exo, 1, "sset_displ_x", sset_names[sset_id])
    @test u ≈ u_read
  end

  close(exo)
  rm("./temp_side_set_variables.e", force=true)
end
