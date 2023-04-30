"""
"""
macro decomp(ex, n_procs)
  ex = abspath(ex)
  dir_name = dirname(ex) * "/" # TODO this will be an issue for windows
  base_name, mesh_ext = splitext(ex)
  nem_file = ex * ".nem"
  pex_file = ex * ".pex"
  log_file = dir_name * "decomp.log"
  run(`rm -rf $pex_file`) 

  nem_slice_out = @capture_out @capture_err nem_slice_exe() do exe
    run(`$exe -e -S -l inertial -c -o $nem_file -m mesh=$n_procs $ex`)
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
    run(`$exe $pex_file`)
  end

  # now write log file
  open(log_file, "w") do file
    write(file, nem_slice_out)
    write(file, nem_spread_out)
  end
end

export @decomp
