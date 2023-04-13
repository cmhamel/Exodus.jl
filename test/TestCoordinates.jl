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

function test_read_coordinates_on_square_mesh(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    coords = Exodus.read_coordinates(exo, init)
    @test size(coords) == (init.num_nodes, init.num_dim)
    close(exo)
end

function test_read_coordinate_names_on_square_mesh(n::Int64)
    exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    init = Initialization(exo)
    coord_names = Exodus.read_coordinate_names(exo, init)
    @test coord_names == ["x", "y"]
    close(exo)
end

function test_put_coordinates_on_square_mesh(n::Int64)
    exo_old = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    exo_new = ExodusDatabase("./test_output.e", "w") # using defaults

    init_old = Initialization(exo_old)
    Exodus.put_initialization(exo_new, init_old)
    init_new = Initialization(exo_new)

    coords_old = Exodus.read_coordinates(exo_old, init_old)
    Exodus.put_coordinates(exo_new, coords_old)
    coords_new = Exodus.read_coordinates(exo_new, init_new)
    @test coords_old == coords_new

    close(exo_old)
    close(exo_new)

    Base.Filesystem.rm("./test_output.e")
end

function test_put_coordinate_names_on_square_mesh(n::Int64)
    exo_old = ExodusDatabase(abspath(mesh_file_names[n]), "r")
    exo_new = ExodusDatabase("./test_output.e", "w") # using defaults
    init_old = Initialization(exo_old) # Don't forget this
    Exodus.put_initialization(exo_new, init_old)             # Don't forget this
    init_new = Initialization(exo_new)
    coord_names_old = Exodus.read_coordinate_names(exo_old, init_old)
    Exodus.put_coordinate_names(exo_new, coord_names_old)
    coord_names_new = Exodus.read_coordinate_names(exo_new, init_new)
    @test coord_names_new == coord_names_old
    @test coord_names_new[1] == "x"
    @test coord_names_new[2] == "y"
    # cleanup, maybe wrap this in a macro?
    Exodus.close(exo_old)
    Exodus.close(exo_new)
    Base.Filesystem.rm("./test_output.e")
end

@exodus_unit_test_set "Square Mesh Read Coordinates" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_coordinates_on_square_mesh(n)
    end
end

@exodus_unit_test_set "Square Mesh Read Coordinate Names" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_read_coordinate_names_on_square_mesh(n)
    end
end

@exodus_unit_test_set "Square Mesh Put Coordinates" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_put_coordinates_on_square_mesh(n)
    end
end

@exodus_unit_test_set "Square Mesh Put Coordinate Names" begin
    for (n, mesh) in enumerate(mesh_file_names)
        test_put_coordinate_names_on_square_mesh(n)
    end
end