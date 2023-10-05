"""
Prints epu help message
"""
function epu()
  epu_exe() do exe
    run(`$exe --help`)
  end
end

"""
"""
function epu(file_name::String)
  if Sys.iswindows()
    exodus_windows_error()
  end

  file_name = abspath(file_name::String)
  epu_out = @capture_out @capture_err epu_exe() do exe
    run(`$exe -auto $file_name`, wait=true)
  end
  folder = abspath(dirname(file_name))
  open(joinpath(folder, "epu.log"), "w") do file
    write(file, epu_out)
  end
end