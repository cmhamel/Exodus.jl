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

function test_read_initialization_on_square_mesh(n::Int64)
    exo = Exodus.ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Exodus.Initialization(exo)
    @test init.num_dim       == 2
    @test init.num_nodes     == number_of_nodes[n]
    @test init.num_elems     == number_of_elements[n]
    @test init.num_elem_blks == 1
    @test init.num_node_sets == 4
    @test init.num_side_sets == 4
    Exodus.close(exo)
end

function test_put_initialization_on_square_mesh(n::Int64)
    exo_old = Exodus.ExodusDatabase(abspath(mesh_file_names[n]), "r")
    exo = Exodus.ExodusDatabase("./test_output.e", "w") # using Defaults

    init_old = Exodus.Initialization(exo_old)
    Exodus.put_initialization(exo, init_old)
    init = Exodus.Initialization(exo)
    @test init.num_dim       == init_old.num_dim
    @test init.num_nodes     == init_old.num_nodes
    @test init.num_elems     == init_old.num_elems
    @test init.num_elem_blks == init_old.num_elem_blks
    @test init.num_node_sets == init_old.num_node_sets
    @test init.num_side_sets == init_old.num_side_sets

    Exodus.close(exo_old)
    Exodus.close(exo)
    Base.Filesystem.rm("./test_output.e")
end

@exodus_unit_test_set "Square Mesh Read Initialization" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_initialization_on_square_mesh(n)
    end
end

@exodus_unit_test_set "Square Mesh Put Initialization" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_put_initialization_on_square_mesh(n)
    end
end

@exodus_unit_test_set "Test Initialization - Print" begin
    exo = Exodus.ExodusDatabase(abspath(mesh_file_names[1]), "r")
    init = Exodus.Initialization(exo)
    @show init
    Exodus.close(exo)
end