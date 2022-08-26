using Documenter
using Exodus

makedocs(
    sitename = "Exodus",
    format = Documenter.HTML(),
    modules = [Exodus]
)

deploydocs(
    repo = "github.com/cmhamel/Exodus.jl.git"
)
