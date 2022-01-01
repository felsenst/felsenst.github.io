
#include <stdio.h>

void getstryng(char *fname)
{ /* read in a file name from stdin and take off newline if any */

  fname = fgets(fname, 100, stdin);
  if ( !fname ) {
    fprintf(stderr,"\nencountered end of file on standard input\n");
    fprintf(stderr,"\nexiting\n");
    exit (0) ;
  }
  if (strchr(fname, '\n') != NULL)
    *strchr(fname, '\n') = '\0';
} /* getstryng */


int main() {
   FILE *inf;
   double p, q, D, r, x[5], y[5], wm[5], w[4][4], w1[4][4],
         ww1, ww2, ww3, wbar, wprev;
   int t, i, j, t9, interval;
   char fname[100]; 

   printf("Name of file with fitnesses?\n");
   getstryng(fname);
   inf = fopen(fname, "r");
   if (!inf) {
     printf("can't read %s\n",fname);
     exit(-1);
   }
   for (i=1; i<=3; i++) {
     fscanf(inf, "%lf%lf%lf", &ww1, &ww2, &ww3);
     w1[i][1] = ww1;
     w1[i][2] = ww2;
     w1[i][3] = ww3;
     fscanf(inf, "%*[^\n]");
     if ((ww1 < 0.0) || (ww2 < 0.0) || (ww3 < 0.0)) {
       printf("\n A fitness is negative.  Exiting... \n");
       exit(-1);
     }
   }
   printf("\n");
   printf("         BB      Bb     bb\n");
   printf("     =========================\n");
   printf(" AA  | %5.3f | %5.3f | %5.3f |\n", w1[1][1], w1[1][2], w1[1][3]);
   printf("     |-------+-------+-------|\n");
   printf(" Aa  | %5.3f | %5.3f | %5.3f |\n", w1[2][1], w1[2][2], w1[2][3]);
   printf("     |-------+-------+-------|\n");
   printf(" aa  | %5.3f | %5.3f | %5.3f |\n", w1[3][1], w1[3][2], w1[3][3]);
   printf("     =========================\n");
   printf("\n");
   do {
     i = 0;
     do {
       if (i > 0)
         printf("\np or q are outside the range [0,1]. Please try again.\n");
       printf("initial gene frequencies of A, B?\n");
       scanf("%lf%lf%*[^\n]", &p, &q);
       i++;
     } while ( (p < 0.0) || (p > 1.0) || (q < 0.0) || (q > 1.0));
     i = 0;
     do {
       if (i > 0)
         printf("\nD is too big or too small.  Please try again\n");
       printf("initial D?\n");
       scanf("%lf%*[^\n]", &D);
       i++;
     } while ((p*q+D < 0) || (p*(1-q)-D < 0)
               || ((1-p)*q-D < 0) || ((1-p)*(1-q)+D < 0)) ;
     x[1] = p*q + D;
     x[2] = p*(1-q)-D;
     x[3] = (1-p)*q-D;
     x[4] = (1-p)*(1-q)+D;
     printf("recombination fraction?\n");
     scanf("%lf%*[^\n]", &r);
     t = 0;
     t9 = 0;
     for (i=1; i<=3; i++)
       for (j=1; j<=3; j++)
         w[i][j] = w1[i][j];
     printf("print every how many generations?\n");
     scanf("%ld%*[^\n]", &interval);
     while (t <= t9) {
       if (t == t9) {
         printf("how many (more) generations? (0 to restart, -1 to stop)\n");
         scanf("%ld%*[^\n]", &i);
         t9 += i;
         if (i > 0) {
           printf("\n      t        p(A)        p(B)        D         mean w  (increase?)\n");
           printf("     ---       ----        ----       ---        ------  -----------\n");
         }
       }
       if (t9 == t)
          break;
       if (t9 > t) {
         if (t > 0)
            wprev = wbar;
         wm[1] = x[1]*w[1][1]+x[2]*w[1][2]+x[3]*w[2][1]+x[4]*w[2][2]; 
         wm[2] = x[1]*w[1][2]+x[2]*w[1][3]+x[3]*w[2][2]+x[4]*w[2][3]; 
         wm[3] = x[1]*w[2][1]+x[2]*w[2][2]+x[3]*w[3][1]+x[4]*w[3][2]; 
         wm[4] = x[1]*w[2][2]+x[2]*w[2][3]+x[3]*w[3][2]+x[4]*w[3][3]; 
         wbar = x[1]*wm[1]+x[2]*wm[2]+x[3]*wm[3]+x[4]*wm[4];
         if ((t%interval) == 0) {
           printf("  %6ld   %10.7f  %10.7f  %10.7f  %10.7f", t, p, q, D, wbar);
           if (t > 0) {
             if (wbar > wprev)
               printf(" +\n");
             else 
               printf(" -\n");
           }
           else printf("\n");
         }
         y[1] = (x[1]*wm[1]-r*D)/wbar;
         y[2] = (x[2]*wm[2]+r*D)/wbar;
         y[3] = (x[3]*wm[3]+r*D)/wbar;
         y[4] = (x[4]*wm[4]-r*D)/wbar;
         for (i=1; i<=4; i++)
             x[i] = y[i];
         p = x[1]+x[2];
         q = x[1]+x[3];
         D = x[1]-p*q;
         t++;
       }
     }
   }
   while (t9 >= t);
}
