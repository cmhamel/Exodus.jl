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
function exo_int_types(exoid::Cint)
  int64_status = @ccall libexodus.ex_int64_status(exoid::Cint)::UInt32
  # TODO need better checks for non 32 bit case
  if int64_status == 0x0000
    maps_int_type = Cint
    ids_int_type = Cint
    bulk_int_type = Cint
    # TODO this will break for non 32 bit case
    # TODO figure out other cases from hex codes in exodusII.h
  end
  return maps_int_type, ids_int_type, bulk_int_type
end

"""
"""
function exo_float_type(exoid::Cint)
  float_size = @ccall libexodus.ex_inquire_int(exoid::Cint, EX_INQ_DB_FLOAT_SIZE::ex_inquiry)::Cint
  exodus_error_check(float_size, "Exodus.exo_float_type -> libexodus.ex_inquire_int")
  # this is more straightforward
  if float_size == 4
    float_type = Cfloat
  elseif float_size == 8
    float_type = Cdouble
  end
  return float_type
end

"""
Init method for read/read-write
"""
function ExodusDatabase(file_name::String, mode::String)
  if lowercase(mode) == "r"
    exo = @ccall libexodus.ex_open_int(
      file_name::Cstring, EX_READ::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      version_number::Ref{Cfloat}, EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_open_int")

    M, I, B = exo_int_types(exo)
    F       = exo_float_type(exo)
    
    exo_temp = ExodusDatabase{M, I, B, F}(exo, "r", Initialization(B))

    # init = Initialization(exo)
    init = Initialization(exo_temp)
    return ExodusDatabase{M, I, B, F}(exo, mode, init)
  # elseif lowercase(mode) == "w"
    # exo = 
  elseif lowercase(mode) == "rw"
    exo = @ccall libexodus.ex_open_int(
      file_name::Cstring, EX_WRITE::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      version_number::Ref{Cfloat}, EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_open_int")

    M, I, B = exo_int_types(exo)
    F       = exo_float_type(exo)
    exo_temp = ExodusDatabase{M, I, B, F}(exo, "r", Initialization(B))
    init = Initialization(exo_temp)
    return ExodusDatabase{M, I, B, F}(exo, mode, init)
  # elseif lowercase(mode) == "w"
  #   exo = ex_create(file_name, EX_WRITE, cpu_word_size, IO_word_size)
  #   maps_int_type, ids_int_type, bulk_int_type = Int32, Int32, Int32
  else
    throw(ErrorException("Invalid mode"))
  end
end

"""
"""
function ExodusDatabase(
  file_name::String;
  maps_int_type::Type = Int32, ids_int_type::Type = Int32, 
  bulk_int_type::Type = Int32, float_type::Type = Float64,
  num_dim::I = 0, num_nodes::I = 0, num_elems::I = 0,
  num_elem_blks::I = 0, num_node_sets::I = 0, num_side_sets::I = 0
) where {I <: Integer}

  if isfile(file_name)
    exo = @ccall libexodus.ex_open_int(
      file_name::Cstring, EX_CLOBBER::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      version_number::Ref{Cfloat}, EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_open_int")
    exo_temp = ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo, "rw", Initialization(bulk_int_type))
    init = Initialization(exo_temp)
    return ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(exo, "rw", init)
  else
    exo = @ccall libexodus.ex_create_int(
      file_name::Cstring, EX_WRITE::Cint, cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_create_int")

    # below is what they do in the example but this is weirdly throwing an error
    # exo = @ccall libexodus.ex_create_int(
    #   file_name::Cstring, EX_CLOBBER::Cint, Ref{Cint}(0)::Ref{Cint}, Ref{Cint}(4)::Ref{Cint}, EX_API_VERS_NODOT::Cint
    # )::Cint
    # exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_create_int")

    init = Initialization{bulk_int_type}(
      num_dim, num_nodes, num_elems,
      num_elem_blks, num_node_sets, num_side_sets
    )
    write_initialization!(exo, init)
    return ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(
      exo, "w", init
    )
  end
end

"""
"""
function ExodusDatabase(
  file_name::String, init::Initialization;
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
