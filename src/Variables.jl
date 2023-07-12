"""
"""
function read_number_of_variables(exo::ExodusDatabase, type::ex_entity_type)
  num_vars = Ref{Cint}(0)
  error_code = @ccall libexodus.ex_get_variable_param(
    get_file_id(exo)::Cint, type::ex_entity_type, num_vars::Ptr{Cint}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_number_of_variables -> libexodus.ex_get_variable_param")
  return num_vars[]
end

"""
"""
read_number_of_element_variables(exo::ExodusDatabase) = read_number_of_variables(exo, EX_ELEM_BLOCK)

"""
"""
read_number_of_global_variables(exo::ExodusDatabase) = read_number_of_variables(exo, EX_GLOBAL)

"""
"""
read_number_of_nodal_variables(exo::ExodusDatabase) = read_number_of_variables(exo, EX_NODAL)

"""
"""
read_number_of_node_set_variables(exo::ExodusDatabase) = read_number_of_variables(exo, EX_NODE_SET)

"""
"""
read_number_of_side_set_variables(exo::ExodusDatabase) = read_number_of_variables(exo, EX_SIDE_SET)

"""
"""
function read_variable_name(exo::ExodusDatabase, var_index::Integer, type::ex_entity_type)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_variable_name(
    get_file_id(exo)::Cint, type::ex_entity_type, var_index::Cint, var_name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_variable_name -> libexodus.ex_get_variable_name")
  return unsafe_string(pointer(var_name))
end

"""
"""
read_element_variable_name(exo::ExodusDatabase, var_index::Integer) = read_variable_name(exo, var_index, EX_ELEM_BLOCK)

"""
"""
read_global_variable_name(exo::ExodusDatabase, var_index::Integer) = read_variable_name(exo, var_index, EX_GLOBAL)

"""
"""
read_nodal_variable_name(exo::ExodusDatabase, var_index::Integer) = read_variable_name(exo, var_index, EX_NODAL)

"""
"""
read_node_set_variable_name(exo::ExodusDatabase, var_index::Integer) = read_variable_name(exo, var_index, EX_NODE_SET)

"""
"""
read_side_set_variable_name(exo::ExodusDatabase, var_index::Integer) = read_variable_name(exo, var_index, EX_SIDE_SET)

"""
"""
function read_variable_names(exo::ExodusDatabase, type::ex_entity_type)
  num_vars = read_number_of_variables(exo, type)
  var_names = Vector{Vector{UInt8}}(undef, num_vars)
  for n in 1:length(var_names)
    var_names[n] = Vector{UInt8}(undef, MAX_STR_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_variable_names(
    get_file_id(exo)::Cint, type::ex_entity_type, num_vars::Cint, var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_variable_names -> libexodus.ex_get_names")

  new_var_names = Vector{String}(undef, num_vars)
  for n in 1:length(var_names)
    new_var_names[n] = unsafe_string(pointer(var_names[n]))
  end
  return new_var_names
end

"""
"""
read_element_variable_names(exo::ExodusDatabase) = read_variable_names(exo, EX_ELEM_BLOCK)

"""
"""
read_global_variable_names(exo::ExodusDatabase) = read_variable_names(exo, EX_GLOBAL)

"""
"""
read_nodal_variable_names(exo::ExodusDatabase) = read_variable_names(exo, EX_NODAL)

"""
"""
read_node_set_variable_names(exo::ExodusDatabase) = read_variable_names(exo, EX_NODE_SET)

"""
"""
read_side_set_variable_names(exo::ExodusDatabase) = read_variable_names(exo, EX_SIDE_SET)

"""
"""
function read_variable_values(
  exo::ExodusDatabase{M, I, B, F}, 
  timestep::Integer, id::Integer, var_index::Integer, 
  type::ex_entity_type
) where {M, I, B, F}
  if type == EX_NODAL
    num_entries = exo.init.num_nodes
  elseif type == EX_ELEM_BLOCK
    _, num_entries, _, _, _, _ =
    read_element_block_parameters(exo, id)
  elseif type == EX_GLOBAL
    num_entries = read_number_of_variables(exo, type)
  elseif type == EX_NODE_SET || type == EX_SIDE_SET
    num_entries, _ = read_set_parameters(exo, id, type)
  else
    throw(ErrorException("Unsuported variable type $type"))
  end

  values = Vector{F}(undef, num_entries)
  error_code = @ccall libexodus.ex_get_var(
    get_file_id(exo)::Cint, timestep::Cint, type::ex_entity_type,
    var_index::Cint, id::ex_entity_id, num_entries::Clonglong, values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_nodal_variable_values -> libexodus.ex_get_var")
  return values
end

"""
"""
function read_variable_values(exo::ExodusDatabase, time_step::Integer, id::Integer, var_name::String, type::ex_entity_type)
  var_name_index = findall(x -> x == var_name, read_variable_names(exo, type))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  read_variable_values(exo, time_step, id, var_name_index, type)
end

"""
"""
function read_variable_values(exo::ExodusDatabase, time_step::Integer, var_name::String, nset_name::String, type::ex_entity_type)
  var_name_index = findall(x -> x == var_name, read_variable_names(exo, type))
  if length(var_name_index) > 1
    throw(ErrorException("This should never happen"))
  end
  var_name_index = var_name_index[1]
  set_name_index = findall(x -> x == nset_name, read_set_names(exo, type))
  if length(set_name_index) > 1
    throw(ErrorException("This should never happen"))
  end
  set_name_index = set_name_index[1]
  read_variable_values(exo, time_step, var_name_index, set_name_index, type)
end

"""
"""
read_element_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_index::Integer) = 
read_variable_values(exo, timestep, id, var_index, EX_ELEM_BLOCK)

"""
"""
read_element_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_name::String) = 
read_variable_values(exo, timestep, id, var_name, EX_ELEM_BLOCK)

"""
"""
read_global_variable_values(exo::ExodusDatabase, timestep::Integer) = 
read_variable_values(exo, timestep, 1, 1, EX_GLOBAL)

"""
"""
read_nodal_variable_values(exo::ExodusDatabase, timestep::Integer, var_index::Integer) = 
read_variable_values(exo, timestep, 1, var_index, EX_NODAL)

"""
"""
read_nodal_variable_values(exo::ExodusDatabase, timestep::Integer, var_name::String) = 
read_variable_values(exo, timestep, 1, var_name, EX_NODAL)

"""
"""
read_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_index::Integer) = 
read_variable_values(exo, timestep, id, var_index, EX_NODE_SET)

"""
"""
read_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_name::String) = 
read_variable_values(exo, timestep, id, var_name, EX_NODE_SET)

"""
"""
read_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, set_name::String, var_name::String) = 
read_variable_values(exo, timestep, set_name, var_name, EX_NODE_SET)

"""
"""
read_side_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_index::Integer) = 
read_variable_values(exo, timestep, id, var_index, EX_SIDE_SET)

"""
"""
read_side_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_name::String) = 
read_variable_values(exo, timestep, id, var_name, EX_SIDE_SET)

"""
"""
read_side_set_variable_values(exo::ExodusDatabase, timestep::Integer, set_name::String, var_name::String) = 
read_variable_values(exo, timestep, set_name, var_name, EX_SIDE_SET)

"""
"""
function read_partial_variable_values(
  exo::ExodusDatabase{M, I, B, F}, 
  time_step::Integer, id::Integer, var_index::Integer, 
  start_node::Integer, num_nodes::Integer, 
  type::ex_entity_type
) where {M, I, B, F}
  values = Vector{F}(undef, num_nodes)
  error_code = @ccall libexodus.ex_get_partial_var(
    get_file_id(exo)::Cint, time_step::Cint, type::ex_entity_type, 
    var_index::Cint, id::Cint, 
    start_node::Clonglong, num_nodes::Clonglong,
    values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_partial_nodal_variable_values -> libexodus.ex_get_partial_var")
  return values
end

"""
"""
function read_partial_variable_values(
  exo::ExodusDatabase, 
  time_step::Integer, id::Integer, var_name::String, 
  start_node::Integer, num_nodes::Integer,
  type::ex_entity_type
)
  var_name_index = findall(x -> x == var_name, read_variable_names(exo, type))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  read_partial_variable_values(exo, time_step, id, var_name_index, start_node, num_nodes, type)
end

"""
"""
read_partial_nodal_variable_values(exo::ExodusDatabase, time_step::Integer, var_index::Integer, start_node::Integer, num_nodes::Integer) = 
read_partial_variable_values(exo, time_step, 1, var_index, start_node, num_nodes, EX_NODAL)

"""
"""
read_partial_nodal_variable_values(exo::ExodusDatabase, time_step::Integer, var_name::String, start_node::Integer, num_nodes::Integer) = 
read_partial_variable_values(exo, time_step, 1, var_name, start_node, num_nodes, EX_NODAL)

# TODO do other data types for partial

"""
"""
function write_number_of_variables(exo::ExodusDatabase, num_vars::Integer, type::ex_entity_type)
  error_code = @ccall libexodus.ex_put_variable_param(
    get_file_id(exo)::Cint, type::ex_entity_type, num_vars::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.write_number_of_variables -> libexodus.ex_put_variable_param")
end

"""
"""
write_number_of_element_variables(exo::ExodusDatabase, num_vars::Integer) = 
write_number_of_variables(exo, num_vars, EX_ELEM_BLOCK)

"""
"""
write_number_of_global_variables(exo::ExodusDatabase, num_vars::Integer) = 
write_number_of_variables(exo, num_vars, EX_GLOBAL)

"""
"""
write_number_of_nodal_variables(exo::ExodusDatabase, num_vars::Integer) = 
write_number_of_variables(exo, num_vars, EX_NODAL)

"""
"""
write_number_of_node_set_variables(exo::ExodusDatabase, num_vars::Integer) = 
write_number_of_variables(exo, num_vars, EX_NODE_SET)

"""
"""
write_number_of_side_set_variables(exo::ExodusDatabase, num_vars::Integer) = 
write_number_of_variables(exo, num_vars, EX_SIDE_SET)

"""
"""
function write_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String, type::ex_entity_type)
  temp = Vector{UInt8}(var_name)
  error_code = @ccall libexodus.ex_put_variable_name(
    get_file_id(exo)::Cint, type::ex_entity_type, var_index::Cint, temp::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_variable_name -> libexodus.ex_put_variable_name")
end

"""
"""
write_element_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String) = 
write_variable_name(exo, var_index, var_name, EX_ELEM_BLOCK)

"""
"""
write_global_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String) = 
write_variable_name(exo, var_index, var_name, EX_GLOBAL)

"""
"""
write_nodal_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String) = 
write_variable_name(exo, var_index, var_name, EX_NODAL)

"""
"""
write_node_set_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String) = 
write_variable_name(exo, var_index, var_name, EX_NODE_SET)

"""
"""
write_side_set_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String) = 
write_variable_name(exo, var_index, var_name, EX_SIDE_SET)

"""
"""
function write_variable_names(exo::ExodusDatabase, var_names::Vector{String}, type::ex_entity_type)
  error_code = @ccall libexodus.ex_put_variable_names(
    get_file_id(exo)::Cint, type::ex_entity_type, length(var_names)::Cint,
    var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_variable_names -> libexodus.ex_put_variable_names")
end

"""
"""
write_element_variable_names(exo::ExodusDatabase, var_names::Vector{String}) = 
write_variable_names(exo, var_names, EX_ELEM_BLOCK)

"""
"""
write_global_variable_names(exo::ExodusDatabase, var_names::Vector{String}) = 
write_variable_names(exo, var_names, EX_GLOBAL)

"""
"""
write_nodal_variable_names(exo::ExodusDatabase, var_names::Vector{String}) = 
write_variable_names(exo, var_names, EX_NODAL)

"""
"""
write_node_set_variable_names(exo::ExodusDatabase, var_names::Vector{String}) = 
write_variable_names(exo, var_names, EX_NODE_SET)

"""
"""
write_side_set_variable_names(exo::ExodusDatabase, var_names::Vector{String}) = 
write_variable_names(exo, var_names, EX_SIDE_SET)

"""
"""
function write_variable_values(
  exo::ExodusDatabase, 
  timestep::Integer, id::Integer, var_index::Integer, 
  var_values::Vector{<:AbstractFloat}, 
  type::ex_entity_type
)
  num_nodes = size(var_values, 1)
  error_code = @ccall libexodus.ex_put_var(
    get_file_id(exo)::Cint, timestep::Cint, type::ex_entity_type,
    var_index::Cint, id::ex_entity_id,
    num_nodes::Clonglong, var_values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_variable_values -> libexodus.ex_put_var")
end

"""
"""
function write_variable_values(
  exo::ExodusDatabase, 
  time_step::Integer, id::Integer, var_name::String, 
  var_value::Vector{<:AbstractFloat},
  type::ex_entity_type
)
  var_name_index = findall(x -> x == var_name, read_variable_names(exo, type))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  write_variable_values(exo, time_step, id, var_name_index, var_value, type)
end

"""
"""
function write_variable_values(
  exo::ExodusDatabase, 
  time_step::Integer, var_name::String, set_name::String, 
  var_value::Vector{<:AbstractFloat},
  type::ex_entity_type
)
  var_name_index = findall(x -> x == var_name, read_variable_names(exo, type))
  if length(var_name_index) > 1
    throw(ErrorException("This should never happen"))
  end
  var_name_index = var_name_index[1]
  set_name_index = findall(x -> x == set_name, read_set_names(exo, type))
  if length(set_name_index) > 1
    throw(ErrorException("This should never happen"))
  end
  set_name_index = set_name_index[1]
  write_variable_values(exo, time_step, var_name_index, set_name_index, var_value, type)
end

"""
"""
write_element_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_index::Integer, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, id, var_index, var_values, EX_ELEM_BLOCK)

"""
"""
write_element_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_name::String, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, id, var_name, var_values, EX_ELEM_BLOCK)

"""
"""
write_global_variable_values(exo::ExodusDatabase, timestep::Integer, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, 1, 1, var_values, EX_GLOBAL)

"""
"""
write_nodal_variable_values(exo::ExodusDatabase, timestep::Integer, var_index::Integer, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, 1, var_index, var_values, EX_NODAL)

"""
"""
write_nodal_variable_values(exo::ExodusDatabase, timestep::Integer, var_name::String, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, 1, var_name, var_values, EX_NODAL)

"""
"""
write_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_index::Integer, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, id, var_index, var_values, EX_NODE_SET)

"""
"""
write_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_name::String, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, id, var_name, var_values, EX_NODE_SET)

"""
"""
write_node_set_variable_values(exo::ExodusDatabase, timestep::Integer, set_name::String, var_name::String, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, set_name, var_name, var_values, EX_NODE_SET)

"""
"""
write_side_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_index::Integer, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, id, var_index, var_values, EX_SIDE_SET)

"""
"""
write_side_set_variable_values(exo::ExodusDatabase, timestep::Integer, id::Integer, var_name::String, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, id, var_name, var_values, EX_SIDE_SET)

"""
"""
write_side_set_variable_values(exo::ExodusDatabase, timestep::Integer, set_name::String, var_name::String, var_values::Vector{<:AbstractFloat}) = 
write_variable_values(exo, timestep, set_name, var_name, var_values, EX_SIDE_SET)


# local exports
export read_element_variable_name
export read_element_variable_names
export read_element_variable_values
export read_global_variable_name
export read_global_variable_names
export read_global_variable_values
export read_nodal_variable_name
export read_nodal_variable_names
export read_nodal_variable_values
export read_node_set_variable_name
export read_node_set_variable_names
export read_node_set_variable_values
export read_number_of_element_variables
export read_number_of_global_variables
export read_number_of_nodal_variables
export read_number_of_node_set_variables
export read_number_of_side_set_variables
export read_partial_nodal_variable_values
export read_side_set_variable_name
export read_side_set_variable_names
export read_side_set_variable_values
export write_element_variable_name
export write_element_variable_names
export write_element_variable_values
export write_global_variable_name
export write_global_variable_names
export write_global_variable_values
export write_nodal_variable_name
export write_nodal_variable_names
export write_nodal_variable_values
export write_node_set_variable_name
export write_node_set_variable_names
export write_node_set_variable_values
export write_number_of_element_variables
export write_number_of_global_variables
export write_number_of_nodal_variables
export write_number_of_node_set_variables
export write_number_of_side_set_variables
export write_side_set_variable_name
export write_side_set_variable_names
export write_side_set_variable_values
