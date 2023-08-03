"""
"""
# function read_number_of_variables(exo::ExodusDatabase, type::ex_entity_type)
function read_number_of_variables(exo::ExodusDatabase, ::Type{V}) where V <: AbstractVariable
  num_vars = Ref{Cint}(0)
  error_code = @ccall libexodus.ex_get_variable_param(
    # get_file_id(exo)::Cint, type::ex_entity_type, num_vars::Ptr{Cint}
    get_file_id(exo)::Cint, entity_type(V)::ex_entity_type, num_vars::Ptr{Cint}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_number_of_variables -> libexodus.ex_get_variable_param")
  return num_vars[]
end

"""
"""
# function read_variable_name(exo::ExodusDatabase, var_index::Integer, type::ex_entity_type)
function read_name(exo::ExodusDatabase, ::Type{V}, var_index::Integer) where V <: AbstractVariable
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_variable_name(
    get_file_id(exo)::Cint, entity_type(V)::ex_entity_type, var_index::Cint, var_name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_variable_name -> libexodus.ex_get_variable_name")
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_names(exo::ExodusDatabase, ::Type{V}) where V <: AbstractVariable
  num_vars = read_number_of_variables(exo, V)
  var_names = Vector{Vector{UInt8}}(undef, num_vars)
  for n in 1:length(var_names)
    var_names[n] = Vector{UInt8}(undef, MAX_STR_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_variable_names(
    get_file_id(exo)::Cint, entity_type(V)::ex_entity_type, num_vars::Cint, var_names::Ptr{Ptr{UInt8}}
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
function read_values(
  exo::ExodusDatabase{M, I, B, F}, ::Type{V},
  timestep::Integer, id::Integer, var_index::Integer, 
) where {M, I, B, F, V <: AbstractVariable}

  if V <: Nodal
    num_entries = exo.init.num_nodes
  elseif V <: Element
    _, num_entries, _, _, _, _ =
    read_block_parameters(exo, id)
  elseif V <: Global
    num_entries = read_number_of_variables(exo, V)
  elseif V <: NodeSetVariable || V <: SideSetVariable
    num_entries, _ = read_set_parameters(exo, id, set_equivalent(V))
  else
    throw(ErrorException("Unsuported variable type $V"))
  end

  values = Vector{F}(undef, num_entries)
  error_code = @ccall libexodus.ex_get_var(
    get_file_id(exo)::Cint, timestep::Cint, entity_type(V)::ex_entity_type,
    var_index::Cint, id::ex_entity_id, num_entries::Clonglong, values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_nodal_variable_values -> libexodus.ex_get_var")
  return values
end

"""
"""
function read_values(exo::ExodusDatabase, ::Type{V}, time_step::Integer, id::Integer, var_name::String) where V <: AbstractVariable
  var_name_index = findall(x -> x == var_name, read_names(exo, V))
  if length(var_name_index) < 1
    throw(BoundsError(read_names(exo, V), var_name_index))
  end
  var_name_index = var_name_index[1]
  read_values(exo, V, time_step, id, var_name_index)
end

"""
"""
function read_values(exo::ExodusDatabase, ::Type{V}, time_step::Integer, var_name::String, nset_name::String) where V <: AbstractVariable
  var_name_index = findall(x -> x == var_name, read_names(exo, Vs))
  if length(var_name_index) < 1
    throw(BoundsError(read_names(exo, V), var_name_index))
  end
  var_name_index = var_name_index[1]
  set_name_index = findall(x -> x == nset_name, read_names(exo, V))
  if length(set_name_index) < 1
    throw(BoundsError(read_names(exo, type), var_name_index))
  end
  set_name_index = set_name_index[1]
  read_values(exo, V, ime_step, var_name_index, set_name_index)
end

"""
"""
function read_partial_values(
  exo::ExodusDatabase{M, I, B, F}, 
  ::Type{V},
  time_step::Integer, id::Integer, var_index::Integer, 
  start_node::Integer, num_nodes::Integer, 
) where {M, I, B, F, V <: AbstractVariable}

  values = Vector{F}(undef, num_nodes)
  error_code = @ccall libexodus.ex_get_partial_var(
    get_file_id(exo)::Cint, time_step::Cint, entity_type(V)::ex_entity_type, 
    var_index::Cint, id::Cint, 
    start_node::Clonglong, num_nodes::Clonglong,
    values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_partial_nodal_variable_values -> libexodus.ex_get_partial_var")
  return values
end

"""
"""
function read_partial_values(
  exo::ExodusDatabase, 
  ::Type{V},
  time_step::Integer, id::Integer, var_name::String, 
  start_node::Integer, num_nodes::Integer,
) where V <: AbstractVariable
  var_name_index = findall(x -> x == var_name, read_names(exo, V))
  if length(var_name_index) < 1
    throw(BoundsError(read_names(exo, V), var_name_index))
  end
  var_name_index = var_name_index[1]
  read_partial_values(exo, V, time_step, id, var_name_index, start_node, num_nodes)
end

"""
"""
function write_number_of_variables(exo::ExodusDatabase, ::Type{V}, num_vars::Integer) where V <: AbstractVariable
  error_code = @ccall libexodus.ex_put_variable_param(
    get_file_id(exo)::Cint, entity_type(V)::ex_entity_type, num_vars::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.write_number_of_variables -> libexodus.ex_put_variable_param")
end

"""
"""
function write_name(exo::ExodusDatabase, ::Type{V}, var_index::Integer, var_name::String) where V <: AbstractVariable
  temp = Vector{UInt8}(var_name)
  error_code = @ccall libexodus.ex_put_variable_name(
    get_file_id(exo)::Cint, entity_type(V)::ex_entity_type, var_index::Cint, temp::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_variable_name -> libexodus.ex_put_variable_name")
end

"""
"""
function write_names(exo::ExodusDatabase, ::Type{V}, var_names::Vector{String}) where V <: AbstractVariable
  error_code = @ccall libexodus.ex_put_variable_names(
    get_file_id(exo)::Cint, entity_type(V)::ex_entity_type, length(var_names)::Cint,
    var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_variable_names -> libexodus.ex_put_variable_names")
end

"""
"""
function write_values(
  exo::ExodusDatabase, 
  ::Type{V},
  timestep::Integer, id::Integer, var_index::Integer, 
  var_values::Vector{<:AbstractFloat},
) where V <: AbstractVariable

  num_nodes = size(var_values, 1)
  error_code = @ccall libexodus.ex_put_var(
    get_file_id(exo)::Cint, timestep::Cint, entity_type(V)::ex_entity_type,
    var_index::Cint, id::ex_entity_id,
    num_nodes::Clonglong, var_values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_variable_values -> libexodus.ex_put_var")
end

"""
"""
function write_values(
  exo::ExodusDatabase, 
  ::Type{V},
  time_step::Integer, id::Integer, var_name::String, 
  var_value::Vector{<:AbstractFloat}
) where V <: AbstractVariable

var_name_index = findall(x -> x == var_name, read_names(exo, V))
  if length(var_name_index) < 1
    throw(BoundsError(read_names(exo, V), var_name_index))
  end
  var_name_index = var_name_index[1]
  write_values(exo, V, time_step, id, var_name_index, var_value)
end

"""
"""
function write_values(
  exo::ExodusDatabase, 
  ::Type{V},
  time_step::Integer, var_name::String, set_name::String, 
  var_value::Vector{<:AbstractFloat}
) where V <: AbstractVariable

  var_name_index = findall(x -> x == var_name, read_names(exo, V))
  if length(var_name_index) < 1
    throw(BoundsError(read_names(exo, V), var_name_index))
  end
  var_name_index = var_name_index[1]
  set_name_index = findall(x -> x == set_name, read_names(exo, set_equivalent(V)))
  if length(set_name_index) < 1
    throw(BoundsError(read_names(exo, set_equivalent(V)), set_name_index))
  end
  set_name_index = set_name_index[1]
  write_values(exo, V, time_step, var_name_index, set_name_index, var_value)
end
