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

function test_read_node_set_ids_on_square_meshes(n::Int64)
    exo = Exodus.ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Exodus.Initialization(exo)
    nset_ids = Exodus.read_node_set_ids(exo, init)
    @test length(nset_ids) == 4
    @test nset_ids == [1, 2, 3, 4]
    Exodus.close(exo)
end

function test_read_node_set_nodes_on_square_meshes(n::Int64)
    exo = Exodus.ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Exodus.Initialization(exo)
    nset_ids = Exodus.read_node_set_ids(exo, init)
    for (id, nset_id) in enumerate(nset_ids)
        nset = Exodus.NodeSet(exo, nset_id)
        @test nset.node_set_id == id
        @test nset.num_nodes == number_of_node_set_nodes[n]
        @test length(nset.nodes) == number_of_node_set_nodes[n]
    end
    Exodus.close(exo)
end

@exodus_unit_test_set "Square Mesh Test Read Node Set IDs" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_node_set_ids_on_square_meshes(n)
    end
end

@exodus_unit_test_set "Square Mesh Test Read Node Set Nodes" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_node_set_nodes_on_square_meshes(n)
    end
end