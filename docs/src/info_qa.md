# Info & QA Records

Exodus files can carry free-form metadata records: **info records** (arbitrary lines of text) and **QA records** (a structured log of which programs have processed the file).

## Info records

```julia
write_info(exo, ["info entry 1", "info entry 2", "info entry 3"])
info = read_info(exo)   # Vector{String}
```

## QA records

A QA record is a `num_records x 4` matrix of strings; each row is typically `[code_name, code_qa_descriptor, date, time]`.

```julia
write_qa(exo, qa_record)   # qa_record::Matrix{String}, size (n, 4)
qa = read_qa(exo)
```
