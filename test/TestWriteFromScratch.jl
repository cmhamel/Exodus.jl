@testset ExtendedTestSet "Write example" begin
  # data to write
  coords = [
    1.0 0.5 0.5 1.0 0.0 0.0 0.5 1.0 0.0
    1.0 1.0 0.5 0.5 1.0 0.5 0.0 0.0 0.0
  ]

  conn = [
    1 2 4 3
    2 5 3 6
    3 6 7 9
    4 3 8 7
  ]

  # make some hack variables to write
  v_nodal_1 = rand(9)
  v_nodal_2 = rand(9)

  v_elem_1 = rand(4)
  v_elem_2 = rand(4)

  # set the types
  maps_int_type = Int32
  ids_int_type  = Int32
  bulk_int_type = Int32
  float_type    = Float64

  # initialization parameters
  num_dim, num_nodes = size(coords)
  num_elems          = size(conn, 2)
  num_elem_blks      = 1
  num_side_sets      = 0
  num_node_sets      = 0

  # create exodus database
  exo = ExodusDatabase(
    "test_write.e";
    maps_int_type, ids_int_type, bulk_int_type, float_type,
    num_dim, num_nodes, num_elems,
    num_elem_blks, num_node_sets, num_side_sets
  )

  @show exo
  
  # how to write coordinates
  write_coordinates(exo, coords)
  # how to write a block
  write_element_block(exo, 1, "QUAD4", conn)
  # need at least one timestep to output variables
  write_time(exo, 1, 0.0)
  # write number of variables and their names
  write_number_of_nodal_variables(exo, 2)
  write_nodal_variable_names(exo, ["v_nodal_1", "v_nodal_2"])
  write_number_of_element_variables(exo, 2)
  write_element_variable_names(exo, ["v_elem_1", "v_elem_2"])
  # write variable values the 1 is for the time step
  write_nodal_variable_values(exo, 1, "v_nodal_1", v_nodal_1)
  write_nodal_variable_values(exo, 1, "v_nodal_2", v_nodal_2)
  # the first 1 is for the time step 
  # and the second 1 is for the block number
  write_element_variable_values(exo, 1, 1, "v_elem_1", v_elem_1)
  write_element_variable_values(exo, 1, 1, "v_elem_2", v_elem_2)

  # now confirm you wrote things correctly
  n_nodal_vars = read_number_of_nodal_variables(exo)
  n_elem_vars  = read_number_of_element_variables(exo)
  @test n_nodal_vars == 2
  @test n_elem_vars == 2
  nodal_var_names = read_nodal_variable_names(exo)
  elem_var_names  = read_element_variable_names(exo)
  @test nodal_var_names == ["v_nodal_1", "v_nodal_2"]
  @test elem_var_names == ["v_elem_1", "v_elem_2"]
  v_nodal_1_read = read_nodal_variable_values(exo, 1, "v_nodal_1")
  v_nodal_2_read = read_nodal_variable_values(exo, 1, "v_nodal_2")
  v_elem_1_read  = read_element_variable_values(exo, 1, 1, "v_elem_1")
  v_elem_2_read  = read_element_variable_values(exo, 1, 1, "v_elem_2")
  @test v_nodal_1_read ≈ v_nodal_1
  @test v_nodal_2_read ≈ v_nodal_2
  @test v_elem_1_read ≈ v_elem_1
  @test v_elem_2_read ≈ v_elem_2
  # don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
  close(exo)

  rm("test_write.e")
end