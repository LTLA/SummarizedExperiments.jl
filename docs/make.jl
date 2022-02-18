using SummarizedExperiments
using Documenter
import DataStructures
import DataFrames

makedocs(
    sitename="SummarizedExperiments.jl",
    modules = [SummarizedExperiments],
    pages=[
        "Home" => "index.md"
    ]
)

deploydocs(;
    repo="github.com/LTLA/SummarizedExperiments.jl",
)

