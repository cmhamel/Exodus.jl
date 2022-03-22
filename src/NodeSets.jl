struct NodeSet <: FEMContainer
    node_set_id::Int64
    num_nodes::Int64
    nodes::Array{Int64}
    function NodeSet(exo_id::ExoID, node_set_id::NodeSetID)
        num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
        node_set_nodes = read_node_set_nodes(exo_id, node_set_id)
        return new(node_set_id, num_nodes, node_set_nodes)
    end
end

Base.show(io::IO, node_set::NodeSet) =
print(io, "NodeSet:\n",
          "\tNode set ID     = ", node_set.node_set_id, "\n",
          "\tNumber of nodes = ", node_set.num_nodes, "\n")

function read_node_set_ids(exo_id::ExoID, num_node_sets::Int64)
    node_set_ids = Array{NodeSetID}(undef, num_node_sets)
    error = ccall((:ex_get_ids, libexodus), Int64,
                  (Int64, Int64, Ref{NodeSetID}),
                  exo_id, EX_NODE_SET, node_set_ids)
    exodus_error_check(error, "read_node_set_ids")
    return node_set_ids
end

function read_node_set_parameters(exo_id::ExoID, node_set_id::NodeSetID)
    num_nodes = Ref{Int64}(0)
    num_df = Ref{Int64}(0)
    error = ccall((:ex_get_set_param, libexodus), Int64,
                  (Int64, Int64, NodeSetID, Ref{Int64}, Ref{Int64}),
                  exo_id, EX_NODE_SET, node_set_id, num_nodes, num_df)
    exodus_error_check(error, "read_node_set_parameters")
    return num_nodes[], num_df[]
end

function read_node_set_nodes(exo_id::ExoID, node_set_id::NodeSetID)
    num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
    node_set_nodes = Array{Int32}(undef, num_nodes)
    error = ccall((:ex_get_node_set, libexodus), Int64,
                  (Int64, NodeSetID, Ref{Int32}),
                  exo_id, node_set_id, node_set_nodes)
    exodus_error_check(error, "read_node_set_nodes")
    return node_set_nodes
end

function read_node_sets(exo_id::ExoID, node_set_ids::Array{NodeSetID})
    node_sets = Array{NodeSet}(undef, size(node_set_ids, 1))
    for (n, node_set_id) in enumerate(node_set_ids)
        node_sets[n] = NodeSet(exo_id, node_set_id)
    end
    return node_sets
end
