"""
"""
function read_number_of_element_variables(exo::E) where {E <: ExodusDatabase}
  num_vars = Ref{Cint}(0) # TODO check to make sure this is right
  ex_get_variable_param!(exo.exo, EX_ELEMENT, num_vars)
  return num_vars[]
end

function read_element_variable_names!(
  exo::E, num_vars::Cint, 
  var_name::Vector{UInt8}, var_names::Vector{String}
) where {E <: ExodusDatabase}
  for n = 1:num_vars
    ex_get_variable_name!(exo.exo, EX_ELEMENT, n, var_name)
    var_names[n] = unsafe_string(pointer(var_name))
  end
end

"""
"""
function read_element_variable_names(exo::E) where {E <: ExodusDatabase}
  num_vars = read_number_of_element_variables(exo)
  var_names = Vector{String}(undef, num_vars)
  var_name = Vector{UInt8}(undef, MAX_STR_LENGTH)
  read_element_variable_names!(exo, num_vars, var_name, var_names)
  return var_names
end

"""
"""
function read_element_variable_values(
  exo::ExodusDatabase{M, I, B, F}, 
  time_step, 
  variable_index,
  block::Block
) where {M <: Integer, I <: Integer, B <: Integer, F <: Real}
  values = Vector{F}(undef, block.num_elem)
  # TODO figure out what the 1 in the call is really doing for nodal values
  # TODO for element variables that should be associated with a block number or soemthing like that
  ex_get_var!(exo.exo, time_step, EX_ELEMENT, variable_index, block.block_id, block.num_elem, values)
  return values
end

# local exports
export read_element_variable_names
export read_element_variable_values
export read_number_of_element_variables
