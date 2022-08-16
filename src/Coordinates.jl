function read_coordinates(exo_id::Cint, num_dim::Cint, num_nodes::Cint)
    if num_dim == 1
        x_coords = Array{Float64}(undef, num_nodes)
        y_coords = Ref{Float64}(0.0)
        z_coords = Ref{Float64}(0.0)
    elseif num_dim == 2
        x_coords = Array{Float64}(undef, num_nodes)
        y_coords = Array{Float64}(undef, num_nodes)
        z_coords = Ref{Float64}(0.0)
    elseif num_dim == 3
        x_coords = Array{Float64}(undef, num_nodes)
        y_coords = Array{Float64}(undef, num_nodes)
        z_coords = Array{Float64}(undef, num_nodes)
    end
    # calling exodus method
    ex_get_coord!(exo_id, x_coords, y_coords, z_coords)
    if num_dim == 1
        error("One dimension isn't really supported and exodusII is likely overkill")
    elseif num_dim == 2
        coords = hcat(x_coords, y_coords)
    elseif num_dim == 3
        coords = hcat(x_coords, y_coords, z_coords)
    else
        error("Should never get here")
    end
    return coords
end

function read_coordinate_names(exo_id::Cint, num_dim::T) where {T <: Integer}
    coord_names = Vector{Vector{UInt8}}(undef, num_dim)
    for n in 1:num_dim
        coord_names[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
    end
    ex_get_coord_names!(exo_id, coord_names)
    new_coord_names = Vector{String}(undef, num_dim)
    for n in 1:num_dim
        new_coord_names[n] = unsafe_string(pointer(coord_names[n]))
    end
    return new_coord_names
end

function put_coordinates(exo::Cint, coords::Matrix{Float64})
    #TODO add views
    x_coords, y_coords = coords[:, 1], coords[:, 2]
    if size(coords, 2) == 2
        # 2D case
        z_coords = Ref{Float64}(0.)
    elseif size(coords, 3) == 3
        # 3D case
        z_coords = coords[:, 3]
    else
        error("Not supporting 1D right now")
    end
    ex_put_coord!(exo, x_coords, y_coords, z_coords)
end

# TODO we can likely remove some allocations
function put_coordinate_names(exo::Cint, coord_names::Vector{String})
    new_coord_names = Vector{Vector{UInt8}}(undef, length(coord_names))
    for (n, coord_name) in enumerate(coord_names)
        new_coord_names[n] = Vector{UInt8}(coord_name)
    end
    ex_put_coord_names!(exo, new_coord_names)
end