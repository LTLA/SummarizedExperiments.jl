@testset "Constructor tests" begin
    @testset "Empty constructor" begin
        x = SummarizedExperiment()

#        @test x.nrow == 0
#        @test x.ncol == 0
        @test length(x.assays) == 0
        @test size(x.rowdata) == (0, 1)
        @test size(x.coldata) == (0, 1)
        @test length(x.metadata) == 0
    end

    using DataStructures
    assays = OrderedDict{String, AbstractArray}(
       "foobar" => [[1,2] [3,4] [5,6]], 
       "whee" => [[1.2,2.3] [3.4,4.5] [5.6,7.8]])

    @testset "Default arguments" begin
        x = SummarizedExperiment(assays)
#        @test x.nrow == 2
#        @test x.ncol == 3
        @test length(x.assays) == 2
        @test size(x.rowdata) == (2, 1)
        @test size(x.coldata) == (3, 1)
        @test length(x.metadata) == 0
    end

    using DataFrames

    rowdata = DataFrame(name = ["Gene1", "Gene2"],
                        Features = ["Feat1", "Feat2"])
    coldata = DataFrame(name = ["Sample1", "Sample2", "Sample3"],
                        Treatment = ["normal", "drug1", "drug2"])
    metadata = Dict{String,Any}("foo" => "bar")

    @testset "Full arguments" begin
        x = SummarizedExperiment(assays, rowdata, coldata, metadata)
#        @test x.nrow == 2
#        @test x.ncol == 3
        @test length(x.assays) == 2
        @test size(x.rowdata) == (2, 2)
        @test size(x.coldata) == (3, 2)
        @test length(x.metadata) == 1
    end
end

