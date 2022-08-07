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
    exo_new = Exodus.copy_exodus_database(exo_old, "./test_output.e")

    Exodus.write_time(exo_new, 1, 0.0)
    Exodus.write_time(exo_new, 2, 1.0)

    times = Exodus.read_times(exo_new)
    @test times == [0.0, 1.0]

    Exodus.close_exodus_database(exo_old)
    Exodus.close_exodus_database(exo_new)
end