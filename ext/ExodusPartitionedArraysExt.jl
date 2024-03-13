module ExodusPartitionedArraysExt

using Exodus
using PartitionedArrays

function exodus_pad(n_procs::Int32)

  if n_procs < 10
    pad_size = 1
  elseif n_procs < 100
    pad_size = 2
  elseif n_procs < 1000
    pad_size = 3
  elseif n_procs < 10000
    pad_size = 4
  else
    throw(ErrorException("Holy crap that's a big mesh. We need to check if we support that!"))
  end
  return pad_size
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
    mesh_file_rank = mesh_file * ".$num_proc" * ".$(lpad(rank - 1, exodus_pad(num_proc), '0'))"
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

function PartitionedArrays.OwnAndGhostIndices(ranks, exos, init_infos)
  # just in case
  # n_nodes_global = n_nodes_global |> Int64

  indices = map(ranks, exos, init_infos) do rank, exo, init_info
    n_nodes_global = init_info[2] |> Int64

    # need this to get the right ids
    id_map = read_id_map(exo, NodeMap)
    node_map = Exodus.ProcessorNodeMaps(exo, rank - 1)

    # get inernal nodes
    internal_nodes = id_map[node_map.node_map_internal]
    internal_nodes = convert.(Int64, internal_nodes)

    # stuff for ghost nodes
    lb_params = Exodus.LoadBalanceParameters(exo, rank - 1)

    cmap_params = Exodus.CommunicationMapParameters(exo, lb_params, rank - 1)
    cmap_ids, cmap_node_cts = cmap_params.node_cmap_ids, cmap_params.node_cmap_node_cnts
    node_cmaps = map((x, y) -> Exodus.NodeCommunicationMap(exo, x, y, rank - 1), cmap_ids, cmap_node_cts)

    ghost_node_ids = mapreduce(x -> x.node_ids, vcat, node_cmaps)
    ghost_proc_ids = mapreduce(x -> x.proc_ids, vcat, node_cmaps)

    # make sure the ghosts are in global
    ghost_node_ids = id_map[ghost_node_ids]

    # now sort and get unique ghost node ids only
    unique_ids = unique(i -> ghost_node_ids[i], 1:length(ghost_node_ids))
    
    ghost_node_ids = ghost_node_ids[unique_ids]
    ghost_proc_ids = ghost_proc_ids[unique_ids]

    # maybe this operation isn't necessary?
    sort_ids = sortperm(ghost_node_ids)

    ghost_node_ids = ghost_node_ids[sort_ids]
    ghost_proc_ids = ghost_proc_ids[sort_ids]

    ghost_node_ids = convert.(Int64, ghost_node_ids)

    own_indices = OwnIndices(n_nodes_global, rank, internal_nodes)
    ghost_indices = GhostIndices(n_nodes_global, ghost_node_ids, ghost_proc_ids)

    return OwnAndGhostIndices(own_indices, ghost_indices)
  end

  return indices
end

# for multi-dof systems
function PartitionedArrays.OwnAndGhostIndices(ranks, exos, init_infos, n_dofs::Int)
  indices = map(ranks, exos, init_infos) do rank, exo, init_info
    n_nodes_global = init_info[2] |> Int64
    n_dofs_global = n_nodes_global * n_dofs

    dofs = reshape(1:n_dofs_global, n_dofs, n_nodes_global)

    # need this to get the right ids
    id_map = read_id_map(exo, NodeMap)
    node_map = Exodus.ProcessorNodeMaps(exo, rank - 1)

    # stuff for ghost nodes
    lb_params = Exodus.LoadBalanceParameters(exo, rank - 1)

    cmap_params = Exodus.CommunicationMapParameters(exo, lb_params, rank - 1)
    cmap_ids, cmap_node_cts = cmap_params.node_cmap_ids, cmap_params.node_cmap_node_cnts
    node_cmaps = map((x, y) -> Exodus.NodeCommunicationMap(exo, x, y, rank - 1), cmap_ids, cmap_node_cts)

    ghost_node_ids = mapreduce(x -> x.node_ids, vcat, node_cmaps)
    ghost_proc_ids = mapreduce(x -> x.proc_ids, vcat, node_cmaps)

    # make these things have many dofs
    id_map = dofs[:, id_map] |> vec
    node_map = Exodus.ProcessorNodeMaps{eltype(node_map.node_map_internal)}(
      convert.(Int32, dofs[:, node_map.node_map_internal]) |> vec,
      convert.(Int32, dofs[:, node_map.node_map_border]) |> vec,
      convert.(Int32, dofs[:, node_map.node_map_external]) |> vec
    )

    # get inernal nodes
    internal_nodes = id_map[node_map.node_map_internal]
    internal_nodes = convert.(Int64, internal_nodes)

    # make sure the ghosts are in global
    ghost_node_ids = dofs[:, ghost_node_ids] |> vec
    ghost_node_ids = id_map[ghost_node_ids]

    new_ghost_proc_ids = ghost_proc_ids
    for n in 2:n_dofs
      new_ghost_proc_ids = hcat(new_ghost_proc_ids, ghost_proc_ids)
    end
    
    ghost_proc_ids = new_ghost_proc_ids' |> vec

    # now sort and get unique ghost node ids only
    unique_ids = unique(i -> ghost_node_ids[i], 1:length(ghost_node_ids))
    
    ghost_node_ids = ghost_node_ids[unique_ids]
    ghost_proc_ids = ghost_proc_ids[unique_ids]

    # maybe this operation isn't necessary?
    sort_ids = sortperm(ghost_node_ids)

    ghost_node_ids = ghost_node_ids[sort_ids]
    ghost_proc_ids = ghost_proc_ids[sort_ids]

    ghost_node_ids = convert.(Int64, ghost_node_ids)

    own_indices = OwnIndices(n_dofs_global, rank, internal_nodes)
    ghost_indices = GhostIndices(n_dofs_global, ghost_node_ids, ghost_proc_ids)

    return OwnAndGhostIndices(own_indices, ghost_indices)
  end

  return indices
end

function PartitionedArrays.uniform_partition(ranks, mesh_file::String)
  exos, init_infos = Exodus.ExodusDatabase(ranks, mesh_file)
  indices = OwnAndGhostIndices(ranks, exos, init_infos)
  return indices
end

function PartitionedArrays.uniform_partition(ranks, mesh_file::String, n_dofs::Int)
  exos, init_infos = Exodus.ExodusDatabase(ranks, mesh_file)
  indices = OwnAndGhostIndices(ranks, exos, init_infos, n_dofs)
  return indices
end

# some write methods
function Exodus.write_values(exos, type::Type{NodalVariable}, timestep, set_id, values::V) where V <: PVector
  locals = local_values(values)
  map(exos, locals) do exo, value
    write_values(exo, type, timestep, set_id, value)
  end
end



end # module