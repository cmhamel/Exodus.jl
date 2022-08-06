struct NodeCommunicationMap <: FEMContainer
    ids::Vector{IntKind}
    node_ids::Vector{Vector{IntKind}}
    proc_ids::Vector{Vector{IntKind}}
    function NodeCommunicationMap(exo_id::int, processor::Int64)
        cm_init = CommunicationMapInitialization(exo_id, processor)
        # node_ids = 
        ids = cm_init.node_cmap_ids
        node_ids, proc_ids = [], []
        for n in 1:length(cm_init.node_cmap_ids)
            temp_node_ids = Vector{IntKind}(undef, cm_init.node_cmap_node_cnts[n])
            temp_proc_ids = Vector{IntKind}(undef, cm_init.node_cmap_node_cnts[n])
            ex_get_node_cmap!(exo_id, cm_init.node_cmap_ids[n], temp_node_ids, temp_proc_ids, processor)
            push!(node_ids, temp_node_ids)
            push!(proc_ids, temp_proc_ids)
        end
        return new(ids, node_ids, proc_ids)
    end
end

struct ElementCommunicationMap <: FEMContainer
    ids::Vector{IntKind}
    elem_ids::Vector{Vector{IntKind}}
    side_ids::Vector{Vector{IntKind}}
    proc_ids::Vector{Vector{IntKind}}
    function ElementCommunicationMap(exo_id::int, processor::Int64)
        cm_init = CommunicationMapInitialization(exo_id, processor)
        @show cm_init
        ids = cm_init.elem_cmap_ids
        elem_ids, side_ids, proc_ids = [], [], []
        for n in 1:length(cm_init.elem_cmap_ids)
            temp_elem_ids = Vector{IntKind}(undef, cm_init.elem_cmap_cnts[n])
            temp_side_ids = Vector{IntKind}(undef, cm_init.elem_cmap_cnts[n])
            temp_proc_ids = Vector{IntKind}(undef, cm_init.elem_cmap_cnts[n])
            # @show temp_proc_ids
            ex_get_elem_cmap!(exo_id, cm_init.elem_cmap_ids[n], temp_elem_ids, temp_side_ids, temp_proc_ids, processor)
            @show temp_proc_ids
            push!(elem_ids, temp_elem_ids)
            push!(side_ids, temp_side_ids)
            push!(proc_ids, temp_proc_ids)
        end
        return new(ids, elem_ids, side_ids, proc_ids)
    end
end