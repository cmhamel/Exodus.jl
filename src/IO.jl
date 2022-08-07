# function create_exodus_database(file_name::ExoFileName)
#     exo_id = ex_create_int(file_name, EX_CLOBBER | 0x0000, cpu_word_size, IO_word_size, version_number_int)
#     ex_set_max_name_length(exo_id, MAX_LINE_LENGTH)
#     return exo_id
# end

function copy_exodus_database(old_exo_id::int, file_name::String)
    new_exo_id = ex_create_int(file_name, EX_CLOBBER | ex_int64_status(old_exo_id), cpu_word_size, IO_word_size, version_number_int)
    ex_copy!(old_exo_id, new_exo_id)
    return new_exo_id
end

function close_exodus_database(exo_id::int)
    ex_close!(exo_id)
end

function open_exodus_database(file_name::ExoFileName)
    exo_id = ex_open_int(file_name, EX_CLOBBER | EX_ALL_INT64_API | EX_ALL_INT64_DB, cpu_word_size, IO_word_size, version_number, version_number_int)
    return exo_id
end
