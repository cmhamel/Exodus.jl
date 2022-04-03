abstract type Variable <: FEMContainer end

mutable struct NodalVariable <: FEMContainer
    name::String
    values::Vector{Float64}
end

mutable struct ElementVariable <: FEMContainer
    name::String
    values::Vector{Float64}
end

NodalVariables = Vector{NodalVariable}
ElementVariables = Vector{ElementVariable}

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

function read_nodal_variables(exo_id::ExoID, variable_names::Array{String}, time_step::Int64)

end