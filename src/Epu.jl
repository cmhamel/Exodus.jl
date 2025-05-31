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
  run(`$(epu_exe()) --help`, wait=true)
end

"""
$(TYPEDSIGNATURES)
"""
function epu(file_name::String)
  @assert !Sys.iswindows()
  # @assert isfile(file_name) # figure out how to handle this

  epu_args = ["-auto", "$(abspath(file_name))"]
  
  # figure out how to get the directory correct
  # TODO maybe just look if the path is relative or absolute
  # and split that
  #
  stdout_file = "epu.log"
  stderr_file = "epu_err.log"

  try
    redirect_stdio(stdout=stdout_file, stderr=stderr_file) do 
      run(`$(epu_exe()) $epu_args`, wait=true)
    end
  catch
    epu_error(Cmd(`$(epu_exe()) $epu_args`))
  end

  # rm("epu_stderr.log", force=true)
end
