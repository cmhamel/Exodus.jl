mesh_file_name = "./mesh/square_meshes/mesh_test_0.0078125.g"
number_of_nodes = 16641
number_of_elements = 128^2


function test_read_block_ids_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  block_ids = read_block_ids(exo)
  @test length(block_ids) == 1
  @test block_ids == [1]
  close(exo)
end

function test_read_blocks_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  block_ids = read_block_ids(exo)
  blocks = read_blocks(exo, block_ids)
  @test length(blocks)               == 1
  @test blocks[1].block_id           == 1
  @test blocks[1].num_elem           == number_of_elements
  @test blocks[1].num_nodes_per_elem == 4
  @test blocks[1].elem_type          == "QUAD4"
  @test length(blocks[1].conn)       == 4 * number_of_elements
  close(exo)
end

@exodus_unit_test_set "Blocks.jl - Read" begin
  test_read_block_ids_on_square_meshes()
  test_read_blocks_on_square_meshes()
end