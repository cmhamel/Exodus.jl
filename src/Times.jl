Times = Vector{Float64}

function read_number_of_time_steps(exo_id::ExoID)
    num_steps = ccall((:ex_inquire_int, libexodus), Int64,
                      (Int64, Int64),
                      exo_id, EX_INQ_TIME)
    return num_steps
end

function read_times(exo_id::ExoID)::Times
    num_steps = read_number_of_time_steps(exo_id)
    times = Vector{Float64}(undef, num_steps)
    error = ccall((:ex_get_all_times, libexodus), Int64,
                  (Int64, Ref{Float64}),
                  exo_id, times)
    exodus_error_check(error, "read_times")
    return times
end

function write_time(exo_id::ExoID, time_step::Int64, time_value::Float64)
    error = ccall((:ex_put_time, libexodus), ExodusError,
                  (ExoID, Int64, Ref{Float64}),
                  exo_id, time_step, time_value)
    exodus_error_check(error, "write_time")
end 