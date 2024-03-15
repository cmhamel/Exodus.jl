module ExodusPartitionedArraysExt

using Exodus
using PartitionedArrays



# for ghost nodes downstream
function read_node_cmaps(rank, exo)
  lb_params = Exodus.LoadBalanceParameters(exo, rank - 1)
  cmap_params = Exodus.CommunicationMapParameters(exo, lb_params, rank - 1)
  cmap_ids, cmap_node_cts = cmap_params.node_cmap_ids, cmap_params.node_cmap_node_cnts
  node_cmaps = map((x, y) -> Exodus.NodeCommunicationMap(exo, x, y, rank - 1), cmap_ids, cmap_node_cts)
  return node_cmaps
end

# Some helpers
function Exodus.ExodusDatabase(ranks, mesh_file::String)
  # first open nemesis file to get number of procs
  @info "Reading nemesis file"
  init_info = map(ranks) do _
    nemesis_file = mesh_file * ".nem"

    nem = ExodusDatabase(nemesis_file, "r")
    num_proc, _, _ = Exodus.read_init_info(nem)

    init_global = Exodus.InitializationGlobal(nem)

    n_nodes_global = Exodus.num_nodes(init_global)

    return num_proc, n_nodes_global
  end

  @info "Reading exodus files"
  exos = map(ranks, init_info) do rank, init
    num_proc = init[1]
    mesh_file_rank = mesh_file * ".$num_proc" * ".$(lpad(rank - 1, Exodus.exodus_pad(num_proc), '0'))"
    exo = ExodusDatabase(mesh_file_rank, "r")
    return exo
  end
  return exos, init_info
end

function Exodus.close(exos::V) where V <: AbstractArray{<:ExodusDatabase}
  map(exos) do exo
    close(exo)
  end
end

# PArrays overrides
function PartitionedArrays.OwnAndGhostIndices(ranks, exos, inits, global_to_color)
  indices = map(ranks, exos, inits) do rank, exo, init
    n_nodes_global = init[2] |> Int64
    internal_node_ids, internal_proc_ids = Exodus.read_internal_nodes_and_procs(rank, exo)
		ghost_node_ids, ghost_proc_ids = Exodus.read_ghost_nodes_and_procs(rank, exo)

    own_indices = OwnIndices(n_nodes_global, rank, internal_node_ids)
    ghost_indices = GhostIndices(n_nodes_global, ghost_node_ids, ghost_proc_ids)

    return OwnAndGhostIndices(own_indices, ghost_indices, global_to_color)
  end
  return indices
end

# dumb for now since each proc has to read each mesh part
function PartitionedArrays.partition_from_color(ranks, file_name::String, global_to_color)
  exos, inits = ExodusDatabase(ranks, file_name)
  return OwnAndGhostIndices(ranks, exos, inits, global_to_color)
end

end # module