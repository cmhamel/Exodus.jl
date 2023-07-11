"""
Method to read coordinates. 
Returns a matrix that is n_dim x n_nodes.
"""
function read_coordinates(exo::ExodusDatabase)
  num_nodes = get_num_nodes(exo)
  float_type = get_float_type(exo)

  coords = Matrix{float_type}(undef, get_init(exo).num_dim, num_nodes)

  if get_num_dim(exo) == 1
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_coord(exo.exo::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid})::Cint
    exodus_error_check(error_code, "Exodus.read_coordinates -> libexodus.ex_get_coord")
    coords[1, :] = x_coords
  elseif get_num_dim(exo) == 2
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = Array{float_type}(undef, num_nodes)
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_coord(exo.exo::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid})::Cint
    exodus_error_check(error_code, "Exodus.read_coordinates -> libexodus.ex_get_coord")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
  elseif get_num_dim(exo) == 3
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = Array{float_type}(undef, num_nodes)
    z_coords = Array{float_type}(undef, num_nodes)
    error_code = @ccall libexodus.ex_get_coord(exo.exo::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid})::Cint
    exodus_error_check(error_code, "Exodus.read_coordinates -> libexodus.ex_get_coord")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
    coords[3, :] = z_coords
  end
  return coords
end

"""
Method to read a partial set of coordinates that are contiguous. 
Returns a matrix that is n_dim x n_nodes
"""
function read_partial_coordinates(exo::ExodusDatabase, start_node_num::I, num_nodes::I) where I <: Integer
  num_dim = get_init(exo).num_dim
  float_type = get_float_type(exo)
  coords = Matrix{float_type}(undef, num_dim, num_nodes)
  start_node_num = convert(Clonglong, start_node_num)
  num_nodes      = convert(Clonglong, num_nodes)
  if num_dim == 1
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_partial_coord(
      get_file_id(exo)::Cint, start_node_num::Clonglong, num_nodes::Clonglong,
      x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
    )::Cint
    exodus_error_check(error_code, "Exodus.read_partial_coordinates -> libexodus.read_partial_coordinates")
    coords[1, :] = x_coords
  elseif num_dim == 2
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = Array{float_type}(undef, num_nodes)
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_partial_coord(
      get_file_id(exo)::Cint, start_node_num::Clonglong, num_nodes::Clonglong,
      x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
    )::Cint
    exodus_error_check(error_code, "Exodus.read_partial_coordinates -> libexodus.read_partial_coordinates")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
  elseif num_dim == 3
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = Array{float_type}(undef, num_nodes)
    z_coords = Array{float_type}(undef, num_nodes)
    error_code = @ccall libexodus.ex_get_partial_coord(
      get_file_id(exo)::Cint, start_node_num::Clonglong, num_nodes::Clonglong,
      x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
    )::Cint
    exodus_error_check(error_code, "Exodus.read_partial_coordinates -> libexodus.read_partial_coordinates")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
    coords[3, :] = z_coords
  end
  return coords
end

"""
Method to read a specific component of a partial set of coordinates that are contiguous. 
Returns a vector of length n_nodes
"""
function read_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, num_nodes::I, component::I) where I <: Integer
  coords = Array{get_float_type(exo)}(undef, num_nodes)
  start_node_num = convert(Clonglong, start_node_num)
  num_nodes      = convert(Clonglong, num_nodes)
  component      = convert(Cint, component)
  error_code = @ccall libexodus.ex_get_partial_coord_component(
    get_file_id(exo)::Cint, start_node_num::Clonglong, num_nodes::Clonglong, component::Cint, coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_partial_coordinates_component -> libexodus.ex_get_partial_coord_component")
  return coords
end

function read_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, num_nodes::I, component::String) where I <: Integer
  if lowercase(component) == "x"
    coord_id = 1
  elseif lowercase(component) == "y"
    coord_id = 2
  elseif lowercase(component) == "z"
    coord_id = 3
  else
    throw(ErrorException("undefined coordinate component $component"))
  end
  return read_partial_coordinates_component(exo, start_node_num, num_nodes, coord_id)
end

"""
Method to read coordinates names
Returns a vector of strings
"""
function read_coordinate_names(exo::ExodusDatabase)
  num_dim = get_init(exo).num_dim
  coord_names = Vector{Vector{UInt8}}(undef, num_dim)
  for n in 1:num_dim
    coord_names[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_coord_names(get_file_id(exo)::Cint, coord_names::Ptr{Ptr{UInt8}})::Cint
  exodus_error_check(error_code, "Exodus.read_coordinate_names -> libexodus.ex_get_coord_names")
  new_coord_names = Vector{String}(undef, get_init(exo).num_dim)
  for n in 1:get_init(exo).num_dim
    new_coord_names[n] = unsafe_string(pointer(coord_names[n]))
  end
  return new_coord_names
end

"""
Method to write coordinates
"""
function write_coordinates(exo::ExodusDatabase, coords::Matrix{F}) where {F <: Real}
  if size(coords, 1) != exo.init.num_dim || size(coords, 2) != exo.init.num_nodes
    throw(ErrorException("Invalid set of coordinates (of size $(size(coords))) to write to exo = $exo"))
  end
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
  end
  error_code = @ccall libexodus.ex_put_coord(
    get_file_id(exo)::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_coordinates -> libexodus.ex_put_coord")
end

"""
Method to write coordinate names, e.g. x, y, z
"""
function write_coordinate_names(exo::ExodusDatabase, coord_names::Vector{String})
  new_coord_names = Vector{Vector{UInt8}}(undef, length(coord_names))
  for (n, coord_name) in enumerate(coord_names)
    new_coord_names[n] = Vector{UInt8}(coord_name)
  end
  error_code = @ccall libexodus.ex_put_coord_names(get_file_id(exo)::Cint, new_coord_names::Ptr{Ptr{UInt8}})::Cint
  exodus_error_check(error_code, "Exodus.write_coordinate_names -> libexodus.ex_put_coord_names")
end

"""
"""
function write_partial_coordinates(exo::ExodusDatabase, start_node_num::I, coords::Matrix{F}) where {I <: Integer, F <: Real}
  coords = convert(Matrix{get_float_type(exo)}, coords)
  if size(coords, 1) == 1
    x_coords = coords[1, :]
    y_coords = C_NULL
    z_coords = C_NULL
  elseif size(coords, 1) == 2
    x_coords = coords[1, :]
    y_coords = coords[2, :]
    z_coords = C_NULL
  elseif size(coords, 1) == 3
    x_coords = coords[1, :]
    y_coords = coords[2, :]
    z_coords = coords[3, :]
  end
  error_code = @ccall libexodus.ex_put_partial_coord(
    get_file_id(exo)::Cint, start_node_num::Clonglong, size(coords, 2)::Clonglong,
    x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_partial_coordinates -> libexodus.ex_put_partial_coord")
end

"""
"""
function write_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, component::I, coords::Vector{F}) where {I <: Integer, F <: Real}
  coords = convert(Vector{get_float_type(exo)}, coords)
  error_code = @ccall libexodus.ex_put_partial_coord_component(
    get_file_id(exo)::Cint, start_node_num::Clonglong, length(coords)::Clonglong, component::Cint,
    coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_partial_coordinates_component -> libexodus.ex_put_partial_coord_component")
end

"""
"""
function write_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, component::String, coords::Vector{F}) where {I <: Integer, F <: Real}
  if lowercase(component) == "x"
    coord_id = 1
  elseif lowercase(component) == "y"
    coord_id = 2
  elseif lowercase(component) == "z"
    coord_id = 3
  else
    throw(ErrorException("undefined coordinate component $component"))
  end
  coords = convert(Vector{get_float_type(exo)}, coords)
  write_partial_coordinates_component(exo, start_node_num, coord_id, coords)
end

# local exports
export read_coordinates
export read_coordinate_names
export read_partial_coordinates
export read_partial_coordinates_component
export write_coordinates
export write_coordinate_names
export write_partial_coordinates
export write_partial_coordinates_component
