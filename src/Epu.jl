"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct EPUException{C} <: Exception
  cmd::C
end

"""
"""
Base.show(io::IO, e::EPUException) = 
print(io, "\n\nError running epu.\ncmd = $(e.cmd)\n\n")

"""
$(TYPEDSIGNATURES)
"""
epu_error(cmd) = throw(EPUException(cmd))


"""
$(TYPEDSIGNATURES)
Prints epu help message
"""
function epu()
  run(`$(epu_exe()) --help`)
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

  errors_found = false
  redirect_stdio(stdout=stdout_file, stderr=stderr_file) do 
    try
      run(`$(epu_exe()) $epu_args`, wait=true)
    catch
      errors_found = true
    end
  end

  if errors_found
    println("error in epu")
    epu_error(epu_args)
  end
  
  rm("epu_stderr.log", force=true)
end
