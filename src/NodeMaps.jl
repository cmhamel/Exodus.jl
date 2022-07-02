struct NodeMap <: FEMContainer
    internal_nodes::Vector{Int64}
    border_nodes::Vector{Int64}
    external_nodes::Vector{Int64}
    processor::Int64
    function NodeMap(exo_id::ExoID, processor::Int64)
        lb_init = LoadBalanceInitialization(exo_id, processor)

        # internal_nodes = 
    end
end