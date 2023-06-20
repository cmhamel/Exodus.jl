function ex_close!(exoid::Cint)
  error_code = ccall(
    (:ex_close, libexodus), Cint, 
    (Cint,), 
    exoid
  )
  exodus_error_check(error_code, "ex_close!")
end

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
ex_create(path, cmode, comp_ws, io_ws) = 
ex_create_int(path, cmode, comp_ws, io_ws, EX_API_VERS_NODOT)

function ex_inquire_int(exoid::Cint, req_info::ex_inquiry)
  info = ccall(
    (:ex_inquire_int, libexodus), Cint,
    (Cint, ex_inquiry), 
    exoid, req_info
  )
  exodus_error_check(info, "ex_inquire_int")
  return info
end

function ex_int64_status(exoid::Cint)
  status = ccall(
    (:ex_int64_status, libexodus), UInt32, 
    (Cint,), 
    exoid
  )
  return status
end

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

# this is a hack for now, maybe make a wrapper?
# FIX TYPES
function ex_open_int(path, mode, comp_ws, io_ws, version, run_version)::Cint
  error_code = ccall(
    (:ex_open_int, libexodus), Cint,
    (Cstring, Cint, Ref{Cint}, Ref{Cint}, Ref{Cfloat}, Cint),
    path, mode, comp_ws, io_ws, version, run_version
  )
  exodus_error_check(error_code, "ex_open_int")
  return error_code
end
ex_open(path, mode, comp_ws, io_ws, version) = 
ex_open_int(path, mode, comp_ws, io_ws, version, EX_API_VERS_NODOT)

function exo_int_types(exoid::Cint)
  int64_status = ex_int64_status(exoid)
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
  return maps_int_type, ids_int_type, bulk_int_type
end

function exo_float_type(exoid::Cint)
  float_size = ex_inquire_int(exoid, EX_INQ_DB_FLOAT_SIZE)
  # this is more straightforward
  if float_size == 4
    float_type = Cfloat
  elseif float_size == 8
    float_type = Cdouble
  else
    error("This should never happen")
  end
  return float_type
end

"""
Init method for read/read-write
"""
function ExodusDatabase(file_name::String, mode::String)
  if lowercase(mode) == "r"
    exo = ex_open(file_name, EX_READ, cpu_word_size, IO_word_size, version_number)
    maps_int_type, ids_int_type, bulk_int_type = exo_int_types(exo)
    # ids_int_type = Clonglong # seems to be the case
    float_type = exo_float_type(exo)
    init = Initialization(exo)
    return ExodusDatabase(
      exo, mode, 
      maps_int_type, ids_int_type, bulk_int_type, float_type,
      init
    )
  # elseif lowercase(mode) == "w"
    # exo = 
  elseif lowercase(mode) == "rw"
    exo = ex_open(file_name, EX_WRITE, cpu_word_size, IO_word_size, version_number)
    maps_int_type, ids_int_type, bulk_int_type = exo_int_types(exo)
    # ids_int_type = Clonglong # seems to be the case
    float_type = exo_float_type(exo)
    init = Initialization(exo)
    return ExodusDatabase(
      exo, mode, 
      maps_int_type, ids_int_type, bulk_int_type, float_type,
      init
    )
  # elseif lowercase(mode) == "w"
  #   exo = ex_create(file_name, EX_WRITE, cpu_word_size, IO_word_size)
  #   maps_int_type, ids_int_type, bulk_int_type = Int32, Int32, Int32
  else
    throw(ErrorException("Invalid mode"))
  end
end

function ExodusDatabase(
  file_name::String;
  # maps_int_type::Type = Int32, ids_int_type::Type = Int64,
  maps_int_type::Type = Int32, ids_int_type::Type = Int32, 
  bulk_int_type::Type = Int32, float_type::Type = Float64,
  num_dim::I = 0, num_nodes::I = 0, num_elems::I = 0,
  num_elem_blks::I = 0, num_node_sets::I = 0, num_side_sets::I = 0
) where {I <: Integer}
  exo = ex_create(file_name, EX_WRITE, cpu_word_size, IO_word_size)
  init = Initialization(
    num_dim, num_nodes, num_elems,
    num_elem_blks, num_node_sets, num_side_sets
  )
  write_initialization!(exo, init)
  return ExodusDatabase(
    exo, "w",
    maps_int_type, ids_int_type, bulk_int_type, float_type,
    init
  )
end

function ExodusDatabase(
  file_name::String, init::Initialization;
  # maps_int_type::Type = Int32, ids_int_type::Type = Int64, 
  maps_int_type::Type = Int32, ids_int_type::Type = Int32, 
  bulk_int_type::Type = Int32, float_type::Type = Float64,
)
  return ExodusDatabase(
    file_name;
    maps_int_type, ids_int_type,
    bulk_int_type, float_type,
    init.num_dim, init.num_nodes, init.num_elems,
    init.num_elem_blks, init.num_node_sets, init.num_side_sets
  )
end

# """
# Init method.
# # Arguments
# - `file_name::String`: absolute path to exodus file
# - `mode::String`: mode to read 
# - `int_mode`: either 32-bit or 64-bit
# - `float_mode`: either 32-bit or 64-bit
# """
# function ExodusDatabase(file_name::String, mode::String; int_mode="32-bit", float_mode="64-bit") # TODO add optional inputs for write different ways
#   if lowercase(mode) == "r" || lowercase(mode) == "rw"
#     exo = ex_open_int(file_name, EX_CLOBBER, cpu_word_size, IO_word_size, version_number, version_number_int)
#     int64_status = ex_int64_status(exo)       # this is a hex code
#     float_size = ex_inquire_int(exo, EX_INQ_DB_FLOAT_SIZE)

#     # @show int64_status
#     # TODO need better checks for non 32 bit case
#     if int64_status == 0x0000
#       maps_int_type = Cint
#       ids_int_type = Cint
#       bulk_int_type = Cint
#     # TODO this will break for non 32 bit case
#     # TODO figure out other cases from hex codes in exodusII.h
#     else
#       error("This should never happen")
#     end

#     # this is more straightforward
#     if float_size == 4
#       float_type = Cfloat
#     elseif float_size == 8
#       float_type = Cdouble
#     else
#       error("This should never happen")
#     end
#     # TODO need to fix below
#     # exo_db = new{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo)
#   elseif lowercase(mode) == "w"
#     # set up integer mode
#     if lowercase(int_mode) == "32-bit"
#       maps_int_type = Cint
#       ids_int_type = Cint
#       bulk_int_type = Cint
#       write_mode = EX_CLOBBER
#     elseif lowercase(int_mode) == "64-bit"
#       maps_int_type = Clonglong
#       ids_int_type = Clonglong
#       bulk_int_type = Clonglong
#       write_mode = EX_CLOBBER | EX_ALL_INT64_API | EX_ALL_INT64_DB
#     else
#       error("This should never happen")
#     end

#     # set up float mode
#     if lowercase(float_mode) == "32-bit"
#       float_type = Cfloat
#       cpu_word_size_temp = Int32(sizeof(Cfloat))
#     elseif lowercase(float_mode) == "64-bit"
#       float_type = Cdouble
#       cpu_word_size_temp = Int32(sizeof(Cdouble))
#     else
#       error("This should never happen")
#     end

#     # create new exo
#     exo = ex_create_int(file_name, write_mode, cpu_word_size_temp, IO_word_size, version_number_int)
#     ex_set_max_name_length(exo, MAX_LINE_LENGTH)
#     # @show int64_status = ex_int64_status(exo)

#   else
#     @show mode
#     error("Mode is currently not supported")
#   end

#   # new stuff
#   init = Initialization(exo)
#   # note that init will be all zeros for an empty exodus database just initialized

#   return ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo, init)
# end

# """
# """
# function ExodusDatabase!(e::E, init::Initialization) where {E <: ExodusDatabase}
#   e.init = init
# end

"""
Used to close and ExodusDatabase.
"""
function Base.close(exo::E) where {E <: ExodusDatabase}
  ex_close!(exo.exo)
end

"""
Used to copy an ExodusDatabase. As of right now this is the best way to create a new ExodusDatabase
for output. Not all of the put methods have been wrapped and properly tested. This one has though.
"""
function Base.copy(exo::E, new_file_name::String) where {E <: ExodusDatabase}
  new_exo_id = ex_create_int(new_file_name, EX_CLOBBER | ex_int64_status(exo.exo), cpu_word_size, IO_word_size, version_number_int)
  ex_copy!(exo.exo, new_exo_id)
  ex_close!(new_exo_id)
end

# local exports
export close
export copy
export exo_int_types
export exo_float_type
# export ExodusDatabase!
