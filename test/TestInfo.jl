@exodus_unit_test_set "Test write/read Info" begin
  exo = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  init = exo.init
  close(exo)

  info = ["info entry 1", "info entry 2", "info entry 3"]
  exo = ExodusDatabase("./info_temp.e", init)
  write_info(exo, info)
  close(exo)

  exo = ExodusDatabase("./info_temp.e", "r")
  new_info = read_info(exo)
  close(exo)
  for n in eachindex(info)
    @test info[n] == new_info[n]
  end
end