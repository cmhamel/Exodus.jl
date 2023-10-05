"""
"""
struct ExodiffException <: Exception
  cmd::Cmd
end

Base.show(io::IO, e::ExodiffException) = 
print(io, "\n\nError running exodiff.\ncmd = $(e.cmd)\n\n")

exodiff_error(cmd::Cmd) = throw(ExodiffException(cmd))

"""
Return true if the two files pass the exodiff test. Otherwise it returns false
"""
function exodiff(
  ex_1::String, 
  ex_2::String;
  command_file = nothing
)
  if Sys.iswindows()
    exodus_windows_error()
  end

  exo_cmd = String[]

  if command_file !== nothing
    push!(exo_cmd, "-f")
    push!(exo_cmd, abspath(command_file))
  end

  # push files to compare to command list
  push!(exo_cmd, abspath(ex_1))
  push!(exo_cmd, abspath(ex_2))

  # finally run the command
  errors_found = false
  exodiff_exe() do exe
    pushfirst!(exo_cmd, "$exe")
    cmd = Cmd(exo_cmd)

    redirect_stdio(stdout="exodiff.log", stderr="exodiff_stderr.log") do 
      try
        run(cmd, wait=true)
      catch
        errors_found = true
      end
    end
  end

  # now handle errors
  return_bool = false
  if errors_found
    open("exodiff_stderr.log") do f 
      words = read(f, String) |> lowercase

      # look for no such file error
      if contains(words, "no such file")
        println("\n\nFile not found error in exodiff\n\n")
        exodiff_error(Cmd(exo_cmd))
      end
    end
    
    return_bool = false
  else
    return_bool = true
  end

  rm("exodiff_stderr.log", force=true)
  return return_bool
end