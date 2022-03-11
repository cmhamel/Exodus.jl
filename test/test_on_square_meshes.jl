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

function test_square_mesh(n::Int)
    mesh_file_name = abspath(mesh_file_names[n])
    test_name = rpad("Testing square mesh: $(basename(mesh_file_name))", 96)
    @testset "$test_name" begin
        # @suppress begin
            # read method test
            #
            exo_id = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
            init = Exodus.get_initialization(exo_id)
            @show init
            # tests on the simple numbers
            #
            @test init.num_dim == 2
            @test init.num_nodes == number_of_nodes[n]
            @test init.num_elem == number_of_elements[n]
            @test init.num_elem_blk == 1
            @test init.num_node_sets == 4
            @test init.num_side_sets == 4
            #
            # # test coordinates
            # #
            x_coords, y_coords, z_coords =
            Exodus.read_coordinates(exo_id, init.num_dim, init.num_nodes)
            #
            @test size(x_coords, 1) == number_of_nodes[n]
            @test size(y_coords, 1) == number_of_nodes[n]
            @show x_coords
            # @test size(z_coords, 1) == number_of_nodes[n]
            #
            # # read block ids
            # #
            # block_ids = Exodus.read_block_ids(exo_id, num_elem_blk)
            # @show num_elem_blk
            # @show block_ids
            # @test size(block_ids, 1) == 1
            # @test block_ids[1] == 1
            #
            # # test block initialization
            # #
            # element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
            # Exodus.read_element_block_parameters(exo_id, 1)
            #
            # @test element_type == "QUAD4"
            # @test num_elem == number_of_elements[n]
            # @test num_nodes == 4
            #
            # # test reading read_connectivity
            # #
            # conn = Exodus.read_block_connectivity(exo_id, 1)
            # @test size(conn, 1) == num_nodes * num_elem
            # @show conn

            # block = Exodus.initialize_block(exo_id, 1)

            # test node set initialization
            #
            # node_set = Mesh.initialize_node_set(exo, 1)
            # @test node_set.node_set_number == 1

            # test mesh initialization
            #
            # mesh = Mesh.MeshStruct()

            Exodus.close_exodus_database(exo_id)
        # end
    end
end

for (n, mesh) in enumerate(mesh_file_names)
    test_square_mesh(n)
end
