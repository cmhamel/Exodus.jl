# please put these in alphabetical order
# also they should mimic the exodus C interface
# such that no temp variables are created

# goal is to be all in place methods
# error checking should be done in this wrapper maybe?

function ex_get_coord!(exo_id::ExoID, # input not to be changed
                       x_coords::ArrayOrRefFloat64, 
                       y_coords::ArrayOrRefFloat64, 
                       z_coords::ArrayOrRefFloat64)
    error = ccall((:ex_get_coord, libexodus), ExodusError,
                  (ExoID, Ref{Float64}, Ref{Float64}, Ref{Float64}),
                  exo_id, x_coords, y_coords, z_coords)
    exodus_error_check(error, "ex_get_coord!")
end

# this is one of the general methods
function ex_get_ids!(exo_id::ExoID, exo_const::Union{ExodusConstant, ExEntityType}, # inputs not to be changed
                     ids::Vector{IntKind})
    error = ccall((:ex_get_ids, libexodus), ExodusError,
                  (ExoID, ExodusConstant, Ref{IntKind}),
                  exo_id, exo_const, ids)
    exodus_error_check(error, "ex_get_ids!")
end

