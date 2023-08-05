"""
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


# id_error(exo, ::Type{t}, id) where t <: AbstractSet = throw(SetIDException(exo, t, id))
# name_error(exo, ::Type{t}, name) where t <: AbstractSet = throw(SetNameException(exo, t, name))
# id_error(exo, ::Type{t}, id) where t <: AbstractVariable = throw(VariableIDException(exo, t, id))
# name_error(exo, ::Type{t}, name) where t <: AbstractVariable = throw(VariableNameException(exo, t, name))
