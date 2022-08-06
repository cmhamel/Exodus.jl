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

function test_initialize_read_on_square_mesh(n::Int64)
    exo_id = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
    init = Exodus.Initialization(exo_id)
    @test init.num_dim == 2
    @test init.num_nodes == number_of_nodes[n]
    @test init.num_elems == number_of_elements[n]
    @test init.num_elem_blks == 1
    @test init.num_node_sets == 4
    @test init.num_side_sets == 4
    Exodus.close_exodus_database(exo_id)
end

function test_initialize_put_on_square_mesh(n::Int64)
    exo_old = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
    exo_new = Exodus.create_exodus_database(abspath("./test_output.e"))
    Exodus.copy_exodus_database(exo_old, exo_new)

    init_old = Exodus.Initialization(exo_old)
    Exodus.put(exo_new, init_old)
    init_new = Exodus.Initialization(exo_new)
    
    @test init_old.num_dim == init_new.num_dim
    @test init_old.num_nodes == init_old.num_nodes
    @test init_old.num_elems == init_new.num_elems
    @test init_old.num_elem_blks == init_new.num_elem_blks
    @test init_old.num_node_sets == init_new.num_node_sets
    @test init_old.num_side_sets == init_new.num_side_sets

    Exodus.close_exodus_database(exo_old)
    Exodus.close_exodus_database(exo_new)
end

@exodus_unit_test_set "Square Mesh Init Read" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_initialize_read_on_square_mesh(n)
    end
end

@exodus_unit_test_set "Square Mesh Init Put" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_initialize_put_on_square_mesh(n)
    end
end