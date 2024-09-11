using Exodus
using Documenter
using Meshes
using Unitful

DocMeta.setdocmeta!(Exodus, :DocTestSetup, :(using Exodus); recursive=true)
meshes_ext = Base.get_extension(Exodus, :ExodusMeshesExt)
unitful_ext = Base.get_extension(Exodus, :ExodusUnitfulExt)
@show meshes_ext
@show unitful_ext
makedocs(;
    modules=[Exodus, meshes_ext, unitful_ext],
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
        "ExodusMeshesExt"  => "meshes_ext.md",
        "ExodusUnitfulExt" => "unitful_ext.md"
    ],
)

deploydocs(;
    repo="github.com/cmhamel/Exodus.jl",
    devbranch="master"
)
