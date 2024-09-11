"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct EPUException <: Exception
  cmd::Cmd
end

"""
"""
Base.show(io::IO, e::EPUException) = 
print(io, "\n\nError running epu.\ncmd = $(e.cmd)\n\n")

"""
$(TYPEDSIGNATURES)
"""
epu_error(cmd::Cmd) = throw(EPUException(cmd))


"""
$(TYPEDSIGNATURES)
Prints epu help message
"""
function epu()
  epu_exe() do exe
    run(`$exe --help`)
  end
end

"""
$(TYPEDSIGNATURES)
"""
function epu(file_name::String)
  @assert !Sys.iswindows()
  # @assert isfile(file_name) # figure out how to handle this

  epu_cmd = String["-auto", "$(abspath(file_name))"]
  
  # figure out how to get the directory correct
  # TODO maybe just look if the path is relative or absolute
  # and split that
  #
  stdout_file = "epu.log"
  stderr_file = "epu_err.log"

  errors_found = false
  epu_exe() do exe
    pushfirst!(epu_cmd, "$exe")
    cmd = Cmd(epu_cmd)

    redirect_stdio(stdout=stdout_file, stderr=stderr_file) do 
      try
        run(cmd, wait=true)
      catch
        errors_found = true
      end
    end

    if errors_found
      println("error in epu")
      epu_error(cmd)
    end
  end
  
  rm("epu_stderr.log", force=true)
end
