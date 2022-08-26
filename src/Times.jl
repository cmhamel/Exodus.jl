"""
    read_number_of_time_steps(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,
                                                                      B <: ExoInt, F <: ExoFloat}
"""
function read_number_of_time_steps(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,
                                                                           B <: ExoInt, F <: ExoFloat}
    num_steps = ex_inquire_int(exo.exo, EX_INQ_TIME)
    return num_steps
end

"""
    read_times(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,
                                                       B <: ExoInt, F <: ExoFloat}
"""
function read_times(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,
                                                            B <: ExoInt, F <: ExoFloat}
    num_steps = read_number_of_time_steps(exo)
    times = Vector{F}(undef, num_steps)
    ex_get_all_times!(exo.exo, times)
    return times
end

"""
    write_time(exo::ExodusDatabase{M, I, B, F}, 
               time_step, time_value::F) where {M <: ExoInt, I <: ExoInt,
                                                B <: ExoInt, F <: ExoFloat}
"""
function write_time(exo::ExodusDatabase{M, I, B, F}, 
                    time_step, time_value::F) where {M <: ExoInt, I <: ExoInt,
                                                     B <: ExoInt, F <: ExoFloat}
    ex_put_time!(exo.exo, Int32(time_step), time_value)
end 