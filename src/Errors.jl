"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct ExodusError <: Exception
  error_code::Cint
  error_msg::String
end

"""
"""
Base.show(io::IO, e::ExodusError) = 
println(io, "Error from exodusII library in method $(e.error_msg) with code $(e.error_code)")

function exodus_error_check(error_code::T, method_name::String) where {T <: Integer}
  if error_code < 0
    throw(ExodusError(error_code, method_name))
  end
end

"""
$(TYPEDSIGNATURES)
Generic error handling method.
# Arguments
- `error_code::T`: error code, usually negative means something went bad
- `method_name::String`: method name that called this
"""
function exodus_error_check(exo::Cint, error_code::T, method_name::String) where {T <: Integer}
  if error_code < 0
    error_code = @ccall libexodus.ex_close(exo::Cint)::Cint
    throw(ExodusError(error_code, method_name))
  end
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct ExodusWindowsError <: Exception
end

Base.show(io::IO, ::ExodusWindowsError) = 
println(io, "This feature is not supported on Windows.")

exodus_windows_error() = throw(ExodusWindowsError())
