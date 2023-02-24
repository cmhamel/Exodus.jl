@exodus_unit_test_set "Test Global Variables Write" begin
    @exodus_unit_test_set "Single time step" begin
        exo = ExodusDatabase("global_vars_test.e", "w")
        init = Initialization(2, 1, 1, 1, 0, 0)
        Exodus.put_initialization(exo, init)
        Exodus.write_time(exo, 1, 0.)
        Exodus.write_number_of_global_variables(exo, 5)

        num_global_vars = Exodus.read_number_of_global_variables(exo)
        @test num_global_vars == 5

        Exodus.write_global_variable_values(exo, 1, [10. 20. 30. 40. 50.])
        glob_var_values = Exodus.read_global_variables(exo, 1, 5)
        @test glob_var_values == [10., 20., 30., 40., 50.]
        close(exo)
    end

    @exodus_unit_test_set "Multi time step" begin
        exo = ExodusDatabase("global_vars_test.e", "w")
        init = Initialization(2, 1, 1, 1, 0, 0)
        Exodus.put_initialization(exo, init)
        Exodus.write_time(exo, 1, 0.)

        Exodus.write_number_of_global_variables(exo, 5)

        num_global_vars = Exodus.read_number_of_global_variables(exo)
        @test num_global_vars == 5

        Exodus.write_global_variable_values(exo, 1, [10. 20. 30. 40. 50.])
        glob_var_values = Exodus.read_global_variables(exo, 1, 5)
        @test glob_var_values == [10., 20., 30., 40., 50.]

        Exodus.write_time(exo, 2, 1.)

        Exodus.write_global_variable_values(exo, 2, [1. 2. 3. 4. 5.])
        glob_var_values = Exodus.read_global_variables(exo, 2, 5)
        @test glob_var_values == [1., 2., 3., 4., 5.]

        close(exo)
    end
end