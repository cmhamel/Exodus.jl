function create_exodus_database(file_name::ExoFileName)
    """
    For some reason #define statements are not picked up by ccall
    """
    exo_id = ccall((:ex_create_int, libexodus), Int64,
                   (Base.Cstring, Int64, Ref{Int64}, Ref{Int64}, Int64),
                   file_name, EX_CLOBBER, cpu_word_size, IO_word_size,
                   version_number_2)
    exodus_error_check(exo_id, "create_exodus_database")
    return exo_id
end

function close_exodus_database(exo_id::ExoID)
    error = ccall((:ex_close, libexodus), Int64, (Int64,), exo_id)
    exodus_error_check(error, "close_exodus_database")
end

function open_exodus_database(file_name::ExoFileName)
    # TODO: maybe add multiple methods for different EX_* options
    exo_id = ccall((:ex_open_int, libexodus), Int64,
                   (Base.Cstring, Int64, Ref{Int64},
                    Ref{Int64}, Ref{Float64}, Int64),
                   file_name, EX_CLOBBER, cpu_word_size, IO_word_size,
                   version_number, version_number_2)
    exodus_error_check(exo_id, "open_exodus_database")
    return exo_id
end
