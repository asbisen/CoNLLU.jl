

"""
    isvalidword(str::AbstractString)

Validate a word line in CoNLLU format. Returns true if the word line is valid, 
false otherwise.

The word line should have 10 fields separated by tab characters. The fields are:

- ID: Word index, integer starting at 1 for each new sentence; may be a range for 
  multiword tokens; may be a decimal number for empty nodes (decimal numbers can be lower 
  than 1 but must be greater than 0).
- FORM: Word form or punctuation symbol.
- LEMMA: Lemma or stem of word form.
- UPOS: Universal part-of-speech tag.
- XPOS: Optional language-specific (or treebank-specific) part-of-speech / morphological 
  tag; underscore if not available.
- FEATS: List of morphological features from the universal feature inventory or from
  a defined language-specific extension; underscore if not available.
- HEAD: Head of the current word, which is either a value of ID or zero (0).
- DEPREL: Universal dependency relation to the HEAD (root iff HEAD = 0) or a defined 
  language-specific subtype of one.
- DEPS: Enhanced dependency graph in the form of a list of head-deprel pairs.
- MISC: Any other annotation.
"""
function isvalidword(str::AbstractString)::Bool
    # the word line should not have any \n (newline) character
    if occursin(r"\n", str)
        @info "encountered new-line in word line $str"
        return false
    end

    # the word line should have 10 fields separated by tab characters
    fields = split(str, '\t')
    nfields = length(fields)
    if nfields != 10
        @info "Invalid number of fields in word (expected 10 / encountered $nfields"
        return false
    end

    # TODO: validate each field
    return true
end




"""
    parse_metadata(str::AbstractString)

Returns:
    key::AbstractString: The key of the metadata.
    value::AbstractString: The value of the metadata.

Parse metadata line in CoNLLU format. The metadata should start with #. 
The metadata can be in the form key = value or just value. If the metadata
is in the form key = value, the function returns the key and value. If the
metadata is just a value, the function generates a random key and returns
the key and value.
"""
function parse_metadata(str::AbstractString)
    # the first character should be #
    if first(str) != '#'
        throw(ArgumentError("metadata should start with #, received\n $str"))
    end

    # remove the leading # and empty spaces
    tmp = strip(str[2:end])

    # check if the metadata is in the form key = value
    if occursin(r"=", tmp)
        key, value = split(tmp, '=', limit=2) # split at the first occurrence of =
        return strip(key), strip(value)
    else # generate a random key
        key = "key_" * join(rand('a':'z', 4))
        value = tmp
        return strip(key), strip(value)
    end
end




"""
    parse_idx(str::AbstractString)

Parse a string to an integer or a range. If the string contains a hyphen (-),
the function returns a range. If the string contains a dot (.), the function
returns a float. Otherwise, the function returns an integer.
"""
function parse_idx(str::AbstractString)
    if occursin(r"-", str)
        tkns = split(str, '-')
        @assert length(tkns) == 2
        st, en = parse.(Int, tkns)
        return st:en
    elseif occursin(r"\.", str)
        return parse(Float64, str)
    else
        return parse(Int, str)
    end
end




function load_connlu_data(filename::AbstractString)
    records = []
    txt = "" # to hold the temporary text block
    
    fd = open(filename, "r")
    inblock = false

    while !eof(fd)
        line = readline(fd)

        # A new block was encountered 
        # check if there is any data in the txt block to process
        if (inblock == false) && (strip(line) != "")
            inblock = true
            txt = txt * '\n' * line
            continue
        elseif (inblock == true) && (strip(line) != "")
            txt = txt * '\n' * line
            continue
        elseif (inblock == true) && (strip(line) == "")
            r = CoNLLUSentence(txt)
            push!(records, r)
            inblock = false
            txt = ""
            continue
        end

        # process the last block
    end # while
    close(fd)
    return records
end



"""
    corpus(s::CoNLLUSentence, upos::String)
    corpus(s::Vector, upos::String)

Build a corpus of words with a specific upos tag. Common tags
are VERB, NOUN, ADJ, ADV, PROPN, PUNCT, NUM, AUX etc.

Examples:
```julia
recs = load_connlu_data("data/en_ewt_ud/en_ewt-ud-dev.conllu")
c = corpus(recs, "VERB")
```
"""
function corpus(s::CoNLLUSentence, upos::String)
    corpus = Set()

    # get all the word idx with matching upos
    idx = findall(x -> x == upos, getfield.(s.words, :upos))
    words = getfield.(s.words, :lemma)[idx]
    return Set(words) 
end

function corpus(s::Vector, upos::String)
    r = corpus.(s, upos)
    return Set(Iterators.flatten(r))
end