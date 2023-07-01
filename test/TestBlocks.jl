mesh_file_name_2D = "./mesh/square_meshes/mesh_test.g"
number_of_nodes_2D = 16641
number_of_elements_2D = 128^2


mesh_file_name_3D = "./mesh/cube_meshes/mesh_test.g"
number_of_nodes_3D = 729
number_of_elements_3D = 512

function test_read_element_block_ids_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_ids = read_element_block_ids(exo)
  @test length(block_ids) == 1
  @test block_ids == [1]
  close(exo)
end

function test_read_element_blocks_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_ids = read_element_block_ids(exo)
  blocks = read_element_blocks(exo, block_ids)
  @test length(blocks)               == 1
  @test blocks[1].block_id           == 1
  @test blocks[1].num_elem           == number_of_elements_2D
  @test blocks[1].num_nodes_per_elem == 4
  @test blocks[1].elem_type          == "QUAD4"
  @test size(blocks[1].conn)         == (4, number_of_elements_2D)
  close(exo)
end

# add more tests to actually test the map
function test_read_element_block_id_map_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block_id_map = read_element_block_id_map(exo, 1)
  @test block_id_map == 1:Block(exo, 1).num_elem |> collect
  close(exo)
end

function test_read_element_block_ids_on_cube_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_ids = read_element_block_ids(exo)
  @test length(block_ids) == 1
  @test block_ids == [1]
  close(exo)
end

# add more tests to actually test the map
function test_read_element_block_id_map_on_cube_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_id_map = read_element_block_id_map(exo, 1)
  @test block_id_map == 1:Block(exo, 1).num_elem |> collect
  close(exo)
end

function test_read_element_blocks_on_cube_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block_ids = read_element_block_ids(exo)
  blocks = read_element_blocks(exo, block_ids)
  @test length(blocks)               == 1
  @test blocks[1].block_id           == 1
  @test blocks[1].num_elem           == number_of_elements_3D
  @test blocks[1].num_nodes_per_elem == 8
  @test blocks[1].elem_type          == "HEX8"
  @test size(blocks[1].conn)         == (8, number_of_elements_3D)
  close(exo)
end

@exodus_unit_test_set "Blocks.jl - Read" begin
  test_read_element_block_ids_on_square_meshes()
  test_read_element_block_id_map_on_square_meshes()
  test_read_element_blocks_on_square_meshes()
  test_read_element_block_ids_on_cube_meshes()
  test_read_element_block_id_map_on_cube_meshes()
  test_read_element_blocks_on_cube_meshes()
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

@exodus_unit_test_set "Test read block element type" begin
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  elem_type = read_element_type(exo, 1)
  @test elem_type == "QUAD4"
  close(exo)
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  elem_type = read_element_type(exo, 1)
  @test elem_type == "HEX8"
  close(exo)
end

@exodus_unit_test_set "Test read partial block connectivity" begin
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  block = Block(exo, 1)
  conn = read_element_block_connectivity(exo, 1)
  conn = reshape(conn, block.num_nodes_per_elem, block.num_elem)
  partial_conn = read_partial_element_block_connectivity(exo, 1, 10, 100)
  partial_conn = reshape(partial_conn, block.num_nodes_per_elem, 100)

  @test conn[:, 10:110 - 1] ≈ partial_conn
  close(exo)

  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  block = Block(exo, 1)
  conn = read_element_block_connectivity(exo, 1)
  conn = reshape(conn, block.num_nodes_per_elem, block.num_elem)
  partial_conn = read_partial_element_block_connectivity(exo, 1, 10, 100)
  partial_conn = reshape(partial_conn, block.num_nodes_per_elem, 100)

  @test conn[:, 10:110 - 1] ≈ partial_conn
  close(exo)
end

@exodus_unit_test_set "Test write block" begin
  # initialization gathering
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  blocks_old = read_element_blocks(exo_old, read_element_block_ids(exo_old))
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_block.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  for block in blocks_old
    write_element_block(exo_new, block)
  end
  blocks_new = read_element_blocks(exo_new, read_element_block_ids(exo_new))
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(blocks_old)
    @test blocks_old[n].block_id == blocks_new[n].block_id
    @test blocks_old[n].num_elem == blocks_new[n].num_elem
    @test blocks_old[n].num_nodes_per_elem == blocks_new[n].num_nodes_per_elem
    @test blocks_old[n].elem_type == blocks_new[n].elem_type
    @test blocks_old[n].conn == blocks_new[n].conn
  end

  Base.Filesystem.rm("./test_output_block.e")
end

@exodus_unit_test_set "Test write block" begin
  # initialization gathering
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  blocks_old = read_element_blocks(exo_old, read_element_block_ids(exo_old))
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_block.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  # for block in blocks_old
  #   write_element_block(exo_new, block)
  # end
  write_element_blocks(exo_new, blocks_old)
  blocks_new = read_element_blocks(exo_new, read_element_block_ids(exo_new))
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(blocks_old)
    @test blocks_old[n].block_id == blocks_new[n].block_id
    @test blocks_old[n].num_elem == blocks_new[n].num_elem
    @test blocks_old[n].num_nodes_per_elem == blocks_new[n].num_nodes_per_elem
    @test blocks_old[n].elem_type == blocks_new[n].elem_type
    @test blocks_old[n].conn == blocks_new[n].conn
  end

  Base.Filesystem.rm("./test_output_block.e")
end

@exodus_unit_test_set "Show Block" begin
  exo = ExodusDatabase(mesh_file_name_2D, "r")
  block = Block(exo, 1)
  @show block
  close(exo)
end

# @exodus_unit_test_set "Test ExodusBlock" begin
#   exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
#   block_1 = ExodusBlock(exo, 1)
#   @show block_1
#   close(exo)
# end