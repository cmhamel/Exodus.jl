ExodusError = Int64

function exodus_error_check(error, method_name::String)
    if error < 0
        # error("Error from exodus library call in method $method_name")
        # error("Error from exodus library call in method...")
        println("error")
    end
end
