using Test
@testset "SummarizedExperiments.jl" begin
using SummarizedExperiments, Documenter
doctest(SummarizedExperiments)
include("class.jl")
end
