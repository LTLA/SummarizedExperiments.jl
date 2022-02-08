export SummarizedExperiment
import DataFrames
import DataStructures

function check_dataframe_has_name(x::DataFrames.DataFrame)
    return size(x)[2] >= 1 && names(x)[1] == "name"
end

function check_dataframe_firstcol(x::DataFrames.DataFrame)
    first = x[!,1]
    return isa(first, Vector{String}) || isa(first, Vector{Nothing})
end

function check_dataframe_in_constructor(x::DataFrames.DataFrame, expected::Int, message::String)
    if size(x)[1] != expected 
        throw(DimensionMismatch("unexpected number of rows for '" * message * "'"))
    end

    if !check_dataframe_has_name(x)
        throw(ArgumentError("first column of '" * message * "' should be 'name'"))
    end

    if !check_dataframe_firstcol(x)
        throw(ArgumentError("first column of '" * message * "' should contain strings or nothings"))
    end
end

function check_assay_dimensions(dims::Tuple{Vararg{Int}}, ref::Tuple{Vararg{Int}})
    return length(dims) >= 2 && dims[1] == ref[1] && dims[2] == ref[2]
end

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
    assays::DataStructures.OrderedDict{String,AbstractArray}
    rowdata::DataFrames.DataFrame
    coldata::DataFrames.DataFrame
    metadata::Dict{String,Any}

    @doc """
        SummarizedExperiment()

    Create an empty `SummarizedExperiment`.
    """
    function SummarizedExperiment()
        return SummarizedExperiment(
           DataStructures.OrderedDict{String,AbstractArray}(), 
           nothing,
           nothing,
           Dict{String,Any}()
        )
    end

    @doc """
        SummarizedExperiment(assays, rowdata=nothing, coldata=nothing, metadata=Dict{String,Any}())

    Create an instance of a `SummarizedExperiment` with the supplied assays and the (optional) row/column annotations.

    All entries of `assays` should have the same extents for the first two dimensions.
    However, they can otherwise have any number of other dimensions.
    Each assay can be of different type.

    If a `DataFrame` is supplied to `rowdata`, the number of rows must be equal to the extent of the first dimension for any entry in `assays`.
    Similarly, for a `DataFrame` in `coldata`, the number of rows must be equal to the extnt of the second dimension.
    The first column must be called `"name"` and contain a `Vector` of `String`s or `Nothing`s (if no names are available).
    If `nothing` is supplied, an empty `DataFrame` is created with a `"name"` column containing all `nothing`s.

    # Examples
    ```jldoctest
    julia> using SummarizedExperiments

    julia> using DataFrames, DataStructures

    julia> assays = OrderedDict{String, AbstractArray}(
              "foobar" => [[1,2] [3,4] [5,6]], 
              "whee" => [[1.2,2.3] [3.4,4.5] [5.6,7.8]]);

    julia> coldata = DataFrame(
              name = [ "a", "b", "c" ],
              treatment = ["normal", "drug1", "drug2"]);

    julia> x = SummarizedExperiment(assays, nothing, coldata)
    2x3 SummarizedExperiment
      assays(2): foobar whee
      rowdata(0):
      coldata(1): Treatment
      metadata(0):
    ```
    """
    function SummarizedExperiment(
            assays::DataStructures.OrderedDict{String, AbstractArray},
            rowdata::Union{DataFrames.DataFrame,Nothing} = nothing,
            coldata::Union{DataFrames.DataFrame,Nothing} = nothing,
            metadata::Dict{String,Any} = Dict{String,Any}()
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
            if !check_assay_dimensions(size(val), refdims)
                throw(DimensionMismatch("'assays[" * repr(key) * "]' and 'assays[" * repr(first_name) * 
                    "]' should have the same extents for the first 2 dimensions"))
            end
        end

        nrow = refdims[1]
        if isa(rowdata, Nothing)
            rowdata = DataFrames.DataFrame(name = Vector{Nothing}(undef, nrow))
        else
            check_dataframe_in_constructor(rowdata, nrow, "rowdata")
        end

        ncol = refdims[2]
        if isa(coldata, Nothing)
            coldata = DataFrames.DataFrame(name = Vector{Nothing}(undef, ncol))
        else
            check_dataframe_in_constructor(coldata, ncol, "coldata")
        end

        new(assays, rowdata, coldata, metadata)
    end
end
