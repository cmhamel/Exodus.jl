"""
    ex_close!(exoid::Cint)
"""
function ex_close!(exoid::Cint)
    error_code = ccall(
        (:ex_close, libexodus), Cint, 
        (Cint,), 
        exoid
    )
    exodus_error_check(error_code, "ex_close!")
end

"""
    ex_copy!(in_exoid::Cint, out_exoid::Cint)
"""
function ex_copy!(in_exoid::Cint, out_exoid::Cint)
    error_code = ccall(
        (:ex_copy, libexodus), Cint, 
        (Cint, Cint), 
        in_exoid, out_exoid
    )
    exodus_error_check(error_code, "ex_copy!")
end

# TODO figure out right type for cmode in the ex_create_int julia call
function ex_create_int(path, cmode, comp_ws::Cint, io_ws::Cint, run_version::Cint)
    exo_id = ccall(
        (:ex_create_int, libexodus), Cint,
        (Cstring, Cint, Ref{Cint}, Ref{Cint}, Cint),
        path, cmode, comp_ws, io_ws, run_version
    )
    exodus_error_check(exo_id, "create_exodus_database")
    return exo_id
end

"""
    ex_inquire_int(exoid::Cint, req_info::ex_inquiry)
"""
function ex_inquire_int(exoid::Cint, req_info::ex_inquiry)
    info = ccall((:ex_inquire_int, libexodus), Cint,
                 (Cint, ex_inquiry), 
                 exoid, req_info)
    exodus_error_check(info, "ex_inquire_int")
    return info
end

"""
    ex_int64_status(exoid::Cint)
"""
function ex_int64_status(exoid::Cint)
    status = ccall(
        (:ex_int64_status, libexodus), UInt32, 
        (Cint,), 
        exoid
    )
    return status
end

"""
    ex_opts(options)
"""
function ex_opts(options)
    error_code = ccall(
        (:ex_opts, libexodus), Cint, 
        (Cint,), 
        options
    )
    exodus_error_check(error_code, "ex_opts")
    return error_code
end

function ex_set_max_name_length(exoid::Cint, len::Cint)
    error_code = ccall(
        (:ex_set_max_name_length, libexodus), Cint,
        (Cint, Cint), 
        exoid, len
    )
    exodus_error_check(error_code, "ex_set_max_name_length")
end

# this method actually returns something
# this method will break currently if called
# TODO figure out how to get #define statements to work from julia artifact
"""
    ex_open(path, mode, comp_ws, io_ws)::Cint
NOT USED
"""
function ex_open(path, mode, comp_ws, io_ws)::Cint
    error_code = ccall(
        (:ex_open, libexodus), Cint,
        (Cstring, Cint, Ptr{Cint}, Ptr{Cint}),
        path, mode, comp_ws, io_ws
    )
    exodus_error_check(error_code, "ex_open")
    return error_code
end

# this is a hack for now, maybe make a wrapper?
"""
    ex_open_int(path, mode, comp_ws, io_ws, version, run_version)::Cint
FIX TYPES
"""
function ex_open_int(path, mode, comp_ws, io_ws, version, run_version)::Cint
    error_code = ccall(
        (:ex_open_int, libexodus), Cint,
        (Cstring, Cint, Ref{Cint}, Ref{Cint}, Ref{Cfloat}, Cint),
        path, mode, comp_ws, io_ws, version, run_version
    )
    exodus_error_check(error_code, "ex_open_int")
    return error_code
end

"""
    ExodusDatabase{M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
Main entry point for the package whether it's in read or write mode. 
"""
struct ExodusDatabase{M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat} 
    exo::Cint
end

"""
    ExodusDatabase(file_name::String, mode::String; int_mode="32-bit", float_mode="64-bit")
Init method.
# Arguments
- `file_name::String`: absolute path to exodus file
- `mode::String`: mode to read 
- `int_mode`: either 32-bit or 64-bit
- `float_mode`: either 32-bit or 64-bit
"""
function ExodusDatabase(file_name::String, mode::String; int_mode="32-bit", float_mode="64-bit") # TODO add optional inputs for write different ways
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

    return ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo)
end

"""
    Base.close(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
Used to close and ExodusDatabase.
"""
function Base.close(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    ex_close!(exo.exo)
end

"""
    Base.copy(exo::ExodusDatabase{M, I, B, F},
              new_file_name::String) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
Used to copy an ExodusDatabase. As of right now this is the best way to create a new ExodusDatabase
for output. Not all of the put methods have been wrapped and properly tested. This one has though.
"""
function Base.copy(exo::ExodusDatabase{M, I, B, F},
                   new_file_name::String) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
    new_exo_id = ex_create_int(new_file_name, EX_CLOBBER | ex_int64_status(exo.exo), cpu_word_size, IO_word_size, version_number_int)
    ex_copy!(exo.exo, new_exo_id)
    ex_close!(new_exo_id)
end
