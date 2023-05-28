"""
"""
function read_number_of_nodal_variables(exo::ExodusDatabase)
  num_vars = Ref{Cint}(0) # TODO check to make sure this is right
  ex_get_variable_param!(exo.exo, EX_NODAL, num_vars)
  return num_vars[]
end

function read_nodal_variable_names!(
  exo::ExodusDatabase, num_vars::Cint, 
  var_name::Vector{UInt8}, var_names::Vector{String}
)
  for n = 1:num_vars
    ex_get_variable_name!(exo.exo, EX_NODAL, convert(Cint, n), var_name)
    var_names[n] = unsafe_string(pointer(var_name))
  end
end

"""
"""
function read_nodal_variable_name(exo::ExodusDatabase, var_index::Integer)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  ex_get_variable_name!(exo.exo, EX_NODAL, convert(Cint, var_index), var_name)
  return unsafe_string(pointer(var_name))
end

"""
"""
function read_nodal_variable_names(exo::ExodusDatabase)
  num_vars = read_number_of_nodal_variables(exo)
  var_names = Vector{String}(undef, num_vars)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  read_nodal_variable_names!(exo, num_vars, var_name, var_names)
  return var_names
end

"""
"""
function read_nodal_variable_values(exo::ExodusDatabase, time_step, variable_index::I_1) where I_1 <: Integer
  values = Vector{exo.F}(undef, exo.init.num_nodes)
  ex_get_var!(exo.exo, convert(Cint, time_step), EX_NODAL, 
              convert(Cint, variable_index), 1, 
              convert(Clonglong, exo.init.num_nodes), values)
  return values
end

function read_nodal_variable_values(exo::ExodusDatabase, time_step, var_name::String)
  var_name_index = findall(x -> x == var_name, read_nodal_variable_names(exo))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  read_nodal_variable_values(exo, time_step, var_name_index)
end

"""
"""
function write_number_of_nodal_variables(exo::ExodusDatabase, num_vars)
  ex_put_variable_param!(exo.exo, EX_NODAL, num_vars)
end


"""
"""
function write_nodal_variable_name(exo::ExodusDatabase, var_index::Integer, var_name::String)
  temp = Vector{UInt8}(var_name)
  ex_put_variable_name!(exo.exo, EX_NODAL, var_index, temp)
end

"""
"""
function write_nodal_variable_names(exo::ExodusDatabase, var_indices::Vector{<:Integer}, var_names::Vector{String})
  if size(var_indices, 1) != size(var_names, 1)
    AssertionError("Indices and Names need to be the same length")
  end

  for n in axes(var_indices, 1)
    temp = Vector{UInt8}(var_names[n])
    ex_put_variable_name!(exo.exo, EX_NODAL, convert(Cint, var_indices[n]), temp)
  end
end

"""
"""
function write_nodal_variable_values(exo::ExodusDatabase, time_step, 
                                     var_index::Integer, var_values::Vector{<:Real}) # TODO add types
  var_index = convert(exo.I, var_index)
  num_nodes = size(var_values, 1)
  ex_put_var!(exo.exo, convert(Cint, time_step), EX_NODAL, 
              convert(Cint, var_index), 1, 
              convert(Clonglong, num_nodes), var_values)
end

"""
"""
function write_nodal_variable_values(exo::ExodusDatabase, time_step, var_name::String, var_value::Vector{<:Real})
  var_name_index = findall(x -> x == var_name, read_nodal_variable_names(exo))
  if length(var_name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  var_name_index = var_name_index[1]
  write_nodal_variable_values(exo, time_step, var_name_index, var_value)
end

# local exports
export read_number_of_nodal_variables
export read_nodal_variable_name
export read_nodal_variable_names
export read_nodal_variable_values
export write_number_of_nodal_variables
export write_nodal_variable_name
export write_nodal_variable_names
export write_nodal_variable_values
