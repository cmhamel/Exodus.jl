function create_exodus_database(file_name::ExoFileName)
    """
    TODO: clean up this method, I don't think it's used or tested
    For some reason #define statements are not picked up by ccall
    """
    # @suppress begin
    #     exo_id = ex_create_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number_2)
    #     return exo_id
    # end
    # exo_id = ex_create_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number_2)
    # exo_id = ex_create_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number_int)
    # exo_id = ex_create_int(file_name, (EX_CLOBBER | EX_ALL_INT64_DB | EX_ALL_INT64_API), cpu_word_size, IO_word_size, version_number_int)
    
    exo_id = ex_create_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number_int)
    ex_set_max_name_length(exo_id, MAX_LINE_LENGTH)
    @show exo_id
    return exo_id
end

# function copy_exodus_database(exo_id::int, new_exo_id::int)
function copy_exodus_database(old_exo_id::int, file_name::String)
    new_exo_id = ex_create_int(file_name, EX_CLOBBER | ex_int64_status(old_exo_id), cpu_word_size, IO_word_size, version_number_int)
    # error_code = ccall((:ex_copy, libexodus), int,
    #                    (int, int), 
    #                    old_exo_id, new_exo_id)
    # exodus_error_check(error_code, "copy_exodus_database")
    ex_copy!(old_exo_id, new_exo_id)
    return new_exo_id
end

# function copy_exodus_database(exo_id::ExoID, new_exo_id::ExoID)
#     # @suppress begin
#     #     ex_copy!(exo_id, new_exo_id)
#     # end
#     ex_copy!(exo_id, new_exo_id)
# end

function close_exodus_database(exo_id::int)
    ex_close!(exo_id)
end

function open_exodus_database(file_name::ExoFileName)
    exo_id = ex_open_int(file_name, EX_READ, cpu_word_size, IO_word_size, version_number, version_number_int)
    return exo_id
end
