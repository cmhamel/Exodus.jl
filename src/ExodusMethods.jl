# please put these in alphabetical order
# also they should mimic the exodus C interface
# such that no temp variables are created

# goal is to be all in place methods
# error checking should be done in this wrapper maybe?

# TODO maybe make a macro to handle ccall into error check

function ex_close!(exoid::int)
    error = ccall((:ex_close, libexodus), int, (int,), exoid)
    exodus_error_check(error, "ex_close!")
end

function ex_copy!(in_exoid::int, out_exoid::int)
    error = ccall((:ex_copy, libexodus), int, (int, int), in_exoid, out_exoid)
    exodus_error_check(error, "ex_copy!")
end

function ex_create(path, cmode, comp_ws, io_ws)::int
    exo_id = ccall((:ex_create, libexodus), int,
                   (Base.Cstring, int, Ptr{int}, Ptr{int}),
                   path, cmode, comp_ws, io_ws)
    exodus_error_check(exo_id, "create_exodus_database")
    return exo_id
end

function ex_create_int(path, cmode, comp_ws, io_ws, run_version)::int
    exo_id = ccall((:ex_create_int, libexodus), int,
                   (Base.Cstring, int, Ptr{int}, Ptr{int}, int),
                    path, cmode, comp_ws, io_ws, run_version)
    exodus_error_check(exo_id, "create_exodus_database")
    return exo_id
end

function ex_get_all_times!(exoid::int, time_values)
    error = ccall((:ex_get_all_times, libexodus), int,
                  (int, Ptr{Cvoid}),
                  exoid, time_values)
    exodus_error_check(error, "ex_get_all_times!")
end

function ex_get_block!(exoid::int, blk_type::ex_entity_type, blk_id::ex_entity_id,
                       entity_descrip, 
                       num_entries_this_blk, num_nodes_per_entry,
                       num_edges_per_entry, num_faces_per_entry,
                       num_attr_per_entry) # TODO get the types right
    error = ccall((:ex_get_block, libexodus), int,
                  (int, ex_entity_type, ex_entity_id,
                  Ptr{UInt8}, 
                  Ptr{void_int}, Ptr{void_int}, 
                  Ptr{void_int}, Ptr{void_int}, 
                  Ptr{void_int}),
                  exoid, blk_type, blk_id,
                  entity_descrip, 
                  num_entries_this_blk, num_nodes_per_entry, 
                  num_edges_per_entry, num_faces_per_entry, 
                  num_attr_per_entry)
    exodus_error_check(error, "ex_get_block!")
end

function ex_get_cmap_params!(exoid::int, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    error = ccall((:ex_get_cmap_params, libexodus), int,
                  (int, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, int),
                  exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    exodus_error_check(error, "ex_get_cmap_params!")
end

function ex_get_conn!(exoid::int, blk_type::ex_entity_type, blk_id::ex_entity_id, 
                      nodeconn, faceconn, edgeconn) # TODO get the types right
    error = ccall((:ex_get_conn, libexodus), ExodusError,
                  (int, ex_entity_type, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
    exoid, blk_type, blk_id, nodeconn, faceconn, edgeconn)
    exodus_error_check(error, "ex_get_conn") 
end

function ex_get_coord!(exoid::int, # input not to be changed
                       x_coords::ArrayOrRefFloat64, 
                       y_coords::ArrayOrRefFloat64, 
                       z_coords::ArrayOrRefFloat64) # TODO get the types right
    error = ccall((:ex_get_coord, libexodus), ExodusError,
                  (int, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                  exoid, x_coords, y_coords, z_coords)
    exodus_error_check(error, "ex_get_coord!")
end

function ex_get_elem_cmap!(exoid::int, map_id::ex_entity_id, elem_ids, side_ids, proc_ids, processor)
    error = ccall((:ex_get_elem_cmap, libexodus), int,
                  (int, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, int),
                  exoid, map_id, elem_ids, side_ids, proc_ids, processor)
    exodus_error_check(error, "ex_get_elem_cmap!")
end

# this is one of the general methods
function ex_get_ids!(exoid::int, exo_const::ex_entity_type, # inputs not to be changed
                     ids) # TODO get the types right
    error = ccall((:ex_get_ids, libexodus), int,
                  (int, ex_entity_type, Ptr{void_int}),
                  exoid, exo_const, ids)
    exodus_error_check(error, "ex_get_ids!")
end

function ex_get_id_map!(exoid::int, map_type::ex_entity_type, map)
    error = ccall((:ex_get_id_map, libexodus), int,
                  (int, ex_entity_type, Ptr{void_int}),
                  exoid, map_type, map)
    exodus_error_check(error, "ex_get_id_map!")
end

function ex_get_init!(exoid::int, 
                      title,
                      num_dim, num_nodes, num_elem, 
                      num_elem_blk, num_node_sets, num_side_sets) # TODO get the types right
    error = ccall((:ex_get_init, libexodus), int,
                  (int, Ptr{UInt8},
                   Ptr{void_int}, Ptr{void_int}, Ptr{void_int},
                   Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
                  exoid, title,
                  num_dim, num_nodes, num_elem,
                  num_elem_blk, num_node_sets, num_side_sets)
    title = unsafe_string(pointer(title))
    exodus_error_check(error, "ex_get_init!")
end

function ex_get_init_global!(exoid::int, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g) # TODO get the types right
    error = ccall((:ex_get_init_global, libexodus), int,
                  (int, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
                  exoid, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g)
    exodus_error_check(error, "ex_get_init_global!")
end

function ex_get_init_info!(exoid::int, num_proc, num_proc_in_f, ftype)
    error = ccall((:ex_get_init_info, libexodus), int,
                  (int, Ptr{int}, Ptr{int}, Ptr{UInt8}),
                  exoid, num_proc, num_proc_in_f, ftype)
    exodus_error_check(error, "ex_get_init_info!")
end

function ex_get_loadbal_param!(exoid::int,
                               num_int_nodes, num_bor_nodes, num_ext_nodes,
                               num_int_elems, num_bor_elems,
                               num_node_cmaps, num_elem_cmaps,
                               processor) # TODO get types right and sorted out
    error = ccall((:ex_get_loadbal_param, libexodus), int,
                  (int, 
                   Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, 
                   Ptr{void_int}, Ptr{void_int}, 
                   Ptr{void_int}, Ptr{void_int}, 
                   IntKind),
                  exoid, 
                  num_int_nodes, num_bor_nodes, num_ext_nodes, 
                  num_int_elems, num_bor_elems,
                  num_node_cmaps, num_elem_cmaps, 
                  processor)
    exodus_error_check(error, "ex_get_loadbal_param!")
end

function ex_get_node_cmap!(exoid::int, map_id::ex_entity_id, node_ids, proc_ids, processor::int)
    error = ccall((:ex_get_node_cmap, libexodus), int,
                  (int, ex_entity_id, Ptr{void_int}, Ptr{void_int}, int),
                  exoid, map_id, node_ids, proc_ids, processor)
    exodus_error_check(error, "ex_get_node_cmap!")
end

# NOTE THIS METHOD IS DEPRECATED WE SHOULD MOVE TO ANOTHER INTERFACE USING EX_GET_SET
function ex_get_node_set!(exoid::int, node_set_id::ex_entity_id, node_set_node_list)
    error = ccall((:ex_get_node_set, libexodus), int,
                  (int, ex_entity_id, Ptr{void_int}),
                  exoid, node_set_id, node_set_node_list)
    exodus_error_check(error, "ex_get_node_set!")
end

function ex_get_processor_node_maps!(exoid::int, node_mapi, node_mapb, node_mape, processor)
    error = ccall((:ex_get_processor_node_maps, libexodus), int,
                  (int, Ptr{int}, Ptr{int}, Ptr{int}, int),
                  exoid, node_mapi, node_mapb, node_mape, processor)
    exodus_error_check(error, "ex_get_processor_node_maps")
end

#getting seg faults from below method
# function ex_get_set!(exoid::int, set_type::ex_entity_type, set_id::ex_entity_id,
#                      set_entry_list, set_extra_list)
#     error = ccall((:ex_get_set, libexodus), int,
#                   (int, ex_entity_type, ex_entity_id, Ptr{void_int}, Any),
#                   exoid, set_type, set_id, set_entry_list, set_extra_list)
#     exodus_error_check(error, "ex_get_set!")
# end

function ex_get_set_param!(exoid::int, set_type::ex_entity_type, set_id::ex_entity_id,
                           num_entry_in_set, num_dist_fact_in_set)
    error = ccall((:ex_get_set_param, libexodus), int,
                  (int, ex_entity_type, ex_entity_id, Ptr{void_int}, Ptr{void_int}),
                  exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set)
    exodus_error_check(error, "ex_get_set_param!")
end

function ex_get_var!(exoid::int, time_step::int, var_type::ex_entity_type, var_index::int,
                     obj_id::ex_entity_id, num_entry_this_obj, var_vals)
    error = ccall((:ex_get_var, libexodus), int,
                  (int, int, ex_entity_type, int, ex_entity_id, int, Ref{Float64}),
                  exoid, time_step, var_type, var_index, obj_id, num_entry_this_obj, var_vals)
    exodus_error_check(error, "ex_get_var!")
end

function ex_get_variable_name!(exoid::int, obj_type::ex_entity_type, var_num::int, var_name)
    error = ccall((:ex_get_variable_name, libexodus), int,
                  (int, ex_entity_type, int, Ptr{UInt8}),
                  exoid, obj_type, var_num, var_name)
    exodus_error_check(error, "ex_get_variable_name")
end

function ex_get_variable_param!(exoid::int, obj_type::ex_entity_type, num_vars)
    error = ccall((:ex_get_variable_param, libexodus), int,
                  (int, int, Ptr{int}),
                  exoid, obj_type, num_vars)
    exodus_error_check(error, "ex_get_variable_param")
end

function ex_inquire_int(exoid::int, req_info::ex_inquiry)::int
    info = ccall((:ex_inquire_int, libexodus), int,
                 (int, ex_inquiry), 
                 exoid, req_info)
    exodus_error_check(info, "ex_inquire_int")
    return info
end

# this method actually returns something
# this method will break currently if called
# TODO figure out how to get #define statements to work from julia artifact
function ex_open(path, mode, comp_ws, io_ws)::int
    error = ccall((:ex_open, libexodus), int,
                  (Base.Cstring, int, Ptr{int}, Ptr{int}),
                  path, mode, comp_ws, io_ws)
    exodus_error_check(error, "ex_open")
    return error
end

# this is a hack for now, maybe make a wrapper?
function ex_open_int(path, mode, comp_ws, io_ws, version, run_version)::int
    error = ccall((:ex_open_int, libexodus), int,
                  (Base.Cstring, int, Ptr{int}, Ptr{int}, Ref{Float64}, int),
                  path, mode, comp_ws, io_ws, version, run_version)
    exodus_error_check(error, "ex_open_int")
    return error
end

function ex_put_init!(exoid::int, 
                      title,
                      num_dim, num_nodes, num_elem, 
                      num_elem_blk, num_node_sets, num_side_sets) # TODO get the types right
    error = ccall((:ex_put_init, libexodus), int,
                  (int, Base.Cstring,
                   Ptr{void_int}, Ptr{void_int}, Ptr{void_int},
                   Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
                  exoid, title,
                  num_dim, num_nodes, num_elem,
                  num_elem_blk, num_node_sets, num_side_sets)
    # title = unsafe_string(pointer(title))
    exodus_error_check(error, "ex_put_init!")
end

function ex_put_time!(exoid::int, time_step::int, time_value)
    error = ccall((:ex_put_time, libexodus), int,
                  (int, int, Ref{Float64}), # need to get types to be void
                  exoid, time_step, time_value)
    exodus_error_check(error, "ex_put_time!")
end

function ex_put_var!(exoid::int, time_step::int, var_type::ex_entity_type, var_index::int,
                     obj_id::ex_entity_id, num_entries_this_obj, var_vals)
    error = ccall((:ex_put_var, libexodus), int,
                  (int, int, ex_entity_type, int, ex_entity_id, int, Ref{Float64}),
                  exoid, time_step, var_type, var_index, obj_id, num_entries_this_obj, var_vals)
    exodus_error_check(error, "ex_put_var!")
end

function ex_put_variable_name!(exoid::int, obj_type::ex_entity_type, var_num::int, var_name)
    error = ccall((:ex_put_variable_name, libexodus), int,
                  (int, ex_entity_type, int, Ptr{UInt8}),
                  exoid, obj_type, var_num, var_name)
    exodus_error_check(error, "ex_put_variable_name!")
end

function ex_put_variable_param!(exoid::int, obj_type::ex_entity_type, num_vars::int)
    error = ccall((:ex_put_variable_param, libexodus), int,
                  (int, ex_entity_type, int),
                  exoid, obj_type, num_vars)
    exodus_error_check(error, "ex_put_variable_param!")
end