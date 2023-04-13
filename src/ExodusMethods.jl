function ex_get_all_times!(exoid::Cint, time_values::Vector{T}) where {T <: ExoFloat}
    error_code = ccall((:ex_get_all_times, libexodus), Cint,
                       (Cint, Ptr{Cvoid}),
                       exoid, time_values)
    exodus_error_check(error_code, "ex_get_all_times!")
end

# TODO think about how to type this best
function ex_get_block!(exoid::Cint, blk_type::ex_entity_type, blk_id, #::ex_entity_id,
                       entity_descrip, 
                       num_entries_this_blk, num_nodes_per_entry,
                       num_edges_per_entry, num_faces_per_entry,
                       num_attr_per_entry) # TODO get the types right
    error_code = ccall((:ex_get_block, libexodus), Cint,
                       (Cint, ex_entity_type, ex_entity_id,
                        Ptr{UInt8}, 
                        Ptr{void_int}, Ptr{void_int}, 
                        Ptr{void_int}, Ptr{void_int}, 
                        Ptr{void_int}),
                       exoid, blk_type, blk_id,
                       entity_descrip, 
                       num_entries_this_blk, num_nodes_per_entry, 
                       num_edges_per_entry, num_faces_per_entry, 
                       num_attr_per_entry)
    exodus_error_check(error_code, "ex_get_block!")
end

# TODO check these aren't outdated with older interface also add types to julia call
function ex_get_cmap_params!(exoid::Cint, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    error_code = ccall((:ex_get_cmap_params, libexodus), Cint,
                       (Cint, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Cint),
                       exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    exodus_error_check(error_code, "ex_get_cmap_params!")
end

function ex_get_conn!(exoid::Cint, blk_type::ex_entity_type, blk_id, #::ex_entity_id, nned to figure this out
                      nodeconn, faceconn, edgeconn) # TODO get the types right
    error_code = ccall((:ex_get_conn, libexodus), Cint,
                       (Cint, ex_entity_type, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
                       exoid, blk_type, blk_id, nodeconn, faceconn, edgeconn)
    exodus_error_check(error_code, "ex_get_conn") 
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

"""
    ex_inquire_int(exoid::Cint, req_info::ex_inquiry)
"""
function ex_inquire_int(exoid::Cint, req_info::ex_inquiry)
    info = ccall((:ex_inquire_int, libexodus), Cint,
                 (Cint, ex_inquiry), 
                 exoid, req_info)
    exodus_error_check(info, "ex_inquire_int")
    return info
end

"""
    ex_int64_status(exoid::Cint)
"""
function ex_int64_status(exoid::Cint)
    status = ccall((:ex_int64_status, libexodus), UInt32, (Cint,), exoid)
    return status
end

"""
    ex_opts(options)
"""
function ex_opts(options)
    error_code = ccall((:ex_opts, libexodus), Cint, (Cint,), options)
    exodus_error_check(error_code, "ex_opts")
    return error_code
end

function ex_put_time!(exoid::Cint, time_step::Cint, time_value)
    error_code = ccall((:ex_put_time, libexodus), Cint,
                       (Cint, Cint, Ref{Float64}), # need to get types to be Ptr{Cvoid} but not working
                       exoid, time_step, time_value)
    exodus_error_check(error_code, "ex_put_time!")
end

function ex_set_max_name_length(exoid::Cint, len::Cint)
    error_code = ccall((:ex_set_max_name_length, libexodus), Cint,
                       (Cint, Cint), exoid, len)
    exodus_error_check(error_code, "ex_set_max_name_length")
end
