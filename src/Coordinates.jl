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
    error = ccall((:ex_get_coord, exo_lib_path), Int64,
                  (ExoID, Ref{Float64}, Ref{Float64}, Ref{Float64}),
                  exo_id, x_coords, y_coords, z_coords)
    exodus_error_check(error, "read_coordinates")
    return x_coords, y_coords, z_coords
end
