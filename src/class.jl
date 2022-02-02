export SummarizedExperiment
import DataFrames
import DataStructures

mutable struct SummarizedExperiment
    assays::DataStructures.OrderedDict{String,AbstractArray}
    rowdata::DataFrames.DataFrame
    coldata::DataFrames.DataFrame
    metadata::Dict{String,Any}

    function SummarizedExperiment(
            assays::DataStructures.OrderedDict{String, AbstractArray},
            rowdata::Union{DataFrames.DataFrame,Vector{String},Nothing},
            coldata::Union{DataFrames.DataFrame,Vector{String},Nothing},
            metadata::Union{Dict{String,Any},Nothing}
        )

        if length(assays) < 1
            throw(BoundsError("expected as least one array in 'assays'"))
        end

        refdims = size(first(assays).second)
        if length(refdims) < 2 
            throw(DimensionMismatch("'assays' should contain arrays with 2 or more dimensions"))
        end

        first_name = first(assays).first
        for (key, val) in assays
            check_assay_dims(size(val), refdims, "assays['" * repr(key) * "']", "assays['" * repr(first_name) * "']")
        end

        _rowdata = create_input_DataFrame(refdims[1], rowdata, "rowdata")
        _coldata = create_input_DataFrame(refdims[2], coldata, "coldata")

        _metadata = Dict{String,Any}()
        if isa(metadata, Dict{String,Any})
            _metadata = metadata
        end

        new(assays, _rowdata, _coldata, _metadata)
    end
end
