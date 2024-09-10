@exodus_unit_test_set "ExodusMeshesExt" begin
  exo = ExodusDatabase("mesh/mixed_element/mixed_element_mesh.g", "r")
  mesh = SimpleMesh(exo)
  close(exo)
end
