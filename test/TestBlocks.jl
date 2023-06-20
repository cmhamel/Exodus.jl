mesh_file_name_2D = "./mesh/square_meshes/mesh_test_0.0078125.g"
number_of_nodes_2D = 16641
number_of_elements_2D = 128^2


mesh_file_name_3D = "./mesh/cube_meshes/mesh_test_0.125.g"
number_of_nodes_3D = 729
number_of_elements_3D = 512

function test_read_block_ids_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_ids = read_block_ids(exo)
  @test length(block_ids) == 1
  @test block_ids == [1]
  close(exo)
end

function test_read_blocks_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_ids = read_block_ids(exo)
  blocks = read_blocks(exo, block_ids)
  @test length(blocks)               == 1
  @test blocks[1].block_id           == 1
  @test blocks[1].num_elem           == number_of_elements_2D
  @test blocks[1].num_nodes_per_elem == 4
  @test blocks[1].elem_type          == "QUAD4"
  @test size(blocks[1].conn)         == (4, number_of_elements_2D)
  close(exo)
end

# add more tests to actually test the map
function test_read_block_id_map_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_id_map = read_block_id_map(exo, 1)
  @test block_id_map == 1:Block(exo, 1).num_elem |> collect
  close(exo)
end

function test_read_block_ids_on_cube_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_ids = read_block_ids(exo)
  @test length(block_ids) == 1
  @test block_ids == [1]
  close(exo)
end

# add more tests to actually test the map
function test_read_block_id_map_on_cube_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_id_map = read_block_id_map(exo, 1)
  @test block_id_map == 1:Block(exo, 1).num_elem |> collect
  close(exo)
end

function test_read_blocks_on_cube_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_ids = read_block_ids(exo)
  blocks = read_blocks(exo, block_ids)
  @test length(blocks)               == 1
  @test blocks[1].block_id           == 1
  @test blocks[1].num_elem           == number_of_elements_3D
  @test blocks[1].num_nodes_per_elem == 8
  @test blocks[1].elem_type          == "HEX8"
  @test size(blocks[1].conn)         == (8, number_of_elements_3D)
  close(exo)
end

@exodus_unit_test_set "Blocks.jl - Read" begin
  test_read_block_ids_on_square_meshes()
  test_read_block_id_map_on_square_meshes()
  test_read_blocks_on_square_meshes()
  test_read_block_ids_on_cube_meshes()
  test_read_block_id_map_on_cube_meshes()
  test_read_blocks_on_cube_meshes()
end

@exodus_unit_test_set "Test block read from name 2D" begin
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_1 = Block(exo, "block_1")
  block_2 = Block(exo, 1)

  @test block_1.block_id           == block_2.block_id
  @test block_1.num_elem           == block_2.num_elem
  @test block_1.num_nodes_per_elem == block_2.num_nodes_per_elem
  @test block_1.elem_type          == block_2.elem_type
  @test block_1.conn               == block_2.conn

  close(exo)
end

@exodus_unit_test_set "Test block read from name 3D" begin
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_1 = Block(exo, "block_1")
  block_2 = Block(exo, 1)

  @test block_1.block_id           == block_2.block_id
  @test block_1.num_elem           == block_2.num_elem
  @test block_1.num_nodes_per_elem == block_2.num_nodes_per_elem
  @test block_1.elem_type          == block_2.elem_type
  @test block_1.conn               == block_2.conn

  close(exo)
end