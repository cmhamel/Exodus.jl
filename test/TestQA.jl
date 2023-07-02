@exodus_unit_test_set "Test read QA" begin
  exo = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  qa = read_qa(exo)
  close(exo)

  @test qa[1, 1] == "CUBIT"
  @test qa[1, 2] == "2021.5"     # may change
  @test qa[1, 3] == "06/29/2023" # may change
  @test qa[1, 4] == "19:34:08"   # may change
end

@exodus_unit_test_set "Test read/write/read QA" begin
  exo = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  init = exo.init
  qa_old = read_qa(exo)
  close(exo)

  exo = ExodusDatabase("./qa_temp.e", init)
  write_qa(exo, qa_old)
  close(exo)
 
  exo = ExodusDatabase("./qa_temp.e", "r")
  qa_new = read_qa(exo)
  close(exo)
  for n in eachindex(qa_old)
    @test qa_old[n] == qa_new[n]
  end

  rm("./qa_temp.e")
end