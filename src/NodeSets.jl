struct NodeSet{I <: ExoInt, B <: ExoInt}
    node_set_id::I
    num_nodes::Clonglong
    nodes::Vector{B}
    function NodeSet(exo::ExodusDatabase{M, I, B, F}, node_set_id::I) where {M <: ExoInt, I <: ExoInt,
                                                                             B <: ExoInt, F <: ExoFloat}
        num_nodes, _ = read_node_set_parameters(exo, node_set_id)
        node_set_nodes = read_node_set_nodes(exo, node_set_id)
        return new{I, B}(node_set_id, num_nodes, node_set_nodes)
    end
end

Base.show(io::IO, node_set::NodeSet{I, B}) where {I <: ExoInt, B <: ExoInt} =
print(io, "NodeSet:\n",
          "\tNode set ID     = ", node_set.node_set_id, "\n",
          "\tNumber of nodes = ", node_set.num_nodes, "\n")

function read_node_set_ids(exo::ExodusDatabase{M, I, B, F},
                           init::Initialization) where {M <: ExoInt, I <: ExoInt,
                                                        B <: ExoInt, F <: ExoFloat}
    node_set_ids = Array{I}(undef, init.num_node_sets)
    ex_get_ids!(exo.exo, EX_NODE_SET, node_set_ids)
    return node_set_ids
end

function read_node_set_parameters(exo::ExodusDatabase{M, I, B, F}, 
                                  node_set_id::I) where {M <: ExoInt, I <: ExoInt,
                                                         B <: ExoInt, F <: ExoFloat}
    num_nodes = Ref{I}(0)
    num_df = Ref{I}(0)
    ex_get_set_param!(exo.exo, EX_NODE_SET, node_set_id, num_nodes, num_df)
    return num_nodes[], num_df[]
end

function read_node_set_nodes(exo::ExodusDatabase{M, I, B, F}, 
                             node_set_id::I) where {M <: ExoInt, I <: ExoInt,
                                                    B <: ExoInt, F <: ExoFloat}
    num_nodes, _ = read_node_set_parameters(exo, node_set_id)
    node_set_nodes = Array{B}(undef, num_nodes)
    ex_get_node_set!(exo.exo, node_set_id, node_set_nodes)
    return node_set_nodes
end

function read_node_sets!(node_sets::Vector{NodeSet},
                         exo::ExodusDatabase{M, I, B, F}, 
                         node_set_ids::Vector{I}) where {M <: ExoInt, I <: ExoInt,
                                                         B <: ExoInt, F <: ExoFloat}
    for (n, node_set_id) in enumerate(node_set_ids)
        node_sets[n] = NodeSet(exo, node_set_id)
    end
end

function read_node_sets(exo::ExodusDatabase{M, I, B, F}, 
                        node_set_ids::Array{I}) where {M <: ExoInt, I <: ExoInt,
                                                       B <: ExoInt, F <: ExoFloat}
    node_sets = NodeSets(undef, size(node_set_ids, 1))
    read_node_sets!(node_sets, exo, node_set_ids)
    return node_sets
end
