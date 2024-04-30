push!(LOAD_PATH,"../")

using Documenter, CoNLLU

makedocs(;
    modules=[CoNLLU],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/asbisen/CoNLLU.jl/blob/{commit}{path}#L{line}",
    sitename="CoNLLU.jl",
    authors="asbisen <asbisen@icloud.com>"
)

deploydocs(;
    repo="github.com/asbisen/CoNLLU.jl",
)