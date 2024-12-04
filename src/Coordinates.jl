"""
$(TYPEDSIGNATURES)
Method to read coordinates. 
Returns a matrix that is n_dim x n_nodes.
"""
function read_coordinates(exo::ExodusDatabase)
  n_nodes = num_nodes(exo.init)
  float_type = get_float_type(exo)

  coords = Matrix{float_type}(undef, num_dimensions(exo.init), n_nodes)

  if num_dimensions(exo.init) == 1
    x_coords = Vector{float_type}(undef, n_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_coord(exo.exo::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid})::Cint
    exodus_error_check(exo, error_code, "Exodus.read_coordinates -> libexodus.ex_get_coord")
    coords[1, :] = x_coords
  elseif num_dimensions(exo.init) == 2
    x_coords = Vector{float_type}(undef, n_nodes)
    y_coords = Vector{float_type}(undef, n_nodes)
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_coord(exo.exo::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid})::Cint
    exodus_error_check(exo, error_code, "Exodus.read_coordinates -> libexodus.ex_get_coord")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
  elseif num_dimensions(exo.init) == 3
    x_coords = Vector{float_type}(undef, n_nodes)
    y_coords = Vector{float_type}(undef, n_nodes)
    z_coords = Vector{float_type}(undef, n_nodes)
    error_code = @ccall libexodus.ex_get_coord(exo.exo::Cint, x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid})::Cint
    exodus_error_check(exo, error_code, "Exodus.read_coordinates -> libexodus.ex_get_coord")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
    coords[3, :] = z_coords
  end
  return coords
end

"""
$(TYPEDSIGNATURES)
Method to read a partial set of coordinates that are contiguous. 
Returns a matrix that is n_dim x n_nodes
"""
function read_partial_coordinates(exo::ExodusDatabase, start_node_num::I, n_nodes::I) where I <: Integer
  num_dim = num_dimensions(exo.init)
  float_type = get_float_type(exo)
  coords = Matrix{float_type}(undef, num_dim, n_nodes)
  start_node_num = convert(Clonglong, start_node_num)
  n_nodes      = convert(Clonglong, n_nodes)
  if num_dim == 1
    x_coords = Vector{float_type}(undef, n_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_partial_coord(
      get_file_id(exo)::Cint, start_node_num::Clonglong, n_nodes::Clonglong,
      x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
    )::Cint
    exodus_error_check(exo, error_code, "Exodus.read_partial_coordinates -> libexodus.read_partial_coordinates")
    coords[1, :] = x_coords
  elseif num_dim == 2
    x_coords = Vector{float_type}(undef, n_nodes)
    y_coords = Vector{float_type}(undef, n_nodes)
    z_coords = C_NULL
    error_code = @ccall libexodus.ex_get_partial_coord(
      get_file_id(exo)::Cint, start_node_num::Clonglong, n_nodes::Clonglong,
      x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
    )::Cint
    exodus_error_check(exo, error_code, "Exodus.read_partial_coordinates -> libexodus.read_partial_coordinates")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
  elseif num_dim == 3
    x_coords = Vector{float_type}(undef, n_nodes)
    y_coords = Vector{float_type}(undef, n_nodes)
    z_coords = Vector{float_type}(undef, n_nodes)
    error_code = @ccall libexodus.ex_get_partial_coord(
      get_file_id(exo)::Cint, start_node_num::Clonglong, n_nodes::Clonglong,
      x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
    )::Cint
    exodus_error_check(exo, error_code, "Exodus.read_partial_coordinates -> libexodus.read_partial_coordinates")
    coords[1, :] = x_coords
    coords[2, :] = y_coords
    coords[3, :] = z_coords
  end
  return coords
end

"""
$(TYPEDSIGNATURES)
Method to read a specific component of a partial set of coordinates that are contiguous. 
Returns a vector of length n_nodes
TODO change to not use Cvoid
"""
function read_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, n_nodes::I, component::I) where I <: Integer

  coords = Vector{get_float_type(exo)}(undef, n_nodes)

  start_node_num = convert(Clonglong, start_node_num)
  n_nodes      = convert(Clonglong, n_nodes)
  component      = convert(Cint, component)
  error_code = @ccall libexodus.ex_get_partial_coord_component(
    get_file_id(exo)::Cint, start_node_num::Clonglong, n_nodes::Clonglong, component::Cint, coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.read_partial_coordinates_component -> libexodus.ex_get_partial_coord_component")
  return coords
end

"""
$(TYPEDSIGNATURES)
"""
function read_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, n_nodes::I, component::String) where I <: Integer
  if lowercase(component) == "x"
    coord_id = 1
  elseif lowercase(component) == "y"
    coord_id = 2
  elseif lowercase(component) == "z"
    coord_id = 3
  end
  return read_partial_coordinates_component(exo, start_node_num, n_nodes, coord_id)
end

"""
$(TYPEDSIGNATURES)
Method to read coordinates names
Returns a vector of strings
"""
function read_coordinate_names(exo::ExodusDatabase)
  num_dim = num_dimensions(exo.init)
  coord_names = Vector{Vector{UInt8}}(undef, num_dim)
  for n in 1:num_dim
    coord_names[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_coord_names(get_file_id(exo)::Cint, coord_names::Ptr{Ptr{UInt8}})::Cint
  exodus_error_check(exo, error_code, "Exodus.read_coordinate_names -> libexodus.ex_get_coord_names")
  new_coord_names = Vector{String}(undef, num_dimensions(exo.init))
  for n in 1:num_dimensions(exo.init)
    new_coord_names[n] = unsafe_string(pointer(coord_names[n]))
  end
  return new_coord_names
end

"""
$(TYPEDSIGNATURES)
Method to write coordinates
"""
function write_coordinates(exo::ExodusDatabase, coords::VecOrMat{F}) where {F <: AbstractFloat}
  # if size(coords, 1) != exo.init.num_dim || size(coords, 2) != exo.init.n_nodes
  #   throw(ErrorException("Invalid set of coordinates (of size $(size(coords))) to write to exo = $exo"))
  # end

  if length(size(coords)) == 1
    if length(coords) != num_nodes(exo.init)
      throw(ErrorException("Invalid set of coordinates of size $(size(coords)) to write to exo = $exo"))
    end
  elseif length(size(coords)) == 2
    if size(coords, 2) != num_nodes(exo.init)
      throw(ErrorException("Invalid set of coordinates of size $(size(coords)) to write to exo = $exo"))
    end
  end

  # if size(coords, 1) == 1
  if length(size(coords)) == 1
    # x_coords = coords[1, :]
    x_coords = coords
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
  exodus_error_check(exo, error_code, "Exodus.write_coordinates -> libexodus.ex_put_coord")
end

"""
$(TYPEDSIGNATURES)
Method to write coordinate names, e.g. x, y, z
"""
function write_coordinate_names(exo::ExodusDatabase, coord_names::Vector{String})
  error_code = @ccall libexodus.ex_put_coord_names(get_file_id(exo)::Cint, coord_names::Ptr{Ptr{UInt8}})::Cint
  exodus_error_check(exo, error_code, "Exodus.write_coordinate_names -> libexodus.ex_put_coord_names")
end

"""
$(TYPEDSIGNATURES)
"""
function write_partial_coordinates(exo::ExodusDatabase, start_node_num::I, coords::VecOrMat{F}) where {I <: Integer, F <: AbstractFloat}
  coords = convert(VecOrMat{get_float_type(exo)}, coords)
  if length(size(coords)) == 1
    x_coords = coords
    y_coords = C_NULL
    z_coords = C_NULL
    n_nodes = length(coords)
  elseif size(coords, 1) == 2
    x_coords = coords[1, :]
    y_coords = coords[2, :]
    z_coords = C_NULL
    n_nodes = size(coords, 2)
  elseif size(coords, 1) == 3
    x_coords = coords[1, :]
    y_coords = coords[2, :]
    z_coords = coords[3, :]
    n_nodes = size(coords, 2)
  end
  error_code = @ccall libexodus.ex_put_partial_coord(
    get_file_id(exo)::Cint, start_node_num::Clonglong, n_nodes::Clonglong,
    x_coords::Ptr{Cvoid}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.write_partial_coordinates -> libexodus.ex_put_partial_coord")
end

"""
$(TYPEDSIGNATURES)
"""
function write_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, component::I, coords::Vector{F}) where {I <: Integer, F <: AbstractFloat}
  coords = convert(Vector{get_float_type(exo)}, coords)
  error_code = @ccall libexodus.ex_put_partial_coord_component(
    get_file_id(exo)::Cint, start_node_num::Clonglong, length(coords)::Clonglong, component::Cint,
    coords::Ptr{Cvoid}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.write_partial_coordinates_component -> libexodus.ex_put_partial_coord_component")
end

"""
$(TYPEDSIGNATURES)
"""
function write_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, component::String, coords::Vector{F}) where {I <: Integer, F <: AbstractFloat}
  if lowercase(component) == "x"
    coord_id = 1
  elseif lowercase(component) == "y"
    coord_id = 2
  elseif lowercase(component) == "z"
    coord_id = 3
  end
  coords = convert(Vector{get_float_type(exo)}, coords)
  write_partial_coordinates_component(exo, start_node_num, coord_id, coords)
end
