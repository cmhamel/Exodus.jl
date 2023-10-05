"""
"""
struct EPUException <: Exception
  cmd::Cmd
end

"""
"""
Base.show(io::IO, e::EPUException) = 
print(io, "\n\nError running epu.\ncmd = $(e.cmd)\n\n")

"""
"""
epu_error(cmd::Cmd) = throw(EPUException(cmd))


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

  epu_cmd = String["-auto", "$(abspath(file_name))"]
  
  errors_found = false
  epu_exe() do exe
    pushfirst!(epu_cmd, "$exe")
    cmd = Cmd(epu_cmd)

    redirect_stdio(stdout="epu.log", stderr="epu_stderr.log") do 
      try
        run(cmd, wait=true)
      catch
        errors_found = true
      end
    end

    if errors_found
      println("error in epu")
    end
  end
  
  rm("epu_stderr.log", force=true)
end