if Sys.iswindows()
  println("Skipping ParallelExodusDatabase tests on Windows...")
else
  @exodus_unit_test_set "ParallelExodusDatabase" begin
    decomp("mesh/square_meshes/mesh_test.g", 4)
    exo = Exodus.ParallelExodusDatabase("mesh/square_meshes/mesh_test.g", 4)
    @show exo
    for lb_params in exo.lb_params
      @show lb_params
    end
    for cmap_params in exo.cmap_params
      @show cmap_params
    end
    coords = read_coordinates(exo)

    block_ids = read_ids(exo, Block)
    for n in 1:4
      @test block_ids[n] == [1]
    end

    nset_ids = read_ids(exo, NodeSet)
    for n in 1:4
      @test nset_ids[n] == [1, 2, 3, 4]
    end

    sset_ids = read_ids(exo, SideSet)
    for n in 1:4
      @test sset_ids[n] == [1, 2, 3, 4]
    end

    blocks = read_sets(exo, Block)
    nsets  = read_sets(exo, NodeSet)
    ssets  = read_sets(exo, SideSet)

    for (n, cmap_params) in enumerate(exo.cmap_params)
      elem_cmap_ids = cmap_params.elem_cmap_ids
      for elem_cmap_id in elem_cmap_ids
        elem_map = ElementCommunicationMap(exo, elem_cmap_id, Cint(n))
      end

      node_cmap_ids = cmap_params.node_cmap_ids
      for node_cmap_id in node_cmap_ids
        node_map = NodeCommunicationMap(exo, node_cmap_id, Cint(n))  
      end
    end

    close(exo)

    for n in 1:4
      rm("mesh/square_meshes/mesh_test.g.4.$(n - 1)"; force=true)
    end
    rm("mesh/square_meshes/mesh_test.g.nem"; force=true)
    rm("mesh/square_meshes/mesh_test.g.pex"; force=true)
    rm("mesh/square_meshes/decomp.log"; force=true)
  end
end