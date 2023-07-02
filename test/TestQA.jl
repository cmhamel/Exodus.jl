@exodus_unit_test_set "Test read QA" begin
  exo = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  qa = read_qa(exo)
  close(exo)

  @test qa[1, 1] == "CUBIT"
  @test qa[1, 2] == "2021.5"     # may change
  @test qa[1, 3] == "06/29/2023" # may change
  @test qa[1, 4] == "19:34:08"   # may change
end