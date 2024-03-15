function collect_element_connectivities!(conns::Vector{Vector{B}}, blocks::Vector{Block{I, Matrix{B}}}) where {I, B}
	n = 1
	for block in blocks
		for e in axes(block.conn, 2)
			conns[n] = block.conn[:, e]
			n = n + 1
		end
	end
end

"""
collects all blocks by default
"""
function collect_element_connectivities(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
	blocks = read_sets(exo, Block)
	conns = Vector{Vector{B}}(undef, map(x -> size(x.conn, 2), blocks) |> sum)
	collect_element_connectivities!(conns, blocks)
	return conns
end


function collect_node_to_element_connectivities!(node_to_elem::Vector{Vector{B}}, conns::Vector{Vector{B}}) where B

	for n in axes(node_to_elem, 1)
		node_to_elem[n] = B[]
	end

	elem_id = 1
	for conn in conns
		for n in conn
			push!(node_to_elem[n], elem_id)
		end
		elem_id = elem_id + 1
	end
end

"""
collect all blocks by default
"""
function collect_node_to_element_connectivities(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
	conns = collect_element_connectivities(exo)
	node_to_elem = Vector{Vector{B}}(undef, num_nodes(exo.init))
	collect_node_to_element_connectivities!(node_to_elem, conns)
	return node_to_elem
end

function collect_element_to_element_connectivities!(
	elem_to_elem::Vector{Vector{B}},
	node_to_elem::Vector{Vector{B}},
	conns::Vector{Vector{B}}
) where B

	for e in axes(elem_to_elem, 1)
		elem_to_elem[e] = B[]
	end

	for e in axes(elem_to_elem, 1)
		conn = conns[e]
		for n in conn
			append!(elem_to_elem[e], node_to_elem[n])
		end

		unique!(elem_to_elem[e])
		sort!(elem_to_elem[e])
	end
end

"""
collect all blocks by default
"""
function collect_element_to_element_connectivities(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
	conns = collect_element_connectivities(exo)
	node_to_elem = collect_node_to_element_connectivities(exo)
	elem_to_elem = Vector{Vector{B}}(undef, num_elements(exo.init))
	collect_element_to_element_connectivities!(elem_to_elem, node_to_elem, conns)
	return elem_to_elem
end


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

# for ghost nodes downstream
function read_node_cmaps(rank, exo)
  lb_params = Exodus.LoadBalanceParameters(exo, rank - 1)
  cmap_params = Exodus.CommunicationMapParameters(exo, lb_params, rank - 1)
  cmap_ids, cmap_node_cts = cmap_params.node_cmap_ids, cmap_params.node_cmap_node_cnts
  node_cmaps = map((x, y) -> Exodus.NodeCommunicationMap(exo, x, y, rank - 1), cmap_ids, cmap_node_cts)
  return node_cmaps
end

function read_ghost_nodes_and_procs(rank, exo)

	# need this to get the right ids
	id_map = read_id_map(exo, NodeMap)

	node_cmaps = read_node_cmaps(rank, exo)

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

	return ghost_node_ids, ghost_proc_ids
end

function read_internal_nodes_and_procs(rank, exo)
	# need this to get the right ids
	id_map = read_id_map(exo, NodeMap)
	node_map = Exodus.ProcessorNodeMaps(exo, rank - 1)

	# get inernal nodes
	internal_node_ids = id_map[node_map.node_map_internal]
	internal_node_ids = convert.(Int64, internal_node_ids)

	return internal_node_ids, fill(rank, length(internal_node_ids))
end

"""
For collecting global_to_color
"""
function collect_global_to_color(file_name::String, n_procs::Int)
	n_procs = n_procs |> Int32
	global_to_color_dict = Dict{Int64, Int32}()

	for n in 1:n_procs
    exo = ExodusDatabase(file_name * ".$(n_procs).$(lpad(n - 1, exodus_pad(n_procs), '0'))", "r")
		internal_node_ids, internal_proc_ids = read_internal_nodes_and_procs(n, exo)
		ghost_node_ids, ghost_proc_ids = read_ghost_nodes_and_procs(n, exo)

		for node in internal_node_ids
      global_to_color_dict[node] = n
    end

    for (node, proc) in zip(ghost_node_ids, ghost_proc_ids)
      global_to_color_dict[node] = proc
    end
    close(exo)
  end

	global_to_color = zeros(Int64, length(global_to_color_dict))
	for (key, val) in global_to_color_dict
		global_to_color[key] = val
	end
	return global_to_color
end
