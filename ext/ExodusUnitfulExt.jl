module ExodusUnitfulExt

using DocStringExtensions
using Exodus
using Unitful

# write methods below

const Frequency = Unitful.FreeUnits{S, Unitful.𝐓^-1, nothing} where S
const Length = Unitful.FreeUnits{S, Unitful.𝐋, nothing} where S
const Time = Unitful.FreeUnits{S, Unitful.𝐓, nothing} where S

const ExoTime = Union{<:Frequency, <:Time}

"""
$(SIGNATURES)
"""
function Exodus.read_coordinates(exo::ExodusDatabase, unit::Length)
  return read_coordinates(exo)unit
end

"""
$(TYPEDSIGNATURES)
"""
function Exodus.read_times(exo::ExodusDatabase, unit::ExoTime)
  return read_times(exo)unit
end

"""
$(TYPEDSIGNATURES)
"""
function Exodus.write_time(exo::ExodusDatabase, step::Int, time::Q) where Q <: Quantity
  return write_time(exo, step, ustrip(time))
end

"""
$(TYPEDSIGNATURES)
"""
function Exodus.read_values(
  exo::ExodusDatabase, type::Type{V}, 
  timestep::Integer, id::Integer, var_index::Integer,
  unit::U
) where {V <: Exodus.AbstractExodusVariable, U <: Unitful.FreeUnits}

  return read_values(exo, type, timestep, id, var_index)unit
end

"""
$(TYPEDSIGNATURES)
Wrapper method for global variables around the main read_values method
read_values(exo::ExodusDatabase, t::Type{GlobalVariable}, timestep::Integer) = read_values(exo, t, timestep, 1, 1)

Example:
read_values(exo, GlobalVariable, 1)
"""
Exodus.read_values(exo::ExodusDatabase, t::Type{GlobalVariable}, timestep::Integer, unit::U) where U <: Unitful.FreeUnits = 
read_values(exo, t, timestep, 1, 1)unit

"""
Wrapper method for nodal variables
"""
Exodus.read_values(exo::ExodusDatabase, t::Type{NodalVariable}, timestep::Integer, index::Integer, unit::U) where U <: Unitful.FreeUnits = 
read_values(exo, t, timestep, 1, index)unit

"""
$(TYPEDSIGNATURES)
"""
function Exodus.read_values(
  exo::ExodusDatabase, ::Type{V}, 
  time_step::Integer, id::Integer, var_name::String, unit::U
) where {V <: Union{ElementVariable, NodalVariable, NodeSetVariable, SideSetVariable}, U <: Unitful.FreeUnits} 

  return read_values(exo, V, time_step, id, Exodus.var_name_index(exo, V, var_name))unit
end

"""
$(TYPEDSIGNATURES)
Wrapper method for nodal variables
"""
Exodus.read_values(exo::ExodusDatabase, t::Type{NodalVariable}, timestep::Integer, name::String, unit::U) where U <: Unitful.FreeUnits = 
read_values(exo, t, timestep, 1, name)unit

"""
$(TYPEDSIGNATURES)
"""
function Exodus.read_values(
  exo::ExodusDatabase, ::Type{V}, 
  time_step::Integer, set_name::String, var_name::String,
  unit::U
) where {V <: Union{ElementVariable, NodeSetVariable, SideSetVariable}, U <: Unitful.FreeUnits}

  read_values(exo, V, time_step, 
              Exodus.set_name_index(exo, Exodus.set_equivalent(V), set_name), 
              Exodus.var_name_index(exo, V, var_name))unit
end

"""
$(TYPEDSIGNATURES)
"""
function Exodus.write_values(
  exo::ExodusDatabase, 
  type::Type{V},
  timestep::Integer, id::Integer, var_index::Integer, 
  var_values::Vector{<:Quantity},
) where V <: Exodus.AbstractExodusVariable

  write_values(exo, type, timestep, id, var_index, ustrip(var_values) |> collect)
end

"""
$(TYPEDSIGNATURES)
Wrapper method for global variables around the main write_values method
write_values(
  exo::ExodusDatabase, t::Type{GlobalVariable}, 
  timestep::Integer, var_values::Vector{<:AbstractFloat}
) = write_values(exo, t, timestep, 1, 1, var_values)

Note: you need to first run
write_number_of_variables(exo, GlobalVariable, n)
where n is the number of variables.

Example:
write_number_of_variables(exo, GlobalVariable, 5)
write_values(exo, GlobalVariable, 1, [10.0, 20.0, 30.0, 40.0, 50.0])
"""
Exodus.write_values(
  exo::ExodusDatabase, t::Type{GlobalVariable}, 
  timestep::Integer, var_values::Vector{<:Quantity}
) = write_values(exo, t, timestep, 1, 1, ustrip(var_values) |> collect)

"""
Wrapper for writing nodal variables by index number
"""
Exodus.write_values(
  exo::ExodusDatabase, t::Type{NodalVariable}, 
  timestep::Integer, var_index::Integer,
  var_values::Vector{<:Quantity}
) = write_values(exo, t, timestep, 1, var_index, ustrip(var_values) |> collect)

"""
$(TYPEDSIGNATURES)
"""
function Exodus.write_values(
  exo::ExodusDatabase, 
  ::Type{V},
  timestep::Integer, id::Integer, var_name::String, 
  var_value::Vector{<:Quantity}
) where V <: Exodus.AbstractExodusVariable

  write_values(exo, V, timestep, id, Exodus.var_name_index(exo, V, var_name), ustrip(var_value) |> collect)
end

"""
$(TYPEDSIGNATURES)
Wrapper method for nodal variables
"""
Exodus.write_values(
  exo::ExodusDatabase, t::Type{NodalVariable},
  timestep::Integer, var_name::String,
  var_values::Vector{<:Quantity}
) = write_values(exo, t, timestep, 1, Exodus.var_name_index(exo, t, var_name), ustrip(var_values) |> collect)

"""
$(TYPEDSIGNATURES)
"""
function Exodus.write_values(
  exo::ExodusDatabase, 
  ::Type{V},
  time_step::Integer, set_name::String, var_name::String,
  var_value::Vector{<:Quantity}
) where V <: Exodus.AbstractExodusVariable

  write_values(exo, V, time_step, 
               Exodus.set_name_index(exo, Exodus.set_equivalent(V), set_name), 
               Exodus.var_name_index(exo, V, var_name), 
               ustrip(var_value) |> collect)
end

end # module
