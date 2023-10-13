module ExodusUnitfulExt

using Exodus
using Unitful

# write methods below

function Exodus.read_coordinates(exo::ExodusDatabase, unit::U) where U <: Unitful.FreeUnits
  read_coordinates(exo)unit
end

function Exodus.read_times(exo::ExodusDatabase, unit::U) where U <: Unitful.FreeUnits
  read_times(exo)unit
end

end