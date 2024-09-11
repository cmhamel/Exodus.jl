"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct NemSliceException <: Exception
  cmd::Cmd
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct NemSpreadException <: Exception
  cmd::Cmd
end

"""
"""
function Base.show(io::IO, e::NemSliceException)
  print(io, "\n\nError in nem_slice.\ncmd = $(e.cmd)\n\n")
end

"""
"""
function Base.show(io::IO, e::NemSpreadException)
  print(io, "\n\nError in nem_spread.\ncmd = $(e.cmd)\n\n")
end

"""
$(TYPEDSIGNATURES)
"""
nem_slice_error(cmd::Cmd) = throw(NemSliceException(cmd))

"""
$(TYPEDSIGNATURES)
"""
nem_spread_error(cmd::Cmd) = throw(NemSpreadException(cmd))

"""
$(TYPEDSIGNATURES)
"""
function nem_slice()
  nem_slice_exe() do exe
    run(`$exe -help`)
  end
end

"""
$(TYPEDSIGNATURES)
"""
function nem_slice(file_name::String, n_procs::I) where I <: Integer
  nem_file = file_name * ".nem"
  dir_name = dirname(file_name) * "/" # TODO this will be an issue for windows
  stdout_file = joinpath(dir_name, "decomp.log")
  stderr_file = joinpath(dir_name, "decomp_err.log")
  nem_slice_cmd = String["-e", "-S", "-l", "inertial", "-c", "-o",
                         "$(abspath(nem_file))", "-m", 
                         "mesh=$n_procs", "$file_name"]

  nem_slice_exe() do exe
    pushfirst!(nem_slice_cmd, "$exe")
    cmd = Base.Cmd(nem_slice_cmd)

    redirect_stdio(stdout=open(stdout_file, "w"), 
                   stderr=open(stderr_file, "w")) do 
      try
        run(cmd, wait=true)
      catch
        nem_slice_error(Base.Cmd(cmd))
      end
    end
  end
end

"""
$(TYPEDSIGNATURES)
"""
function nem_spread()
  nem_slice_exe() do exe
    run(`$exe -help`)
  end
end

"""
$(TYPEDSIGNATURES)
"""
function nem_spread(file_name::String, n_procs::I) where I <: Integer
  nem_file = file_name * ".nem"
  pex_file = file_name * ".pex"
  dir_name = dirname(file_name) * "/" # TODO this will be an issue for windows
  stdout_file = joinpath(dir_name, "decomp.log")
  stderr_file = joinpath(dir_name, "decomp_err.log")
  @show stdout_file
  @show stderr_file
  base_name, mesh_ext = splitext(file_name)
  # now need to write pex file for nem_spread
  open(pex_file, "w") do file
    write(file, "Input FEM file                  = $file_name\n")
    write(file, "LB file                         = $nem_file\n")
    write(file, "Parallel Results File Base Name = $base_name\n")
    write(file, "File Extension for Spread Files = $mesh_ext\n")
    write(file, "Number of Processors            = $n_procs\n")
    write(file, "------------------------------------------------------------\n")
    write(file, "                Parallel I/O section                        \n")
    write(file, "------------------------------------------------------------\n")
    write(file, "Parallel Disk Info= number=1, offset=1, zeros, nosubdirectory\n")
    write(file, "Parallel file location = root=$dir_name, subdir=.\n")
  end

  # errors_found = false
  nem_spread_exe() do exe
    redirect_stdio(stdout=open(stdout_file, "w+"), 
                   stderr=open(stderr_file, "w+")) do 
      try
        run(`$exe $pex_file`, wait=true)
      catch
        # errors_found = true
        nem_spread_error(Base.Cmd(`$exe $pex_file`))
      end
    end
  end

  # if errors_found
  #   nem_spread_error(Base.Cmd(cmd))
  # end
end

"""
$(TYPEDSIGNATURES)
"""
function decomp(file_name::String, n_procs::I) where I <: Integer
  @assert !Sys.iswindows() "This method is not supported on Windows"
  @assert isfile(file_name) "File $file_name not found in decomp. Can't proceed."

  file_name_abs = abspath(file_name)
  dir_name = dirname(file_name) * "/" # TODO this will be an issue for windows
  stdout_file = joinpath(dir_name, "decomp.log")
  stderr_file = joinpath(dir_name, "decomp_err.log")
  Base.rm(file_name_abs * ".nem", force=true)
  Base.rm(file_name_abs * ".pex", force=true)
  Base.rm(stdout_file, force=true)
  Base.rm(stderr_file, force=true)
  for n in 0:n_procs - 1
    Base.rm(file_name_abs * ".$n_procs.$n", force=true)
  end

  # nem slice first
  nem_slice(file_name_abs, n_procs)
  # now nem spread
  nem_spread(file_name_abs, n_procs)

  # TODO add errors

  # if we made it here, we have no errors, at least I think?
  rm(stderr_file, force=true)
end
