using Aqua
using Exodus
using Exodus_jll
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
@exodus_unit_test_set "decomp - 2d" begin
  @decomp "./mesh/square_meshes/mesh_test.g" 16
  for n in 0:15
    rm("./mesh/square_meshes/mesh_test.g.16." * lpad(n, 2, "0"), force=true)
  end
  rm("./mesh/square_meshes/mesh_test.g.nem", force=true)
  rm("./mesh/square_meshes/mesh_test.g.pex", force=true)
  rm("./mesh/square_meshes/decomp.log", force=true)
end

@exodus_unit_test_set "decomp - 3d" begin
  @decomp "./mesh/cube_meshes/mesh_test.g" 16
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

# epu test
#@exodus_unit_test_set "EPU test" begin
#  if !Sys.iswindows()
#    @epu "./mesh/square_meshes/epu_mesh_test.g"
#    @exodiff "epu_mesh_test.g" "./mesh/square_meshes/mesh_test.g"
#  end
#end 

# simple test of error handling capability
@exodus_unit_test_set "Test Errors working" begin
  @test_throws ErrorException Exodus.exodus_error_check(-1, "JohnSmithMethod")
end

# exodiff tests
@exodus_unit_test_set "exodiff" begin
  if Sys.iswindows()
    @show "skipping exodiff tests for windows"
  else
    @exodiff "./example_output/output.gold" "./example_output/output.gold"
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

  types = [Element, Global, Nodal, NodeSetVariable, SideSetVariable]
  for type in types
    e = Exodus.VariableIDException(exo, type, 1001)
    @show e
    e = Exodus.VariableNameException(exo, type, "fake_variable_name")
    @show e
  end

  close(exo)
end

@includetests ARGS

# aqua testing
Aqua.test_all(Exodus)
