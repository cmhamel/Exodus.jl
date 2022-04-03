abstract type Variable <: FEMContainer end

# mutable struct NodalVariable <: FEMContainer
#     name::String
#     values::Vector{Float64}
# end

# mutable struct ElementVariable <: FEMContainer
#     name::String
#     values::Vector{Float64}
# end

# NodalVariables = Vector{NodalVariable}
# ElementVariables = Vector{ElementVariable}

function read_number_of_nodal_variables(exo_id::ExoID)
    num_vars = Ref{Int64}(0)
    error = ccall((:ex_get_variable_param, libexodus), Int64,
                  (Int64, Int64, Ref{Int64}),
                  exo_id, EX_NODAL, num_vars)
    exodus_error_check(error, "read_number_of_nodal_variables")
    return num_vars[]
end

function read_nodal_variable_names!(exo_id::ExoID, num_vars::Int64, var_name::Vector{UInt8}, var_names::Vector{String})
    for n = 1:num_vars
        error = ccall((:ex_get_variable_name, libexodus), Int64,
                      (Int64, Int64, Int64, Ptr{UInt8}),
                      exo_id, EX_NODAL, n, var_name)
        exodus_error_check(error, "read_nodal_variable_names")
        var_names[n] = unsafe_string(pointer(var_name))
    end
end

function read_nodal_variable_names(exo_id::ExoID)
    num_vars = read_number_of_nodal_variables(exo_id)
    var_names = Vector{String}(undef, num_vars)
    var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
    read_nodal_variable_names!(exo_id, num_vars, var_name, var_names)
    return var_names
end

function read_nodal_variable_values(exo_id::ExoID, time_step::Int64, variable_index::Int64, num_nodes::Int64)
    values = Vector{Float64}(undef, num_nodes)
    error = ccall((:ex_get_var, libexodus), ExodusError,
                  (ExoID, Int64, ExodusConstant, Int64, ExodusConstant, Int64, Ref{Float64}),
                  exo_id, time_step, EX_NODAL, variable_index, 1, num_nodes, values)
    exodus_error_check(error, "read_nodal_variable")
    return values
end

function write_number_of_nodal_variables(exo_id::ExoID, num_vars::Int64)
    error = ccall((:ex_put_variable_param, libexodus), ExodusError,
                  (ExoID, ExodusConstant, Int64),
                  exo_id, EX_NODAL, num_vars)
    exodus_error_check(error, "write_number_of_nodal_variables")
end

function write_nodal_variable_names(exo_id::ExoID, var_indices::Vector{Int64}, var_names::Vector{String})
    if size(var_indices, 1) != size(var_names, 1)
        AssertionError("Indices and Names need to be the same length")
    end
    for n = 1:size(var_indices, 1)
        temp = Vector{UInt8}(var_names[n])
        error = ccall((:ex_put_variable_name, libexodus), ExodusError,
                      (ExoID, ExodusConstant, Int64, Ptr{UInt8}),
                      exo_id, EX_NODAL, var_indices[n], temp)
        exodus_error_check(error, "write_nodal_variable_names")
    end
end

function write_nodal_variable_values(exo_id::ExoID, time_step::Int64, 
                                     var_index::Int64, var_values::Vector{Float64})
    #
    #
    num_nodes = size(var_values, 1)
    error = ccall((:ex_put_var, libexodus), ExodusError,
                  (ExoID, Int64, ExodusConstant, Int64, Int64, Int64, Ref{Float64}),
                  exo_id, time_step, EX_NODAL, var_index, 1, num_nodes, var_values)
    exodus_error_check(error, "write_nodal_variable_values")
end