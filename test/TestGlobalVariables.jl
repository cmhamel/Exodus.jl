@exodus_unit_test_set "GlobalVariables.jl" begin
  @exodus_unit_test_set "Read/Write number of global variables" begin
    exo = ExodusDatabase(
      "./example_output/global_vars_temp.e", 
      Initialization(2, 1, 1, 1, 0, 0)
    )

    write_time(exo, 1, 0.)
    write_number_of_global_variables(exo, 5)

    @test read_number_of_global_variables(exo) == 5

    close(exo)
    run(`rm -f ./example_output/global_vars_temp.e`)
  end

  @exodus_unit_test_set "Read/Write global variable names by index" begin
    exo = ExodusDatabase(
      "./example_output/global_vars_temp.e", 
      Initialization(2, 1, 1, 1, 0, 0)
    )

    write_time(exo, 1, 0.)
    write_number_of_global_variables(exo, 5)

    write_global_variable_name(exo, 1, "global_var_1")
    write_global_variable_name(exo, 2, "global_var_2")
    write_global_variable_name(exo, 3, "global_var_3")
    write_global_variable_name(exo, 4, "global_var_4")
    write_global_variable_name(exo, 5, "global_var_5")

    # @show read_global_variable_names(exo)
    @test read_global_variable_name(exo, 1) == "global_var_1"
    @test read_global_variable_name(exo, 2) == "global_var_2"
    @test read_global_variable_name(exo, 3) == "global_var_3"
    @test read_global_variable_name(exo, 4) == "global_var_4"
    @test read_global_variable_name(exo, 5) == "global_var_5"

    close(exo)
    run(`rm -f ./example_output/global_vars_temp.e`)
  end

  @exodus_unit_test_set "Read/Write global variable names all" begin
    exo = ExodusDatabase(
      "./example_output/global_vars_temp.e", 
      Initialization(2, 1, 1, 1, 0, 0)
    )

    write_time(exo, 1, 0.)
    write_number_of_global_variables(exo, 5)
    
    write_global_variable_names(
      exo, 
      [1, 2, 3, 4, 5],
      ["global_var_1", "global_var_2", "global_var_3", "global_var_4", "global_var_5"]
    )
    global_vars = read_global_variable_names(exo)

    @test global_vars[1] == "global_var_1"
    @test global_vars[2] == "global_var_2"
    @test global_vars[3] == "global_var_3"
    @test global_vars[4] == "global_var_4"
    @test global_vars[5] == "global_var_5"

    close(exo)
    run(`rm -f ./example_output/global_vars_temp.e`)
  end

  @exodus_unit_test_set "Read/Write global variables" begin
    exo = ExodusDatabase(
      "./example_output/global_vars_temp.e", 
      Initialization(2, 1, 1, 1, 0, 0)
    )

    write_time(exo, 1, 0.)
    write_number_of_global_variables(exo, 2)

    write_global_variable_name(exo, 1, "v1")
    write_global_variable_name(exo, 2, "v2")

    write_global_variable_values(exo, 1, 2, [10.0, 20.0])
    global_vars = read_global_variable_values(exo, 1, 2)
    @test global_vars[1] ≈ 10.0
    @test global_vars[2] ≈ 20.0

    close(exo)
    run(`rm -f ./example_output/global_vars_temp.e`)
  end
end
