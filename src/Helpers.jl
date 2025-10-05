"""
$(TYPEDSIGNATURES)
"""
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
$(TYPEDSIGNATURES)
collects all blocks by default
"""
function collect_element_connectivities(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
	blocks = read_sets(exo, Block)
	conns = Vector{Vector{B}}(undef, map(x -> size(x.conn, 2), blocks) |> sum)
	collect_element_connectivities!(conns, blocks)
	return conns
end

# this method figures out which proc should own which node
# base on a minimum rank ordering.
# if ranks 1, 2, 3, 4 share nodes, rank 1 owns them
# if ranks 2, 3, 4 share nodes, rank 2 owns them
function collect_global_element_and_node_numberings(file_name::String, n_procs)
	n_procs = n_procs |> Int32

	exo = ExodusDatabase(file_name, "r")
	n_elems_global = num_elements(initialization(exo))
	n_nodes_global = num_nodes(initialization(exo))
	close(exo)

	global_elems = Vector{Int32}(undef, n_elems_global)
	global_nodes = Vector{Vector{Int32}}(undef, n_nodes_global)
	for n in 1:n_nodes_global
		global_nodes[n] = Vector{Int32}(undef, 0)
	end

	for n in 1:n_procs
		exo = ExodusDatabase(file_name * ".$(n_procs).$(lpad(n - 1, exodus_pad(n_procs), '0'))", "r")
		elem_map = read_id_map(exo, ElementMap)
		for elem in elem_map
			global_elems[elem] = n
		end

		node_map = read_id_map(exo, NodeMap)
		for node in node_map
			push!(global_nodes[node], n)
		end
		close(exo)
	end

	new_global_nodes = map(minimum, global_nodes)

	return global_elems, new_global_nodes
end

"""
$(TYPEDSIGNATURES)
"""
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
$(TYPEDSIGNATURES)
collect all blocks by default
"""
function collect_node_to_element_connectivities(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
	conns = collect_element_connectivities(exo)
	node_to_elem = Vector{Vector{B}}(undef, num_nodes(exo.init))
	collect_node_to_element_connectivities!(node_to_elem, conns)
	return node_to_elem
end

"""
$(TYPEDSIGNATURES)
"""
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
$(TYPEDSIGNATURES)
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

function read_element_cmaps(rank, exo)
	lb_params = Exodus.LoadBalanceParameters(exo, rank - 1)
	cmap_params = Exodus.CommunicationMapParameters(exo, lb_params, rank - 1)
	cmap_ids, cmap_elem_cts = cmap_params.elem_cmap_ids, cmap_params.elem_cmap_elem_cnts
	elem_cmaps = map((x, y) -> Exodus.ElementCommunicationMap(exo, x, y, Int32(rank - 1)), cmap_ids, cmap_elem_cts)
	return elem_cmaps
end

# function read_ghost_elements_and_procs(rank, exo)
# 	# need this to get the right ids
# 	id_map = read_id_map(exo, ElementMap)

# 	elem_cmaps = read_element_cmaps(rank, exo)

# 	ghost_elem_ids = mapreduce(x -> x.elem_ids, vcat, elem_cmaps)
# 	ghost_proc_ids = mapreduce(x -> x.proc_ids, vcat, elem_cmaps)

# 	# make sure the ghosts are in global
# 	ghost_elem_ids = id_map[ghost_elem_ids]

# 	# now sort and get unique ghost node ids only
# 	unique_ids = unique(i -> ghost_elem_ids[i], 1:length(ghost_elem_ids))
	
# 	ghost_elem_ids = ghost_elem_ids[unique_ids]
# 	ghost_proc_ids = ghost_proc_ids[unique_ids]

# 	# maybe this operation isn't necessary?
# 	sort_ids = sortperm(ghost_elem_ids)

# 	ghost_elem_ids = ghost_elem_ids[sort_ids]
# 	ghost_proc_ids = ghost_proc_ids[sort_ids]

# 	ghost_elem_ids = convert.(Int64, ghost_elem_ids)

# 	return ghost_elem_ids, ghost_proc_ids
# end

# for ghost nodes downstream
"""
$(TYPEDSIGNATURES)
"""
function read_node_cmaps(rank, exo)
  lb_params = Exodus.LoadBalanceParameters(exo, rank - 1)
  cmap_params = Exodus.CommunicationMapParameters(exo, lb_params, rank - 1)
  cmap_ids, cmap_node_cts = cmap_params.node_cmap_ids, cmap_params.node_cmap_node_cnts
  node_cmaps = map((x, y) -> Exodus.NodeCommunicationMap(exo, x, y, rank - 1), cmap_ids, cmap_node_cts)
  return node_cmaps
end

"""
$(TYPEDSIGNATURES)
"""
function read_ghost_nodes_and_procs(rank, exo)
	# need this to get the right ids
	id_map = read_id_map(exo, NodeMap)

	node_cmaps = read_node_cmaps(rank, exo)

	ghost_node_ids = mapreduce(x -> x.node_ids, vcat, node_cmaps)
	ghost_proc_ids = mapreduce(x -> x.proc_ids, vcat, node_cmaps)

	# make sure the ghosts are in global
	ghost_node_ids = id_map[ghost_node_ids]
	ghost_node_ids = convert.(Int64, ghost_node_ids)

	return ghost_node_ids, ghost_proc_ids
end

"""
$(TYPEDSIGNATURES)
"""
function read_internal_nodes_and_procs(rank, exo)
	# need this to get the right ids
	id_map = read_id_map(exo, NodeMap)
	node_map = Exodus.ProcessorNodeMaps(exo, rank - 1)

	# get inernal nodes
	internal_node_ids = id_map[node_map.node_map_internal]
	internal_node_ids = convert.(Int64, internal_node_ids)

	return internal_node_ids, fill(rank, length(internal_node_ids))
end

# # TODO convert to use MPI maybe?
# function collect_global_element_to_color(file_name::String, n_procs::Int)
# 	n_procs = n_procs |> Int32
# 	global_to_color_dict = Dict{Int64, Int32}()

# 	for n in 1:n_procs
# 		exo = ExodusDatabase(file_name * ".$(n_procs).$(lpad(n - 1, exodus_pad(n_procs), '0'))", "r")
# 		id_map = read_id_map(exo, ElementMap)
# 		for id in id_map
# 			global_to_color_dict[id] = n
# 		end
# 		close(exo)
# 	end

# 	global_to_color = zeros(Int64, length(global_to_color_dict))
# 	for (key, val) in global_to_color_dict
# 		global_to_color[key] = val
# 	end
# 	return global_to_color
# end

# """
# For collecting global_to_color
# $(TYPEDSIGNATURES)
# """
# function collect_global_node_to_color(file_name::String, n_procs::Int, n_dofs::Int=1)
# 	n_procs = n_procs |> Int32
# 	global_to_color_dict = Dict{Int64, Int32}()

# 	exo = ExodusDatabase(file_name, "r")
# 	n_nodes_global = num_nodes(initialization(exo))
# 	close(exo)

# 	n_dofs_global = n_nodes_global * n_dofs
# 	dofs = reshape(1:n_dofs_global, (n_dofs, n_nodes_global))

# 	for n in 1:n_procs
#     	exo = ExodusDatabase(file_name * ".$(n_procs).$(lpad(n - 1, exodus_pad(n_procs), '0'))", "r")
# 		internal_node_ids, _ = read_internal_nodes_and_procs(n, exo)
# 		ghost_node_ids, ghost_proc_ids = read_ghost_nodes_and_procs(n, exo)

# 		# modify if we have more than one dof
# 		# if n_dofs > 1
# 		# 	internal_node_ids = convert.(Int32, dofs[:, internal_node_ids] |> vec)
# 		# 	ghost_node_ids = convert.(Int32, dofs[:, ghost_node_ids] |> vec)
# 		# 	new_ghost_proc_ids = ghost_proc_ids
# 		# 	for n in 2:n_dofs
# 		# 		new_ghost_proc_ids = hcat(new_ghost_proc_ids, ghost_proc_ids)
# 		# 	end
# 		# 	ghost_proc_ids = new_ghost_proc_ids' |> vec
# 		# end
# 		if n_dofs > 1
# 			@assert false "fix me"
# 		end
# 		display(internal_node_ids)
# 		for node in internal_node_ids
# 			global_to_color_dict[node] = n
# 		end

# 		for (node, proc) in zip(ghost_node_ids, ghost_proc_ids)
# 			global_to_color_dict[node] = proc
# 		end
#     	close(exo)
#   	end

# 	global_to_color = zeros(Int64, length(global_to_color_dict))
# 	for (key, val) in global_to_color_dict
# 		global_to_color[key] = val
# 	end
# 	return global_to_color
# end


