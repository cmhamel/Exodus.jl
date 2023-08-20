"""
"""
struct ExodusError <: Exception
  error_code::Cint
  error_msg::String
end

"""
"""
Base.show(io::IO, e::ExodusError) = 
println(io, "Error from exodusII library in method $(e.method_name) with code $(e.error_code)")

"""
Generic error handling method.
# Arguments
- `error_code::T`: error code, usually negative means something went bad
- `method_name::String`: method name that called this
"""
function exodus_error_check(error_code::T, method_name::String) where {T <: Integer}
  if error_code < 0
    throw(ExodusError(error_code, method_name))
  end
end
