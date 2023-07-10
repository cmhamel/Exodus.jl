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
