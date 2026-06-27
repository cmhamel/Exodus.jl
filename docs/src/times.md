# Time Steps

```julia
n_steps = read_number_of_time_steps(exo)

t = read_time(exo, 1)             # time value at step 1
times = read_times(exo)           # Vector of all time values

write_time(exo, 1, 0.0)           # write the time value for step 1
```

Time steps are 1-indexed, matching Exodus/Fortran convention. When writing transient field data with [`write_values`](@ref) (see [Variables](@ref)), make sure a time value has been written for every `timestep` you reference with `write_time` first.
