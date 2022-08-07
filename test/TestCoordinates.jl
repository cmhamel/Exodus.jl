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

function test_read_coordinates_on_square_mesh(n::Int64)
    exo = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
    init = Exodus.Initialization(exo)
    coords = Exodus.read_coordinates(exo, init.num_dim, init.num_nodes)
    @test size(coords) == (init.num_nodes, init.num_dim)
    Exodus.close_exodus_database(exo)
end

function test_read_coordinate_names_on_square_mesh(n::Int64)
    exo = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
    coord_names = Exodus.read_coordinate_names(exo, Int32(2))
    @test coord_names == ["x", "y"]
    Exodus.close_exodus_database(exo)
end

# function test_put_coordinates_on_square_mesh(n::Int64)
#     error_code = Exodus.ex_opts(Exodus.EX_VERBOSE)
#     @show error_code

#     exo_old = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
#     exo_new = Exodus.create_exodus_database("./test_output.e")

#     init_old = Exodus.Initialization(exo_old)
#     Exodus.put(exo_new, init_old)
#     init_new = Exodus.Initialization(exo_new)

#     coords_old = Exodus.read_coordinates(exo_old, init_old.num_dim, init_old.num_nodes)
#     Exodus.put_coordinates(exo_new, coords_old)
#     coords_new = Exodus.read_coordinates(exo_new, init_new.num_dim, init_old.num_nodes)
#     @show coords_old
#     @show coords_new


#     Exodus.close_exodus_database(exo_old)
#     Exodus.close_exodus_database(exo_new)

#     Base.Filesystem.rm("./test_output.e")
# end

# function test_put_coordinate_names_on_square_mesh(n::Int64)
#     exo_old = Exodus.open_exodus_database(abspath(mesh_file_names[n]))
#     exo_new = Exodus.create_exodus_database("./test_output.e")

#     coord_names_old = Exodus.read_coordinate_names(exo_old, 2)
#     @show coord_names_old
#     Exodus.put_coordinate_names(exo_new, coord_names_old)
#     coord_names_new = Exodus.read_coordinate_names(exo_new, 2)
#     @show coord_names_new

#     Exodus.close_exodus_database(exo_old)
#     Exodus.close_exodus_database(exo_new)

#     Base.Filesystem.rm("./test_output.e")
# end

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

# @exodus_unit_test_set "Square Mesh Put Coordinates" begin
#     for (n, mesh) in enumerate(mesh_file_names)
#         test_put_coordinates_on_square_mesh(n)
#     end
# end

# @exodus_unit_test_set "Square Mesh Put Coordinate Names" begin
#     for (n, mesh) in enumerate(mesh_file_names)
#         # test_put_coordinate_names_on_square_mesh(n)
#     end
# end