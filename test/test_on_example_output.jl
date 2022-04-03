output_files = ["../example_output/output.e"]

function test_on_output(output_file::String)
    output_file_name = abspath(output_file)
    test_name = rpad("Testing output file: $(basename(output_file_name))", 96)
    @testset "$test_name" begin
        exo_id = Exodus.open_exodus_database(output_file_name)
        num_vars = Exodus.read_number_of_nodal_variables(exo_id)
        @test num_vars == 1
        variable_names = Exodus.read_nodal_variable_names(exo_id)
        @test variable_names == ["u"]   
        num_time_steps = Exodus.read_number_of_time_steps(exo_id)  
        @test num_time_steps == 2
        times = Exodus.read_times(exo_id)
        @test times == [0.0, 1.0]
    end
end

for output_file in output_files
    test_on_output(output_file)
end