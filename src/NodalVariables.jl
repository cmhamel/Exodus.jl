function read_number_of_nodal_variables(exo_id::Cint)
    num_vars = Ref{Cint}(0)
    ex_get_variable_param!(exo_id, EX_NODAL, num_vars)
    return num_vars[]
end

function read_nodal_variable_names!(exo_id::Cint, num_vars::Cint, var_name::Vector{UInt8}, var_names::Vector{String})
    for n = 1:num_vars
        ex_get_variable_name!(exo_id, EX_NODAL, n, var_name)
        var_names[n] = unsafe_string(pointer(var_name))
    end
end

function read_nodal_variable_names(exo_id::Cint)
    num_vars = read_number_of_nodal_variables(exo_id)
    var_names = Vector{String}(undef, num_vars)
    var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
    read_nodal_variable_names!(exo_id, num_vars, var_name, var_names)
    return var_names
end

function read_nodal_variable_values(exo_id::Cint, time_step, variable_index, num_nodes)
    values = Vector{Float64}(undef, num_nodes)
    # TODO figure out what the 1 in the call is really doing for nodal values
    # TODO for element variables that should be associated with a block number or soemthing like that
    ex_get_var!(exo_id, time_step, EX_NODAL, variable_index, 1, num_nodes, values)
    return values
end

function write_number_of_nodal_variables(exo_id::Cint, num_vars)
    ex_put_variable_param!(exo_id, EX_NODAL, num_vars)
end

# TODO check types everywhere in this file
function write_nodal_variable_names(exo_id::Cint, var_indices::Vector{Cint}, var_names::Vector{String})
    if size(var_indices, 1) != size(var_names, 1)
        AssertionError("Indices and Names need to be the same length")
    end
    for n = 1:size(var_indices, 1)
        temp = Vector{UInt8}(var_names[n])
        ex_put_variable_name!(exo_id, EX_NODAL, var_indices[n], temp)
    end
end

function write_nodal_variable_values(exo_id::Cint, time_step, 
                                     var_index, var_values::Vector{Float64})
    num_nodes = size(var_values, 1)
    ex_put_var!(exo_id, time_step, EX_NODAL, var_index, 1, num_nodes, var_values)
end