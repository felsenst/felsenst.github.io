
# Two-locus genotype frequency interation program #

This program, ```twoloci.c```, iterates genotype frequencies for an infinitely large population with two loci, each of which has two 
alleles.  The alleles at the first locus are  A  and  a, the alleles at the second locus are  B  and  b.  The iterations are 
deterministic, as the infinite population size means that there is no genetic drift.  The recombination fraction






## Compiling the program ##

If your C compiler is GCC, the program can be compiled with the command

```gcc -lm twoloci.c -o twoloci```

otherwise it may work to type

```cc -lm twoloci.c -o twoloci```



## An example run ##

If the fitnesses are in file ```fitnesses``` and are

1.0 1.0 1.01
1.0 1.0 1.0
1.01 1.0 0.0

Then a typical run output will look like this:


```
Name of file with fitnesses?
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
-1
```
