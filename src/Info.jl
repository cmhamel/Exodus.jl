"""
$(TYPEDSIGNATURES)
"""
function read_info(exo::ExodusDatabase)
  num_info = LibExodus.ex_inquire_int(get_file_id(exo), EX_INQ_INFO)
  info_strs = [Vector{Cchar}(undef, MAX_LINE_LENGTH) for _ in 1:num_info]
  info = Vector{Cstring}(undef, num_info)
  for n in eachindex(info_strs)
    info[n] = pointer(info_strs[n])
  end
  error_code = LibExodus.ex_get_info(get_file_id(exo), info)
  exodus_error_check(exo, error_code, "Exodus.read_info -> LibExodus.ex_get_info")
  new_info = Vector{String}(undef, num_info)
  for n in eachindex(info)
    new_info[n] = unsafe_string(pointer(info[n]))
  end
  return new_info
end

"""
$(TYPEDSIGNATURES)
"""
function write_info(exo::ExodusDatabase, info::Vector{String})
  error_code = LibExodus.ex_put_info(get_file_id(exo), length(info), info)
  exodus_error_check(exo, error_code, "Exodus.write_info -> LibExodus.ex_put_info")
end
