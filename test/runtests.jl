using Test
using CoNLLU


rec1 = raw"""

# sent_id = weblog-blogspot.com_zentelligence_20040423000200_ENG_20040423_000200-0002
# text = What if Google expanded on its search-engine (and now e-mail) wares into a full-fledged operating system?
1	What	what	PRON	WP	PronType=Int	0	root	0:root	_
2	if	if	SCONJ	IN	_	4	mark	4:mark	_
3	Google	Google	PROPN	NNP	Number=Sing	4	nsubj	4:nsubj	_
4	expanded	expand	VERB	VBD	Mood=Ind|Number=Sing|Person=3|Tense=Past|VerbForm=Fin	1	advcl	1:advcl:if	_
5	on	on	ADP	IN	_	15	case	15:case	_
6	its	its	PRON	PRP$	Case=Gen|Gender=Neut|Number=Sing|Person=3|Poss=Yes|PronType=Prs	15	nmod:poss	15:nmod:poss	_
7	search	search	NOUN	NN	Number=Sing	9	compound	9:compound	SpaceAfter=No
8	-	-	PUNCT	HYPH	_	7	punct	7:punct	SpaceAfter=No
9	engine	engine	NOUN	NN	Number=Sing	15	compound	15:compound	_
10	(	(	PUNCT	-LRB-	_	13	punct	13:punct	SpaceAfter=No
11	and	and	CCONJ	CC	_	13	cc	13:cc	_
12	now	now	ADV	RB	_	13	advmod	13:advmod	_
13	e-mail	e-mail	NOUN	NN	Number=Sing	9	conj	9:conj:and|15:compound	SpaceAfter=No
14	)	)	PUNCT	-RRB-	_	13	punct	13:punct	_
15	wares	wares	NOUN	NNS	Number=Plur	4	obl	4:obl:on	_
16	into	into	ADP	IN	_	22	case	22:case	_
17	a	a	DET	DT	Definite=Ind|PronType=Art	22	det	22:det	_
18	full	full	ADV	RB	_	20	advmod	20:advmod	SpaceAfter=No
19	-	-	PUNCT	HYPH	_	18	punct	18:punct	SpaceAfter=No
20	fledged	fledged	ADJ	JJ	Degree=Pos	22	amod	22:amod	_
21	operating	operating	NOUN	NN	Number=Sing	22	compound	22:compound	_
22	system	system	NOUN	NN	Number=Sing	4	obl	4:obl:into	SpaceAfter=No
23	?	?	PUNCT	.	_	4	punct	4:punct	_

"""

@testset "Parser" begin
    fields = split(rec1, '\n')
    @test isvalidword(fields[4]) == true
    @test parse_metadata(fields[2]) == ("sent_id", "weblog-blogspot.com_zentelligence_20040423000200_ENG_20040423_000200-0002")
    @test CoNLLUWord(fields[4]).upos == "PRON"
end # testset "Basic Tests"
