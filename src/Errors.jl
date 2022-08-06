ExodusError = Int64

function exodus_error_check(error, method_name::String)
    if error < 0
        # error("Error from exodus library call in method $method_name")
        @show error
        # error("Error from exodus library call in method ")
    end
end
