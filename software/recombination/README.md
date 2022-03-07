
# Programs for simulation of the evolution of recombination #

## Program simulating effect of recombination for Felsenstein 1974 paper ##

This is a program written by me for the 1974 paper on the evolutionary advantage of recombination.
It simulates the fixation of advantageous alleles in the absence of recombination and compares that
to the expected rate of fixation at loci that are not in linkage disequilibrium (computed from
Kimura's 1962 formula).  It is written in FORTRAN IV for the University of Washington's
CDC 6400 mainframe computer.  

Click [here](recomb1964.for) to display or download  recomb1974.for, and


@@ Programs simulating selection for an allele bringing about

These two programs were written for the 1976 paper by Felsenstein and Yokoyama in Genetics.  I designed the programs but I think
that Shozo Yokoyama wrote them, and he did the runs that were reported in the paper.

They are written in FORTRAN IV for the University of Washington's CDC 6400 mainframe.  One case that was run was where the locus
that controls recombination had the allele for recombination dominant, the other had it recessive.  Generally
they were run with an equal initial frequency of the recombination allele (50:50) and then we could detect the
effectiveness of natural selection for recombination by finding that the recombination allele fixed significantly
more than 50% of the time.

I believe that  recomb1.for  simulates the dominant case, and  recomb2.for  the recessive case.  In the latter case the 
two subpopulations that have the two alleles at the recombination locus have no gene flow between them, so that Fisher 
and Muller's argument for the advantage of recombination predicts that selection for recombination will occur.  It is less 
obvious that this will be true for the dominant case, but it proved to be true in the simulations.

Click [here](recomb1976a.for) to display or download  recomb1976a.for, and

Click [here](recomb1976b.for) to display or download  recomb1976b.for.

