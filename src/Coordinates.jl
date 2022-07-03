# TODO maybe make this into a struct or AbstractArray type

function read_coordinates(exo_id::ExoID, num_dim::Int64, num_nodes::Int64)
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
    @show size(coords)
    return coords
end
