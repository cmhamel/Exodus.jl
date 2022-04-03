mesh_file_names = ["../mesh/square_meshes/mesh_test_0.0078125.g"]

test_output_file = "../example_output/output.e"

function test_mesh(mesh_file_name::String, output_file_name::String)
    mesh_file_name = abspath(mesh_file_name)
    test_name = rpad("Testing square mesh: $(basename(mesh_file_name))", 96)
    @testset "$test_name" begin
        exo_id = Exodus.open_exodus_database(abspath(mesh_file_name))
        new_exo_id = Exodus.create_exodus_database(abspath(output_file_name))
        data_id = Exodus.open_exodus_database(abspath(test_output_file))
        data_init = Exodus.Initialization(data_id)
        data_times = Exodus.read_times(data_id)

        Exodus.copy_exodus_database(exo_id, new_exo_id)

        Exodus.write_number_of_nodal_variables(new_exo_id, 3)
        Exodus.write_nodal_variable_names(new_exo_id, [1, 2, 3], ["u", "v", "w"])

        for n = 1:size(data_times, 1)
            u_values = Exodus.read_nodal_variable_values(data_id, n, 1, data_init.num_nodes)
            Exodus.write_time(new_exo_id, n, n - 1.0)
            Exodus.write_nodal_variable_values(new_exo_id, n, 1, 1.0 .* u_values)
            Exodus.write_nodal_variable_values(new_exo_id, n, 2, 2.0 .* u_values)
            Exodus.write_nodal_variable_values(new_exo_id, n, 3, 3.0 .* u_values)
        end

        Exodus.close_exodus_database(exo_id)
        Exodus.close_exodus_database(new_exo_id)
        Exodus.close_exodus_database(data_id)
    end
end

for mesh in mesh_file_names
    output_file_name = "./test_output.e"
    test_mesh(mesh, output_file_name)
end