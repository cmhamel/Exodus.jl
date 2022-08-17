@exodus_unit_test_set "Test ExodusDatabase Read Mode" begin
    exo = Exodus.ExodusDatabase("../example_output/output.e", "r")
    @test typeof(exo) == Exodus.ExodusDatabase{Cint, Cint, Cint, Cdouble}
    Exodus.close(exo)
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Defaults" begin
    exo = Exodus.ExodusDatabase("test_output.e", "w")
    @test typeof(exo) == Exodus.ExodusDatabase{Cint, Cint, Cint, Cdouble}
    Exodus.close(exo)
    Base.Filesystem.rm("./test_output.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Cint/Cfloat" begin
    exo = Exodus.ExodusDatabase("test_output.e", "w", "32-bit", "32-bit")
    @test typeof(exo) == Exodus.ExodusDatabase{Cint, Cint, Cint, Cfloat}
    Exodus.close(exo)
    Base.Filesystem.rm("./test_output.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Clonglong/Cfloat" begin
    exo = Exodus.ExodusDatabase("test_output.e", "w", "64-bit", "32-bit")
    @test typeof(exo) == Exodus.ExodusDatabase{Clonglong, Clonglong, Clonglong, Cfloat}
    Exodus.close(exo)
    Base.Filesystem.rm("./test_output.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Clonglong/Cdouble" begin
    exo = Exodus.ExodusDatabase("test_output.e", "w", "64-bit", "64-bit")
    @test typeof(exo) == Exodus.ExodusDatabase{Clonglong, Clonglong, Clonglong, Cdouble}
    Exodus.close(exo)
    Base.Filesystem.rm("./test_output.e")
end

@exodus_unit_test_set "Test ExodusDatabase Copy Mode" begin
    exo_old = Exodus.ExodusDatabase("../example_output/output.e", "r")
    Exodus.copy(exo_old, "./test_output.e")
    exo_new = Exodus.ExodusDatabase("./test_output.e", "r")
    init_old = Exodus.Initialization(exo_old)
    init_new = Exodus.Initialization(exo_new)
    coords_old = Exodus.read_coordinates(exo_old, init_old)
    coords_new = Exodus.read_coordinates(exo_new, init_new)
    coords_names_old = Exodus.read_coordinate_names(exo_old, init_old)
    coords_names_new = Exodus.read_coordinate_names(exo_new, init_new)
    
    @test init_old         == init_new
    @test coords_old       == coords_new
    @test coords_names_old == coords_names_new

    # TODO add more tests once you finish updating the rest
    Exodus.close(exo_old)
    Exodus.close(exo_new)
end
