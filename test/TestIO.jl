@exodus_unit_test_set "Test ExodusDatabase Read Mode" begin
    exo = ExodusDatabase("./example_output/output.gold", "r")
    @test typeof(exo) == ExodusDatabase{Cint, Cint, Cint, Cdouble}
    close(exo)
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Defaults" begin
    exo = ExodusDatabase("test_output.gold", "w")
    @test typeof(exo) == ExodusDatabase{Cint, Cint, Cint, Cdouble}
    close(exo)
    Base.Filesystem.rm("./test_output.gold")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Cint/Cfloat" begin
    exo = ExodusDatabase("test_output.gold", "w"; int_mode="32-bit", float_mode="32-bit")
    @test typeof(exo) == ExodusDatabase{Cint, Cint, Cint, Cfloat}
    close(exo)
    Base.Filesystem.rm("./test_output.gold")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Clonglong/Cfloat" begin
    exo = ExodusDatabase("test_output.gold", "w"; int_mode="64-bit", float_mode="32-bit")
    @test typeof(exo) == ExodusDatabase{Clonglong, Clonglong, Clonglong, Cfloat}
    close(exo)
    Base.Filesystem.rm("./test_output.gold")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Clonglong/Cdouble" begin
    exo = ExodusDatabase("test_output.gold", "w"; int_mode="64-bit", float_mode="64-bit")
    @test typeof(exo) == ExodusDatabase{Clonglong, Clonglong, Clonglong, Cdouble}
    close(exo)
    Base.Filesystem.rm("./test_output.gold")
end

@exodus_unit_test_set "Test ExodusDatabase Copy Mode" begin
    exo_old = ExodusDatabase("./example_output/output.gold", "r")
    copy(exo_old, "./test_output.gold")
    exo_new = ExodusDatabase("./test_output.gold", "r")
    init_old = Initialization(exo_old)
    init_new = Initialization(exo_new)
    coords_old = read_coordinates(exo_old, init_old)
    coords_new = read_coordinates(exo_new, init_new)
    coords_names_old = read_coordinate_names(exo_old, init_old)
    coords_names_new = read_coordinate_names(exo_new, init_new)
    
    @test init_old         == init_new
    @test coords_old       == coords_new
    @test coords_names_old == coords_names_new

    # TODO add more tests once you finish updating the rest
    close(exo_old)
    close(exo_new)
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Bad int_mode" begin
    @test_throws ErrorException ExodusDatabase("./test_output.gold", "w"; int_mode="xx-bit", float_mode="64-bit")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Bad float_mode" begin
    @test_throws ErrorException ExodusDatabase("./test_output.gold", "w"; int_mode="64-bit", float_mode="xx-bit")
end

@exodus_unit_test_set "Test ExodusDatabase Bad Mode - Error" begin
    @test_throws ErrorException ExodusDatabase("./test_output.gold", "a")
end
