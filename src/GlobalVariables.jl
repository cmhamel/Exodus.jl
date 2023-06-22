"""
"""
function read_number_of_global_variables(exo::ExodusDatabase)
  num_vars = Ref{Cint}(0) # TODO check to make sure this is right
  ex_get_variable_param!(get_file_id(exo), EX_GLOBAL, num_vars)
  return num_vars[]
end

"""
"""
function read_global_variable_names!(
  exo::ExodusDatabase, num_vars::Cint,
  var_name::Vector{UInt8}, var_names::Vector{String}
)
  for n = 1:num_vars
    ex_get_variable_name!(get_file_id(exo), EX_GLOBAL, convert(Cint, n), var_name)
    var_names[n] = unsafe_string(pointer(var_name))
  end
end

"""
"""
function read_global_variable_name(exo::ExodusDatabase, var_index::Integer)
  var_index = convert(Cint, var_index)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  ex_get_variable_name!(get_file_id(exo), EX_GLOBAL, var_index, var_name)
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_global_variable_names(exo::ExodusDatabase)
  num_vars = read_number_of_global_variables(exo)
  var_names = Vector{String}(undef, num_vars)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  read_global_variable_names!(exo, num_vars, var_name, var_names)
  return var_names
end

"""
"""
function read_global_variable_values(
  exo::ExodusDatabase, timestep::Integer, num_vars::Integer
)
  values = Vector{get_float_type(exo)}(undef, num_vars)
  ex_get_var!(get_file_id(exo), convert(Cint, timestep), EX_GLOBAL, 
              Int32(1), 1, 
              num_vars, values)
  return values
end

"""
"""
function write_number_of_global_variables(exo::ExodusDatabase, num_vars)
  ex_put_variable_param!(get_file_id(exo), EX_GLOBAL, num_vars)
end

"""
"""
function write_global_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String)
  var_index = convert(get_id_int_type(exo), var_index)
  temp = Vector{UInt8}(var_name)
  ex_put_variable_name!(get_file_id(exo), EX_GLOBAL, convert(Cint, var_index), temp)
end

"""
"""
function write_global_variable_names(exo::ExodusDatabase, var_indices::Vector{<:Integer}, var_names::Vector{String})
  if size(var_indices, 1) != size(var_names, 1)
    AssertionError("Indices and Names need to be the same length")
  end

  for n in axes(var_indices, 1)
    temp = Vector{UInt8}(var_names[n])
    ex_put_variable_name!(get_file_id(exo), EX_GLOBAL, convert(Cint, var_indices[n]), temp)
  end
end

"""
"""
function write_global_variable_values(
  exo::ExodusDatabase, timestep::Integer, num_vars::Integer, var_values::Vector{<:Real}
)
  ex_put_var!(get_file_id(exo), convert(Cint, timestep), 
              EX_GLOBAL, Int32(1), 1, 
              num_vars, var_values)
end

# local exports
export read_global_variable_name
export read_global_variable_names
export read_global_variable_values
export read_number_of_global_variables
export write_global_variable_name
export write_global_variable_names
export write_global_variable_values
export write_number_of_global_variables

