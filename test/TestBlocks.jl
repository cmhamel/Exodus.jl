mesh_file_names = ["./mesh/square_meshes/mesh_test_1.g",
                   "./mesh/square_meshes/mesh_test_0.5.g",
                   "./mesh/square_meshes/mesh_test_0.25.g",
                   "./mesh/square_meshes/mesh_test_0.125.g",
                   "./mesh/square_meshes/mesh_test_0.0625.g",
                   "./mesh/square_meshes/mesh_test_0.03125.g",
                   "./mesh/square_meshes/mesh_test_0.015625.g",
                   "./mesh/square_meshes/mesh_test_0.0078125.g"]

number_of_nodes = [4, 9, 25, 81, 289, 1089, 4225, 16641]
number_of_elements = [1, 2^2, 4^2, 8^2, 16^2, 32^2, 64^2, 128^2]


function test_read_block_ids_on_square_meshes(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    block_ids = Exodus.read_block_ids(exo, init)
    @test length(block_ids) == 1
    @test block_ids == [1]
    close(exo)
end

function test_read_blocks_on_square_meshes(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    block_ids = Exodus.read_block_ids(exo, init)
    blocks = Exodus.read_blocks(exo, block_ids)
    @test length(blocks)               == 1
    @test blocks[1].block_id           == 1
    @test blocks[1].num_elem           == number_of_elements[n]
    @test blocks[1].num_nodes_per_elem == 4
    @test blocks[1].elem_type          == "QUAD4"
    @test length(blocks[1].conn)       == 4 * number_of_elements[n]
    close(exo)
end

@exodus_unit_test_set "Square Mesh Test Read Block IDs" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_block_ids_on_square_meshes(n)
    end
end

@exodus_unit_test_set "Square Mesh Test Read Blocks" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_blocks_on_square_meshes(n)
    end
end