module ExodusPartitionedArraysExt

using Exodus
using PartitionedArrays

# New sketch

# 1. Read in node cmaps
# 2. Get node to elem connectivity
# 3. Also get elem and id maps
# 4. Loop over node to elem conn and 
#    get all unique ids


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
    n_elems_global = Exodus.num_elements(init_global)

    return num_proc, n_nodes_global, n_elems_global
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

function PartitionedArrays.partition_from_color(
  ranks, exos,
  global_elem_to_color, 
  global_node_to_color
)
  tuple_of_arrays(map(exos, ranks) do exo, rank
    node_map = read_id_map(exo, NodeMap)
    node_procs = global_node_to_color[node_map]

    own_nodes = findall(x -> x == rank, node_procs)
    ghost_nodes = findall(x -> x != rank, node_procs)

    new_own_nodes = convert.(Int64, node_map[own_nodes])
    own = OwnIndices(length(global_node_to_color), rank, new_own_nodes)

    new_ghost_nodes = convert.(Int64, node_map[ghost_nodes])
    ghost_procs = global_node_to_color[new_ghost_nodes]
    ghost = GhostIndices(length(global_node_to_color), new_ghost_nodes, ghost_procs)
    
    dof_own_and_ghost = OwnAndGhostIndices(own, ghost, global_node_to_color)

    elem_map = convert.(Int64, read_id_map(exo, ElementMap))
    own = OwnIndices(length(global_elem_to_color), rank, elem_map)
    ghost = GhostIndices(length(global_elem_to_color), Int64[], Int64[])
    elem_own_and_ghost = OwnAndGhostIndices(own, ghost, global_elem_to_color)

    dof_own_and_ghost, elem_own_and_ghost
  end)
end

# PArrays overrides
# Bug in this currently
# function PartitionedArrays.OwnAndGhostIndices(ranks, exos, inits, global_to_color)
#   indices = map(ranks, exos, inits) do rank, exo, init
#     n_nodes_global = init[2] |> Int64
#     internal_node_ids, internal_proc_ids = Exodus.read_internal_nodes_and_procs(rank, exo)
# 		ghost_node_ids, ghost_proc_ids = Exodus.read_ghost_nodes_and_procs(rank, exo)

#     ghost_node_ids = unique(ghost_node_ids)
#     # ghost_proc_ids = 

#     own_indices = OwnIndices(n_nodes_global, rank, internal_node_ids)
#     ghost_indices = GhostIndices(n_nodes_global, ghost_node_ids, ghost_proc_ids)

#     return OwnAndGhostIndices(own_indices, ghost_indices, global_to_color)
#   end
#   return indices
# end

# function PartitionedArrays.OwnAndGhostIndices(exos, global_to_color)
#   n_nodes_global = length(global_to_color)
#   map(1:length(exos), exos) do rank, exo
#     internal_node_ids, _ = Exodus.read_internal_nodes_and_procs(rank, exo)
#     ghost_node_ids, ghost_proc_ids = Exodus.read_ghost_nodes_and_procs(rank, exo)
#     own_indices = OwnIndices(n_nodes_global, rank, internal_node_ids)
#     ghost_indices = GhostIndices(n_nodes_global, ghost_node_ids, ghost_proc_ids)
#     return OwnAndGhostIndices(own_indices, ghost_indices, global_to_color)
#   end
# end

# # dumb for now since each proc has to read each mesh part
# function PartitionedArrays.partition_from_color(ranks, file_name::String, global_to_color)
#   parts = partition_from_color(ranks, global_to_color)
#   exos, inits = ExodusDatabase(ranks, file_name)
#   # return OwnAndGhostIndices(ranks, exos, inits, global_to_color)
#   # below doesn't work
#   # parts = OwnAndGhostIndices(ranks, exos, inits, global_to_color)

#   # now update ghost nodes
#   node_procs = map(ranks, exos) do rank, exo
#     ghost_nodes, ghost_procs = Exodus.read_ghost_nodes_and_procs(rank, exo)
#   end
#   ghost_nodes, ghost_procs = tuple_of_arrays(node_procs)

#   parts = map(parts, ghost_nodes, ghost_procs) do part, gids, owners
#     replace_ghost(part, gids, owners)
#   end
#   return parts

#   # # now update ghost elems
#   # out = map(exos, ranks) do exo, rank
#   #   ghost_elems, ghost_procs = Exodus.read_ghost_elements_and_procs(rank, exo)
#   # end
#   # ghost_elems, ghost_procs = tuple_of_arrays(out)

#   # parts = map(ghost_elems, ghost_procs, parts) do ge, gp, part
#   #   replace_ghost(part, ge, gp)
#   # end
#   # return parts
# end

# function PartitionedArrays.partition_from_color(ranks, file_name::String)
#   n_procs = length(ranks) |> Int32
#   global_nodes = Exodus.collect_global_node_numberings(file_name, n_procs)

#   # open exo files
#   exos = map(ranks) do rank
#     ExodusDatabase(file_name * ".$(n_procs).$(lpad(rank - 1, Exodus.exodus_pad(n_procs), '0'))", "r")
#   end

#   # create element partition
#   # TODO use actual element numbering in partition
#   num_elems = map(exos) do exo
#     Exodus.initialization(exo).num_elements
#   end

#   element_parts = variable_partition(num_elems, sum(num_elems))

#   # create node partition
#   # TODO modify to have dofs as well
#   num_nodes = map(ranks) do rank
#     filter(x -> x == rank, global_nodes) |> length
#   end

#   dof_parts = variable_partition(num_nodes, sum(num_nodes))
#   return element_parts, dof_parts
# end

end # module
