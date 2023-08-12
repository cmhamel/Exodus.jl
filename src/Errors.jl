struct ExodusError <: Exception
  error_code::Cint
  # exodus_jl_method_name::String
  # exodus_ii_method_name::String
  error_message::String
end

function Base.show(io::IO, e::ExodusError)
  println(io, "ExodusII error thrown with error code $(e.error_code).")
  println(io, "Error message: $(e.error_message)")
end

"""
Generic error handling method.
# Arguments
- `error_code::T`: error code, usually negative means something went bad
- `method_name::String`: method name that called this
"""
function exodus_error_check(error_code::T, error_message::String) where T <: Integer
  if error_code < 0
    # error("Error from exodus library call in method $method_name with code $error_code")
    throw(ExodusError(error_code, error_message))
  end
end


# id_error(exo, ::Type{t}, id) where t <: AbstractSet = throw(SetIDException(exo, t, id))
# name_error(exo, ::Type{t}, name) where t <: AbstractSet = throw(SetNameException(exo, t, name))
# id_error(exo, ::Type{t}, id) where t <: AbstractVariable = throw(VariableIDException(exo, t, id))
# name_error(exo, ::Type{t}, name) where t <: AbstractVariable = throw(VariableNameException(exo, t, name))
