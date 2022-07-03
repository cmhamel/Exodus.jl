# please put these in alphabetical order
# also they should mimic the exodus C interface
# such that no temp variables are created

# goal is to be all in place methods
# error checking should be done in this wrapper maybe?

function ex_get_block!(exo_id::ExoID, blk_type::ex_entity_type, blk_id::ex_entity_id,
                       entity_descrip, 
                       num_entries_this_blk, num_nodes_per_entry,
                       num_edges_per_entry, num_faces_per_entry,
                       num_attr_per_entry)
    error = ccall((:ex_get_block, libexodus), int,
                  (ExoID, ex_entity_type, ex_entity_id,
                  Ptr{UInt8}, 
                  Ptr{void_int}, Ptr{void_int}, 
                  Ptr{void_int}, Ptr{void_int}, 
                  Ptr{void_int}),
                  exo_id, blk_type, blk_id,
                  entity_descrip, 
                  num_entries_this_blk, num_nodes_per_entry, 
                  num_edges_per_entry, num_faces_per_entry, 
                  num_attr_per_entry)
    exodus_error_check(error, "ex_get_block!")
end

function ex_get_coord!(exo_id::int, # input not to be changed
                       x_coords::ArrayOrRefFloat64, 
                       y_coords::ArrayOrRefFloat64, 
                       z_coords::ArrayOrRefFloat64)
    error = ccall((:ex_get_coord, libexodus), ExodusError,
                  (int, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                  exo_id, x_coords, y_coords, z_coords)
    exodus_error_check(error, "ex_get_coord!")
end

# this is one of the general methods
function ex_get_ids!(exo_id::int, exo_const::ex_entity_type, # inputs not to be changed
                     ids)
    error = ccall((:ex_get_ids, libexodus), int,
                  (int, ex_entity_type, Ptr{void_int}),
                  exo_id, exo_const, ids)
    exodus_error_check(error, "ex_get_ids!")
end

