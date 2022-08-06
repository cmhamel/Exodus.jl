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
    
    exo_id = ex_create_int(file_name, (EX_CLOBBER | EX_ALL_INT64_DB | EX_ALL_INT64_API), cpu_word_size, IO_word_size, version_number_int)
    # exo_id = ex_create_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number_int)
    return exo_id
end

function copy_exodus_database(exo_id::int, new_exo_id::int)
    # @suppress begin
    new_exo_id = ccall((:ex_copy, libexodus), int,
                       (int, int), 
                       exo_id, new_exo_id)
    exodus_error_check(new_exo_id, "copy_exodus_database")
    # end
end

# function copy_exodus_database(exo_id::ExoID, new_exo_id::ExoID)
#     # @suppress begin
#     #     ex_copy!(exo_id, new_exo_id)
#     # end
#     ex_copy!(exo_id, new_exo_id)
# end

function close_exodus_database(exo_id::int)
    # @suppress begin
    #     ex_close!(exo_id)
    # end
    ex_close!(exo_id)
end

function open_exodus_database(file_name::ExoFileName)
    # TODO: maybe add multiple methods for different EX_* options
    # @suppress begin

    #     exo_id = ex_open_int(file_name, (EX_CLOBBER | EX_ALL_INT64_DB | EX_ALL_INT64_API),
    #                          cpu_word_size, IO_word_size, version_number, version_number_2)
    #     # below is the behavior that we want to move towards but some work 
    #     # left to do
    #     # exo_id = ex_open(file_name, (EX_CLOBBER | EX_ALL_INT64_DB | EX_ALL_INT64_API),
    #     #                  cpu_word_size, IO_word_size)
    #     return exo_id
    # end
    exo_id = ex_open_int(file_name, (EX_CLOBBER | EX_ALL_INT64_DB | EX_ALL_INT64_API),
                         cpu_word_size, IO_word_size, version_number, version_number_int)
    return exo_id
end
