import DataStructures

function Base.getindex(x::SummarizedExperiment, indices...)
    if length(indices) != 2
        throw(DimensionMismatch("exactly two indices are required for SummarizedExperiment indexing"))
    end

    if isa(indices[1], Int)
        index_rows = [indices[1]]
    else 
        index_rows = indices[1]
    end
    new_rowdata = x.rowdata[index_rows,:]

    if isa(indices[2], Int)
        index_cols = [indices[2]]
    else
        index_cols = indices[2]
    end
    new_coldata = x.coldata[index_cols,:]

    new_assays = DataStructures.OrderedDict{String,AbstractArray}();
    for (key, val) in x.assays
        new_assays[key] = val[index_rows,index_cols]
    end

    return SummarizedExperiment(new_assays, new_rowdata, new_coldata, copy(x.metadata))
end
