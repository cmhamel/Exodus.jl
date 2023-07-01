"""
"""
function read_number_of_node_set_variables(exo::ExodusDatabase)
  num_vars = Ref{Cint}(0)
  ex_get_variable_param!(get_file_id(exo), EX_NODE_SET, num_vars)
  return num_vars[]
end

function read_node_set_variable_names!(
  exo::ExodusDatabase, num_vars::Cint, 
  var_name::Vector{UInt8}, var_names::Vector{String}
)
  for n = 1:num_vars
    ex_get_variable_name!(get_file_id(exo), EX_NODE_SET, convert(Cint, n), var_name)
    var_names[n] = unsafe_string(pointer(var_name))
  end
end

"""
"""
function read_node_set_variable_name(exo::ExodusDatabase, var_index::Integer)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  ex_get_variable_name!(get_file_id(exo), EX_NODE_SET, convert(Cint, var_index), var_name)
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_node_set_variable_names(exo::ExodusDatabase)
  num_vars = read_number_of_node_set_variables(exo)
  var_names = Vector{String}(undef, num_vars)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  read_node_set_variable_names!(exo, num_vars, var_name, var_names)
  return var_names
end

"""
"""
function read_node_set_variable_values(exo::ExodusDatabase, time_step, variable_index::I_1, nset_id) where I_1 <: Integer
  n_nodes, _ = read_node_set_parameters(exo, nset_id)
  values = Vector{get_float_type(exo)}(undef, n_nodes)
  ex_get_var!(get_file_id(exo), convert(Cint, time_step), EX_NODE_SET, 
              convert(Cint, variable_index), nset_id, 
              convert(Clonglong, n_nodes), values)
  return values
end

"""
"""
function read_node_set_variable_values(exo::ExodusDatabase, time_step, var_name::String, nset_name::String)
  var_name_index = findall(x -> x == var_name, read_node_set_variable_names(exo))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  nset_name_index = findall(x -> x == nset_name, read_node_set_names(exo))
  if length(nset_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  nset_name_index = nset_name_index[1]
  read_node_set_variable_values(exo, time_step, var_name_index, nset_name_index)
end

"""
"""
function write_number_of_node_set_variables(exo::ExodusDatabase, num_vars)
  ex_put_variable_param!(get_file_id(exo), EX_NODE_SET, num_vars)
end

"""
"""
function write_node_set_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String)
  temp = Vector{UInt8}(var_name)
  ex_put_variable_name!(get_file_id(exo), EX_NODE_SET, var_index, temp)
end

"""
"""
function write_node_set_variable_names(exo::ExodusDatabase, var_indices::Vector{<:Integer}, var_names::Vector{String})
  if size(var_indices, 1) != size(var_names, 1)
    AssertionError("Indices and Names need to be the same length")
  end

  for n in axes(var_indices, 1)
    temp = Vector{UInt8}(var_names[n])
    ex_put_variable_name!(get_file_id(exo), EX_NODE_SET, convert(Cint, var_indices[n]), temp)
  end
end

"""
"""
function write_node_set_variable_values(exo::ExodusDatabase, time_step, 
                                        var_index::Integer, nset_id, var_values::Vector{<:Real}) # TODO add types
  var_index = convert(get_id_int_type(exo), var_index)
  num_nodes = size(var_values, 1)
  # TODO probably need some size error checking
  ex_put_var!(get_file_id(exo), convert(Cint, time_step), EX_NODE_SET, 
              convert(Cint, var_index), nset_id, 
              convert(Clonglong, num_nodes), var_values)
end

"""
"""
function write_node_set_variable_values(exo::ExodusDatabase, time_step, var_name::String, nset_name::String, var_value::Vector{<:Real})
  var_name_index = findall(x -> x == var_name, read_node_set_variable_names(exo))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  nset_name_index = findall(x -> x == nset_name, read_node_set_names(exo))
  if length(nset_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  nset_name_index = nset_name_index[1]
  write_node_set_variable_values(exo, time_step, var_name_index, nset_name_index, var_value)
end


export read_node_set_variable_name
export read_node_set_variable_names
export read_node_set_variable_values
export read_number_of_node_set_variables

export write_node_set_variable_name
export write_node_set_variable_names
export write_node_set_variable_values
export write_number_of_node_set_variables