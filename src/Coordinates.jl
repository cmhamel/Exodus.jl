function ex_get_coord_internal!(exoid::Cint, # TODO need to figure out typing when null is passed for x y or z
                x_coords, y_coords, z_coords)
  error_code = ccall((:ex_get_coord, libexodus), Cint,
             (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
            exoid, x_coords, y_coords, z_coords)
  exodus_error_check(error_code, "ex_get_coord!")
end
"""
ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}) where {T <: ExoFloat}
"""
ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}) where {T <: Real} =
ex_get_coord_internal!(exoid, x_coords, y_coords, z_coords)
"""
ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Vector{T}, z_coords::Ptr{Cvoid}) where {T <: ExoFloat}
"""
ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Vector{T}, z_coords::Ptr{Cvoid}) where {T <: Real} =
ex_get_coord_internal!(exoid, x_coords, y_coords, z_coords)
"""
ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Vector{T}, z_coords::Vector{T}) where {T <: ExoFloat}
"""
ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Vector{T}, z_coords::Vector{T}) where {T <: Real} =
ex_get_coord_internal!(exoid, x_coords, y_coords, z_coords)

"""
ex_get_coord_names!(exo_id::Cint, coord_names::Vector{Vector{UInt8}})
"""
function ex_get_coord_names!(exo_id::Cint, coord_names::Vector{Vector{UInt8}})

  error_code = ccall((:ex_get_coord_names, libexodus), Cint,
             (Cint, Ptr{Ptr{UInt8}}),
            exo_id, coord_names)
  exodus_error_check(error_code, "ex_get_coord_names!")
end


"""
  read_coordinates(exo::ExodusDatabase{M, I, B, F})
Method to read coordinates. Returns a matrix that is n_nodes x n_dim.

TODO... This method should really return n_dim x n_nodes but there's
TODO... issues encountered downstream with some views found in Tardigrade
"""
function read_coordinates(exo::ExodusDatabase{M, I, B, F}) where {M <: Integer, I <: Integer,
                                                                  B <: Integer, F <: Real}
  if exo.init.num_dim == 1
    x_coords = Array{F}(undef, exo.init.num_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
  elseif exo.init.num_dim == 2
    x_coords = Array{F}(undef, exo.init.num_nodes)
    y_coords = Array{F}(undef, exo.init.num_nodes)
    z_coords = C_NULL
  elseif exo.init.num_dim == 3
    x_coords = Array{F}(undef, exo.init.num_nodes)
    y_coords = Array{F}(undef, exo.init.num_nodes)
    z_coords = Array{F}(undef, exo.init.num_nodes)
  end
  # calling exodus method
  ex_get_coord!(exo.exo, x_coords, y_coords, z_coords)
  if exo.init.num_dim == 1
    error("One dimension isn't really supported and exodusII is likely overkill")
  elseif exo.init.num_dim == 2
    coords = collect(hcat(x_coords, y_coords)')
  elseif exo.init.num_dim == 3
    coords = collect(hcat(x_coords, y_coords, z_coords)')
  else
    error("Should never get here")
  end
  return coords
end

"""
  read_coordinate_names(exo::ExodusDatabase)
"""
function read_coordinate_names(exo::E) where {E <: ExodusDatabase}
  coord_names = Vector{Vector{UInt8}}(undef, exo.init.num_dim)
  for n in 1:exo.init.num_dim
    coord_names[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  end
  ex_get_coord_names!(exo.exo, coord_names)
  new_coord_names = Vector{String}(undef, exo.init.num_dim)
  for n in 1:exo.init.num_dim
    new_coord_names[n] = unsafe_string(pointer(coord_names[n]))
  end
  return new_coord_names
end

"""
  ex_put_coord!(exoid::Cint, x_coords, y_coords, z_coords)
NOT THAT WELL TESTED
"""
function ex_put_coord!(exoid::Cint, # input not to be changed
             x_coords, y_coords, z_coords)
  error_code = ccall(
    (:ex_put_coord, libexodus), Cint,
    (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
    exoid, x_coords, y_coords, z_coords
  )
  exodus_error_check(error_code, "ex_put_coord!")
end

"""
  ex_put_coord_names!(exoid::Cint, coord_names::Vector{Vector{UInt8}})
"""
function ex_put_coord_names!(exoid::Cint, coord_names::Vector{Vector{UInt8}})
  error_code = ccall(
    (:ex_put_coord_names, libexodus), Cint,
    (Cint, Ptr{Ptr{UInt8}}),
    exoid, coord_names
  )
  exodus_error_check(error_code, "ex_put_coord_names!")
end


"""
  put_coordinates(exo::ExodusDatabase, coords::Matrix)
Work in progress... not that well tested
"""
function write_coordinates(exo::ExodusDatabase{M, I, B, F}, 
                           coords::Matrix{F}) where {M <: Integer, I <: Integer,
                                                     B <: Integer, F <: Real}
  # NOTE THIS ASSUMES SOMETHING ABOUT COORDS ORDERING IN LESS THEN 3D

  if size(coords, 1) == 1
    x_coords = coords[1, :]
    y_coords = C_NULL
    z_coords = C_NULL
  elseif size(coords, 1) == 2
    # 2D case
    x_coords = coords[1, :]
    y_coords = coords[2, :]
    z_coords = C_NULL
  elseif size(coords, 1) == 3
    # 3D case
    x_coords = coords[1, :]
    y_coords = coords[2, :]
    z_coords = coords[3, :]
  else
    error("This should never happen!")
  end
  ex_put_coord!(exo.exo, x_coords, y_coords, z_coords)
end

# TODO we can likely remove some allocations
"""
  write_coordinate_names(exo::ExodusDatabase, coord_names::Vector{String})
Work in progress...
"""
function write_coordinate_names(exo::ExodusDatabase, coord_names::Vector{String})
  new_coord_names = Vector{Vector{UInt8}}(undef, length(coord_names))
  for (n, coord_name) in enumerate(coord_names)
    new_coord_names[n] = Vector{UInt8}(coord_name)
  end
  ex_put_coord_names!(exo.exo, new_coord_names)
end

# local exports
export read_coordinates
export read_coordinate_names
export write_coordinates
export write_coordinate_names
