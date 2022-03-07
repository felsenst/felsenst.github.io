
# Programs for simulation of individual selection for recombination #

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

Click [here](recomb1.for) to display or download  recomb1.for, and

Click [here](recomb2.for) to display or download  recomb2.for.

