@exodus_unit_test_set "Helpers" begin
    @exodus_unit_test_set "Global numberings" begin
        mesh_file = "mesh/square_meshes/mesh_test.g"
        n_procs = 4
        decomp(mesh_file, n_procs)
        exo = ExodusDatabase(mesh_file, "r")
        elem_nums, node_nums = Exodus.collect_global_element_and_node_numberings(
            mesh_file, n_procs
        )

        n_elems = Exodus.initialization(exo).num_elements
        n_nodes = Exodus.initialization(exo).num_nodes
        close(exo)

        # make sure it's the right length
        @test length(elem_nums) == n_elems
        @test length(node_nums) == n_nodes
        # ensure each proc has a sensible number
        for n in axes(elem_nums, 1)
            @test elem_nums[n] >= 1
            @test elem_nums[n] <= n_procs
        end

        for n in axes(node_nums, 1)
            @test node_nums[n] >= 1
            @test node_nums[n] <= n_procs
        end

        # check to see if the elem maps check out
        for n in 1:n_procs
            shard_file = mesh_file * ".$n_procs.$(n - 1)"
            elem_map = ExodusDatabase(shard_file, "r") do exo
                read_id_map(exo, ElementMap)
            end

            for e in elem_map
                @test elem_nums[e] == n
            end
        end

        # cleanup
        for n in 1:n_procs
            shard_file = mesh_file * ".$n_procs.$(n - 1)"
            rm(shard_file; force = true)
        end
    end
end
