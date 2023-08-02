# @exodus_unit_test_set "EPU - 2D" begin
#   if !Sys.iswindows()
#     # cp("./mesh/square_meshes/mesh_test.g", "./mesh/square_meshes/temp_mesh.g", force=true)
#     @decomp "./mesh/square_meshes/temp_mesh.g" 16
#     @epu "./mesh/square_meshes/temp_mesh.g.16.00"
#     @exodiff "./mesh/square_meshes/mesh_test.g" "./temp_mesh.g"
#     # for n in 0:15
#     #   rm("./mesh/square_meshes/temp_mesh.g.16." * lpad(n, 2, "0"), force=true)
#     # end
#     # rm("./mesh/square_meshes/temp_mesh.g.nem", force=true)
#     # rm("./mesh/square_meshes/temp_mesh.g.pex", force=true)
#     # rm("./mesh/square_meshes/decomp.log", force=true)

#     # fix this part of the test
#     # rm("./mesh/square_meshes/epu.log", force=true)
#     # rm("./mesh/square_meshes/temp_mesh.g", force=true)
#     # rm("./temp_mesh.g", force=true)
#   end
# end

@exodus_unit_test_set "EPU test" begin
  if !Sys.iswindows()
    # cp("./mesh/square_meshes/mesh_test.g", "./temp.g", force=true)
    # cp("./mesh/square_meshes/mesh_test.g", "./temp.g")
    # run(`cp ./mesh/square_meshes/mesh_test.g ./temp.g`)
    # @decomp "./temp.g" 4
    decomp("./temp_epu.g", 4)
    @epu "temp.g_epu.4.0"
    @exodiff "temp_epu.g", "./mesh/square_meshes/mesh_test.g"

    for n in 0:15
      rm("temp_epu.4." * lpad(n, 1, "0"), force=true)
    end
    rm("temp_epu.g.nem", force=true)
    rm("temp_epu.g.pex", force=true)
    rm("decomp.log", force=true)
  end
end 