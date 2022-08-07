struct NodeSet{T}
    node_set_id::int
    num_nodes::int
    nodes::Vector{T}
    function NodeSet(exo_id::int, node_set_id::int)
        num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
        node_set_nodes = read_node_set_nodes(exo_id, node_set_id)

        # TODO this could possibly break
        if ex_int64_status(exo_id) > 0
            return new{Int64}(node_set_id, num_nodes, node_set_nodes)
        else
            return new{Int32}(node_set_id, num_nodes, node_set_nodes)
        end
    end
end

Base.show(io::IO, node_set::NodeSet) =
print(io, "NodeSet:\n",
          "\tNode set ID     = ", node_set.node_set_id, "\n",
          "\tNumber of nodes = ", node_set.num_nodes, "\n")

function read_node_set_ids(exo_id::int, num_node_sets::int)
    node_set_ids = Array{Int64}(undef, num_node_sets)
    ex_get_ids!(exo_id, EX_NODE_SET, node_set_ids)
    return node_set_ids
end

function read_node_set_parameters(exo_id::int, node_set_id::int)
    num_nodes = Ref{int}(0)
    num_df = Ref{int}(0)
    ex_get_set_param!(exo_id, EX_NODE_SET, node_set_id, num_nodes, num_df)
    return num_nodes[], num_df[]
end

# TODO change the return types maybe?
function read_node_set_nodes(exo_id::int, node_set_id::int)
    num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
    node_set_nodes = Array{int}(undef, num_nodes)
    ex_get_node_set!(exo_id, node_set_id, node_set_nodes)
    return node_set_nodes
end

function read_node_sets!(exo_id::int, node_set_ids::int, node_sets::Vector{NodeSet})
    for (n, node_set_id) in enumerate(node_set_ids)
        node_sets[n] = NodeSet(exo_id, node_set_id)
    end
end

function read_node_sets(exo_id::int, node_set_ids::Array{int})
    node_sets = NodeSets(undef, size(node_set_ids, 1))
    read_node_sets!(exo_id, node_set_ids, node_sets)
    return node_sets
end
