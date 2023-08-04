"""
"""
macro decomp(ex, n_procs)
  ex = abspath(ex)
  dir_name = dirname(ex) * "/" # TODO this will be an issue for windows
  base_name, mesh_ext = splitext(ex)
  nem_file = ex * ".nem"
  pex_file = ex * ".pex"
  log_file = dir_name * "decomp.log"
  # for n in 0:n_procs - 1
  #   rm(ex * "$n_procs." * lpa)
  # end
  rm(log_file, force=true)
  rm(nem_file, force=true)
  rm(pex_file, force=true)

  nem_slice_out = @capture_out @capture_err nem_slice_exe() do exe
    run(`$exe -e -S -l inertial -c -o $nem_file -m mesh=$n_procs $ex`, wait=true)
  end

  # now need to write pex file for nem_spread
  open(pex_file, "w") do file
    write(file, "Input FEM file                  = $ex\n")
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

  # now run nem_spread
  nem_spread_out = @capture_out @capture_err nem_spread_exe() do exe
    run(`$exe $pex_file`, wait=true)
  end

  # now write log file
  open(log_file, "w") do file
    write(file, nem_slice_out)
    write(file, nem_spread_out)
  end
end


function nem_slice(file_name::String, n_procs::I) where I <: Integer
  nem_file = file_name * ".nem"
  nem_slice_out = @capture_out @capture_err nem_slice_exe() do exe
    run(`$exe -e -S -l inertial -c -o $nem_file -m mesh=$n_procs $file_name`, wait=true)
  end
  return nem_slice_out
end

function nem_spread(file_name::String, n_procs::I) where I <: Integer
  nem_file = file_name * ".nem"
  pex_file = file_name * ".pex"
  dir_name = dirname(file_name) * "/" # TODO this will be an issue for windows
  # dir_name = file_name |> dirname |> abspath # doesn't do what I want it to
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

  nem_spread_out = @capture_out @capture_err nem_spread_exe() do exe
    run(`$exe $pex_file`, wait=true)
  end

  return nem_spread_out
end

"""
"""
function decomp(file_name::String, n_procs::I) where I <: Integer
  # some file management up front
  # WARNING by default it removes old files
  file_name_abs = abspath(file_name)
  Base.rm(file_name_abs * ".nem", force=true)
  Base.rm(file_name_abs * ".pex", force=true)
  Base.rm(joinpath(dirname(file_name_abs), "decomp.log"), force=true)
  for n in 0:n_procs - 1
    Base.rm(file_name_abs * ".$n_procs.$n", force=true)
  end
  # nem slice first
  nem_slice_out = nem_slice(file_name_abs, n_procs)
  # now nem spread
  nem_spread_out = nem_spread(file_name_abs, n_procs)
  # now write log file
  log_file = joinpath(dirname(file_name_abs), "decomp.log")
  open(log_file, "w") do file
    write(file, nem_slice_out)
    write(file, nem_spread_out)
  end
end
