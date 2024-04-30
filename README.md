**Note**: This package should be considered WIP and in very early stage. The API is subject to change.

# CoNLLU.jl

Julia package for reading and writing CoNLL-U files. CoNLL-U is a plain text format for representing annotated linguistic data, such as part-of-speech tagged text or dependency trees. The format is described in detail at the [Universal Dependencies](http://universaldependencies.org/format.html) website.

## Installation

```julia
Pkg.add("CoNLLU")
```

## Usage

```julia
using CoNLLU

# Read a CoNLL-U file (all sentences to a vector)
dataset = CoNLLUDataset("example.conllu")
sentences = collect(dataset) # return a list of all the CoNLLUSentence objects in the dataset

# Alternatively, for large objects the sentences can be read one at a time
dataset = CoNLLUDataset("example.conllu")

lemma_corpus = Set() # set to store all the lemmas in the dataset
upos_corpus = Set() # set to store all the part of speech tags in the dataset

for sentence in dataset
    # get all the lemmas in the sentence
    lemma = getfield.(sentence.words, :lemma) |> Set
    lemma_corpus = union(lemma_corpus, lemma)

    # get all the part of speech tags in the sentence
    upos = getfield.(sentence.words, :upos) |> Set
    upos_corpus = union(upos_corpus, upos)
end
```


## Structures

The package defines the following structures:

- `CoNLLUDataset`: A collection of `CoNLLUSentence` objects.
- `CoNLLUSentence`: A sentence in a CoNLL-U file, consisting of a list of `CoNLLUWord` objects.
- `CoNLLUWord`: A word in a CoNLL-U sentence, with fields for the various columns in the CoNLL-U format.
