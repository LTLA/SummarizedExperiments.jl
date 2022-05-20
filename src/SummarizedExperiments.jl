module SummarizedExperiments

using Reexport
@reexport using DataStructures: OrderedDict
@reexport using DataFrames: DataFrame

include("class.jl")
export SummarizedExperiment

include("subset.jl")
include("assign.jl")

include("getters.jl")
export size, rowdata, coldata, assay, assays, metadata

include("setters.jl")
export setrowdata!, setcoldata!, setassay!, setassays!, setmetadata!

include("combine.jl")
include("miscellaneous.jl")

include("example.jl")
export exampleobject

end
