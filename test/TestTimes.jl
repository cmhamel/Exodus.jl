@exodus_unit_test_set "Test Get Number of Time Steps" begin
    exo = Exodus.open_exodus_database("../example_output/output.e")
    n_steps = Exodus.read_number_of_time_steps(exo)
    @test n_steps == 2
    Exodus.close_exodus_database(exo)
end

@exodus_unit_test_set "Test Read Times" begin
    exo = Exodus.open_exodus_database("../example_output/output.e")
    times = Exodus.read_times(exo)
    @test times == [0.0, 1.0]
    Exodus.close_exodus_database(exo)
end

@exodus_unit_test_set "Test Write Times" begin
    exo_old = Exodus.open_exodus_database("../example_output/output.e")
    exo_new = Exodus.create_exodus_database("./test_output.e")

    # TODO add put call

    Exodus.close_exodus_database(exo_old)
    Exodus.close_exodus_database(exo_new)
end