struct ExodusError <: Exception
  error_code::Cint
  error_message::String
end

struct ExodusError2 <: Exception
  error_code::Cint
  exodus_jl_method_name::String
  exodus_ii_method_name::String
end

function Base.show(io::IO, e::ExodusError2)
  println(io, "")
  println(io, "ExodusII library error thrown with error code $(e.error_code).")
  print(io, "Error caused by Exodus.jl wrapper method \"$(e.exodus_jl_method_name)\" ")
  println(io, "which calls the exodusII library method \"$(e.exodus_ii_method_name)\"")
end

function Base.show(io::IO, e::ExodusError)
  println(io, "ExodusII library error thrown with error code $(e.error_code).")
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
    throw(ExodusError(error_code, error_message))
  end
end

function exodus_ii_error_check(
  error_code::T, 
  exodus_jl_method_name::String,
  exodus_ii_method_name::String
) where T <: Integer

  if error_code < 0
    throw(ExodusError2(error_code, exodus_jl_method_name, exodus_ii_method_name))
  end
end

macro exodus_ii_error_check(ex)
  local exodus_jl_method_name = split(string(ex.args[1].args[1]), "(")[1] |> String

  for (n, expr) in enumerate(ex.args[2].args)
    if !(hasproperty(expr, :args)) 
      continue
    end

    for arg in expr.args
      local str_arg = string(arg)
      if occursin("libexodus", str_arg)
        local exodus_ii_method_name = split(split(str_arg, "libexodus.")[2], "(")[1] |> String
        local error_expr = Expr(:call, :exodus_ii_error_check, 
                                :error_code, Expr(:quote, exodus_jl_method_name), Expr(:quote, exodus_ii_method_name))
        insert!(ex.args[2].args, n + 1, error_expr)
        return ex
      end
    end
  end
end