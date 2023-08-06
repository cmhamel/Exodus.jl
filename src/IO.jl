"""
"""
function set_exodus_options(options::T) where T
  error_code = @ccall libexodus.ex_opts(options::Cint)::Cint
  exodus_error_check(error_code, "Exodus.set_exodus_options -> libexodus.ex_opts")
end

"""
"""
function set_exodus_max_name_length(exoid::Cint, len::Cint)
  error_code = @ccall libexodus.ex_set_max_name_length(
    exoid::Cint, len::Cint
  )::Cint
  exodus_error_check(error_code, "ex_set_max_name_length")
end

"""
"""
function int_and_float_modes(exo::Cint)::Tuple{Type, Type, Type, Type}
  int64_status = @ccall libexodus.ex_int64_status(exo::Cint)::UInt32
  float_size   = @ccall libexodus.ex_inquire_int(exo::Cint, EX_INQ_DB_FLOAT_SIZE::ex_inquiry)::Cint

  # should be 8 options or 2^3
  if int64_status == 0x00000000
    M, I, B = Cint, Cint, Cint
  elseif int64_status == EX_MAPS_INT64_API
    M, I, B = Clonglong, Cint, Cint
  elseif int64_status == EX_MAPS_INT64_API | EX_IDS_INT64_API
    M, I, B = Clonglong, Clonglong, Cint
  elseif int64_status == EX_MAPS_INT64_API | EX_BULK_INT64_API
    M, I, B = Clonglong, Cint, Clonglong
  elseif int64_status == EX_IDS_INT64_API
    M, I, B = Cint, Clonglong, Cint
  elseif int64_status == EX_IDS_INT64_API | EX_BULK_INT64_API
    M, I, B = Cint, Clonglong, Clonglong
  elseif int64_status == EX_BULK_INT64_API
    M, I, B = Cint, Cint, Clonglong
  elseif int64_status == EX_MAPS_INT64_API | EX_IDS_INT64_API | EX_BULK_INT64_API
    M, I, B = Clonglong, Clonglong, Clonglong
  else
    mode_error("Bad int64_status, probably 64 int bit mesh, not supported right now $int64_status")
  end

  if float_size == 4
    F = Cfloat
  elseif float_size == 8
    F = Cdouble
  else
    mode_error("Bad float mode: float_size == $(float_size)")
  end

  return M, I, B, F
end

function map_int_type(int_status::UInt32)
  if int_status == 0x00000000
    return Cint
  elseif int_status == EX_MAPS_INT64_API
    return Clonglong
  elseif int_status == EX_ALL_INT64_API
    return Clonglong
  else
    return Cint# hack for now
  end
end

function id_int_type(int_status::UInt32)
  if int_status == 0x00000000
    return Cint
  elseif int_status == EX_IDS_INT64_API
    return Clonglong
  elseif int_status == EX_ALL_INT64_API
    return Clonglong
  else
    return Cint# hack for now
  end
end

function bulk_int_type(int_status::UInt32)
  if int_status == 0x00000000
    return Cint
  elseif int_status == EX_BULK_INT64_API
    return Clonglong
  elseif int_status == EX_ALL_INT64_API
    return Clonglong
  else
    return Cint# hack for now
  end
end

function float_type(float_size::Int32)
  if float_size == 4
    return Cfloat
  elseif float_size == 8
    return Cdouble
  end
end

"""
"""
function ExodusDatabase(
  exo::Cint, mode::String,
  ::Type{M}, ::Type{I}, ::Type{B}, ::Type{F},
) where {M, I, B, F}
  
  # get init
  init = Initialization(exo, B)
  return ExodusDatabase{M, I, B, F}(exo=exo, mode=mode, init=init)
end

"""
"""
function ExodusDatabase(file_name::String, mode::String)
  if mode == "r"
    ex_mode = EX_READ
  elseif mode == "rw" || (mode == "w" && !isfile(file_name))
    ex_mode = EX_WRITE
  elseif mode == "w" && isfile(file_name)
    ex_mode = EX_CLOBBER
  else
    mode_error(mode)
  end

  # get exodus
  if mode == "w" && !isfile(file_name)
    exo = @ccall libexodus.ex_create_int(
      file_name::Cstring, EX_WRITE::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_create_int")
  else
    exo = @ccall libexodus.ex_open_int(
      file_name::Cstring, ex_mode::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      version_number::Ref{Cfloat}, EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_open_int")
  end

  int64_status = @ccall libexodus.ex_int64_status(exo::Cint)::UInt32
  float_size   = @ccall libexodus.ex_inquire_int(exo::Cint, EX_INQ_DB_FLOAT_SIZE::ex_inquiry)::Cint

  M = map_int_type(int64_status)
  I = id_int_type(int64_status)
  B = bulk_int_type(int64_status)
  F = float_type(float_size)

  # init read or write
  # if mode == "r" || mode == "rw"
  #   init = Initialization(exo, B)
  # elseif mode == "w" && isfile(file_name)
  #   init = Initialization(exo, B)
  # else
  #   init = Initialization(B)
  # end

  return ExodusDatabase(exo, mode, M, I, B, F)
end

function ExodusDatabase(
  file_name::String, mode::String, init::Initialization{B},
  ::Type{M}, ::Type{I}, ::Type{B}, ::Type{F}
) where {M, I, B, F}
  
  if mode != "w"
    # throw(ModeException("You can only use write mode with this method"))
    mode_error("You can only use write mode with this method!")
  end

  # trying out different float sizes
  exo = @ccall libexodus.ex_create_int(
    file_name::Cstring, EX_WRITE::Cint, 
    # sizeof(F)::Ref{Cint}, sizeof(F)::Ref{Cint}, 
    cpu_word_size::Ref{Cint}, sizeof(F)::Ref{Cint},
    EX_API_VERS_NODOT::Cint
  )::Cint
  exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_create_int")

  int_modes = 0x00000000
  if M == Int64
    int_modes = int_modes | EX_MAPS_INT64_API
  end

  if I == Int64
    int_modes = int_modes | EX_IDS_INT64_API
  end

  if B == Int64
    int_modes = int_modes | EX_BULK_INT64_API
  end

  if int_modes != 0x00000000
    error = @ccall libexodus.ex_set_int64_status(exo::Cint, int_modes::Cint)::Cint
    exodus_error_check(error, "Exodus.ExodusDatabase -> libexodus.ex_set_int64_status")
  end

  write_initialization!(exo, init)

  # setup caches
  cache_M, cache_I, cache_B, cache_F = M[], I[], B[], F[]
  
  # finally return the ExodusDatabase
  return ExodusDatabase{M, I, B, F}(
    exo, mode, init,
    cache_M, cache_I, cache_B, cache_F
  )
end

"""
Used to close and ExodusDatabase.
"""
function Base.close(exo::ExodusDatabase)
  error_code = @ccall libexodus.ex_close(get_file_id(exo)::Cint)::Cint
  exodus_error_check(error_code, "Exodus.close -> libexodus.ex_close")
end

"""
Used to copy an ExodusDatabase. As of right now this is the best way to create a new ExodusDatabase
for output. Not all of the put methods have been wrapped and properly tested. This one has though.
"""
function Base.copy(exo::E, new_file_name::String) where {E <: ExodusDatabase}
  int64_status = @ccall libexodus.ex_int64_status(get_file_id(exo)::Cint)::UInt32
  # TODO maybe make options an optional argument
  options = EX_CLOBBER | int64_status
  new_exo_id = @ccall libexodus.ex_create_int(
    new_file_name::Cstring, options::Cint, cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, EX_API_VERS_NODOT::Cint
  )::Cint
  exodus_error_check(new_exo_id, "Exodus.copy -> libexodus.ex_create_int")
  # first make a copy
  error_code = @ccall libexodus.ex_copy(get_file_id(exo)::Cint, new_exo_id::Cint)::Cint
  exodus_error_check(error_code, "Exodus.copy -> libexodus.ex_copy")
  # now close the exodus file
  error_code = @ccall libexodus.ex_close(new_exo_id::Cint)::Cint
  exodus_error_check(error_code, "Exodus.close -> libexodus.ex_close")
end
