# SummarizedExperiments for Julia

## Overview 

The [**SummarizedExperiment** package](https://bioconductor.org/packages/SummarizedExperiment) is a staple of the Bioconductor ecosystem,
providing a powerful yet user-friendly container for summarized genomics datasets.
This repository ports the basic `SummarizedExperiment` functionality from R to Julia,
allowing Julians to conveniently manipulate analysis-ready datasets in the same fashion as R/Bioconductor workflows.

The `SummarizedExperiment` class is centered around the idea of assay matrices for experimental data 
where the rows are features (most commonly genes) and the columns are samples.
Typical use cases include intensities for microarrays or counts for sequencing data.
We hold further annotations on the rows and columns in the `rowdata` and `coldata` respectively,
both of which are synchronized to the assays during subsetting and concatenation.

Check out Figure 2 of the [_Orchestrating high-throughput genomic analysis with Bioconductor_](https://doi.org/10.1038/nmeth.3252) paper for more details.

## Quick start

Users may install this package from the GitHub repository through the usual process on the Pkg REPL:

```julia
add https://github.com/LTLA/SummarizedExperiments.jl
```

And then:

```julia
julia> using SummarizedExperiments

julia> x = exampleobject(100, 10) # Mocking up an example object
100x10 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene99 Gene100
  rowdata(2): name Type
  colnames: Patient1 Patient2 ... Patient9 Patient10
  coldata(3): name Treatment Response
  metadata(1): version

julia> coldata(x)
10×3 DataFrame
 Row │ name       Treatment  Response
     │ String     String     Float64
─────┼─────────────────────────────────
   1 │ Patient1   normal     0.197936
   2 │ Patient2   drug1      0.886853
   3 │ Patient3   drug2      0.184345
   4 │ Patient4   drug1      0.271934
   5 │ Patient5   normal     0.227814
   6 │ Patient6   drug1      0.357306
   7 │ Patient7   drug2      0.0882962
   8 │ Patient8   normal     0.306175
   9 │ Patient9   normal     0.731478
  10 │ Patient10  drug2      0.419693

julia> assay(x)
100×10 Matrix{Int64}:
 76  77   36  26    9   10  62  88   2  31
 56  28  100  68   35   19  29  35  17  70
 72  82   56  72   79    0  20  52  22  24
 98  59    0  17   27   90  17  22  26  85
 17   9   44  73   72   52  96  90  68  29
 62  56   15  24   60   38  79  67  71  90
 etc. etc.
```

## Constructors

```@docs
SummarizedExperiment(assays::DataStructures.OrderedDict{String, AbstractArray})
```

```@docs
SummarizedExperiment()
```

## Getters

```@docs
size(x::SummarizedExperiment)
```

```@docs
assay(x::SummarizedExperiment)
```

```@docs
assays(x::SummarizedExperiment)
```

```@docs
rowdata(x::SummarizedExperiment)
```

```@docs
coldata(x::SummarizedExperiment)
```

```@docs
metadata(x::SummarizedExperiment)
```

## Setters 

```@docs
setassay!(x::SummarizedExperiment, value::AbstractArray)
```

```@docs
setassays!(x::SummarizedExperiment, value::DataStructures.OrderedDict{String,AbstractArray})
```

```@docs
setrowdata!(x::SummarizedExperiment, value::DataFrames.DataFrame)
```

```@docs
setcoldata!(x::SummarizedExperiment, value::DataFrames.DataFrame)
```

```@docs
setmetadata!(x::SummarizedExperiment, value::Dict{String,Any})
```

## Subsetting

```@docs
Base.getindex(x::SummarizedExperiment, i, j)
```

## Subset assignment

```@docs
Base.setindex!(x::SummarizedExperiment, value::SummarizedExperiment, i, j)
```

## Concatenation

```@docs
Base.hcat(A::Vararg{SummarizedExperiment})
```

```@docs
Base.vcat(A::Vararg{SummarizedExperiment})
```

## Miscellaneous

```@docs
Base.copy(x::SummarizedExperiment)
```

```@docs
Base.deepcopy(x::SummarizedExperiment)
```

```@docs
Base.show(io::IO, x::SummarizedExperiment)
```

## Contact

This package is maintained by Aaron Lun ([**@LTLA**](https://github.com/LTLA)).
Post bug reports and feature requests as issues on the [GitHub repository](https://github.com/LTLA/SummarizedExperiments.jl/issues).
