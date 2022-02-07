import DataFrames
import DataStructures

function collapse_data(x::Vector{DataFrames.DataFrame})
    base = copy(x[1])
    refnames = Set(names(base))

    # The first instance of each key is always taken. For the sake of speed, we
    # don't bother checking for equality or any of that crap.
    for i in 2:length(x)
        current = x[i]
        for n in names(current)
            if !(n in refnames)
                insertcols!(base, n => current[!,n])
            end
        end
    end

    return base
end

function collapse_data(x::Vector{Dict{String,Any}})
    base = copy(x[1])

    # The first instance of each key is always taken. For the sake of speed, we
    # don't bother checking for equality or any of that crap.
    for i in 2:length(x)
        current = x[i]
        for (key, val) in current
            if !haskey(base, key)
                base[key] = val
            end
        end
    end

    return base
end

function Base.vcat(A::Vararg{SummarizedExperiment})
    if length(A) < 2
        return A[1] # no-op in this case.
    end

    collected_rowdata = [rowdata(A[1])];
    collected_coldata = [coldata(A[1])];
    collected_metadata = [metadata(A[1])];
    collected_assays = DataStructures.OrderedDict{String,Vector{AbstractArray}}();
    for (key, val) in assays(A[1])
        collected_assays[key] = AbstractArray[val]
    end

    for i in 2:length(A)
        push!(collected_rowdata, rowdata(A[i]))
        push!(collected_coldata, coldata(A[i]))

        for (key, val) in assays(A[i])
            if !haskey(collected_assays, key)
                throw(KeyError("could not find '" * key * "' in assays of object " * string(i)))
            end
            
            ref = collected_assays[key][1]
            if length(size(ref)) != length(size(val)) || size(ref)[2] != size(val)[2]
                throw(DimensionMismatch("inconsistent dimensions for assay '" * key * "' in object " * string(i)))
            end
            
            push!(collected_assays[key], val)
        end
    end

    full_rowdata = vcat(collected_rowdata...)
    full_assays = DataStructures.OrderedDict{String,AbstractArray}()
    for (key, val) in collected_assays
        full_assays[key] = vcat(val...)
    end

    full_coldata = collapse_data(collected_coldata)
    full_metadata = collapse_data(collected_metadata)

    return SummarizedExperiment(full_assays, full_rowdata, full_coldata, full_metadata)
end

function Base.hcat(A::Vararg{SummarizedExperiment})
    if length(A) < 2
        return A[1] # no-op in this case.
    end

    collected_rowdata = [rowdata(A[1])];
    collected_coldata = [coldata(A[1])];
    collected_metadata = [metadata(A[1])];
    collected_assays = DataStructures.OrderedDict{String,Vector{AbstractArray}}();
    for (key, val) in assays(A[1])
        collected_assays[key] = AbstractArray[val]
    end

    for i in 2:length(A)
        push!(collected_rowdata, rowdata(A[i]))
        push!(collected_coldata, coldata(A[i]))

        for (key, val) in assays(A[i])
            if !haskey(collected_assays, key)
                throw(KeyError("could not find '" * key * "' in assays of object " * string(i)))
            end
            
            ref = collected_assays[key][1]
            if length(size(ref)) != length(size(val)) || size(ref)[1] != size(val)[1]
                throw(DimensionMismatch("inconsistent dimensions for assay '" * key * "' in object " * string(i)))
            end
            
            push!(collected_assays[key], val)
        end
    end

    full_coldata = vcat(collected_coldata...)
    full_assays = DataStructures.OrderedDict{String,AbstractArray}()
    for (key, val) in collected_assays
        full_assays[key] = hcat(val...)
    end

    full_rowdata = collapse_data(collected_rowdata)
    full_metadata = collapse_data(collected_metadata)

    return SummarizedExperiment(full_assays, full_rowdata, full_coldata, full_metadata)
end
