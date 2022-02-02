import DataFrames

function check_assay_dims(dims::Tuple{Int, Int, Vararg{Int}}, xdims::Tuple{Int, Int, Vararg{Int}}, name::String, ref::String)
    if length(dims) < 2 || dims[1] != xdims[1] || dims[2] != xdims[2]
        throw(DimensionMismatch("'" * name * "' and '" * ref * "' should have the same extents for the first 2 dimensions"))
    end
    return nothing
end

function create_input_DataFrame(expected::Int, data::Union{DataFrames.DataFrame,Vector{String},Nothing}, name::String)
    if isa(data, DataFrames.DataFrame)
        if size(data)[1] != expected
            throw(DimensionMismatch("unexpected number of rows for '" * name * "'"))
        end
        return data
    elsif isa(data, Vector{String})
        if length(data) != expected
            throw(DimensionMismatch("unexpected length of '" * name * "'"))
        end
        return DataFrames.DataFrame(name = data)
    else
        if expected == 0
            return DataFrames.DataFrame(name = Int64[])
        else
            return DataFrames.DataFrame(name = 1:expected)
        end
    end
end
