struct NodeSet{T <: Integer}
    node_set_id::T
    num_nodes::T
    nodes::Vector{T}
    function NodeSet(exo_id::Cint, node_set_id::T) where {T <: Integer}
        num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
        node_set_nodes = read_node_set_nodes(exo_id, node_set_id)
        return new{T}(node_set_id, num_nodes, node_set_nodes)
    end
end

Base.show(io::IO, node_set::NodeSet) =
print(io, "NodeSet:\n",
          "\tNode set ID     = ", node_set.node_set_id, "\n",
          "\tNumber of nodes = ", node_set.num_nodes, "\n")

function read_node_set_ids(exo_id::Cint, num_node_sets::T) where {T <: Integer}
    if ex_int64_status(exo_id) > 0
        node_set_ids = Array{Clonglong}(undef, num_node_sets)
        ex_get_ids!(exo_id, EX_NODE_SET, node_set_ids)
    else
        node_set_ids = Array{Cint}(undef, num_node_sets)
        ex_get_ids!(exo_id, EX_NODE_SET, node_set_ids)
    end
    return node_set_ids
end

function put_node_set_ids(exo_id::Cint, nset_ids::Vector{T}) where {T <: Integer}
    
end

function read_node_set_parameters(exo_id::Cint, node_set_id::T) where {T <: Integer}
    num_nodes = Ref{T}(0)
    num_df = Ref{T}(0)
    ex_get_set_param!(exo_id, EX_NODE_SET, node_set_id, num_nodes, num_df)
    return num_nodes[], num_df[]
end

# TODO change the return types maybe?
function read_node_set_nodes(exo_id::Cint, node_set_id::T) where {T <: Integer}
    num_nodes, _ = read_node_set_parameters(exo_id, node_set_id)
    node_set_nodes = Array{T}(undef, num_nodes)
    ex_get_node_set!(exo_id, node_set_id, node_set_nodes)
    return node_set_nodes
end

function read_node_sets!(exo_id::Cint, node_set_ids::Vector{T}, node_sets::Vector{NodeSet}) where {T <: Integer}
    for (n, node_set_id) in enumerate(node_set_ids)
        node_sets[n] = NodeSet(exo_id, node_set_id)
    end
end

function read_node_sets(exo_id::Cint, node_set_ids::Array{T}) where {T <: Integer}
    node_sets = NodeSets(undef, size(node_set_ids, 1))
    read_node_sets!(exo_id, node_set_ids, node_sets)
    return node_sets
end
