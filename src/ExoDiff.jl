"""
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
  exodiff_output = @capture_out @capture_err exodiff_exe() do exe
    pushfirst!(exo_cmd, "$exe")
    cmd = Cmd(exo_cmd)
    run(cmd, wait=true)
  end

  # write to a log file
  open("exodiff.log", "w") do file
    write(file, exodiff_output)
  end
end