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

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
