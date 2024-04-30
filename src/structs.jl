
struct CoNLLUWord
    id
    form
    lemma
    upos
    xpos
    feats
    head
    deprel
    deps
    misc
end


"""
    CoNLLUWord(str::AbstractString)::CoNLLUWord

Parse a word line in CoNLLU format. The word line should have 10 fields separated by tab
characters. The function validates the word line and returns a CoNLLUWord object.
"""
function CoNLLUWord(str::AbstractString)::CoNLLUWord
    isvalidword(str) || error("Invalid word line $str")

    fields = split(str, '\t')   
    
    id     = parse_idx(fields[1])
    form   = fields[2]
    lemma  = fields[3]
    upos   = fields[4]
    xpos   = fields[5]
    feats  = fields[6]
    head   = fields[7]
    deprel = fields[8]
    deps   = fields[9]
    misc   = fields[10]

    return CoNLLUWord(id, form, lemma, upos, xpos, feats, head, deprel, deps, misc)
end






"""
CoNLLU Format is described at https://universaldependencies.org/format.html. The excerpt
below is from the same link.

We use a revised version of the CoNLL-X format called CoNLL-U. Annotations are encoded 
in plain text files (UTF-8, normalized to NFC, using only the LF character as line break, 
including an LF character at the end of file) with three types of lines:

- Word lines containing the annotation of a word/token/node in 10 fields separated by 
  single tab characters; see below.
- Blank lines marking sentence boundaries. The last line of each sentence is a blank line.
- Sentence-level comments starting with hash (#). Comment lines occur at the beginning 
  of sentences, before word lines.

Sentences consist of one or more word lines, and word lines contain the following fields:

- **ID**: Word index, integer starting at 1 for each new sentence; may be a range for 
  multiword tokens; may be a decimal number for empty nodes (decimal numbers can be lower 
  than 1 but must be greater than 0).
- **FORM**: Word form or punctuation symbol.
- **LEMMA**: Lemma or stem of word form.
- **UPOS**: Universal part-of-speech tag.
- **XPOS**: Optional language-specific (or treebank-specific) part-of-speech / morphological 
  tag; underscore if not available.
- **FEATS**: List of morphological features from the universal feature inventory or from 
  a defined language-specific extension; underscore if not available.
- **HEAD**: Head of the current word, which is either a value of ID or zero (0).
- **DEPREL**: Universal dependency relation to the HEAD (root iff HEAD = 0) or a defined 
  language-specific subtype of one.
- **DEPS**: Enhanced dependency graph in the form of a list of head-deprel pairs.
- **MISC**: Any other annotation.

The fields DEPS and MISC replace the obsolete fields PHEAD and PDEPREL of the CoNLL-X 
format. In addition, we have modified the usage of the ID, FORM, LEMMA, XPOS, FEATS and 
HEAD fields as explained below.

The fields must additionally meet the following constraints:

Fields must not be empty.
Fields other than FORM, LEMMA, and MISC must not contain space characters.
Underscore (_) is used to denote unspecified values in all fields except ID. Note that 
no format-level distinction is made for the rare cases where the FORM or LEMMA is the 
literal underscore – processing in such cases is application-dependent. Further, in UD 
treebanks the UPOS, HEAD, and DEPREL columns are not allowed to be left unspecified except 
in multiword tokens, where all must be unspecified, and empty nodes, where UPOS is 
optional and HEAD and DEPREL must be unspecified. The enhanced DEPS annotation is optional 
in UD treebanks, but if it is provided, it must be provided for all sentences in the treebank.
"""
struct CoNLLUSentence
    metadata::Dict
    words::Vector
end


function CoNLLUSentence(str::AbstractString)
    lines = split(str, '\n')
    metadata = Dict()
    words = []

    for l in lines
        length(l) == 0 && continue # empty line (sentence boundary) do nothing      
 
        if first(l) == '#' # metadata line
            k,v = parse_metadata(l)
            metadata[k] = v
        else # word line
            push!(words, CoNLLUWord(l))
        end
    end

    return CoNLLUSentence(metadata, words)
end




"""
    id(s::CoNLLUSentence)

Returns the sentence id if it exists in the metadata, otherwise returns nothing.
"""
function id(s::CoNLLUSentence)
    ret = haskey(s.metadata, "sent_id") ? s.metadata["sent_id"] : nothing
    return ret
end




"""
    text(s::CoNLLUSentence)

Returns the sentence text if it exists in the metadata, otherwise returns nothing.
"""
function text(s::CoNLLUSentence)
    ret = haskey(s.metadata, "text") ? s.metadata["text"] : nothing
    return ret
end




"""
    metakeys(s::CoNLLUSentence)

Returns the keys of the metadata.
"""
function metakeys(s::CoNLLUSentence)
    return keys(s.metadata)
end




"""
    metavalues(s::CoNLLUSentence)

Returns the values of the metadata.
"""
function metavalues(s::CoNLLUSentence)
    return values(s.metadata)
end



function to_table(c::CoNLLUSentence; include_metadata=true)
  keys = [i for i in fieldnames(CoNLLUWord)]
  values = [getfield.(c.words, k) for k in keys]

  if include_metadata == true
      # replicate metadata for each word
      push!(keys, :metadata)
      metadata = [join(c.metadata, '\n') for _ in 1:length(c.words)]
      push!(values, metadata)
  end

  return (;zip(keys, values)...)
end



function Base.show(io::IO, ::MIME"text/plain", c::CoNLLUSentence)
  tbl = to_table(c; include_metadata=false)

  metastr = join(["$k = $v" for (k,v) in c.metadata], '\n')
  write(io, metastr * "\n")
  pretty_table(tbl; show_row_number=true, show_header=true, show_subheader=false, tf=tf_simple, columns_width=8)
end
