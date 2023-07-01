"""
"""
function read_number_of_element_variables(exo::ExodusDatabase)
  num_vars = Ref{Cint}(0) # TODO check to make sure this is right
  error_code = @ccall libexodus.ex_get_variable_param(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, num_vars::Ptr{Cint} 
  )::Cint
  exodus_error_check(error_code, "Exodus.read_number_of_element_variables -> Exodus.ex_get_variable_param")
  return num_vars[]
end

"""
"""
function read_element_variable_name(exo::ExodusDatabase, var_index::Integer)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_variable_name(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, var_index::Cint, var_name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_variable_name -> libexodus.ex_get_variable_name")
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_element_variable_names(exo::ExodusDatabase)
  num_vars = read_number_of_element_variables(exo)
  var_names = Vector{Vector{UInt8}}(undef, num_vars)
  for n in 1:length(var_names)
    var_names[n] = Vector{UInt8}(undef, MAX_STR_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_variable_names(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, num_vars::Cint, var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_variable_names -> libexodus.ex_get_names")

  new_var_names = Vector{String}(undef, num_vars)
  for n in 1:length(var_names)
    new_var_names[n] = unsafe_string(pointer(var_names[n]))
  end
  return new_var_names
end

"""
"""
function read_element_variable_values(
  exo::ExodusDatabase, 
  time_step, 
  block_id::Integer,
  variable_index::Integer
)
  _, num_elem, _, _, _, _ = read_element_block_parameters(exo, block_id)
  values = Vector{get_float_type(exo)}(undef, num_elem)
  error_code = @ccall libexodus.ex_get_var(
    get_file_id(exo)::Cint, time_step::Cint, EX_ELEM_BLOCK::ex_entity_type,
    variable_index::Cint, block_id::ex_entity_id, num_elem::Clonglong, values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_variable_values -> libexodus.ex_get_var")
  return values
end

"""
"""
function read_element_variable_values(
  exo::ExodusDatabase, 
  time_step, 
  block_id::Integer,
  var_name::String
)
  var_name_index = findall(x -> x == var_name, read_element_variable_names(exo))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  read_element_variable_values(exo, time_step, block_id, var_name_index)
end

"""
"""
function write_number_of_element_variables(exo::ExodusDatabase, num_vars::Integer)
  error_code = @ccall libexodus.ex_put_variable_param(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, num_vars::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.write_number_of_element_variables -> libexodus.ex_put_variable_param")
end

"""
"""
function write_element_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String)
  temp = Vector{UInt8}(var_name)
  error_code = @ccall libexodus.ex_put_variable_name(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, var_index::Cint, temp::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_variable_name -> libexodus.ex_put_variable_name")
end

"""
"""
function write_element_variable_names(exo::ExodusDatabase, var_names::Vector{String})
  error_code = @ccall libexodus.ex_put_variable_names(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, length(var_names)::Cint,
    var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_variable_names -> libexodus.ex_put_variable_names")
end

"""
"""
function write_element_variable_values(
  exo::ExodusDatabase, 
  timestep::Integer, 
  block_id::Integer,
  var_index::Integer, 
  var_values::Vector{<:Real}
)
  num_elements = size(var_values, 1)
  error_code = @ccall libexodus.ex_put_var(
    get_file_id(exo)::Cint, timestep::Cint, EX_ELEM_BLOCK::ex_entity_type,
    var_index::Cint, block_id::ex_entity_id,
    num_elements::Clonglong, var_values::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_variable_values -> libexodus.ex_put_var")
end

"""
"""
function write_element_variable_values(
  exo::ExodusDatabase, 
  time_step::Integer, 
  block_id::Integer,
  var_name::String, 
  var_values::Vector{<:Real}
)
  var_name_index = findall(x -> x == var_name, read_element_variable_names(exo))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  write_element_variable_values(exo, convert(Cint, time_step), block_id, convert(Cint, var_name_index), var_values)
end

# local exports
export read_element_variable_name
export read_element_variable_names
export read_element_variable_values
export read_number_of_element_variables
export write_element_variable_name
export write_element_variable_names
export write_element_variable_values
export write_number_of_element_variables
