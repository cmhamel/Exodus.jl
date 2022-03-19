struct NodeSet <: FEMContainer
    nodeset_id::Int64
    num_nodes::Int64
    nodes::Array{Int64}
end
