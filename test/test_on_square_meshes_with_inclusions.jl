mesh_file_names = ["../mesh/square_meshes_with_inclusions/mesh_test_0.0078125.g"]

# number_of_nodes = [4, 9, 25, 81, 289, 1089, 4225, 16641]
# number_of_elements = [1, 2^2, 4^2, 8^2, 16^2, 32^2, 64^2, 128^2]

# TODO: clean this up!

function test_square_mesh_with_inclusion(n::Int)
    mesh_file_name = abspath(mesh_file_names[n])
    test_name = rpad("Testing square mesh with inclusion: $(base_name(mesh_file_name))", 96)
    @testset "$test_name" begin
        # @suppress begin
            # read method test
            #
            exo_id = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
            # num_dim, num_nodes, num_elem,
            # num_elem_blk, num_node_sets, num_side_sets, title =
            # Exodus.read_initialization_parameters(exo_id)
            init = Exodus.Initialization(exo_id)
            # tests on the simple numbers
            #
            @test num_dim == 2
            # @test num_nodes == number_of_nodes[n]
            # @test num_elem == number_of_elements[n]
            @test num_elem_blk == 2
            @test num_node_sets == 4
            @test num_side_sets == 4

            # test coordinates
            #
            x_coords, y_coords, z_coords =
            Exodus.read_coordinates(exo_id, num_dim, num_nodes)

            # @test size(x_coords, 1) == number_of_nodes[n]
            # @test size(y_coords, 1) == number_of_nodes[n]
            # @test size(z_coords, 1) == number_of_nodes[n]

            # read block ids
            #
            block_ids = Exodus.read_block_ids(exo_id, num_elem_blk)
            @show num_elem_blk
            @show block_ids
            @test size(block_ids, 1) == 2
            @test block_ids[1] == 1
            @test block_ids[2] == 2

            # test block initialization
            #
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
    test_square_mesh_with_inclusion(n)
    # sleep(1)
end
