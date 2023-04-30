macro epu(ex)
  ex = abspath(ex)
  epu_out = @capture_out @capture_err epu_exe() do exe
    run(`$exe -auto $ex`)
  end
  open("epu.log", "w") do file
    write(file, epu_out)
  end
end

export @epu
