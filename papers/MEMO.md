

These are written in Pascal, a now-rare computer language
which I found great for writing programs in that it
pressured me to not make some obvious errors.  They
should run on Free Pascal, (fpc) which you can download and
install on your computer.  The first line may need to
be deleted.

They are the programs used for the calculations in my
1981 paper in Evolution, "Skepticism toward Santa Rosalia:
Why are there so few kinds of animals?"
(which was not really a refutation of G. Evelyn Hutchinson's
famous paper on the determinants of the number of species,
rather it raised the issue of why the genetics of speciation
might further limit the number of species of organisms).


| Program  |            which case it calculates |
| -------  |           ------------------------ |
| specn.pas |          Haploid, 2 loci plus 1 mating cue |
|           |        (version with migration before recombination) |
| specn2.pas |         Same, but recombination before migration |
| specn3.pas |           "    "       "          "       " (?) |
| specn4.pas |         Also a 4th locus which is a modifier of 
|            |        the strength of assortative mating. | 
|            |          Migration before recombination |
| specn5.pas |         Diploid case without modifier (M before R) |
| specn6.pas |         Same as specn5.pas but recomb. before mig. |
| specn7.pas |         Same as specn.pas but also an interaction |
|            |       parameter for epistasis between loci B, C. |
