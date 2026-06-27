using Clang.Generators
using Exodus_jll

function patch!(ctx)
    Clang.Generators.walk!(ctx.dag) do node
        if node isa Clang.Generators.FunctionDecl
            for arg in node.args
                if arg.type == :(Ptr{Cvoid})
                    arg.type = :(Ptr{Cfloat})
                end
            end

            if node.rettype == :(Ptr{Cvoid})
                node.rettype = :(Ptr{Cfloat})
            end
        end
    end
end

cd(@__DIR__)

include_dir = normpath(Exodus_jll.artifact_dir, "include")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

# only wrap libclang headers in include/clang-c
display(readdir(include_dir))
# include_dir = joinpath(include_dir, "clang-c")
# headers = [joinpath(include_dir, header) for header in readdir(include_dir) if endswith(header, ".h")]
headers = String[]
for header in readdir(include_dir)
    if endswith(header, ".h")
        # if "zoltan" in header
        if occursin("zoltan", header)
            continue
        end
        push!(headers, joinpath(include_dir, header))
    end
end

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)