"""
  exodus_error_check(error_code::T)
Generic error handling method.
# Arguments
- `error_code::T`: error code, usually negative means something went bad
- `method_name::String`: method name that called this
"""
function exodus_error_check(error_code::T, method_name::String) where {T <: Integer}
  if error_code < 0
    error("Error from exodus library call in method $method_name with code $error_code")
  end
end
