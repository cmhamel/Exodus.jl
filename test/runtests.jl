using Exodus
using Test
using Profile
using Suppressor

mesh_file_names = ["../mesh/mesh_test_1.g",
                   "../mesh/mesh_test_0.5.g",
                   "../mesh/mesh_test_0.25.g",
                   "../mesh/mesh_test_0.125.g",
                   "../mesh/mesh_test_0.0625.g",
                   "../mesh/mesh_test_0.03125.g",
                   "../mesh/mesh_test_0.015625.g",
                   "../mesh/mesh_test_0.0078125.g"]

number_of_nodes = [4, 9, 25, 81, 289, 1089, 4225, 16641]
number_of_elements = [1, 2^2, 4^2, 8^2, 16^2, 32^2, 64^2, 128^2]

function test_square_mesh(n::Int)
    mesh_file_name = abspath(mesh_file_names[n])
    test_name = rpad("Testing square mesh: $(mesh_file_name)", 96)
    @testset "$test_name" begin
        # @suppress begin
            # read method test
            #
            exo_id = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
            num_dim, num_nodes, num_elem,
            num_elem_blk, num_node_sets, num_side_sets =
            Exodus.read_initialization_parameters(exo_id)

            # tests on the simple numbers
            #
            @test num_dim == 2
            @test num_nodes == number_of_nodes[n]
            @test num_elem == number_of_elements[n]
            @test num_elem_blk == 1
            @test num_node_sets == 4
            @test num_side_sets == 4


            # test coordinates
            #
            x_coords, y_coords, z_coords =
            Exodus.read_coordinates(exo_id, num_dim, num_nodes)

            @test size(x_coords, 1) == number_of_nodes[n]
            @test size(y_coords, 1) == number_of_nodes[n]
            @test size(z_coords, 1) == number_of_nodes[n]

            # test block initialization
            #
            block = Exodus.read_element_block_parameters(exo_id, 1)
            println(block)
            # block = Mesh.initialize_block(exo, 1)
            # @test block.block_number == 1
            # @test block.Nₑ == number_of_elements[n]
            # @test block.Nₙ_per_e == 4
            # @test block.element_type == "QUAD4"

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
