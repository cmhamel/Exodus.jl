@exodus_unit_test_set "EPU - 2D" begin
  if !Sys.iswindows()
    cp("./mesh/square_meshes/mesh_test.g", "./mesh/square_meshes/temp_mesh.g", force=true)
    @decomp "./mesh/square_meshes/temp_mesh.g" 16
    @epu "./mesh/square_meshes/temp_mesh.g.16.00"
    @exodiff "./mesh/square_meshes/mesh_test.g" "./temp_mesh.g"
    for n in 0:15
      rm("./mesh/square_meshes/temp_mesh.g.16." * lpad(n, 2, "0"), force=true)
    end
    # rm("./mesh/square_meshes/temp_mesh.g.nem", force=true)
    # rm("./mesh/square_meshes/temp_mesh.g.pex", force=true)
    # rm("./mesh/square_meshes/decomp.log", force=true)

    # fix this part of the test
    # rm("./mesh/square_meshes/epu.log", force=true)
    # rm("./mesh/square_meshes/temp_mesh.g", force=true)
    # rm("./temp_mesh.g", force=true)
  end
end

# @exodus_unit_test_set "EPU - 3D" begin
#   if !Sys.iswindows()
#     cp("./mesh/cube_meshes/mesh_test.g", "./mesh/cube_meshes/temp_mesh.g", force=true)
#     @decomp "./mesh/cube_meshes/temp_mesh.g" 16
#     @epu "./mesh/cube_meshes/temp_mesh.g.16.00"
#     @exodiff "./mesh/cube_meshes/mesh_test.g" "./temp_mesh.g"
#     for n in 0:15
#       rm("./mesh/cube_meshes/temp_mesh.g.16." * lpad(n, 2, "0"), force=true)
#     end
#   end
# end
