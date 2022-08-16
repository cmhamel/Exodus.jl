struct ExodusDatabase{M, I, B, F}
    exo::Cint
    function ExodusDatabase(file_name::String, mode::String) # TODO add optional inputs for write different ways
        if lowercase(mode) == "r"
            exo = ex_open_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number, version_number_int)
            int64_status = ex_int64_status(exo)             # this is a hex code
            float_size = determine_floating_point_type(exo) # this is the float size

            # TODO need better checks for non 32 bit case
            if int64_status == 0x0000
                maps_int_type = Int32
                ids_int_type = Int32
                bulk_int_type = Int32
            # TODO this will break for non 32 bit case
            else
                error("This should never happen")
            end

            if float_size == 4
                float_type = Float32
            elseif float_size == 8
                float_type = Float64
            else
                error("This should never happen")
            end
            # TODO need to fix below
            exo_db =  new{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo)
        elseif lowercase(mode) == "w"
            # need more inputs for this case I think, like type of DB ints and floats
        else
            @show mode
            error("Mode is currently not supported")
        end

        return exo_db
    end
end

# TODO
# need easy to use methods to pull off the types from
# ExodusDatabase
# TODO
# below methods can be removed once properly deprecated
# and tests passing
# except for the close_exodus_database until
# we figure out how to do cleanup better
# but eitherway close_exodus_database needs to be re-written

function create_exodus_database(file_name::String)
    exo_id = ex_create_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number_int)
    ex_set_max_name_length(exo_id, MAX_LINE_LENGTH)
    return exo_id
end

function copy_exodus_database(old_exo_id::Cint, file_name::String)
    new_exo_id = ex_create_int(file_name, EX_CLOBBER | ex_int64_status(old_exo_id), cpu_word_size, IO_word_size, version_number_int)
    ex_copy!(old_exo_id, new_exo_id)
    return new_exo_id
end

function close_exodus_database(exo_id::Cint)
    ex_close!(exo_id)
end

function close_exodus_database(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
    ex_close!(exo.exo)
end

function open_exodus_database(file_name::String)
    exo_id = ex_open_int(file_name, EX_CLOBBER | EX_ALL_INT64_API | EX_ALL_INT64_DB, cpu_word_size, IO_word_size, version_number, version_number_int)
    determine_floating_point_type(exo_id)
    return exo_id
end


function determine_floating_point_type(exo_id::Cint)
    float_type = ex_inquire_int(exo_id, EX_INQ_DB_FLOAT_SIZE)
    # @show float_type
    return float_type
end