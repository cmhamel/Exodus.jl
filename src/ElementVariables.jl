"""
"""
function read_number_of_element_variables(exo::ExodusDatabase)
  num_vars = Ref{Cint}(0) # TODO check to make sure this is right
  ex_get_variable_param!(exo.exo, EX_ELEM_BLOCK, num_vars)
  return num_vars[]
end


function read_element_variable_names!(
  exo::ExodusDatabase, num_vars::Cint, 
  var_name::Vector{UInt8}, var_names::Vector{String}
)
  for n = 1:num_vars
    ex_get_variable_name!(exo.exo, EX_ELEM_BLOCK, convert(Cint, n), var_name)
    var_names[n] = unsafe_string(pointer(var_name))
  end
end

"""
"""
function read_element_variable_name(exo::ExodusDatabase, var_index::Integer)
  var_index = convert(Cint, var_index)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  ex_get_variable_name!(exo.exo, EX_ELEM_BLOCK, var_index, var_name)
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_element_variable_names(exo::ExodusDatabase)
  num_vars = read_number_of_element_variables(exo)
  var_names = Vector{String}(undef, num_vars)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  read_element_variable_names!(exo, num_vars, var_name, var_names)
  return var_names
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
  values = Vector{exo.F}(undef, num_elem)
  ex_get_var!(exo.exo, convert(Cint, time_step), EX_ELEM_BLOCK, 
              convert(Cint, variable_index), block_id, convert(Clonglong, num_elem), values)
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
  ex_put_variable_param!(exo.exo, EX_ELEM_BLOCK, num_vars)
end

"""
"""
function write_element_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String)
  var_index = convert(exo.I, var_index)
  temp = Vector{UInt8}(var_name)
  ex_put_variable_name!(exo.exo, EX_ELEM_BLOCK, var_index, temp)
end

"""
"""
function write_element_variable_names(exo::ExodusDatabase, var_indices::Vector{<:Integer}, var_names::Vector{String})
  var_indices = convert.((exo.I,), var_indices)
  if size(var_indices, 1) != size(var_names, 1)
    AssertionError("Indices and Names need to be the same length")
  end

  for n in axes(var_indices, 1)
    temp = Vector{UInt8}(var_names[n])
    ex_put_variable_name!(exo.exo, EX_ELEM_BLOCK, var_indices[n], temp)
  end
end

"""
"""
function write_element_variable_values(
  exo::ExodusDatabase, 
  time_step::Integer, 
  block_id::Integer,
  var_index::Integer, 
  var_values::Vector{<:Real}
)
  num_elements = size(var_values, 1)
  ex_put_var!(exo.exo, convert(Cint, time_step), EX_ELEM_BLOCK, 
              convert(Cint, var_index), block_id, 
              convert(Clonglong, num_elements), var_values)
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
