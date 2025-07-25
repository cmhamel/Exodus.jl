using Aqua
using Base
using Exodus
using Exodus_jll
using Meshes
using MPI
using PartitionedArrays
using Test
using TestSetExtensions
using Unitful

# macro for testing
macro exodus_unit_test_set(test_name::String, ex)
  return quote
    local test_set_name = rpad($test_name, 64)
    @testset ExtendedTestSet "$test_set_name" begin
      local val = $ex
      val
    end
  end
end

# copy 
@exodus_unit_test_set "copy" begin
  exo = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo, "./copy_test.e")
  close(exo)

  exodiff("./copy_test.e", "./mesh/square_meshes/mesh_test.g")
  rm("./copy_test.e")

  copy_mesh("./mesh/square_meshes/mesh_test.g", "./copy_test.e")
  exodiff("./copy_test.e", "./mesh/square_meshes/mesh_test.g")

  rm("./copy_test.e")
end

# decomp tests
if Sys.iswindows()
  println("Skipping decomp tests on Windows...")
else
  @exodus_unit_test_set "decomp - aux" begin
    @test_throws Exodus.NemSliceException Exodus.nem_slice("bad_file", 16)
    @test_throws Exodus.NemSpreadException Exodus.nem_spread("bad_file", 16)
    @test_throws AssertionError decomp("bad_file", 16)
  end
  @exodus_unit_test_set "decomp - 2d" begin
    decomp("./mesh/square_meshes/mesh_test.g", 16)

    # check if successful
    for n in 0:15
      @test isfile("./mesh/square_meshes/mesh_test.g.16." * lpad(n, 2, "0"))
    end
    @test isfile("./mesh/square_meshes/mesh_test.g.nem")
    @test isfile("./mesh/square_meshes/mesh_test.g.pex")
    @test isfile("./mesh/square_meshes/decomp.log")

    for n in 0:15
      rm("./mesh/square_meshes/mesh_test.g.16." * lpad(n, 2, "0"), force=true)
    end
    rm("./mesh/square_meshes/mesh_test.g.nem", force=true)
    rm("./mesh/square_meshes/mesh_test.g.pex", force=true)
    rm("./mesh/square_meshes/decomp.log", force=true)
  end

  @exodus_unit_test_set "decomp - 3d" begin
    decomp("./mesh/cube_meshes/mesh_test.g", 16)
  
    # check if successful
    for n in 0:15
      @test isfile("./mesh/cube_meshes/mesh_test.g.16." * lpad(n, 2, "0"))
    end
    @test isfile("./mesh/cube_meshes/mesh_test.g.nem")
    @test isfile("./mesh/cube_meshes/mesh_test.g.pex")
    @test isfile("./mesh/cube_meshes/decomp.log")


    for n in 0:15
      rm("./mesh/cube_meshes/mesh_test.g.16." * lpad(n, 2, "0"), force=true)
    end
    rm("./mesh/cube_meshes/mesh_test.g.nem", force=true)
    rm("./mesh/cube_meshes/mesh_test.g.pex", force=true)
    rm("./mesh/cube_meshes/decomp.log", force=true)
  end

  @exodus_unit_test_set "decomp methods" begin
    decomp("./mesh/square_meshes/mesh_test.g", 16)
    for n in 0:15
      rm("./mesh/square_meshes/mesh_test.g.16." * lpad(n, 2, "0"), force=true)
    end
    rm("./mesh/square_meshes/mesh_test.g.nem", force=true)
    rm("./mesh/square_meshes/mesh_test.g.pex", force=true)
    rm("./mesh/square_meshes/decomp.log", force=true)
  end
end
# epu test
if Sys.iswindows()
  println("Skipping epu tests on Windows...")
else
  @exodus_unit_test_set "epu help" begin
    epu()
  end

  @exodus_unit_test_set "epu error" begin
    @test_throws Exodus.EPUException epu("bad_file.e.8.0")
  end

  @exodus_unit_test_set "EPU test" begin
    epu("./mesh/square_meshes/epu_mesh_test.g.4.0")
    exodiff("epu_mesh_test.g", "./mesh/square_meshes/mesh_test.g")
    rm("epu_mesh_test.g", force=true)
  end
end 

# simple test of error handling capability
@exodus_unit_test_set "Test Errors working" begin
  @test_throws Exodus.ExodusError Exodus.exodus_error_check(-1, "JohnSmithMethod")
  e = Exodus.ExodusError(-1, "JohnSmithMethod")
  @show e
  e = Exodus.ExodusWindowsError()
  @show e
end

# exodiff tests
if Sys.iswindows()
  println("skipping exodiff tests for Windows...")
else
  @exodus_unit_test_set "exodiff help" begin
    exodiff()
    exodiff("./example_output/output.gold", "./example_output/output.gold", ["-Help"]) == true
  end

  @exodus_unit_test_set "exodiff" begin
    exodiff("./example_output/output.gold", "./example_output/output.gold") == true
    rm("./exodiff.log", force=true)
  end

  @exodus_unit_test_set "exodiff with command file" begin
    exodiff("./example_output/output.gold", "./example_output/output.gold";
            command_file="./example_output/command_file.cmd") == true
    rm("./exodiff.log", force=true)
  end

  @exodus_unit_test_set "exodiff failure" begin
    exodiff("./example_output/output.gold", "./example_output/global_vars_test.gold")
    rm("./exodiff.log", force=true)
  end

  @exodus_unit_test_set "exodiff file not found" begin
    @test_throws Exodus.ExodiffException exodiff("./example_output/output.gold", "bad_file.gold")
    rm("./exodiff.log", force=true)
    rm("./exodiff_stderr.log", force=true)
  end
end

@exodus_unit_test_set "decomp -> epu -> exodiff" begin
  if Sys.iswindows()
    println("skipping exodiff tests for Windows...")
  else
    cp("mesh/cube_meshes/mesh_test.g", "temp_mesh.g")
    decomp("temp_mesh.g", 8)

    rm("temp_mesh.g", force=true)
    epu("temp_mesh.g")
    foreach(rm, filter(x -> contains(x, "temp_mesh.g."), readdir()))
    exodiff("temp_mesh.g", "mesh/cube_meshes/mesh_test.g")
    rm("decomp.log", force=true)
    rm("epu.log", force=true)
    rm("exodiff.log", force=true)
    rm("temp_mesh.g", force=true)
  end
end

@exodus_unit_test_set "Exception testing" begin
  exo = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")

  types = [Block, NodeSet, SideSet]
  for type in types
    e = Exodus.SetIDException(exo, type, 1001)
    @show e
    e = Exodus.SetNameException(exo, type, "fake_set_name")
    @show e
  end

  types = [ElementVariable, GlobalVariable, NodalVariable, NodeSetVariable, SideSetVariable]
  for type in types
    e = Exodus.VariableIDException(exo, type, 1001)
    @show e
    e = Exodus.VariableNameException(exo, type, "fake_variable_name")
    @show e
  end

  e = Exodus.ModeException("w")
  @show e
  close(exo)

  init = Initialization{Int32}(
    Int32(2), Int32(4), Int32(1), 
    Int32(1), Int32(0), Int32(0)
  )
  exo = ExodusDatabase{Int32, Int32, Int32, Float64}("./test_exceptions.e", "w", init)
  write_number_of_variables(exo, NodalVariable, 3)
  write_names(exo, NodalVariable, ["u", "v", "w"])
  e = Exodus.VariableIDException(exo, NodalVariable, 4)
  @show e
  e = Exodus.VariableNameException(exo, NodalVariable, "x")
  @show e
  close(exo)
  rm("./test_exceptions.e", force=true)
end

@exodus_unit_test_set "Clobber mode" begin
  init = Initialization(Int32)
  exo = ExodusDatabase{Int32, Int32, Int32, Float32}("test_temp.e", "w", init)
  close(exo)

  exo = ExodusDatabase("test_temp.e", "w")
  close(exo)
  rm("test_temp.e", force=true)
end

@exodus_unit_test_set "Modes" begin
  init = Initialization(Int32)
  exo = ExodusDatabase{Int32, Int32, Int32, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)
  @test M == Int32
  @test I == Int32
  @test B == Int32
  @test F == Float32
  close(exo)
  rm("test_temp.e", force=true)

  init = Initialization(Int32)
  exo = ExodusDatabase{Int32, Int64, Int32, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)
  @test M == Int32
  @test I == Int64
  @test B == Int32
  @test F == Float32
  close(exo)
  rm("test_temp.e", force=true)

  init = Initialization(Int64)
  exo = ExodusDatabase{Int32, Int32, Int64, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)  
  @test M == Int32
  @test I == Int32
  @test B == Int64
  @test F == Float32
  close(exo)
  rm("test_temp.e", force=true)

  init = Initialization(Int64)
  exo = ExodusDatabase{Int32, Int64, Int64, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)  
  @test M == Int32
  @test I == Int64
  @test B == Int64
  @test F == Float32
  close(exo)
  rm("test_temp.e", force=true)

  #

  init = Initialization(Int32)
  exo = ExodusDatabase{Int64, Int32, Int32, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)  
  @test M == Int64
  @test I == Int32
  @test B == Int32
  @test F == Float32
  close(exo)
  rm("test_temp.e", force=true)

  init = Initialization(Int32)
  exo = ExodusDatabase{Int64, Int64, Int32, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)  
  close(exo)
  rm("test_temp.e", force=true)

  init = Initialization(Int64)
  exo = ExodusDatabase{Int64, Int32, Int64, Float32}("test_temp.e", "w", init)
  M = Exodus.map_int_mode(exo.exo)
  I = Exodus.id_int_mode(exo.exo)
  B = Exodus.bulk_int_mode(exo.exo)
  F = Exodus.float_mode(exo.exo)  
  @test M == Int64
  @test I == Int32
  @test B == Int64
  @test F == Float32
  close(exo)
  rm("test_temp.e", force=true)

  @test_throws Exodus.ModeException ExodusDatabase("test_temp.e", "non")

  init = Initialization(Int32)
  @test_throws Exodus.ModeException ExodusDatabase{Int32, Int32, Int32, Float32}("test_temp.e", "r", init)
end

# set max name length
@exodus_unit_test_set "Set Exodus Max Name Length" begin
  exo = ExodusDatabase("test_set_exodus_max_name_length.e", "w")
  Exodus.set_exodus_max_name_length(exo.exo, Cint(20))
  close(exo)
  rm("test_set_exodus_max_name_length.e", force=true)
end

@exodus_unit_test_set "Mesh with no block, nset or sset names" begin
  exo = ExodusDatabase("mesh/mesh_with_no_names/mesh_test.g", "r")
  @show exo
  close(exo)
end

# test windows errors
if Sys.iswindows()
  @exodus_unit_test_set "Windows errors for parallel support" begin
    @test_throws AssertionError decomp("./mesh/square_meshes/mesh_test.g", 4)
    @test_throws AssertionError epu("./mesh/square_meshes/epu_mesh_test.g.4.0")
  end
end

@includetests ARGS

# Aqua testing
@testset ExtendedTestSet "Aqua.jl" begin
  Aqua.test_all(Exodus)
end

# JET testing
# @testset ExtendedTestSet "JET.jl" begin
#   JET.test_package("Exodus"; target_defined_modules=true)
# end
