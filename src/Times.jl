"""
$(TYPEDSIGNATURES)
"""
function read_number_of_time_steps(exo::ExodusDatabase)
  num_steps = LibExodus.ex_inquire_int(get_file_id(exo), EX_INQ_TIME)
  exodus_error_check(exo, num_steps, "Exodus.ex_inquite_int -> LibExodus.ex_inquire_int")
  return num_steps
end

"""
$(TYPEDSIGNATURES)
TODO figure out how to make this not use a vector of length 1 - either a ref or a ptr
"""
function read_time(exo::ExodusDatabase, time_step::I) where I <: Integer
  time = Vector{get_float_type(exo)}(undef, 1)
  error_code = LibExodus.ex_get_time(get_file_id(exo), time_step, time)
  exodus_error_check(exo, error_code, "Exodus.read_time -> LibExodus.ex_get_time")
  return time[1]
end

"""
$(TYPEDSIGNATURES)
"""
function read_times(exo::ExodusDatabase)
  num_steps = read_number_of_time_steps(exo)
  times = Vector{get_float_type(exo)}(undef, num_steps)
  error_code = LibExodus.ex_get_all_times(get_file_id(exo), times)
  exodus_error_check(exo, error_code, "Exodus.read_times -> LibExodus.read_times")
  return times
end

"""
$(TYPEDSIGNATURES)
"""
function write_time(exo::ExodusDatabase, time_step::I, time_value::F) where {I <: Integer, F <: AbstractFloat}
  error_code = LibExodus.ex_put_time(get_file_id(exo), time_step, Base.RefValue(time_value))
  exodus_error_check(exo, error_code, "Exodus.write_time -> LibExodus.ex_put_time")
end
