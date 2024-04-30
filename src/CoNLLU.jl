module CoNLLU

import Base.show
using PrettyTables

include("structs.jl")
include("utils.jl")
include("dataset.jl")


export # structs
    CoNLLUWord,
    CoNLLUSentence,
    id,
    text,
    metakeys,
    metavalues

export # utils
    isvalidword,
    parse_metadata,
    parse_idx,
    load_connlu_data,
    corpus

export # dataset
    CoNLLUDataset

end # module CoNLLU
