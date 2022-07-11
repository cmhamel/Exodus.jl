Times = Vector{Float64}

function read_number_of_time_steps(exo_id::ExoID)
    num_steps = ex_inquire_int(exo_id, EX_INQ_TIME)
    return num_steps
end

function read_times(exo_id::ExoID)::Times
    num_steps = read_number_of_time_steps(exo_id)
    @show num_steps
    times = Vector{Float64}(undef, num_steps)
    ex_get_all_times!(exo_id, times)
    return times
end

function write_time(exo_id::ExoID, time_step::IntKind, time_value::Float64)
    ex_put_time!(exo_id, time_step, time_value)
end 