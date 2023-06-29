function ex_get_coord!(
  exoid::Cint,
  x_coords::T1, y_coords::T2, z_coords::T3
) where {T1, T2, T3}
  error_code = ccall((:ex_get_coord, libexodus), Cint,
                     (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                     exoid, x_coords, y_coords, z_coords)
  exodus_error_check(error_code, "ex_get_coord!")
end

function ex_get_coord_names!(exo_id::Cint, coord_names::Vector{Vector{UInt8}})

  error_code = ccall((:ex_get_coord_names, libexodus), Cint,
                     (Cint, Ptr{Ptr{UInt8}}),
                     exo_id, coord_names)
  exodus_error_check(error_code, "ex_get_coord_names!")
end

function ex_get_partial_coord!(
  exoid::Cint,
  start_node_num::Clonglong,
  num_nodes::Clonglong,
  x_coords::Union{Vector{<:Real}, Ptr},
  y_coords::Union{Vector{<:Real}, Ptr},
  z_coords::Union{Vector{<:Real}, Ptr}
)
  error_code = ccall(
    (:ex_get_partial_coord, libexodus), Cint,
    (Cint, Clonglong, Clonglong, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
    exoid, start_node_num, num_nodes, x_coords, y_coords, z_coords
  )
  exodus_error_check(error_code, "ex_get_partial_coord!")
end

function ex_get_partial_coord_component!(
  exoid::Cint,
  start_node_num::Clonglong,
  num_nodes::Clonglong,
  component::Cint,
  coords::Vector{<:Real}
)
  error_code = ccall(
    (:ex_get_partial_coord_component, libexodus), Cint,
    (Cint, Clonglong, Clonglong, Cint, Ptr{Cvoid}),
    exoid, start_node_num, num_nodes, component, coords
  )
  exodus_error_check(error_code, "ex_get_partial_coord_component!")
end

"""
Method to read coordinates. Returns a matrix that is n_dim x n_nodes.
"""
function read_coordinates(exo::ExodusDatabase)
  num_nodes = get_num_nodes(exo)
  float_type = get_float_type(exo)

  coords = Matrix{float_type}(undef, get_init(exo).num_dim, get_init(exo).num_nodes)
  
  if get_num_dim(exo) == 1
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
    ex_get_coord!(get_file_id(exo), x_coords, y_coords, z_coords)
    coords[1, :] = x_coords
  elseif get_num_dim(exo) == 2
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = Array{float_type}(undef, num_nodes)
    z_coords = C_NULL
    ex_get_coord!(get_file_id(exo), x_coords, y_coords, z_coords)
    coords[1, :] = x_coords
    coords[2, :] = y_coords
  elseif get_num_dim(exo) == 3
    x_coords = Array{float_type}(undef, num_nodes)
    y_coords = Array{float_type}(undef, num_nodes)
    z_coords = Array{float_type}(undef, num_nodes)
    ex_get_coord!(get_file_id(exo), x_coords, y_coords, z_coords)
    coords[1, :] = x_coords
    coords[2, :] = y_coords
    coords[3, :] = z_coords
  end
  return coords
end

function read_partial_coordinates(exo::ExodusDatabase, start_node_num::I, num_nodes::I) where I <: Integer
  if get_init(exo).num_dim == 1
    x_coords = Array{get_float_type(exo)}(undef, num_nodes)
    y_coords = C_NULL
    z_coords = C_NULL
  elseif get_init(exo).num_dim == 2
    x_coords = Array{get_float_type(exo)}(undef, num_nodes)
    y_coords = Array{get_float_type(exo)}(undef, num_nodes)
    z_coords = C_NULL
  elseif get_init(exo).num_dim == 3
    x_coords = Array{get_float_type(exo)}(undef, num_nodes)
    y_coords = Array{get_float_type(exo)}(undef, num_nodes)
    z_coords = Array{get_float_type(exo)}(undef, num_nodes)
  end
  ex_get_partial_coord!(get_file_id(exo), 
                        start_node_num, num_nodes,
                        x_coords, y_coords, z_coords)
  if get_init(exo).num_dim == 1
    error("One dimension isn't really supported and exodusII is likely overkill")
  elseif get_init(exo).num_dim == 2
    coords = hcat(x_coords, y_coords)' |> collect
  elseif get_init(exo).num_dim == 3
    coords = hcat(x_coords, y_coords, z_coords)' |> collect
  else
    error("Should never get here")
  end
  return coords
end

function read_partial_coordinates_component(exo::ExodusDatabase, start_node_num::I, num_nodes::I, component::I) where I <: Integer
  coords = Array{get_float_type(exo)}(undef, num_nodes)
  ex_get_partial_coord_component!(get_file_id(exo), start_node_num, num_nodes, convert(Cint, component), coords)
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
"""
function read_coordinate_names(exo::ExodusDatabase)
  coord_names = Vector{Vector{UInt8}}(undef, get_init(exo).num_dim)
  for n in 1:get_init(exo).num_dim
    coord_names[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  end
  ex_get_coord_names!(get_file_id(exo), coord_names)
  new_coord_names = Vector{String}(undef, get_init(exo).num_dim)
  for n in 1:get_init(exo).num_dim
    new_coord_names[n] = unsafe_string(pointer(coord_names[n]))
  end
  return new_coord_names
end

"""
NOT THAT WELL TESTED
"""
function ex_put_coord!(
  exoid::Cint, # input not to be changed
  x_coords::Union{Vector{<:Real}, Ptr}, 
  y_coords::Union{Vector{<:Real}, Ptr}, 
  z_coords::Union{Vector{<:Real}, Ptr}
)
  error_code = ccall(
    (:ex_put_coord, libexodus), Cint,
    (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
    exoid, x_coords, y_coords, z_coords
  )
  exodus_error_check(error_code, "ex_put_coord!")
end

function ex_put_coord_names!(exoid::Cint, coord_names::Vector{Vector{UInt8}})
  error_code = ccall(
    (:ex_put_coord_names, libexodus), Cint,
    (Cint, Ptr{Ptr{UInt8}}),
    exoid, coord_names
  )
  exodus_error_check(error_code, "ex_put_coord_names!")
end


"""
Work in progress... not that well tested
"""
function write_coordinates(exo::ExodusDatabase, coords::Matrix{F}) where {F <: Real}
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
  ex_put_coord!(get_file_id(exo), x_coords, y_coords, z_coords)
end

# TODO we can likely remove some allocations
"""
Work in progress...
"""
function write_coordinate_names(exo::ExodusDatabase, coord_names::Vector{String})
  new_coord_names = Vector{Vector{UInt8}}(undef, length(coord_names))
  for (n, coord_name) in enumerate(coord_names)
    new_coord_names[n] = Vector{UInt8}(coord_name)
  end
  ex_put_coord_names!(get_file_id(exo), new_coord_names)
end

# local exports

export ex_get_coord!
export ex_get_coord_names!
export ex_get_partial_coord!
export ex_get_partial_coord_component!
export ex_put_coord!
export ex_put_coord_names!

export read_coordinates
export read_coordinate_names
export read_partial_coordinates
export read_partial_coordinates_component
export write_coordinates
export write_coordinate_names
