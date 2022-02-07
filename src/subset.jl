import DataStructures

Base.IndexStyle(x::SummarizedExperiment) = IndexCartesian()

"""
    getindex(x::SummarizedExperiment, I...)

Subset `x` by the rows or columns based on the first and second arguments to `I`, respectively.
Types for the arguments to `I` are similar to those for arrays:

- An integer `Vector` containing indices.
- An `Int` containing a single index.
- A boolean `Vector` of length equal to the relevant dimension,
  indicating whether each entry of that dimension should be retained.
- A `:` operator to retain the entirety of a dimension's extent.

```jldoctest
julia> x = exampleobject(20, 10);

julia> x[1,:]
1x10 SummarizedExperiment
  assays(3): foo bar whee
  rowdata(2): ID Type
  coldata(3): ID Treatment Response
  metadata(1): version

julia> x[:,1:5]
20x5 SummarizedExperiment
  assays(3): foo bar whee
  rowdata(2): ID Type
  coldata(3): ID Treatment Response
  metadata(1): version

julia> keep = [ i > 5 for i in 1:size(x)[1] ];

julia> x[keep,1:2]
15x2 SummarizedExperiment
  assays(3): foo bar whee
  rowdata(2): ID Type
  coldata(3): ID Treatment Response
  metadata(1): version
```
"""
function Base.getindex(x::SummarizedExperiment, I...)
    if length(I) != 2
        throw(DimensionMismatch("exactly two indices are required for SummarizedExperiment indexing"))
    end

    indices = to_indices(x, I)

    if isa(indices[1], Int)
        index_rows = [indices[1]]
    else 
        index_rows = indices[1]
    end

    if isa(indices[2], Int)
        index_cols = [indices[2]]
    else
        index_cols = indices[2]
    end

    # Subsetting the row data.
    new_rowdata = x.rowdata
    if size(new_rowdata)[2] > 0
        new_rowdata = new_rowdata[index_rows,:]
    end

    # Subsetting the column data.
    new_coldata = x.coldata
    if size(new_coldata)[2] > 0
        new_coldata = x.coldata[index_cols,:]
    end

    new_assays = DataStructures.OrderedDict{String,AbstractArray}();
    for (key, val) in x.assays
        subdex = Array{Any,1}(undef, length(size(val)))
        fill!(subdex, :)
        subdex[1] = index_rows
        subdex[2] = index_cols
        new_assays[key] = getindex(val, subdex...)
    end

    output = SummarizedExperiment(new_assays, new_rowdata, new_coldata, copy(x.metadata))
    output.nrow = length(index_rows)
    output.ncol = length(index_cols)

    return output
end
