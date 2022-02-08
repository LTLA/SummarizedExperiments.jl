import DataStructures
import DataFrames
export exampleobject

"""
    exampleobject(nrow, ncol)

Create an example `SummarizedExperiment` object with the specified number of rows and columns.
This is to be used to improve the succinctness of examples and tests.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10)
20x10 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene19 Gene20
  rowdata(2): name Type
  colnames: Patient1 Patient2 ... Patient9 Patient10
  coldata(3): name Treatment Response
  metadata(1): version
```
"""
function exampleobject(nrow::Int64, ncol::Int64) 
    first_assay = Array{Int64, 2}(undef, (nrow, ncol))
    for i in 1:length(first_assay)
        first_assay[i] = round(rand() * 100)
    end

    second_assay = Array{Float64, 2}(undef, (nrow, ncol))
    for i in 1:length(second_assay)
        second_assay[i] = rand()
    end

    third_assay = Array{Float32, 3}(undef, (nrow, ncol, 2))
    for i in 1:length(third_assay)
        third_assay[i] = -rand()
    end

    assays = DataStructures.OrderedDict{String, AbstractArray}(
        "foo" => first_assay, 
        "bar" => second_assay, 
        "whee" => third_assay
    )

    tchoices = ["normal", "drug1", "drug2"]
    coldata = DataFrames.DataFrame(
        "name" => [ "Patient" * string(i) for i in 1:ncol ],
        "Treatment" => [ tchoices[Int(floor(rand() * length(tchoices) + 1))] for i in 1:ncol ],
        "Response" => [ rand() for i in 1:ncol ]
    )

    gchoices = ["Protein-coding", "Pseudogene"]
    rowdata = DataFrames.DataFrame(
        "name" => [ "Gene" * string(i) for i in 1:nrow ],
        "Type" => [ gchoices[Int(floor(rand() * length(gchoices) + 1))] for i in 1:nrow ]
    )

    metadata = Dict{String,Any}("version" => "1.1.0")
    return SummarizedExperiment(assays, rowdata, coldata, metadata)
end
