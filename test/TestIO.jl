# @exodus_unit_test_set "Test Create Exodus Database" begin
#     exo = Exodus.create_exodus_database("./test_output.e")
#     Exodus.close_exodus_database(exo)

#     Base.Filesystem.rm("./test_output.e")
# end

@exodus_unit_test_set "Test Copy Exodus Database" begin
    # error_code = Exodus.ex_opts(Exodus.EX_VERBOSE | Exodus.A)

    exo_old = Exodus.open_exodus_database("../example_output/output.e")
    exo_new = Exodus.copy_exodus_database(exo_old, "./test_output.e")

    init_old = Exodus.Initialization(exo_old)
    init_new = Exodus.Initialization(exo_new)

    @test init_old == init_new

    Exodus.close_exodus_database(exo_old)
    Exodus.close_exodus_database(exo_new)

    Base.Filesystem.rm("./test_output.e")
end