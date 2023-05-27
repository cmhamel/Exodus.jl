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
    ex_get_variable_name!(exo.exo, EX_NODAL, n, var_name)
    var_names[n] = unsafe_string(pointer(var_name))
  end
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
function read_nodal_variable_values(exo::ExodusDatabase, time_step, variable_index)
  values = Vector{exo.F}(undef, exo.init.num_nodes)
  # TODO figure out what the 1 in the call is really doing for nodal values
  # TODO for element variables that should be associated with a block number or soemthing like that
  ex_get_var!(exo.exo, time_step, EX_NODAL, variable_index, 1, exo.init.num_nodes, values)
  return values
end

# TODO fix these
"""
"""
function write_number_of_nodal_variables(exo::ExodusDatabase, num_vars)
  ex_put_variable_param!(exo.exo, EX_NODAL, num_vars)
end

# TODO check types everywhere in this file
"""
"""
function write_nodal_variable_names(exo::ExodusDatabase, var_indices::Vector{<:Integer}, var_names::Vector{String})
  var_indices = convert.((exo.I,), var_indices)
  if size(var_indices, 1) != size(var_names, 1)
    AssertionError("Indices and Names need to be the same length")
  end

  for n in axes(var_indices, 1)
    temp = Vector{UInt8}(var_names[n])
    ex_put_variable_name!(exo.exo, EX_NODAL, var_indices[n], temp)
  end
end

"""
"""
function write_nodal_variable_values(exo::ExodusDatabase, time_step, 
                                     var_index, var_values::Vector{Float64})
  num_nodes = size(var_values, 1)
  ex_put_var!(exo.exo, time_step, EX_NODAL, var_index, 1, num_nodes, var_values)
end

# local exports
export read_number_of_nodal_variables
export read_nodal_variable_names
export read_nodal_variable_values
export write_number_of_nodal_variables
export write_nodal_variable_names
