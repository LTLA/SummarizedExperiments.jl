export size, rowdata, setrowdata, coldata, setcoldata, assay, setassay, assays, setassays, metadata, setmetadata
import DataFrames
import DataStructures

function Base.size(x::SummarizedExperiment)
    return (size(x.rowdata)[1], size(x.coldata)[1])
end

function rowdata(x::SummarizedExperiment)
    return x.rowdata
end

function setrowdata(x::SummarizedExperiment, value::DataFrames.DataFrame)
    if size(value)[1] != size(x.rowdata)[1]
        throw(DimensionMismatch("'value' and 'rowdata(x)' should have the same number of rows"))
    end
    x.rowdata = value
    return x
end 

function coldata(x::SummarizedExperiment)
    return x.coldata
end

function setcoldata(x::SummarizedExperiment, value::DataFrames.DataFrame)
    if size(value)[1] != size(x.coldata)[1]
        throw(DimensionMismatch("'value' and 'coldata(x)' should have the same number of rows"))
    end
    x.coldata = value
    return x
end 

function assay(x::SummarizedExperiment)
    if length(x.assays) < 1
        throw(BoundsError("'x' has no assays"))
    end
    return first(x.assays).second
end

function assays(x::SummarizedExperiment)
    return x.assays
end

function setassay(x::SummarizedExperiment, name::String, value::AbstractArray)
    check_assay_dims(size(value), size(x), "value", "x")
    x.assays[name] = value
    return x
end

function setassays(x::SummarizedExperiment, value::DataStructures.OrderedDict{AbstractArray})
    xdims = size(x)
    for (name, val) in value
        check_assay_dims(size(val), xdims, "value[" * repr(name) * "]", "x")
    end
    x.assays = value
    return x
end

function metadata(x::SummarizedExperiment)
    return x.metadata;
end

function setmetadata(x::SummarizedExperiment, value::Dict{String,Any})
    x.metadata = value;
end
