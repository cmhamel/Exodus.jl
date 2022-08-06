@exodus_unit_test_set "Test Create Exodus Database" begin
    exo = Exodus.create_exodus_database("./test_output.e")
    Exodus.close_exodus_database(exo)

    Base.Filesystem.rm("./test_output.e")
end

# @exodus_unit_test_set "Test Copy Exodus Database" begin
#     exo_old = Exodus.open_exodus_database("../example_output/output.e")
#     exo_new = Exodus.create_exodus_database("./test_output.e")

#     Exodus.copy_exodus_database(exo_old, exo_new)

#     init_old = Exodus.Initialization(exo_old)
#     init_new = Exodus.Initialization(exo_new)

#     @show init_old
#     @show init_new

#     Exodus.close_exodus_database(exo_old)
#     Exodus.close_exodus_database(exo_new)

#     Base.Filesystem.rm("./test_output.e")
# end