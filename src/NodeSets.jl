struct NodeSet <: FEMContainer
    node_set_id::NodeSetID
    num_nodes::IntKind
    nodes::Vector{IntKind}
    function NodeSet(exo_id::int, node_set_id::NodeSetID)
        num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
        node_set_nodes = read_node_set_nodes(exo_id, node_set_id)
        return new(node_set_id, num_nodes, node_set_nodes)
    end
end

Base.show(io::IO, node_set::NodeSet) =
print(io, "NodeSet:\n",
          "\tNode set ID     = ", node_set.node_set_id, "\n",
          "\tNumber of nodes = ", node_set.num_nodes, "\n")

# more verbose types
#
NodeSets = Vector{NodeSet}
NodeSetIDs = Vector{NodeSetID}

function read_node_set_ids(exo_id::int, num_node_sets::IntKind)
    node_set_ids = Array{NodeSetID}(undef, num_node_sets)
    ex_get_ids!(exo_id, EX_NODE_SET, node_set_ids)
    return node_set_ids
end

function read_node_set_parameters(exo_id::int, node_set_id::NodeSetID)
    num_nodes = Ref{IntKind}(0)
    num_df = Ref{IntKind}(0)
    ex_get_set_param!(exo_id, EX_NODE_SET, node_set_id, num_nodes, num_df)
    return num_nodes[], num_df[]
end

# TODO change the return types maybe?
function read_node_set_nodes(exo_id::int, node_set_id::NodeSetID)
    num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
    node_set_nodes = Array{IntKind}(undef, num_nodes)
    ex_get_node_set!(exo_id, node_set_id, node_set_nodes)
    return node_set_nodes
end

function read_node_sets!(exo_id::int, node_set_ids::NodeSetIDs, node_sets::NodeSets)
    for (n, node_set_id) in enumerate(node_set_ids)
        node_sets[n] = NodeSet(exo_id, node_set_id)
    end
end

function read_node_sets(exo_id::int, node_set_ids::Array{NodeSetID})
    node_sets = NodeSets(undef, size(node_set_ids, 1))
    read_node_sets!(exo_id, node_set_ids, node_sets)
    return node_sets
end
