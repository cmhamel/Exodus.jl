function exodus_error_check(error::Int64, method_name::String)
    if error < 0
        error("Error from exodus library call in method $method_name")
    end
end
