@exodus_unit_test_set "Test Read/Write ExodusDatabase - 1D Mesh" begin
  coords = [0.0, 0.25, 0.5, 0.75, 1.0]
  conn = [
    1 2
    2 3
    3 4
    4 5
  ]
  
  # set the types
  maps_int_type = Int32
  ids_int_type  = Int32
  bulk_int_type = Int32
  float_type    = Float64

  # initialization parameters
  # num_dim, num_nodes = size(coords)
  num_dim       = 1
  num_nodes     = size(coords, 1)
  num_elems     = size(conn, 1)
  num_elem_blks = 1
  num_side_sets = 0
  num_node_sets = 0

  # create exodus database
  exo = ExodusDatabase(
    "test_write_1D_mesh.e";
    maps_int_type, ids_int_type, bulk_int_type, float_type,
    num_dim, num_nodes, num_elems,
    num_elem_blks, num_node_sets, num_side_sets
  )
  
  # how to write coordinates
  write_coordinates(exo, coords)
  coords_read = read_coordinates(exo)
  @test coords == coords_read[1, :]

  # test bad write coordiantes
  @test_throws ErrorException write_coordinates(exo, randn(100))

  # test partial coord write/read
  temp = randn(2)
  write_partial_coordinates(exo, 2, temp)
  partial_coords = read_partial_coordinates(exo, 2, 2)
  @test partial_coords[1, :] == temp

  # test partial coord write/read with component index
  temp = randn(2)
  write_partial_coordinates_component(exo, 2, 1, temp)
  partial_coords = read_partial_coordinates_component(exo, 2, 2, 1)
  @test partial_coords == temp

  # test partial coord write/read with component name
  temp = randn(2)
  write_partial_coordinates_component(exo, 2, "x", temp)
  partial_coords = read_partial_coordinates_component(exo, 2, 2, "x")
  @test partial_coords == temp

  Base.Filesystem.rm("test_write_1D_mesh.e")
end

@exodus_unit_test_set "Write example - 2D Mesh" begin
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
    "test_write_2D_mesh.e";
    maps_int_type, ids_int_type, bulk_int_type, float_type,
    num_dim, num_nodes, num_elems,
    num_elem_blks, num_node_sets, num_side_sets
  )
  
  # how to write coordinates
  write_coordinates(exo, coords)
  # test bad coordinates write
  @test_throws ErrorException write_coordinates(exo, randn(100, 4))
  # test partial coord write/read
  temp = randn(2, 2)
  write_partial_coordinates(exo, 2, temp)
  partial_coords = read_partial_coordinates(exo, 2, 2)
  @test partial_coords == temp
  # test partial coord write/read with component index
  temp = randn(2, 2)
  write_partial_coordinates_component(exo, 2, 1, temp[1, :])
  write_partial_coordinates_component(exo, 2, 2, temp[2, :])
  partial_coords_x = read_partial_coordinates_component(exo, 2, 2, 1)
  partial_coords_y = read_partial_coordinates_component(exo, 2, 2, 2)
  @test partial_coords_x == temp[1, :]
  @test partial_coords_y == temp[2, :]
  # test partial coord write/read with component name
  temp = randn(2, 2)
  write_partial_coordinates_component(exo, 2, "x", temp[1, :])
  write_partial_coordinates_component(exo, 2, "y", temp[2, :])
  partial_coords_x = read_partial_coordinates_component(exo, 2, 2, "x")
  partial_coords_y = read_partial_coordinates_component(exo, 2, 2, "y")
  @test partial_coords_x == temp[1, :]
  @test partial_coords_y == temp[2, :]
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

  # rm("test_write.e")
  Base.Filesystem.rm("test_write_2D_mesh.e")
end