module ExodusPartitionedArraysExt

using Exodus
using PartitionedArrays

# Some helpers for IO
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
# Bug in this currently
# function PartitionedArrays.OwnAndGhostIndices(ranks, exos, inits, global_to_color)
#   indices = map(ranks, exos, inits) do rank, exo, init
#     n_nodes_global = init[2] |> Int64
#     internal_node_ids, internal_proc_ids = Exodus.read_internal_nodes_and_procs(rank, exo)
# 		ghost_node_ids, ghost_proc_ids = Exodus.read_ghost_nodes_and_procs(rank, exo)

#     own_indices = OwnIndices(n_nodes_global, rank, internal_node_ids)
#     ghost_indices = GhostIndices(n_nodes_global, ghost_node_ids, ghost_proc_ids)

#     return OwnAndGhostIndices(own_indices, ghost_indices, global_to_color)
#   end
#   return indices
# end

# dumb for now since each proc has to read each mesh part
function PartitionedArrays.partition_from_color(ranks, file_name::String, global_to_color)
  parts = partition_from_color(ranks, global_to_color)
  exos, inits = ExodusDatabase(ranks, file_name)

  # below doesn't work
  # parts = OwnAndGhostIndices(ranks, exos, inits, global_to_color)

  # now update ghost nodes
  node_procs = map(ranks, exos) do rank, exo
    ghost_nodes, ghost_procs = Exodus.read_ghost_nodes_and_procs(rank, exo)
  end
  ghost_nodes, ghost_procs = tuple_of_arrays(node_procs)

  parts = map(parts, ghost_nodes, ghost_procs) do part, gids, owners
    replace_ghost(part, gids, owners)
  end
  return parts
end

end # module