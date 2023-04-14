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
number_of_node_set_nodes = [1, 2, 4, 8, 16, 32, 64, 128] .+ 1

function test_read_node_set_ids_on_square_meshes(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    nset_ids = read_node_set_ids(exo, init)
    @test length(nset_ids) == 4
    @test nset_ids == [1, 2, 3, 4]
    close(exo)
end

function test_read_node_set_nodes_on_square_meshes(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    nset_ids = read_node_set_ids(exo, init)
    for (id, nset_id) in enumerate(nset_ids)
        nset = NodeSet(exo, nset_id)
        @test nset.node_set_id == id
        @test nset.num_nodes == number_of_node_set_nodes[n]
        @test length(nset.nodes) == number_of_node_set_nodes[n]
    end
    close(exo)
end

function test_read_node_sets_on_square_meshes(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    nset_ids = read_node_set_ids(exo, init)
    nsets = read_node_sets(exo, nset_ids)
    @test length(nsets) == 4
    for i = 1:4
        @test length(nsets[i]) == number_of_node_set_nodes[n]
    end
    close(exo)
end

@exodus_unit_test_set "Test Nodesets - Read Node Set IDs" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_node_set_ids_on_square_meshes(n)
    end
end

@exodus_unit_test_set "Test Nodesets - Read Node Set Nodes" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_node_set_nodes_on_square_meshes(n)
    end
end

@exodus_unit_test_set "Test Nodesets - Read Node Set Nodes" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_node_sets_on_square_meshes(n)
    end
end

@exodus_unit_test_set "Test Nodesets - Print" begin
    exo = ExodusDatabase(abspath(mesh_file_names[1]), "r")
    init = Initialization(exo)
    nset_ids = read_node_set_ids(exo, init)
    nsets = read_node_sets(exo, nset_ids)
    for nset in nsets
        @show nset
    end
    close(exo)
end