export size, rowdata, setrowdata!, coldata, setcoldata!, assay, setassay!, assays, setassays!, metadata, setmetadata!
import DataFrames
import DataStructures

"""
    size(x::SummarizedExperiment)

Return a 2-tuple containing the number of rows and columns in `x`.
"""
function Base.size(x::SummarizedExperiment)
    return (x.nrow, x.ncol)
end

"""
    rowdata(x)

Return the row annotations as a `DataFrame` with number of rows equal to the number of rows in `x`.
If no annotations are present, an empty `DataFrame` is returned instead.
"""
function rowdata(x::SummarizedExperiment)
    return x.rowdata
end

"""
    setrowdata!(x, value)

Set the row annotations in `x` to `value`.
This can either be an empty `DataFrame` (i.e., no row annotations)
or a `DataFrame` with number of rows equal to the number of rows in `x`.
"""    
function setrowdata!(x::SummarizedExperiment, value::DataFrames.DataFrame)
    if size(value)[2] > 0 && size(value)[1] != x.nrow
        throw(DimensionMismatch("'value' and 'rowdata(x)' should have the same number of rows"))
    end
    x.rowdata = value
    return
end 

"""
    coldata(x)

Return the column annotations as a `DataFrame` with number of rows equal to the number of columns in `x`.
If no annotations are present, an empty `DataFrame` is returned instead.
"""
function coldata(x::SummarizedExperiment)
    return x.coldata
end

"""
    setcoldata!(x, value)

Set the column annotations in `x` to `value`.
This can either be an empty `DataFrame` (i.e., no column annotations)
or a `DataFrame` with number of rows equal to the number of columns in `x`.
"""    
function setcoldata!(x::SummarizedExperiment, value::DataFrames.DataFrame)
    if size(value)[2] > 0 && size(value)[1] != x.ncol
        throw(DimensionMismatch("'value' and 'coldata(x)' should have the same number of rows"))
    end
    x.coldata = value
    return
end 

"""
    assay(x[, i])

Return the requested assay in `x`.
`i` may be an integer specifying an index or a string containing the name.
If `i` is not supplied, the first assay is returned.
"""
function assay(x::SummarizedExperiment)
    return assay(x, 1)
end

function assay(x::SummarizedExperiment, i::Int64)
    counter = 0
    for v in values(x.assays)
        counter += 1
        if counter == i
            return v
        end
    end

    throw(BoundsError("'i = " * string(i) * "' is out of range of 'assays(x)'"))
end

function assay(x::SummarizedExperiment, i::String)
    if !haskey(x.assays, i)
        throw(KeyError("'" * i * "' is not present in 'assays(x)'"))
    end
    return x.assays[i]
end

"""
    setassay!(x[, i], value)

Set the requested assay in `x` to `value`.
The first two dimensions of `value` must have extent equal to those of `x`.
`i` may be an integer specifying an index, in which case it must be positive and no greater than `length(assays(x))`;
or a string containing the name, in which case it may be an existing or new name.
If `i` is not supplied, `value` is set to the first assay.
"""
function setassay!(x::SummarizedExperiment, value::AbstractArray)
    setassay!(x, 1, value)
    return
end

function setassay!(x::SummarizedExperiment, i::Int64, value::AbstractArray)
    dim = size(value)
    if dim[1] != x.nrow || dim[2] != x.ncol
        throw(DimensionMismatch("dimensions of 'value' should be the same as those of 'x'"))
    end

    counter = 0
    for k in keys(x.assays)
        counter += 1
        if counter == i
            x.assays[k] = value
            return
        end
    end

    throw(BoundsError("'i = " * string(i) * "' is out of range of 'assays(x)'"))
end

function setassay!(x::SummarizedExperiment, i::String, value::AbstractArray)
    dim = size(value)
    if dim[1] != x.nrow || dim[2] != x.ncol
        throw(DimensionMismatch("dimensions of 'value' should be the same as those of 'x'"))
    end
    x.assays[i] = value
    return
end

"""
    assays(x)

Return all assays from `x`.
"""
function assays(x::SummarizedExperiment)
    return x.assays
end

"""
    setassays!(x, value)

Set assays in `x` to `value`.
All values in `value` should have the same extents for the first two dimensions.
"""
function setassays!(x::SummarizedExperiment, value::DataStructures.OrderedDict{String,AbstractArray})
    xdims = size(x)
    for (name, val) in value
        check_assay_dims(size(val), xdims, "value[" * repr(name) * "]", "x")
    end
    x.assays = value
    return
end

"""
    metadata(x)

Return all metadata from `x`.
"""
function metadata(x::SummarizedExperiment)
    return x.metadata;
end

"""
    setmetadata!(x, value)

Set metadata in `x` to `value`.
"""
function setmetadata!(x::SummarizedExperiment, value::Dict{String,Any})
    x.metadata = value;
    return
end
