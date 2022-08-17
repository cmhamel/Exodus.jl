# please put these in alphabetical order
# also they should mimic the exodus C interface
# such that no temp variables are created

# goal is to be all in place methods
# error_code checking should be done in this wrapper maybe?

# TODO maybe make a macro to handle ccall into error_code check

function ex_close!(exoid::Cint)
    error_code = ccall((:ex_close, libexodus), Cint, (Cint,), exoid)
    exodus_error_check(error_code, "ex_close!")
end

function ex_copy!(in_exoid::Cint, out_exoid::Cint)
    error_code = ccall((:ex_copy, libexodus), Cint, (Cint, Cint), in_exoid, out_exoid)
    exodus_error_check(error_code, "ex_copy!")
end

# still need to figure out how to deal with #defines from C
# function ex_create(path, cmode, comp_ws, io_ws)::Cint
#     exo_id = ccall((:ex_create, libexodus), Cint,
#                    (Cstring, Cint, Ref{Cint}, Ref{Cint}),
#                    path, cmode, comp_ws, io_ws)
#     exodus_error_check(exo_id, "create_exodus_database")
#     return exo_id
# end

# TODO figure out right type for cmode in the ex_create_int julia call
function ex_create_int(path, cmode, comp_ws::Cint, io_ws::Cint, run_version::Cint)::Cint
    exo_id = ccall((:ex_create_int, libexodus), Cint,
                   (Cstring, Cint, Ref{Cint}, Ref{Cint}, Cint),
                    path, cmode, comp_ws, io_ws, run_version)
    exodus_error_check(exo_id, "create_exodus_database")
    return exo_id
end

function ex_get_all_times!(exoid::Cint, time_values::Vector{T}) where {T <: Real}
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

function ex_get_coord!(exoid::Cint, # input not to be changed
                       x_coords, y_coords, z_coords) # TODO need to get types to Julia call right
    error_code = ccall((:ex_get_coord, libexodus), Cint,
                       (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                       exoid, x_coords, y_coords, z_coords)
    exodus_error_check(error_code, "ex_get_coord!")
end

function ex_get_coord_names!(exo_id::Cint, coord_names::Vector{Vector{UInt8}})

    error_code = ccall((:ex_get_coord_names, libexodus), Cint,
                       (Cint, Ptr{Ptr{UInt8}}),
                       exo_id, coord_names)
    exodus_error_check(error_code, "ex_get_coord_names!")
end

function ex_get_elem_cmap!(exoid::Cint, map_id::ex_entity_id, elem_ids, side_ids, proc_ids, processor)
    error_code = ccall((:ex_get_elem_cmap, libexodus), Cint,
                       (Cint, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Cint),
                       exoid, map_id, elem_ids, side_ids, proc_ids, processor)
    exodus_error_check(error_code, "ex_get_elem_cmap!")
end

# this is one of the general methods
function ex_get_ids!(exoid::Cint, exo_const::ex_entity_type, # inputs not to be changed
                     ids) # TODO get the types right
    error_code = ccall((:ex_get_ids, libexodus), Cint,
                       (Cint, ex_entity_type, Ptr{void_int}),
                       exoid, exo_const, ids)
    exodus_error_check(error_code, "ex_get_ids!")
end

function ex_get_id_map!(exoid::Cint, map_type::ex_entity_type, map)
    error_code = ccall((:ex_get_id_map, libexodus), Cint,
                       (Cint, ex_entity_type, Ptr{void_int}),
                       exoid, map_type, map)
    exodus_error_check(error_code, "ex_get_id_map!")
end

# TODO add types
function ex_get_init!(exoid::Cint, 
                      title,
                      num_dim, num_nodes, num_elem, 
                      num_elem_blk, num_node_sets, num_side_sets) # TODO get the types right
    error_code = ccall((:ex_get_init, libexodus), Cint,
                       (Cint, Ptr{UInt8},
                        Ptr{void_int}, Ptr{void_int}, Ptr{void_int},
                        Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
                       exoid, title,
                       num_dim, num_nodes, num_elem,
                       num_elem_blk, num_node_sets, num_side_sets)
    title = unsafe_string(pointer(title))
    exodus_error_check(error_code, "ex_get_init!")
end

function ex_get_init_global!(exoid::Cint, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g) # TODO get the types right
    error_code = ccall((:ex_get_init_global, libexodus), Cint,
                       (Cint, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
                       exoid, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g)
    exodus_error_check(error_code, "ex_get_init_global!")
end

function ex_get_init_info!(exoid::Cint, num_proc, num_proc_in_f, ftype)
    error_code = ccall((:ex_get_init_info, libexodus), Cint,
                       (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{UInt8}),
                       exoid, num_proc, num_proc_in_f, ftype)
    exodus_error_check(error_code, "ex_get_init_info!")
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

function ex_get_node_cmap!(exoid::Cint, map_id::ex_entity_id, node_ids, proc_ids, processor::Cint)
    error_code = ccall((:ex_get_node_cmap, libexodus), Cint,
                       (Cint, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Cint),
                       exoid, map_id, node_ids, proc_ids, processor)
    exodus_error_check(error_code, "ex_get_node_cmap!")
end

# NOTE THIS METHOD IS DEPRECATED WE SHOULD MOVE TO ANOTHER INTERFACE USING EX_GET_SET
# function ex_get_node_set!(exoid::Cint, node_set_id::ex_entity_id, node_set_node_list) figure this out
function ex_get_node_set!(exoid::Cint, node_set_id, node_set_node_list)
    error_code = ccall((:ex_get_node_set, libexodus), Cint,
                       (Cint, ex_entity_id, Ptr{void_int}),
                       exoid, node_set_id, node_set_node_list)
    exodus_error_check(error_code, "ex_get_node_set!")
end

function ex_get_processor_node_maps!(exoid::Cint, node_mapi, node_mapb, node_mape, processor)
    error_code = ccall((:ex_get_processor_node_maps, libexodus), Cint,
                       (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint),
                       exoid, node_mapi, node_mapb, node_mape, processor)
    exodus_error_check(error_code, "ex_get_processor_node_maps")
end

#getting seg faults from below method
# function ex_get_set!(exoid::int, set_type::ex_entity_type, set_id::ex_entity_id,
#                      set_entry_list, set_extra_list)
#     error_code = ccall((:ex_get_set, libexodus), int,
#                   (int, ex_entity_type, ex_entity_id, Ptr{void_int}, Any),
#                   exoid, set_type, set_id, set_entry_list, set_extra_list)
#     exodus_error_check(error_code, "ex_get_set!")
# end

function ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id, #::ex_entity_id, # figure thsi out
                           num_entry_in_set, num_dist_fact_in_set)
    error_code = ccall((:ex_get_set_param, libexodus), Cint,
                       (Cint, ex_entity_type, ex_entity_id, Ptr{void_int}, Ptr{void_int}),
                       exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set)
    exodus_error_check(error_code, "ex_get_set_param!")
end

# function ex_get_set_param!(exoid::int, set_type::ex_entity_type, set_id::Int64,
#                            num_entry_in_set, num_dist_fact_in_set)
#     error_code = ccall((:ex_get_set_param, libexodus), int,
#                        (int, ex_entity_type, Int64, Ptr{void_int}, Ptr{void_int}),
#     exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set)
#     exodus_error_check(error_code, "ex_get_set_param!")
# end

function ex_get_var!(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint,
                     obj_id::ex_entity_id, num_entry_this_obj, var_vals)
    error_code = ccall((:ex_get_var, libexodus), Cint,
                       (Cint, Cint, ex_entity_type, Cint, ex_entity_id, Clonglong, Ptr{Cvoid}),
                       exoid, time_step, var_type, var_index, obj_id, num_entry_this_obj, var_vals)
    exodus_error_check(error_code, "ex_get_var!")
end

function ex_get_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name)
    error_code = ccall((:ex_get_variable_name, libexodus), Cint,
                       (Cint, ex_entity_type, Cint, Ptr{UInt8}),
                       exoid, obj_type, var_num, var_name)
    exodus_error_check(error_code, "ex_get_variable_name")
end

function ex_get_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars)
    error_code = ccall((:ex_get_variable_param, libexodus), Cint,
                       (Cint, Cint, Ptr{Cint}),
                       exoid, obj_type, num_vars)
    exodus_error_check(error_code, "ex_get_variable_param")
end

function ex_inquire_int(exoid::Cint, req_info::ex_inquiry)::Cint
    info = ccall((:ex_inquire_int, libexodus), Cint,
                 (Cint, ex_inquiry), 
                 exoid, req_info)
    exodus_error_check(info, "ex_inquire_int")
    return info
end

function ex_int64_status(exoid::Cint)
    status = ccall((:ex_int64_status, libexodus), UInt32, (Cint,), exoid)
    return status
end

# this method actually returns something
# this method will break currently if called
# TODO figure out how to get #define statements to work from julia artifact
function ex_open(path, mode, comp_ws, io_ws)::Cint
    error_code = ccall((:ex_open, libexodus), Cint,
                       (Cstring, Cint, Ptr{Cint}, Ptr{Cint}),
                       path, mode, comp_ws, io_ws)
    exodus_error_check(error_code, "ex_open")
    return error_code
end

# this is a hack for now, maybe make a wrapper?
function ex_open_int(path, mode, comp_ws, io_ws, version, run_version)::Cint
    error_code = ccall((:ex_open_int, libexodus), Cint,
                       (Cstring, Cint, Ref{Cint}, Ref{Cint}, Ref{Cfloat}, Cint),
                       path, mode, comp_ws, io_ws, version, run_version)
    exodus_error_check(error_code, "ex_open_int")
    return error_code
end

function ex_opts(options)
    error_code = ccall((:ex_opts, libexodus), Cint, (Cint,), options)
    exodus_error_check(error_code, "ex_opts")
    return error_code
end

# TODO the put methods probably shouldn't have a ! in them

function ex_put_coord!(exoid::Cint, # input not to be changed
                       x_coords, y_coords, z_coords) # TODO get the types right
    error_code = ccall((:ex_put_coord, libexodus), Cint,
                       (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                       exoid, x_coords, y_coords, z_coords)
    exodus_error_check(error_code, "ex_put_coord!")
end

function ex_put_coord_names!(exoid::Cint, 
                             coord_names::Vector{Vector{UInt8}})
    error_code = ccall((:ex_put_coord_names, libexodus), Cint,
                       (Cint, Ptr{Ptr{UInt8}}),
                       exoid, coord_names)
    exodus_error_check(error_code, "ex_put_coord_names!")
end

function ex_put_init!(exoid::Cint, 
                      title,
                      num_dim, num_nodes, num_elem, 
                      num_elem_blk, num_node_sets, num_side_sets) # TODO get the types right
    error_code = ccall((:ex_put_init, libexodus), Cint,
                       (Cint, Ptr{UInt8},
                        Clonglong, Clonglong, Clonglong,
                        Clonglong, Clonglong, Clonglong),
                       exoid, title,
                       num_dim, num_nodes, num_elem,
                       num_elem_blk, num_node_sets, num_side_sets)
    exodus_error_check(error_code, "ex_put_init!")
end

function ex_put_time!(exoid::Cint, time_step::Cint, time_value)
    error_code = ccall((:ex_put_time, libexodus), Cint,
                       (Cint, Cint, Ref{Float64}), # need to get types to be Ptr{Cvoid} but not working
                       exoid, time_step, time_value)
    exodus_error_check(error_code, "ex_put_time!")
end

function ex_put_var!(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint,
                     obj_id::ex_entity_id, num_entries_this_obj, var_vals)
    error_code = ccall((:ex_put_var, libexodus), Cint,
                       (Cint, Cint, ex_entity_type, Cint, ex_entity_id, Cint, Ptr{Cvoid}),
                       exoid, time_step, var_type, var_index, obj_id, num_entries_this_obj, var_vals)
    exodus_error_check(error_code, "ex_put_var!")
end

function ex_put_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name)
    error_code = ccall((:ex_put_variable_name, libexodus), Cint,
                       (Cint, ex_entity_type, Cint, Ptr{UInt8}),
                       exoid, obj_type, var_num, var_name)
    exodus_error_check(error_code, "ex_put_variable_name!")
end

function ex_put_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint)
    error_code = ccall((:ex_put_variable_param, libexodus), Cint,
                       (Cint, ex_entity_type, Cint),
                       exoid, obj_type, num_vars)
    exodus_error_check(error_code, "ex_put_variable_param!")
end

function ex_set_max_name_length(exoid::Cint, len::Cint)
    error_code = ccall((:ex_set_max_name_length, libexodus), Cint,
                       (Cint, Cint), exoid, len)
    exodus_error_check(error_code, "ex_set_max_name_length")
end