
"""
ARGS[1] should be the path to exodus e.g.
~/seacas/packages/seacas/libraries/exodus
"""
exodus_files = readdir(joinpath(ARGS[1], "src"))
# exodus_files = readdir("/home/fractalmagic/seacas/packages/seacas/libraries/exodus/src/")
methods = []
for f in exodus_files
  if contains(f, ".c") || contains(f, ".C")
    push!(methods, splitext(f)[1])
  end
end

# setup dict to track methods
d = Dict{String, Integer}()
for method in methods
  d[method] = 0
end

julia_files = readdir("src")
for f in julia_files
  if contains(f, ".jl")
    lines = readlines(joinpath("src", f))
    for line in lines
      if contains(line, "libexodus") && !contains(line, "exodus_error_check") && contains(line, ".")
        method = split(line, "@ccall")[2]
        method = split(method)[1]
        method = split(method, "(")[1]
        method = split(method, ".")[2]
        # @show method
        if method == "ex_create_int"
          d["ex_create"] = d["ex_create"] + 1
        elseif method == "ex_inquire_int"
          d["ex_inquire"] = d["ex_inquire"] + 1
        elseif method == "ex_open_int"
          d["ex_open"] = d["ex_open"] + 1
        elseif method == "ex_set_max_name_length"
          d["ex_utils"] = d["ex_utils"] + 1
        end

        try
          d[method] = d[method] + 1
          if method == "ex_open_int"
            d["ex_open"] = 1
          end
        catch KeyError
          println("Skipping $method")
        end

        
      end
    end
  end
end

total_misses = 0
total_files = 0
for key in keys(d)
  global total_files = total_files + 1
  if d[key] == 0
    global total_misses = total_misses + 1
    println("Missed method: $key")
  end

end

println("Total missed files = $total_misses out of total files = $total_files")
println("Total percentage of files covered = ", (total_files - total_misses) / total_files * 100.0, "%")