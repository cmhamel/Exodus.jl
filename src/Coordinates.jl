
"""
    read_coordinates(exo::ExodusDatabase{M, I, B, F}, 
                     init::Initialization) where {M <: ExoInt, I <: ExoInt,
                                                  B <: ExoInt, F <: ExoFloat}
Method to read coordinates. Returns a matrix that is n_nodes x n_dim.

TODO... This method should really return n_dim x n_nodes but there's
TODO... issues encountered downstream with some views found in Tardigrade
"""
function read_coordinates(exo::ExodusDatabase{M, I, B, F}, 
                          init::Initialization) where {M <: ExoInt, I <: ExoInt,
                                                       B <: ExoInt, F <: ExoFloat}
    if init.num_dim == 1
        x_coords = Array{F}(undef, init.num_nodes)
        y_coords = C_NULL
        z_coords = C_NULL
    elseif init.num_dim == 2
        x_coords = Array{F}(undef, init.num_nodes)
        y_coords = Array{F}(undef, init.num_nodes)
        z_coords = C_NULL
    elseif init.num_dim == 3
        x_coords = Array{F}(undef, init.num_nodes)
        y_coords = Array{F}(undef, init.num_nodes)
        z_coords = Array{F}(undef, init.num_nodes)
    end
    # calling exodus method
    ex_get_coord!(exo.exo, x_coords, y_coords, z_coords)
    if init.num_dim == 1
        error("One dimension isn't really supported and exodusII is likely overkill")
    elseif init.num_dim == 2
        coords = hcat(x_coords, y_coords)
    elseif init.num_dim == 3
        coords = hcat(x_coords, y_coords, z_coords)
    else
        error("Should never get here")
    end
    return coords
end

"""
    read_coordinate_names(exo::ExodusDatabase{M, I, B, F}, 
                          init::Initialization) where {M <: ExoInt, I <: ExoInt,
                                                       B <: ExoInt, F <: ExoFloat}
"""
function read_coordinate_names(exo::ExodusDatabase{M, I, B, F}, 
                               init::Initialization) where {M <: ExoInt, I <: ExoInt,
                                                            B <: ExoInt, F <: ExoFloat}
    coord_names = Vector{Vector{UInt8}}(undef, init.num_dim)
    for n in 1:init.num_dim
        coord_names[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
    end
    ex_get_coord_names!(exo.exo, coord_names)
    new_coord_names = Vector{String}(undef, init.num_dim)
    for n in 1:init.num_dim
        new_coord_names[n] = unsafe_string(pointer(coord_names[n]))
    end
    return new_coord_names
end

"""
    put_coordinates(exo::ExodusDatabase{M, I, B, F}, 
                         coords::Matrix{F}) where {M <: ExoInt, I <: ExoInt,
                                                   B <: ExoInt, F <: ExoFloat}
Work in progress... not that well tested
"""
function put_coordinates(exo::ExodusDatabase{M, I, B, F}, 
                         coords::Matrix{F}) where {M <: ExoInt, I <: ExoInt,
                                                   B <: ExoInt, F <: ExoFloat}
    # NOTE THIS ASSUMES SOMETHING ABOUT COORDS ORDERING IN LESS THEN 3D

    if size(coords, 2) == 1
        x_coords = @views coords[:, 1]
        y_coords = C_NULL
        z_coords = C_NULL
    elseif size(coords, 2) == 2
        # 2D case
        x_coords = @views coords[:, 1]
        y_coords = @views coords[:, 2]
        z_coords = C_NULL
    elseif size(coords, 3) == 3
        # 3D case
        x_coords = @views coords[:, 1]
        y_coords = @views coords[:, 2]
        z_coords = @views coords[:, 3]
    else
        error("Not supporting 1D right now")
    end
    ex_put_coord!(exo.exo, x_coords, y_coords, z_coords)
end

# TODO we can likely remove some allocations
"""
    put_coordinate_names(exo::ExodusDatabase{M, I, B, F}, 
                         coord_names::Vector{String}) where {M <: ExoInt, I <: ExoInt,
                                                             B <: ExoInt, F <: ExoFloat}
Work in progress...
"""
function put_coordinate_names(exo::ExodusDatabase{M, I, B, F}, 
                              coord_names::Vector{String}) where {M <: ExoInt, I <: ExoInt,
                                                                  B <: ExoInt, F <: ExoFloat}
    new_coord_names = Vector{Vector{UInt8}}(undef, length(coord_names))
    for (n, coord_name) in enumerate(coord_names)
        new_coord_names[n] = Vector{UInt8}(coord_name)
    end
    ex_put_coord_names!(exo.exo, new_coord_names)
end