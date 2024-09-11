using Exodus
using Documenter
using Unitful

DocMeta.setdocmeta!(Exodus, :DocTestSetup, :(using Exodus); recursive=true)
unitful_ext = Base.get_extension(Exodus, :ExodusUnitfulExt)

makedocs(;
    modules=[Exodus, unitful_ext],
    authors="Craig M. Hamel <cmhamel32@gmail.com> and contributors",
    repo="https://github.com/cmhamel/Exodus.jl/blob/{commit}{path}#{line}",
    sitename="Exodus.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cmhamel.github.io/Exodus.jl/stable",
        edit_link="master",
        assets=String[],
        size_threshold=nothing
    ),
    pages=[
        "Exodus"           => "index.md",
        "Exodus Methods"   => "methods.md",
        "Exodus Types"     => "types.md",
        "ExodusUnitfulExt" => "unitful_ext.md"
    ],
)

deploydocs(;
    repo="github.com/cmhamel/Exodus.jl",
    # devbranch="master",
    devbranch="docs/revamp"
)
