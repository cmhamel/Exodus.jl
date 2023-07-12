"""
"""
macro epu(ex)
  ex = abspath(ex)
  epu_out = @capture_out @capture_err epu_exe() do exe
    run(`$exe -auto $ex`, wait=true)
  end
  folder = abspath(dirname(ex))
  # folder = dirname
  # open(folder * "epu.log", "w") do file
  open(joinpath(folder, "epu.log"), "w") do file
    write(file, epu_out)
  end
end
