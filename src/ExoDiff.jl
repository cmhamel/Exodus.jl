# TODO add relevant options to macro
# check exodiff -h for all the options from
# a regular seacas build
"""
"""
macro exodiff(ex_1, ex_2)
  ex_1, ex_2 = abspath(ex_1), abspath(ex_2)
  exodiff_output = @capture_out @capture_err exodiff_exe() do exe
    run(`$exe $ex_1 $ex_2`, wait=true)
  end
  open("exodiff.log", "w") do file
    write(file, exodiff_output)
  end
end

function exodiff(ex_1::String, ex_2::String)
  if Sys.iswindows()
    exodus_windows_error()
  end

  ex_1, ex_2 = abspath(ex_1), abspath(ex_2)
  exodiff_output = @capture_out @capture_err exodiff_exe() do exe
    run(`$exe $ex_1 $ex_2`, wait=true)
  end
  open("exodiff.log", "w") do file
    write(file, exodiff_output)
  end
end