import DataStructures

"""
    setindex!(x, value, i, j)

Assign the `SummarizedExperiment` `value` to a subset of `SummarizedExperiment` `x` by the rows or columns based on `i` and `j`, respectively.
Types for the arguments to `i` and `j` are similar to those for arrays:

- An integer `Vector` containing indices.
- An `Int` containing a single index.
- A boolean `Vector` of length equal to the relevant dimension,
  indicating whether each entry of that dimension should be retained.
- A `:` operator to retain the entirety of a dimension's extent.

On assignment, the assay values in the specified subset of `x` will be replaced by the corresponding values in `value`.
Rows of the `rowdata(x)` and `coldata(x)` will be replaced by those in `value`, according to `i` and `j` respectively.
Metadata fields in `metadata(value)` will be added to or overwrite those in `metadata(x)`.

It is assumed that `x` and `value` contain the same name, order and type of columns in their `rowdata` and `coldata`.
Similarly, both objects should contain the same name, order and type of arrays in their `assays`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> x[:,1] = x[:,2];

julia> sn = coldata(x)[!,"name"];

julia> sn[1] == sn[2]
true

julia> y = assay(x);

julia> y[:,1] == y[:,2]
true
```
"""
function Base.setindex!(x::SummarizedExperiment, value::SummarizedExperiment, i, j)
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

    # Make sure we don't modify 'x' by reference until the very end.
    rd_copy = copy(x.rowdata)
    rd_copy[index_rows,:] = value.rowdata
    cd_copy = copy(x.coldata)
    cd_copy[index_cols,:] = value.coldata

    if collect(keys(x.assays)) != collect(keys(value.assays))
        throw(ErrorException("'x' and 'value' should have the same assay names"))
    end

    output = deepcopy(x.assays) # no way around this, as any additions in progress 
                                # will operate by reference and overwrite the source.

    for (k, v) in output
        subdex = Array{Any,1}(undef, length(size(v)))
        fill!(subdex, :)
        subdex[1] = index_rows
        subdex[2] = index_cols
        setindex!(v, value.assays[k], subdex...)
    end

    # Setting everything to their modified states. Everything at this point
    # is assumed to be a no-throw, so we are guaranteed to return.
    x.rowdata = rd_copy
    x.coldata = cd_copy
    x.assays = output

    for (m, val) in value.metadata
        x.metadata[m] = val 
    end

    return x
end
