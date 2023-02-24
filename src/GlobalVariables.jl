
function read_number_of_global_variables(
    exo::ExodusDatabase{M, I, B, F}
) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    num_vars = Ref{Cint}(0) # TODO check to make sure this is right
    ex_get_variable_param!(exo.exo, EX_GLOBAL, num_vars)
    return num_vars[]
end

function read_global_variables(
    exo::ExodusDatabase{M, I, B, F}, 
    timestep, num_glob_vars
) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}

    glob_var_vals = Vector{F}(undef, num_glob_vars)
    ex_get_glob_vars!(exo.exo, timestep, num_glob_vars, glob_var_vals)
    return glob_var_vals
end

function write_number_of_global_variables(
    exo::ExodusDatabase{M, I, B, F},
    num_vars
) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    ex_put_variable_param!(exo.exo, EX_GLOBAL, num_vars)
end

function write_global_variable_values(
    exo::ExodusDatabase{M, I, B, F},
    timestep, var_values
) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    # vals = Vector{F}([var_value])
    ex_put_var!(exo.exo, timestep, EX_GLOBAL, 1, 1, length(var_values), var_values)
end

