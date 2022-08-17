struct ExodusDatabase{M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat} 
    exo::Cint
    function ExodusDatabase(file_name::String, mode::String, int_mode="32-bit", float_mode="64-bit") # TODO add optional inputs for write different ways
        if lowercase(mode) == "r"
            exo = ex_open_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number, version_number_int)
            int64_status = ex_int64_status(exo)             # this is a hex code
            float_size = ex_inquire_int(exo, EX_INQ_DB_FLOAT_SIZE)

            # @show int64_status
            # TODO need better checks for non 32 bit case
            if int64_status == 0x0000
                maps_int_type = Cint
                ids_int_type = Cint
                bulk_int_type = Cint
            # TODO this will break for non 32 bit case
            # TODO figure out other cases from hex codes in exodusII.h
            else
                error("This should never happen")
            end

            # this is more straightforward
            if float_size == 4
                float_type = Cfloat
            elseif float_size == 8
                float_type = Cdouble
            else
                error("This should never happen")
            end
            # TODO need to fix below
            # exo_db = new{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo)
        elseif lowercase(mode) == "w"
            # set up integer mode
            if lowercase(int_mode) == "32-bit"
                maps_int_type = Cint
                ids_int_type = Cint
                bulk_int_type = Cint
                write_mode = EX_CLOBBER
            elseif lowercase(int_mode) == "64-bit"
                maps_int_type = Clonglong
                ids_int_type = Clonglong
                bulk_int_type = Clonglong
                write_mode = EX_CLOBBER | EX_ALL_INT64_API | EX_ALL_INT64_DB
            else
                error("This should never happen")
            end

            # set up float mode
            if lowercase(float_mode) == "32-bit"
                float_type = Cfloat
                cpu_word_size_temp = Int32(sizeof(Cfloat))
            elseif lowercase(float_mode) == "64-bit"
                float_type = Cdouble
                cpu_word_size_temp = Int32(sizeof(Cdouble))
            else
                error("This should never happen")
            end

            # create new exo
            exo = ex_create_int(file_name, write_mode, cpu_word_size_temp, IO_word_size, version_number_int)
            ex_set_max_name_length(exo, MAX_LINE_LENGTH)
            # @show int64_status = ex_int64_status(exo)
        else
            @show mode
            error("Mode is currently not supported")
        end

        exo_db = new{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo)

        return exo_db
    end
end

function close(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    ex_close!(exo.exo)
end

function copy(exo::ExodusDatabase{M, I, B, F},
              new_file_name::String) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    new_exo_id = ex_create_int(new_file_name, EX_CLOBBER | ex_int64_status(exo.exo), cpu_word_size, IO_word_size, version_number_int)
    ex_copy!(exo.exo, new_exo_id)
    ex_close!(new_exo_id)
end
