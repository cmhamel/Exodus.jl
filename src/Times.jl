function ex_get_all_times!(exoid::Cint, time_values::Vector{T}) where {T <: Real}
  error_code = ccall(
    (:ex_get_all_times, libexodus), Cint,
    (Cint, Ptr{Cvoid}),
    exoid, time_values
  )
  exodus_error_check(error_code, "ex_get_all_times!")
end

"""
  read_number_of_time_steps(exo::ExodusDatabase)
"""
function read_number_of_time_steps(exo::E) where {E <: ExodusDatabase}
  num_steps = ex_inquire_int(exo.exo, EX_INQ_TIME)
  return num_steps
end

"""
  read_times(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,
                             B <: ExoInt, F <: ExoFloat}
"""
function read_times(exo::ExodusDatabase{M, I, B, F}) where {M <: Integer, I <: Integer,
                              B <: Integer, F <: Real}
  num_steps = read_number_of_time_steps(exo)
  times = Vector{F}(undef, num_steps)
  ex_get_all_times!(exo.exo, times)
  return times
end

function ex_put_time!(exoid::Cint, time_step::Cint, time_value)
  error_code = ccall(
    (:ex_put_time, libexodus), Cint,
    (Cint, Cint, Ref{Float64}), # need to get types to be Ptr{Cvoid} but not working
    exoid, time_step, time_value
  )
  exodus_error_check(error_code, "ex_put_time!")
end

"""
  write_time(exo::ExodusDatabase{M, I, B, F}, 
         time_step, time_value::F) where {M <: ExoInt, I <: ExoInt,
                        B <: ExoInt, F <: ExoFloat}
"""
function write_time(exo::ExodusDatabase{M, I, B, F}, 
          time_step, time_value::F) where {M <: Integer, I <: Integer,
                           B <: Integer, F <: Real}
  ex_put_time!(exo.exo, Int32(time_step), time_value)
end 