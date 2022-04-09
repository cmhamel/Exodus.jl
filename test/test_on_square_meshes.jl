mesh_file_names = ["../mesh/square_meshes/mesh_test_1.g",
                   "../mesh/square_meshes/mesh_test_0.5.g",
                   "../mesh/square_meshes/mesh_test_0.25.g",
                   "../mesh/square_meshes/mesh_test_0.125.g",
                   "../mesh/square_meshes/mesh_test_0.0625.g",
                   "../mesh/square_meshes/mesh_test_0.03125.g",
                   "../mesh/square_meshes/mesh_test_0.015625.g",
                   "../mesh/square_meshes/mesh_test_0.0078125.g"]

number_of_nodes = [4, 9, 25, 81, 289, 1089, 4225, 16641]
number_of_elements = [1, 2^2, 4^2, 8^2, 16^2, 32^2, 64^2, 128^2]
number_of_node_set_nodes = [1, 2, 4, 8, 16, 32, 64, 128] .+ 1

function test_square_mesh(n::Int)
    mesh_file_name = abspath(mesh_file_names[n])
    test_name = rpad("Testing square mesh: $(basename(mesh_file_name))", 96)
    @testset "$test_name" begin
        @suppress begin
            #
            # read method test
            #
            exo_id = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
            init = Exodus.Initialization(exo_id)
            #
            # tests on the simple numbers
            #
            @test init.num_dim == 2
            @test init.num_nodes == number_of_nodes[n]
            @test init.num_elem == number_of_elements[n]
            @test init.num_elem_blk == 1
            @test init.num_node_sets == 4
            @test init.num_side_sets == 4
            #
            # test coordinates
            #
            coords = Exodus.read_coordinates(exo_id, init.num_dim, init.num_nodes)
            @test size(coords, 1) == number_of_nodes[n]
            @test size(coords, 2) == 2
            #
            # read block ids
            #
            block_ids = Exodus.read_block_ids(exo_id, init.num_elem_blk)
            @test size(block_ids, 1) == 1
            @test block_ids[1] == 1
            blocks = Exodus.read_blocks(exo_id, block_ids)
            block = blocks[1]
            @test block.block_id == 1
            @test block.num_elem == number_of_elements[n]
            @test block.num_nodes_per_elem == 4
            @test block.elem_type == "QUAD4"
            @test size(block.conn, 1) == 4 * number_of_elements[n]
            # @test size(block.conn, 1) == number_of_elements[n]
            # @test size(block.conn, 2) == 4
            #
            # test node set initialization
            #
            node_set_ids = Exodus.read_node_set_ids(exo_id, init.num_node_sets)
            @test node_set_ids == [1, 2, 3, 4]
            node_sets = Exodus.read_node_sets(exo_id, node_set_ids)
            @test size(node_sets, 1) == 4
            for (m, node_set) in enumerate(node_sets)
                # @show node_set
                @test node_set.node_set_id == node_set_ids[m]
                @test node_set.num_nodes == number_of_node_set_nodes[n]
                @test size(node_set.nodes, 1) == number_of_node_set_nodes[n]
            end
            #
            mesh = Exodus.Mesh(coords, blocks, node_sets)
            @test size(mesh.coords, 1) == number_of_nodes[n]
            @test size(mesh.coords, 2) == 2

            Exodus.close_exodus_database(exo_id)
        end
    end
end

for (n, mesh) in enumerate(mesh_file_names)
    test_square_mesh(n)
end
