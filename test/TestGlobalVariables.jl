@exodus_unit_test_set "Test Global Variables Write" begin
    @exodus_unit_test_set "Single time step" begin
        exo = ExodusDatabase("./example_output/global_vars_test.gold", "w")
        init = Initialization(2, 1, 1, 1, 0, 0)
        put_initialization(exo, init)
        write_time(exo, 1, 0.)
        write_number_of_global_variables(exo, 5)

        num_global_vars = read_number_of_global_variables(exo)
        @test num_global_vars == 5

        write_global_variable_values(exo, 1, [10. 20. 30. 40. 50.])
        glob_var_values = read_global_variables(exo, 1, 5)
        @test glob_var_values == [10., 20., 30., 40., 50.]
        close(exo)
    end

    @exodus_unit_test_set "Multi time step" begin
        exo = ExodusDatabase("./example_output/global_vars_test.gold", "w")
        init = Initialization(2, 1, 1, 1, 0, 0)
        put_initialization(exo, init)
        write_time(exo, 1, 0.)

        write_number_of_global_variables(exo, 5)

        num_global_vars = read_number_of_global_variables(exo)
        @test num_global_vars == 5

        write_global_variable_values(exo, 1, [10. 20. 30. 40. 50.])
        glob_var_values = read_global_variables(exo, 1, 5)
        @test glob_var_values == [10., 20., 30., 40., 50.]

        write_time(exo, 2, 1.)

        write_global_variable_values(exo, 2, [1. 2. 3. 4. 5.])
        glob_var_values = read_global_variables(exo, 2, 5)
        @test glob_var_values == [1., 2., 3., 4., 5.]

        close(exo)
    end
end