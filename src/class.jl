export SummarizedExperiment
import DataFrames
import DataStructures

"""
The `SummarizedExperiment` class is a Bioconductor container for matrix-like data with row and column annotations.
Any number of matrices (also known as "assays") can be stored in the container, 
provided they are assigned to unique names and all have the same extents for the first two dimensions.

The row and column annotations are stored as `DataFrame`s, with number of rows equal to the number of assay rows and columns, respectively.
Any number and type of columns may be present in each `DataFrame`.
If no annotations are present, they should be empty `DataFrame`s with no columns.

Each instance may also contain arbitrary metadata not associated with the rows or columns.
"""
mutable struct SummarizedExperiment
    nrow::Int64
    ncol::Int64
    assays::DataStructures.OrderedDict{String,AbstractArray}
    rowdata::DataFrames.DataFrame
    coldata::DataFrames.DataFrame
    metadata::Dict{String,Any}

    @doc """
        SummarizedExperiment(assays, rowdata=DataFrame(), coldata=DataFrame(), metadata=Dict{String,Any}())

    Create an instance of a `SummarizedExperiment`.

    ```jldoctest
    julia> using DataFrames, DataStructures
    julia> assays = OrderedDict{String, AbstractArray}(
              "foobar" => [[1,2] [3,4] [5,6]], 
              "whee" => [[1.2,2.3] [3.4,4.5] [5.6,7.8]])
    julia> coldata = DataFrame(Treatment=["normal", "drug1", "drug2"])
    julia> x = SummarizedExperiments.SummarizedExperiment(assays, DataFrame(), coldata)
    2x3 SummarizedExperiments.SummarizedExperiment
      rowdata(0):
      coldata(1): Treatment
      metadata(0):
    ```
    """
    function SummarizedExperiment(
            assays::DataStructures.OrderedDict{String, AbstractArray},
            rowdata::DataFrames.DataFrame=DataFrames.DataFrame(),
            coldata::DataFrames.DataFrame=DataFrames.DataFrame(),
            metadata::Dict{String,Any}=Dict{String,Any}()
        )

        if length(assays) < 1
            throw(BoundsError("expected as least one array in 'assays'"))
        end

        refdims = size(first(assays).second)
        if length(refdims) < 2 
            throw(DimensionMismatch("'assays' should contain arrays with 2 or more dimensions"))
        end
        nrow = refdims[1]
        ncol = refdims[2]

        first_name = first(assays).first
        for (key, val) in assays
            dims = size(val)
            if length(dims) < 2 || dims[1] != nrow || dims[2] != ncol
                throw(DimensionMismatch("'assays[" * repr(key) * "]' and 'assays[" * repr(first_name) * "]' should have the same extents for the first 2 dimensions"))
            end
        end

        if size(rowdata)[2] > 0 && size(rowdata)[1] != nrow
            throw(DimensionMismatch("unexpected number of rows for 'rowdata"))
        end

        if size(coldata)[2] > 0 && size(coldata)[1] != ncol
            throw(DimensionMismatch("unexpected number of rows for 'coldata"))
        end

        new(nrow, ncol, assays, rowdata, coldata, metadata)
    end
end
