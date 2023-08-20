using Aqua
using Base
using Exodus
using Exodus_jll
# using JET
using Test
using TestSetExtensions

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

  Exodus_jll.exodiff_exe() do exe
    run(`$exe ./copy_test.e ./mesh/square_meshes/mesh_test.g`, wait=true)
  end
end

# decomp tests
if Sys.iswindows()
  println("Skipping decomp tests on Windows...")
else
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
  @exodus_unit_test_set "EPU test" begin
  #  epu("./mesh/square_meshes/epu_mesh_test.g")
    # @epu "./mesh/square_meshes/epu_mesh_test.g.4.0"
    epu("./mesh/square_meshes/epu_mesh_test.g.4.0")
    # @exodiff "epu_mesh_test.g" "./mesh/square_meshes/mesh_test.g"
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
  @exodus_unit_test_set "exodiff" begin
    # @exodiff "./example_output/output.gold" "./example_output/output.gold"
    exodiff("./example_output/output.gold", "./example_output/output.gold")
    rm("./exodiff.log", force=true)
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

  close(exo)
end

# set max name length
@exodus_unit_test_set "Set Exodus Max Name Length" begin
  exo = ExodusDatabase("test_set_max_name_length.e", "w")
  Exodus.set_max_name_length(exo.exo, Cint(20))
  close(exo)
  rm("test_set_max_name_length.e", force=true)
end

# test windows errors
if Sys.iswindows()
  @exodus_unit_test_set "Windows errors for parallel support" begin
    @test_throws Exodus.ExodusWindowsError decomp("./mesh/square_meshes/mesh_test.g", 4)
    @test_throws Exodus.ExodusWindowsError epu("./mesh/square_meshes/epu_mesh_test.g.4.0")
    @test_throws Exodus.ExodusWindowsError exodiff("./mesh/square_meshes/mesh_test.g", "./mesh/square_meshes/mesh_test.g")
  end
end

@includetests ARGS

# Aqua testing
Aqua.test_all(Exodus)

# JET testing
# test_package("Exodus"; 
#              target_defined_modules=true)
#             #  ignored_modules=(Parameters,),
#             #  analyze_from_definitions=true)

# above not working falling back to manual opt and call testing
# test_opt(read_coordinates; target_defined_modules=true, ignored_modules=(Base,))
# test_opt(read_coordinate_names)
# test_opt(re)
