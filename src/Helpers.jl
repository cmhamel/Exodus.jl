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

