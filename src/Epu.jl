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
  return nothing
end

"""
$(TYPEDSIGNATURES)
"""
function epu(file_name::String)
  @assert !Sys.iswindows()
  # @assert isfile(file_name) # figure out how to handle this
  file_dir = dirname(file_name)
  if file_dir == ""
    file_dir = pwd()
  end
  epu_args = [
    "-auto", "$(abspath(file_name))",
    # below option ensures we write to same directory as file_name
    "-current_dirrectory", file_dir,
    "-root_directory", file_dir
  ]
  
  # error handling files (make this optional eventually)
  stdout_file = abspath("$file_dir/epu.log")
  stderr_file = abspath("$file_dir/epu_err.log")
  cd(file_dir) do
    try
      redirect_stdio(stdout=stdout_file, stderr=stderr_file) do
        run(`$(epu_exe()) $epu_args`, wait=true)
      end
    catch
      epu_error(Cmd(`$(epu_exe()) $epu_args`))
    end
  end

  # just make sure there's no erros
  open(stderr_file, "r") do f
    lines = readlines(f)
    @assert lines == String[] "Non-empty error file in epu"
  end

  rm(stderr_file, force=true)
  return nothing
end
