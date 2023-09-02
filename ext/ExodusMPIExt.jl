module ExodusMPIExt

using Exodus
using Exodus_with_MPI_jll
using MPI

function Exodus.ExodusDatabase(file_name::String, mode::String, comm::MPI.Comm, info::MPI.Info;
                               use_cache_arrays::Bool = false)
  # @show comm

  if mode == "r"
    ex_mode = Exodus.EX_READ
  elseif mode == "rw"
    ex_mode = Exodus.EX_WRITE
  elseif mode == "w" && isfile(file_name)
    ex_mode = Exodus.EX_CLOBBER
  else
    mode_error(mode)
  end

  exo = @ccall libexodus_with_mpi.ex_open_par_int(
    file_name::Cstring, 
    ex_mode::Cint, 
    Exodus.cpu_word_size::Ref{Cint}, 
    Exodus.IO_word_size::Ref{Cint}, 
    Exodus.version_number::Ref{Cfloat}, 
    comm::MPI.Comm, info::MPI.Info,
    Exodus.EX_API_VERS_NODOT::Cint
  )::Cint
  Exodus.exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_open_par_int")
  M, I, B, F = Exodus.int_and_float_types(exo)

  if use_cache_arrays
    println("WARNING: Arrays returned from methods in this mode will change")
    println("WARNING: with subsequent method calls so use wisely!!!\n\n")
  end

  exo_db = ExodusDatabase(exo, mode, file_name, M, I, B, F; use_cache_arrays=use_cache_arrays)

  for type in [Block, NodeSet, SideSet]
    ids   = read_ids(exo_db, type)
    names = read_names(exo_db, type)
    for (n, name) in enumerate(names)
      set_name_dict(exo_db, type)[name] = ids[n]
    end
  end

  for type in [ElementVariable, GlobalVariable, NodalVariable, NodeSetVariable, SideSetVariable]
    ids   = 1:read_number_of_variables(exo_db, type)
    names = read_names(exo_db, type)
    for (n, name) in enumerate(names)
      var_name_dict(exo_db, type)[name] = ids[n]
    end
  end

  return exo_db
end

end # ExodusMPIExt