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
    error = ccall((:ex_get_coord, libexodus), ExodusError,
                  (ExoID, Ref{Float64}, Ref{Float64}, Ref{Float64}),
                  exo_id, x_coords, y_coords, z_coords)
    exodus_error_check(error, "read_coordinates")
    coords = Array{Float64}(undef, size(x_coords, 1), num_dim)
    if num_dim == 1
        coords = x_coords
    elseif num_dim == 2
        coords[:, 1] .= x_coords
        coords[:, 2] .= y_coords
    elseif num_dim == 3
        coords[:, 1] .= x_coords
        coords[:, 2] .= y_coords
        coords[:, 3] .= z_coords
    end
    return coords
end
