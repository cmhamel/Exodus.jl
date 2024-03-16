# Make these tests also include own and ghost node indices tests
# also test comm maps, etc.
if Sys.iswindows()
  println("Skipping ExodusPartitionedArraysExt test on Windows")
else
  @exodus_unit_test_set "ExodusPartitionedArraysExt" begin
    decomp("mesh/cube_meshes/mesh_test.g", 8)
    ranks = LinearIndices((8,))
    exos, inits = ExodusDatabase(ranks, "mesh/cube_meshes/mesh_test.g")
    close(exos)
  end

  @exodus_unit_test_set "ExodusPartitionedArraysExt" begin
    mesh_file = "mesh/cube_meshes/mesh_test.g"
    decomp(mesh_file, 8)
    global_to_color = Exodus.collect_global_to_color(mesh_file, 8)
    ranks = LinearIndices((8,))
    parts = partition_from_color(ranks, mesh_file, global_to_color)
    temp = pones(parts)
    consistent!(temp)
    assemble!(temp)
  end

  @exodus_unit_test_set "ExodusPartitionedArraysExt" begin
    mesh_file = "mesh/cube_meshes/mesh_test.g"
    decomp(mesh_file, 8)
    global_to_color = Exodus.collect_global_to_color(mesh_file, 8, 2)
    ranks = LinearIndices((8,))
    parts = partition_from_color(ranks, mesh_file, global_to_color)
    temp = pones(parts)
    consistent!(temp)
    assemble!(temp)
  end

  @exodus_unit_test_set "ExodusPartitionedArraysExt - with mpi" begin
    decomp("mesh/cube_meshes/mesh_test.g", 8)
    mpiexec(cmd -> run(`$cmd -n 8 julia --project=@. mpi/TestMPI.jl`))
  end
end
