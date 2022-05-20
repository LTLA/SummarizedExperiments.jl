# import DataStructures

Base.IndexStyle(x::SummarizedExperiment) = IndexCartesian()

"""
    getindex(x::SummarizedExperiment, i, j)

Subset `x` by the rows or columns based on `i` and `j`, respectively.
Types for the arguments to `i` and `j` are similar to those for arrays:

- An integer `Vector` containing indices.
- An `Int` containing a single index.
- A boolean `Vector` of length equal to the relevant dimension,
  indicating whether each entry of that dimension should be retained.
- A `:` operator to retain the entirety of a dimension's extent.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> x[1,:]
1x10 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1
  rowdata(2): name Type
  colnames: Patient1 Patient2 ... Patient9 Patient10
  coldata(3): name Treatment Response
  metadata(1): version

julia> x[:,1:5]
20x5 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene19 Gene20
  rowdata(2): name Type
  colnames: Patient1 Patient2 ... Patient4 Patient5
  coldata(3): name Treatment Response
  metadata(1): version

julia> keep = [ i > 5 for i in 1:size(x)[1] ];

julia> x[keep,1:2]
15x2 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene6 Gene7 ... Gene19 Gene20
  rowdata(2): name Type
  colnames: Patient1 Patient2
  coldata(3): name Treatment Response
  metadata(1): version
```
"""
function Base.getindex(x::SummarizedExperiment, i, j)
    indices = to_indices(x, (i, j))

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

    new_rowdata = x.rowdata[index_rows,:]
    new_coldata = x.coldata[index_cols,:]

    new_assays = DataStructures.OrderedDict{String,AbstractArray}();
    for (key, val) in x.assays
        subdex = Array{Any,1}(undef, length(size(val)))
        fill!(subdex, :)
        subdex[1] = index_rows
        subdex[2] = index_cols
        new_assays[key] = getindex(val, subdex...)
    end

    return SummarizedExperiment(new_assays, new_rowdata, new_coldata, copy(x.metadata))
end
