ExodusError = Int64

function exodus_error_check(error_code, method_name::String)
    if error_code < 0
        error("Error from exodus library call in method $method_name with code $error_code")
    end

    # if error_code > 0
    #     println("Warning code frome exodus library call in method $method_name with code $error_code")
    # end
end
