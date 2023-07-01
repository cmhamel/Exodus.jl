@exodus_unit_test_set "Test NodeSetVariables - write/read number of variables" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_node_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_node_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_node_set_variables(exo, 5)

  n_vars = read_number_of_node_set_variables(exo)
  @test n_vars == 5
  close(exo)
  rm("./temp_node_set_variables.e", force=true)
end

@exodus_unit_test_set "Test NodeSetVariables - write/read nodeset names" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_node_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_node_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_node_set_variables(exo, 2)
  write_node_set_variable_names(exo, ["nset_displ_x", "nset_displ_y"])

  var_names = read_node_set_variable_names(exo)
  @test var_names == ["nset_displ_x", "nset_displ_y"]

  close(exo)
  rm("./temp_node_set_variables.e", force=true)
end

@exodus_unit_test_set "Test NodeSetVariables - write/read nodeset values" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_node_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_node_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_node_set_variables(exo, 1)

  for nset_id in [1, 2, 3, 4]
    num_nodes, _ = read_node_set_parameters(exo, nset_id)
    u = randn(num_nodes)
    write_node_set_variable_values(exo, 1, 1, nset_id, u)
    u_read = read_node_set_variable_values(exo, 1, 1, nset_id)
    @test u ≈ u_read
  end

  close(exo)
  rm("./temp_node_set_variables.e", force=true)
end

@exodus_unit_test_set "Test NodeSetVariables - write/read nodeset values by name" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_node_set_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_node_set_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_node_set_variables(exo, 1)
  write_node_set_variable_names(exo, ["nset_displ_x"])

  nset_names = read_node_set_names(exo)
  for nset_id in [1, 2, 3, 4]
    num_nodes, _ = read_node_set_parameters(exo, nset_id)
    u = randn(num_nodes)
    write_node_set_variable_values(exo, 1, "nset_displ_x", nset_names[nset_id], u)
    u_read = read_node_set_variable_values(exo, 1, "nset_displ_x", nset_names[nset_id])
    @test u ≈ u_read
  end

  close(exo)
  rm("./temp_node_set_variables.e", force=true)
end
