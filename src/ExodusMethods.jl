

# TODO check these aren't outdated with older interface also add types to julia call
function ex_get_cmap_params!(exoid::Cint, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    error_code = ccall((:ex_get_cmap_params, libexodus), Cint,
                       (Cint, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Cint),
                       exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    exodus_error_check(error_code, "ex_get_cmap_params!")
end

function ex_get_elem_cmap!(exoid::Cint, map_id::ex_entity_id, elem_ids, side_ids, proc_ids, processor)
    error_code = ccall((:ex_get_elem_cmap, libexodus), Cint,
                       (Cint, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Cint),
                       exoid, map_id, elem_ids, side_ids, proc_ids, processor)
    exodus_error_check(error_code, "ex_get_elem_cmap!")
end

function ex_get_loadbal_param!(exoid::Cint,
                               num_int_nodes, num_bor_nodes, num_ext_nodes,
                               num_int_elems, num_bor_elems,
                               num_node_cmaps, num_elem_cmaps,
                               processor) # TODO get types right and sorted out
    error_code = ccall((:ex_get_loadbal_param, libexodus), Cint,
                       (Cint, 
                        Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, 
                        Ptr{void_int}, Ptr{void_int}, 
                        Ptr{void_int}, Ptr{void_int}, 
                        Cint),
                       exoid, 
                       num_int_nodes, num_bor_nodes, num_ext_nodes, 
                       num_int_elems, num_bor_elems,
                       num_node_cmaps, num_elem_cmaps, 
                       processor)
    exodus_error_check(error_code, "ex_get_loadbal_param!")
end

"""
    ex_get_map!(exoid::Cint, elem_map::Vector{T}) where {T <: ExoInt}
"""
function ex_get_map!(exoid::Cint, elem_map::Vector{T}) where {T <: ExoInt}
    error_code = ccall((:ex_get_map, libexodus), Cint,
                       (Cint, Ptr{void_int}),
                       exoid, elem_map)
    exodus_error_check(error_code, "ex_get_map!")
end

function ex_get_node_cmap!(exoid::Cint, map_id::ex_entity_id, node_ids, proc_ids, processor::Cint)
    error_code = ccall((:ex_get_node_cmap, libexodus), Cint,
                       (Cint, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Cint),
                       exoid, map_id, node_ids, proc_ids, processor)
    exodus_error_check(error_code, "ex_get_node_cmap!")
end

function ex_get_processor_node_maps!(exoid::Cint, node_mapi, node_mapb, node_mape, processor)
    error_code = ccall((:ex_get_processor_node_maps, libexodus), Cint,
                       (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint),
                       exoid, node_mapi, node_mapb, node_mape, processor)
    exodus_error_check(error_code, "ex_get_processor_node_maps")
end
