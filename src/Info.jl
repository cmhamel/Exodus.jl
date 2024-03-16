"""
"""
function read_info(exo::ExodusDatabase)
  num_info = @ccall libexodus.ex_inquire_int(
    get_file_id(exo)::Cint, EX_INQ_INFO::ex_inquiry
  )::Cint
  info = Vector{Vector{UInt8}}(undef, num_info)
  for n in eachindex(info)
    info[n] = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  end
  error_code = @ccall libexodus.ex_get_info(
    get_file_id(exo)::Cint, info::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.read_info -> libexodus.ex_get_info")
  new_info = Vector{String}(undef, num_info)
  for n in eachindex(info)
    new_info[n] = unsafe_string(pointer(info[n]))
  end
  return new_info
end

"""
"""
function write_info(exo::ExodusDatabase, info::Vector{String})
  error_code = @ccall libexodus.ex_put_info(
    get_file_id(exo)::Cint, length(info)::Cint, info::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.write_info -> libexodus.ex_put_info")
end
