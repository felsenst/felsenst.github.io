
# Two-locus genotype frequency interation program #

This program, ```twoloci.c```, iterates genotype frequencies for an infinitely large population with two loci, each of which has two 
alleles.  The alleles at the first locus are  A  and  a, the alleles at the second locus are  B  and  b.  The iterations are 
deterministic, as the infinite population size means that there is no genetic drift.  The recombination fraction  r  can be specified 
by the user.  The initial state of the population is given by entering the initial gene frequencies of  A  and  B, and the 
initial value of the linkage disequilibrium parameter  D.  

The user is first asked for the name of the file with the fitnesses.  The fitness values are on three lines, 
each line having three fitnesses separated by blanks.  The first line is for  AA  genotypes, and is the fitnesses 
for BB, Bb, and bb.  The second line is for Aa, the third line is for  aa.

Thus a typical fitness file would look like this:

```0.7 0.65 0.9
0.8 1.0 0.8
0.9 0.75 0.9```

A fitness file for two loci for which there is no interaction between the loci (i.e, where the fitnesses 
interact multiplicatively) would be

```0.64 0.8 0.56
0.8 1.0 0.7
0.72 0.9 0.63```

The user specifies how many generations are to be run, and how often the population gene frequencies and D are to be 
printed out.  The prinout for those generations also shows the mean fitness and a ```+``` or ```-``` indicating
whether the mean fitness has increased or decreased since the previous generation.



## Compiling the program ##

If your C compiler is GCC, the program can be compiled with the command

```gcc -lm twoloci.c -o twoloci```

otherwise it may work to type

```cc -lm twoloci.c -o twoloci```



## An example run ##

If the fitnesses are in file ```fitnesses``` and are

```1.0 1.0 1.01
1.0 1.0 1.0
1.01 1.0 0.0```


Then a typical run output will look like this:


```Name of file with fitnesses?
fitnesses

         BB      Bb     bb
     =========================
 AA  | 1.000 | 1.000 | 1.010 |
     |-------+-------+-------|
 Aa  | 1.000 | 1.000 | 1.000 |
     |-------+-------+-------|
 aa  | 1.010 | 1.000 | 0.000 |
     =========================

initial gene frequencies of A, B?
0.4 0.6
initial D?
-0.01
recombination fraction?
0.2
print every how many generations?
1
how many (more) generations? (0 to restart, -1 to stop)
10

      t        p(A)        p(B)        D         mean w  (increase?)
     ---       ----        ----       ---        ------  -----------
       0    0.4000000   0.6000000  -0.0100000   0.9487580
       1    0.4219084   0.6338487  -0.0228959   0.9661950 +
       2    0.4369957   0.6575943  -0.0295407   0.9752735 +
       3    0.4484042   0.6759053  -0.0326589   0.9806127 +
       4    0.4575925   0.6909450  -0.0337441   0.9840493 +
       5    0.4653215   0.7038407  -0.0336489   0.9864244 +
       6    0.4720235   0.7152311  -0.0328759   0.9881645 +
       7    0.4779602   0.7255029  -0.0317278   0.9895023 +
       8    0.4832992   0.7349026  -0.0303890   0.9905724 +
       9    0.4881526   0.7435948  -0.0289721   0.9914563 +
how many (more) generations? (0 to restart, -1 to stop)
-1```
