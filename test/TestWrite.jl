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
  num_node_sets = 0
  num_side_sets = 0

  # create init  
  init = Initialization(
    Int32(num_dim), Int32(num_nodes), Int32(num_elems),
    Int32(num_elem_blks), Int32(num_node_sets), Int32(num_side_sets)
  )

  # create exodus database
  exo = ExodusDatabase(
    "test_write_1D_mesh.e", "w", init,
    Int32, Int32, Int32, Float64
  )

  # how to write coordinates
  write_coordinates(exo, coords)
  coords_read = read_coordinates(exo)
  @test coords == coords_read[1, :]

  # test bad write coordiantes
  @test_throws ErrorException write_coordinates(exo, randn(100))

  # test partial coord write/read
  temp = randn(2)
  Exodus.write_partial_coordinates(exo, 2, temp)
  partial_coords = Exodus.read_partial_coordinates(exo, 2, 2)
  @test partial_coords[1, :] == temp

  # test partial coord write/read with component index
  temp = randn(2)
  Exodus.write_partial_coordinates_component(exo, 2, 1, temp)
  partial_coords = Exodus.read_partial_coordinates_component(exo, 2, 2, 1)
  @test partial_coords == temp

  # test partial coord write/read with component name
  temp = randn(2)
  Exodus.write_partial_coordinates_component(exo, 2, "x", temp)
  partial_coords = Exodus.read_partial_coordinates_component(exo, 2, 2, "x")
  @test partial_coords == temp

  close(exo)

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
  num_node_sets      = 0
  num_side_sets      = 0

  # create init
  init = Initialization(
    Int32(num_dim), Int32(num_nodes), Int32(num_elems),
    Int32(num_elem_blks), Int32(num_node_sets), Int32(num_side_sets)
  )

  # create exodus database
  exo = ExodusDatabase(
    "test_write_2D_mesh.e", "w", init,
    Int32, Int32, Int32, Float64
  )
  
  # how to write coordinates
  write_coordinates(exo, coords)
  # test bad coordinates write
  @test_throws ErrorException write_coordinates(exo, randn(100, 4))
  # test partial coord write/read
  temp = randn(2, 2)
  Exodus.write_partial_coordinates(exo, 2, temp)
  partial_coords = Exodus.read_partial_coordinates(exo, 2, 2)
  @test partial_coords == temp
  # test partial coord write/read with component index
  temp = randn(2, 2)
  Exodus.write_partial_coordinates_component(exo, 2, 1, temp[1, :])
  Exodus.write_partial_coordinates_component(exo, 2, 2, temp[2, :])
  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 2, 2, 1)
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 2, 2, 2)
  @test partial_coords_x == temp[1, :]
  @test partial_coords_y == temp[2, :]
  # test partial coord write/read with component name
  temp = randn(2, 2)
  Exodus.write_partial_coordinates_component(exo, 2, "x", temp[1, :])
  Exodus.write_partial_coordinates_component(exo, 2, "y", temp[2, :])
  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 2, 2, "x")
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 2, 2, "y")
  @test partial_coords_x == temp[1, :]
  @test partial_coords_y == temp[2, :]
  # how to write a block
  write_block(exo, 1, "QUAD4", conn)
  # need at least one timestep to output variables
  write_time(exo, 1, 0.0)
  # write number of variables and their names
  write_number_of_variables(exo, NodalVariable, 2)
  write_names(exo, NodalVariable, ["v_nodal_1", "v_nodal_2"])
  write_number_of_variables(exo, ElementVariable, 2)
  write_names(exo, ElementVariable, ["v_elem_1", "v_elem_2"])
  # write variable values the 1 is for the time step
  write_values(exo, NodalVariable, 1, 1, "v_nodal_1", v_nodal_1)
  write_values(exo, NodalVariable, 1, 1, "v_nodal_2", v_nodal_2)
  # the first 1 is for the time step 
  # and the second 1 is for the block number
  write_values(exo, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
  write_values(exo, ElementVariable, 1, 1, "v_elem_2", v_elem_2)

  # now confirm you wrote things correctly
  n_nodal_vars = read_number_of_variables(exo, NodalVariable)
  n_elem_vars  = read_number_of_variables(exo, ElementVariable)
  @test n_nodal_vars == 2
  @test n_elem_vars == 2
  nodal_var_names = read_names(exo, NodalVariable)
  elem_var_names  = read_names(exo, ElementVariable)
  @test nodal_var_names == ["v_nodal_1", "v_nodal_2"]
  @test elem_var_names == ["v_elem_1", "v_elem_2"]
  v_nodal_1_read = read_values(exo, NodalVariable, 1, 1, "v_nodal_1")
  v_nodal_2_read = read_values(exo, NodalVariable, 1, 1, "v_nodal_2")
  v_elem_1_read  = read_values(exo, ElementVariable, 1, 1, "v_elem_1")
  v_elem_2_read  = read_values(exo, ElementVariable, 1, 1, "v_elem_2")
  @test v_nodal_1_read ≈ v_nodal_1
  @test v_nodal_2_read ≈ v_nodal_2
  @test v_elem_1_read ≈ v_elem_1
  @test v_elem_2_read ≈ v_elem_2
  # don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
  close(exo)

  # rm("test_write.e")
  Base.Filesystem.rm("test_write_2D_mesh.e")
end

@exodus_unit_test_set "Write example - 3D Mesh" begin
  coords = [
    0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0
    0.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0
    0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0
  ]

  conn = [
    1 2 3 4 5 6 7 8
  ]

  # set the types
  maps_int_type = Int32
  ids_int_type  = Int32
  bulk_int_type = Int32
  float_type    = Float64

  # initialization parameters
  num_dim, num_nodes = 3, 8
  num_elems          = 1
  num_elem_blks      = 1
  num_node_sets      = 0
  num_side_sets      = 0

  # create exodus database
  # exo = ExodusDatabase(
  #   "test_write_3D_mesh.e";
  #   maps_int_type, ids_int_type, bulk_int_type, float_type,
  #   num_dim, num_nodes, num_elems,
  #   num_elem_blks, num_node_sets, num_side_sets
  # )

  init = Initialization(
    Int32(num_dim), Int32(num_nodes), Int32(num_elems),
    Int32(num_elem_blks), Int32(num_node_sets), Int32(num_side_sets)
  )

  exo = ExodusDatabase(
    "test_write_3D_mesh.e", "w", init,
    Int32, Int32, Int32, Float64
  )

  # how to write coordinates
  write_coordinates(exo, coords)
  # test bad coordinates write
  @test_throws ErrorException write_coordinates(exo, randn(100, 4))
  # test partial coord write/read
  temp = randn(3, 2)
  Exodus.write_partial_coordinates(exo, 2, temp)
  partial_coords = Exodus.read_partial_coordinates(exo, 2, 2)
  @test partial_coords == temp
  # test partial coord write/read with component index
  temp = randn(3, 2)
  Exodus.write_partial_coordinates_component(exo, 2, 1, temp[1, :])
  Exodus.write_partial_coordinates_component(exo, 2, 2, temp[2, :])
  Exodus.write_partial_coordinates_component(exo, 2, 3, temp[3, :])
  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 2, 2, 1)
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 2, 2, 2)
  partial_coords_z = Exodus.read_partial_coordinates_component(exo, 2, 2, 3)
  @test partial_coords_x == temp[1, :]
  @test partial_coords_y == temp[2, :]
  @test partial_coords_z == temp[3, :]
  # test partial coord write/read with component name
  temp = randn(3, 2)
  Exodus.write_partial_coordinates_component(exo, 2, "x", temp[1, :])
  Exodus.write_partial_coordinates_component(exo, 2, "y", temp[2, :])
  Exodus.write_partial_coordinates_component(exo, 2, "z", temp[3, :])
  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 2, 2, "x")
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 2, 2, "y")
  partial_coords_z = Exodus.read_partial_coordinates_component(exo, 2, 2, "z")
  @test partial_coords_x == temp[1, :]
  @test partial_coords_y == temp[2, :]
  @test partial_coords_z == temp[3, :]

  close(exo)

  Base.Filesystem.rm("test_write_3D_mesh.e")
end