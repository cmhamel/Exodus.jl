Times = Vector{Float64}

function read_number_of_time_steps(exo_id::Cint)
    num_steps = ex_inquire_int(exo_id, EX_INQ_TIME)
    return num_steps
end

function read_times(exo_id::Cint)::Times
    num_steps = read_number_of_time_steps(exo_id)
    times = Vector{Float64}(undef, num_steps)
    ex_get_all_times!(exo_id, times)
    return times
end

function write_time(exo_id::Cint, time_step, time_value::Float64) # maybe get type right?
    ex_put_time!(exo_id, Int32(time_step), time_value)
end 