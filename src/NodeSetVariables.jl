"""
"""
function read_number_of_node_set_variables(exo::ExodusDatabase)
  num_vars = Ref{Cint}(0)
  error_code = @ccall libexodus.ex_get_variable_param(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, num_vars::Ptr{Cint} 
  )::Cint
  exodus_error_check(error_code, "Exodus.read_number_of_node_set_variables -> Exodus.ex_get_variable_param")
  return num_vars[]
end

"""
"""
function read_node_set_variable_name(exo::ExodusDatabase, var_index::Integer)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_variable_name(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, var_index::Cint, var_name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_variable_names! -> libexodus.ex_get_variable_name")
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_node_set_variable_names(exo::ExodusDatabase)
  num_vars = read_number_of_node_set_variables(exo)
  var_names = Vector{Vector{UInt8}}(undef, num_vars)
  for n in 1:length(var_names)
    var_names[n] = Vector{UInt8}(undef, MAX_STR_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_variable_names(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, num_vars::Cint, var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_variable_names -> libexodus.ex_get_names")

  new_var_names = Vector{String}(undef, num_vars)
  for n in 1:length(var_names)
    new_var_names[n] = unsafe_string(pointer(var_names[n]))
  end
  return new_var_names
end

"""
"""
function read_node_set_variable_values(exo::ExodusDatabase, time_step, variable_index::I_1, nset_id) where I_1 <: Integer
  n_nodes, _ = read_node_set_parameters(exo, nset_id)
  values = Vector{get_float_type(exo)}(undef, n_nodes)
  error_code = @ccall libexodus.ex_get_var(
    get_file_id(exo)::Cint, time_step::Cint, EX_NODE_SET::ex_entity_type,
    variable_index::Cint, nset_id::ex_entity_id, n_nodes::Clonglong, values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_variable_values -> libexodus.ex_get_var")
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
  error_code = @ccall libexodus.ex_put_variable_param(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, num_vars::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.write_number_of_node_set_variables -> libexodus.ex_put_variable_param")
end

"""
"""
function write_node_set_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String)
  temp = Vector{UInt8}(var_name)
  error_code = @ccall libexodus.ex_put_variable_name(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, var_index::Cint, temp::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_variable_name -> libexodus.ex_put_variable_name")
end

"""
"""
function write_node_set_variable_names(exo::ExodusDatabase, var_names::Vector{String})
  error_code = @ccall libexodus.ex_put_variable_names(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, length(var_names)::Cint,
    var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_variable_names -> libexodus.ex_put_variable_names")
end

"""
"""
function write_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, 
                                        var_index::Integer, nset_id, var_values::Vector{<:Real}) # TODO add types
  num_nodes = size(var_values, 1)
  error_code = @ccall libexodus.ex_put_var(
    get_file_id(exo)::Cint, timestep::Cint, EX_NODE_SET::ex_entity_type,
    var_index::Cint, nset_id::ex_entity_id,
    num_nodes::Clonglong, var_values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_variable_values -> libexodus.ex_put_var")
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
