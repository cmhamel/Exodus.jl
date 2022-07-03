struct NodeMap <: FEMContainer
    internal_nodes::Vector{IntKind}
    border_nodes::Vector{IntKind}
    external_nodes::Vector{IntKind}
    processor::IntKind
    function NodeMap(exo_id::ExoID, processor::IntKind)
        lb_init = LoadBalanceInitialization(exo_id, processor)

        internal_nodes = Vector{IntKind}(undef, lb_init.num_internal_nodes)
        border_nodes = Vector{IntKind}(undef, lb_init.num_border_nodes)
        external_nodes = Vector{IntKind}(undef, lb_init.num_external_nodes)

        error = ccall((:ex_get_processor_node_maps, libexodus), ExodusError,
                      (ExoID, Ref{IntKind}, Ref{IntKind}, Ref{IntKind}, IntKind),
                      exo_id, internal_nodes, border_nodes, external_nodes, processor)
        exodus_error_check(error, "NodeMap")
        return new(internal_nodes, border_nodes, external_nodes, processor)
    end
end
Base.show(io::IO, node_map::NodeMap) = 
print(io, "NodeMap:\n",
          "\tNumber of internal nodes = ", length(node_map.internal_nodes), "\n",
          "\tNumber of border nodes   = ", length(node_map.border_nodes), "\n",
          "\tNumber of external nodes = ", length(node_map.external_nodes), "\n",
          "\tProcessor                = ", node_map.processor)