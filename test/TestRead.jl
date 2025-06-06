mesh_file_name_2D = "./mesh/square_meshes/mesh_test.g"
number_of_nodes_2D = 16641
number_of_elements_2D = 128^2
number_of_node_set_nodes_2D = 128 + 1

mesh_file_name_3D = "./mesh/cube_meshes/mesh_test.g"
number_of_nodes_3D = 729
number_of_elements_3D = 512

@exodus_unit_test_set "Test Read ExodusDatabase - 2D Mesh" begin
  exo = ExodusDatabase(mesh_file_name_2D, "r")

  # blocks
  @test read_ids(exo, Block) == [1]
  @test read_names(exo, Block) == ["block_1"]
  @test read_name(exo, Block, 1) == "block_1"

  block = Block(exo, 1)
  @test block.id                 == 1
  @test block.num_elem           == number_of_elements_2D
  @test block.num_nodes_per_elem == 4
  @test block.elem_type          == "QUAD4"
  @test size(block.conn)         == (4, number_of_elements_2D)
  @test Exodus.read_element_type(exo, 1) == "QUAD4"

  block = Block(exo, "block_1")
  @test block.id                 == 1
  @test block.num_elem           == number_of_elements_2D
  @test block.num_nodes_per_elem == 4
  @test block.elem_type          == "QUAD4"
  @test size(block.conn)         == (4, number_of_elements_2D)
  @test Exodus.read_element_type(exo, 1) == "QUAD4"

  block = read_block(exo, 1)
  block = read_block(exo, "block_1")
  blocks = read_blocks(exo, read_ids(exo, Block))
  blocks = read_blocks(exo, 1)

  conn = Exodus.read_block_connectivity(exo, 1, block.num_nodes_per_elem * block.num_elem)
  conn = copy(conn)
  conn = reshape(conn, block.num_nodes_per_elem, block.num_elem)
  partial_conn = Exodus.read_partial_block_connectivity(exo, 1, 10, 100)
  partial_conn = reshape(partial_conn, block.num_nodes_per_elem, 100)

  @test conn[:, 10:110 - 1] ≈ partial_conn

  block_id_map = read_block_id_map(exo, 1)
  @test block_id_map == 1:Block(exo, 1).num_elem |> collect
  
  # coordinate values
  coords = read_coordinates(exo)
  @test size(coords) == (2, number_of_nodes_2D)

  # parital coordiantes values
  partial_coords = Exodus.read_partial_coordinates(exo, 10, 100)
  @test coords[:, 10:110 - 1] ≈ partial_coords

  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 10, 100, 1)
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 10, 100, 2)
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y

  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 10, 100, "x")
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 10, 100, "y")
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y

  # coordinate names
  coord_names = Exodus.read_coordinate_names(exo)
  @test coord_names == ["x", "y"]

  # init
  @test Exodus.num_dimensions(exo.init)     == 2
  @test Exodus.num_nodes(exo.init)          == number_of_nodes_2D
  @test Exodus.num_elements(exo.init)       == number_of_elements_2D
  @test Exodus.num_element_blocks(exo.init) == 1
  @test Exodus.num_node_sets(exo.init)      == 4
  @test Exodus.num_side_sets(exo.init)      == 4

  # maps
  elem_map = read_map(exo)
  @test length(elem_map) == Exodus.num_elements(exo.init)

  # nodesets
  nset_ids = read_ids(exo, NodeSet)
  @test nset_ids == [1, 2, 3 ,4]

  for (id, nset_id) in enumerate(nset_ids)
    nset = NodeSet(exo, nset_id)
    @test nset.id == id
    @test length(nset.nodes) == number_of_node_set_nodes_2D
  end

  nset_names = read_names(exo, NodeSet)
  nset_names_gold = ["nset_1", "nset_2", "nset_3", "nset_4"]
  for (n, nset_name) in enumerate(nset_names)
    @test nset_name == nset_names_gold[n]
  end

  nsets = read_sets(exo, NodeSet)

  @test_throws Exodus.SetIDException NodeSet(exo, 5)
  @test_throws Exodus.SetIDException read_set(exo, NodeSet, 5)
  @test_throws Exodus.SetNameException NodeSet(exo, "nset_fake")
  @test_throws Exodus.SetNameException read_set(exo, NodeSet, "nset_fake")

  # qa
  qa = read_qa(exo)
  @test qa[1, 1] == "CUBIT"
  @test qa[1, 2] == "2021.5"     # may change
  @test qa[1, 3] == "06/29/2023" # may change
  @test qa[1, 4] == "19:34:08"   # may change

  # sidesets
  sset_ids = read_ids(exo, SideSet)
  @test sset_ids == [1, 2, 3, 4]

  for (id, sset_id) in enumerate(sset_ids)
    sset = SideSet(exo, sset_id)
    @test sset.id == id
    @test length(sset.elements) == number_of_node_set_nodes_2D - 1
    @test length(sset.sides)    == number_of_node_set_nodes_2D - 1
    read_side_set_node_list(exo, sset_id)
  end

  sset_names = read_names(exo, SideSet)
  sset_names_gold = ["sset_1", "sset_2", "sset_3", "sset_4"]
  for (n, sset_name) in enumerate(sset_names)
    @test sset_name == sset_names_gold[n]
  end

  ssets = read_sets(exo, SideSet)

  @test_throws Exodus.SetIDException SideSet(exo, 5)
  @test_throws Exodus.SetIDException read_set(exo, SideSet, 5)
  @test_throws Exodus.SetNameException SideSet(exo, "sset_fake")
  @test_throws Exodus.SetNameException read_set(exo, SideSet, "sset_fake")

  # map tests
  # @test read_num_map(exo, NodeMap) == 1
  # @test read_num_map(exo, ElementMap) == 1

  close(exo)
end

@exodus_unit_test_set "Test Read ExodusDatabase - 3D Mesh" begin
  exo = ExodusDatabase(mesh_file_name_3D, "r")

  # coordinate values
  coords = read_coordinates(exo)
  @test size(coords) == (3, number_of_nodes_3D)

  # partial coordinate values
  partial_coords = Exodus.read_partial_coordinates(exo, 10, 100)
  @test coords[:, 10:110 - 1] ≈ partial_coords

  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 10, 100, 1)
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 10, 100, 2)
  partial_coords_z = Exodus.read_partial_coordinates_component(exo, 10, 100, 3)
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y
  @test coords[3, 10:110 - 1] ≈ partial_coords_z

  partial_coords_x = Exodus.read_partial_coordinates_component(exo, 10, 100, "x")
  partial_coords_y = Exodus.read_partial_coordinates_component(exo, 10, 100, "y")
  partial_coords_z = Exodus.read_partial_coordinates_component(exo, 10, 100, "z")
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y
  @test coords[3, 10:110 - 1] ≈ partial_coords_z

  # coordinate names
  coord_names = Exodus.read_coordinate_names(exo)
  @test coord_names == ["x", "y", "z"]

  # init
  @test Exodus.num_dimensions(exo.init)     == 3
  @test Exodus.num_nodes(exo.init)          == number_of_nodes_3D
  @test Exodus.num_elements(exo.init)       == number_of_elements_3D
  @test Exodus.num_element_blocks(exo.init) == 1
  @test Exodus.num_node_sets(exo.init)      == 6
  @test Exodus.num_side_sets(exo.init)      == 6

  # nodesets
  nset_ids = read_ids(exo, NodeSet)
  @test nset_ids == [1, 2, 3, 4, 5, 6]

  close(exo)
end

@exodus_unit_test_set "Test Read ExodusDatabase - multiple blocks" begin
  exo = ExodusDatabase("mesh/multi_block/multi_block_mesh.g", "r")
  @test read_ids(exo, Block) == [1, 2]
  @test read_ids(exo, NodeSet) == [1, 2, 3, 4, 5]
  @test read_ids(exo, SideSet) == [1, 2, 3, 4, 5]
  @test read_names(exo, Block) == ["block_1", "block_2"]
  @test read_names(exo, NodeSet) == ["nset_1", "nset_2", "nset_3", "nset_4", "nset_5"]
  @test read_names(exo, SideSet) == ["sset_1", "sset_2", "sset_3", "sset_4", "sset_5"]
  
  conns = collect_element_connectivities(exo)
  block_1 = Block(exo, 1)
  block_2 = Block(exo, 2)
  @test_throws Exodus.SetNameException Block(exo, "block_3")

  for e in axes(block_1.conn, 2)
    @test conns[e] == block_1.conn[:, e]
  end

  for e in axes(block_2.conn, 2)
    @test conns[size(block_1.conn, 2) + e] == block_2.conn[:, e]
  end

  # TODO make these tests actually test something
  collect_node_to_element_connectivities(exo)
  collect_element_to_element_connectivities(exo)

  close(exo)
end
