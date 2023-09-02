/* simul8.c, written by Joe Felsenstein
 * (c) Copyright 1993-1995 by Joe Felsenstein.
 * version of 9 Oct 1997
 * DOS graphics by Hisashi Horino
 * X implementation and C conversion by Sean T. Lamont
 * menuing interface and unified version by Bill Alford
 * Permission is granted to copy and use this program provided this
 * notice (including copyright and program authors) is not removed
 * and no fee is charged for the program.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef X
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#endif

#ifdef __TURBOC__
#include <graphics.h>
#include <conio.h>
#endif

#ifdef __WATCOMC__
#include <conio.h>
#include <graph.h>
#endif

#include <math.h>

#define MAX_POP_SIZE    10000
#define MAX_POPULATIONS   200
#define MAX_GEN_RUN     10000

#define DEFGEOMETRY "700x400"
#define APPNAME "simul8"
#define FONT "-*-new century schoolbook-medium-r-*-*-14-*"

#define TRUE  1
#define FALSE 0
typedef char Boolean;

#define GRAPHICS    1
#define CHARACTERS  2
#define RECONFIGURE 3
typedef int DisplayType;

#define LARGE_BUF_LENGTH 500
char Buffer[LARGE_BUF_LENGTH];



/*
 * Global variables  :(
 */

DisplayType disp_type;

long lines = 8;                 /* The number of lines/populations */

double p1[MAX_POPULATIONS+1];   /* the array of the populations */

long t1;                        /* the beginning generation for a run */

long n;                         /* the size of the population * 2 */
long n0;                        /* the size of the population (before repro.)*/
double w1;                      /* fitness of AA */
double w2;                      /* fitness of Aa */
double w3;                      /* fitness of aa */

double u;                       /* mut rate from A to a */
double v;                       /* mut rate from a to A */

double m;                       /* migration rate */

double p0;                      /* initial freq. of A */

long g9;                        /* generations to run */

long fixdown, fixup;            /* number of populations A lost, fixed */

typedef struct {
  float x,y;
} point;

point **saved_run;                /* the saved run */
int last_saved_g = 0;                /* the last dimensions of the saved data */
int last_saved_lines = 0;        /* the last dimensions of the saved data */


/* Graphics variables */
/* note: the drawing is based off of 600x400 screen.  The line drawing */
/*       routines are where the scaling to a different screen size should */
/*       occur. */

#define HEIGHT  400
#define WIDTH   600
#define MAXY    ( HEIGHT - 50 )
#define MAXX    ( WIDTH - 50 )
#define PIXELS_PER_UNIT ( HEIGHT * (3.0 / 4.0) / 10 ) 
                                /* 3/4 of the window for the graph */
#define YTOP    20
#define YBOT    ( (int) ((float) (PIXELS_PER_UNIT * 10) + 0.5) + YTOP )
                                /* the +0.5 is to round correctly */
#define XSPACE ( MAXX / 25.0 )        /* why these numbers, I don't know */
#define YSPACE ( MAXY / 17.5 )



/* X */
#ifdef X
Display *display;                /* the X display */
Window  mainwin;                /* the main display window */

char *fontrsc;                        /* the font resource */
char fontname[LARGE_BUF_LENGTH]; /* the font name to use */
XFontStruct *fontst;                /* the font strcture for the font */

int x, y;                        /* the corner of the window */
int width, height;                /* the width and height of the window */

XGCValues gcv;                        /* graphics context values */
GC gc1;                                /* a graphics context */
/*
XSizeHints xsh;
XEvent myevent;
*/
#endif


/* non X */
#ifdef __TURBOC__
long  HiMode,GraphDriver,GraphMode,LoMode;
long backcolor = 10;                        /* the background color */
long linecolor = 1;                         /* the color of the lines */
#endif

#ifdef __WATCOMC__
struct textsettings ts;                    /* in hopes it affects it */
long backcolor = 1;                        /* the background color */
long linecolor = 7;                        /* the color of the lines */
#endif

/* both */
int HalfTextHeight;                /* Half of the height of the font */


void uppercase(ch)
     char *ch;
{
  /* convert ch to upper case -- either ASCII or EBCDIC */
  *ch = isupper(*ch) ? *ch : toupper(*ch);
}  /* uppercase */


double dgetnum() 
{
  double num;

  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  while ( sscanf(Buffer, "%lg", &num) != 1) {
    printf("\nPlease enter a number: ");
    fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  }
  
  return num;
}


long lgetnum() 
{
  long num;

  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  while ( sscanf(Buffer, "%ld", &num) != 1) {
    printf("\nPlease enter a number: ");
    fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  }

  return num;
}

double randreal()
{
#ifdef X
  return (((double)(random())) / (double)2147483647); /* div by RAND_MAX */
#endif
#ifdef __TURBOC__
  return (((double)(rand())) / (double) RAND_MAX);
#endif
#ifdef __WATCOMC__
  return (((double)(rand())) / (double) RAND_MAX);
#endif
}

/* 
 * binomial
 *   A binomial distribution 
 *   Parameters:
 *     long n:    the number of trials
 *     double pp: the probability of heads per trial
 *   Return value: the number of "heads"
 */
static long binomial(n, pp)
     long n;
     double pp;
{  /* binomial */
  long j, bnl;
  double p;
  
  if (pp <= 0.5) {
    p = pp;
  }
  else {
    p = 1.0 - pp;
  }
  bnl = 0;
  for (j = 1; j <= n; j++) {
    if (randreal() < p) {
      bnl++;
    }
  }
  if (p != pp) {
    bnl = n - bnl;
  }
  return bnl;
}  /* binomial */


void Line(x1,y1,x2,y2)
     int x1,y1,x2,y2;
{
#ifdef X
  XDrawLine(display,mainwin,gc1,(long)x1,(long)y1,(long)x2,(long)y2);
  XFlush(display);
#endif
#ifdef __TURBOC__
  line(x1,y1,x2,y2);
#endif
#ifdef __WATCOMC__
  _moveto(x1,y1);
  _lineto(x2,y2);
#endif
}


void OutTextXY(x,y,text)
     int x,y;
     char *text;
{
#ifdef X
  int fontsize=fontst->ascent + fontst->descent;
  XDrawString(display,mainwin,gc1,
              (long)(x-(fontsize/2)),(long)(y+fontsize/2),text,strlen(text));
#endif
#ifdef __TURBOC__
        outtextxy(x-HalfTextHeight,y+HalfTextHeight*2,text);
#endif
#ifdef __WATCOMC__
       _setcharsize(12,12);
       _setcharspacing(-5);
       _grtext(x,y,text);
#endif
} /* OutTextXY */


void ClearDisplay()
{
#ifdef X
  XClearWindow(display,mainwin);
#endif
#ifdef __TURBOC__
  clrscr();
#endif
#ifdef __WATCOMC__
  _clearscreen(_GCLEARSCREEN);
  _setcolor((long)backcolor);
  _floodfill( 100, 100, -1);
  _setcolor((long)linecolor);
#endif
}


void ClearText()
{
#ifdef X
#endif
#ifdef __TURBOC__
#endif
#ifdef __WATCOMC__
#endif
}


void write_prolog(psfp)
     FILE *psfp;                /* the postscript file pointer */
{
  fprintf(psfp, "%%!PS-Adobe-2.0\n");
  fprintf(psfp, "%%%%Creator: simul8\n");
  fprintf(psfp, "%%%%Title %s\n", Buffer);
  fprintf(psfp, "%%%%BoundingBox: %d %d %d %d\n", 0, 0, WIDTH, HEIGHT);
  fprintf(psfp, "%%%%EndComments\n");
  fprintf(psfp, "%%%%BeginProlog\n");
  fprintf(psfp, "\n");

  fprintf(psfp, "/T {\n");
  fprintf(psfp, "\t%f gsave sub translate\n", (float)(-1.0*HalfTextHeight));
  fprintf(psfp, "\t1 -1 scale 0 0 moveto show grestore\n");
  fprintf(psfp, "\t} bind def\n");
  fprintf(psfp, "\n");

  fprintf(psfp, "/L {\n");
  fprintf(psfp, "\tlineto\n");
  fprintf(psfp, "\t} bind def\n");
  fprintf(psfp, "\n");

  fprintf(psfp, "/M {\n");
  fprintf(psfp, "\tmoveto\n");
  fprintf(psfp, "\t} bind def\n");
  fprintf(psfp, "\n");

  fprintf(psfp, "/S {\n");
  fprintf(psfp, "\tstroke\n");
  fprintf(psfp, "\t} bind def\n");
  fprintf(psfp, "\n");
  

  fprintf(psfp, "%%%%EndProlog\n");
}

 
void write_scale(psfp, tbeg, tdur)
     FILE *psfp;                /* the postscript file pointer */
     long tbeg, tdur;
{
  int i;


  fprintf(psfp, "%%%%Page: 1 1\n");
  fprintf(psfp, "20 600 translate\n 0.9 -0.9 scale\n");
  fprintf(psfp, "/Times-Roman findfont 14 scalefont setfont\n");

  fprintf(psfp, "(1.0) %.2f %.2f T\n", 
          (float)(XSPACE*2.5),
          (float)(YTOP - 0.12*HalfTextHeight));
  for (i = 1; i <= 9; i++) {
    sprintf(Buffer, "%2.1f", 1 - i / 10.0);
    fprintf(psfp, "(%s) %.2f %.2f T\n", Buffer,
            (float)(XSPACE*2.5),
            (float)(YTOP + i*PIXELS_PER_UNIT - 0.12*HalfTextHeight));
  }
  fprintf(psfp, "(0.0) %.2f %.2f T\n",
          (float)(XSPACE*2.5),
          (float)(YTOP + PIXELS_PER_UNIT*10 - 0.12*HalfTextHeight));
  fprintf(psfp, "(P\\050A\\051) %.2f %.2f T\n",
          (float)(XSPACE*2.0/3.0),
          (float)((YTOP + YBOT) / 2 - 0.12*HalfTextHeight));  /* \050 = '(',
                                                                 \051 = ')' */
  sprintf(Buffer, "%ld", tbeg);
  fprintf(psfp, "(%s) %.2f %.2f T\n", Buffer,
          (float)(XSPACE*3.8),
          (float)(YBOT + 2.0*HalfTextHeight));
  sprintf(Buffer, "%12ld", tbeg + tdur);
  fprintf(psfp, "(%s) %.2f %.2f T\n", Buffer,
          (float)(XSPACE*22.7),
          (float)(YBOT + 2.0*HalfTextHeight));
  fprintf(psfp, "(Generation) %.2f %.2f T\n",
          (float)(XSPACE*13),
                (float)(YBOT + HalfTextHeight * 3.0));
  fprintf(psfp, "S %.2f %.2f M\n%.2f %.2f L\nS\n", 
          (float)(XSPACE*4), (float)(YTOP),
          (float)(XSPACE*4), (float)(YBOT));
  /* print the number lost, fixed */
  sprintf(Buffer, "Lost:  %3ld", fixdown);
  fprintf(psfp, "(%s) %.2f %.2f T\n", Buffer,
          (float)(XSPACE*25.5),
          (float)(YBOT - 0.2*HalfTextHeight));
  sprintf(Buffer, "Fixed: %3ld", fixup);
  fprintf(psfp, "(%s) %.2f %.2f T\n", Buffer,
          (float)(XSPACE*25.5),
          (float)(YTOP - 0.2*HalfTextHeight));
  /* draw dashed lines along top and bottom of the graph area */
  for (i = 1; i <= 50; i++) {
    fprintf(psfp, "%.2f %.2f M  %.2f %.2f L  S\n",
            (float)(XSPACE*4 + (i - 1) * 9),    
            (float)(YTOP),
            (float)(XSPACE*4 + (i - 1) * 9 + 5),
            (float)(YTOP));
    fprintf(psfp, "%.2f %.2f M  %.2f %.2f L  S\n",
            (float)(XSPACE*4 + (i - 1) * 9),    
            (float)(YBOT),
            (float)(XSPACE*4 + (i - 1) * 9 + 5),
            (float)(YBOT));
  }
  fprintf(psfp, "\n");
}


void write_lines(psfp)
     FILE *psfp;                /* the postscript file pointer */
{
  int i, j;

  /* draw the infinite population curve */
  for (j=0; j<last_saved_g; j++) {
    while ((saved_run[0][j].x == 0.0 && 
            saved_run[0][j].y == 0.0) ||
           (saved_run[0][j+1].x == 0.0 && 
            saved_run[0][j+1].y == 0.0)) {
      j++;
    }
    if (j+1 >= last_saved_g) {
      break;
    }
    fprintf(psfp, "\n");
    fprintf(psfp, "S \n%f %f M\n",
            saved_run[0][j].x, saved_run[0][j].y);
    j++;
    fprintf(psfp, "%f %f L\n", 
            saved_run[0][j].x, saved_run[0][j].y);
  }

  /* draw the populations */
  for (i=1; i<last_saved_lines; i++) {
    fprintf(psfp, "\n");
    fprintf(psfp, "S \n%f %f M\n", 
            saved_run[i][0].x, saved_run[i][0].y);
    for (j=1; j<last_saved_g; j++) {
      fprintf(psfp, "%f %f L\n", 
              saved_run[i][j].x, saved_run[i][j].y);
    }
  }
  fprintf(psfp, "S\n");
  fprintf(psfp, "showpage\n");
  fprintf(psfp, "\n");
}
  

void save_to_postscript(tbeg, tdur)
     long tbeg, tdur;
{
  int i,j;
  FILE *psfp;                        /* the postscript file pointer */

#ifdef __TURBOC__
  if (disp_type != CHARACTERS) {
    restorecrtmode();
  }
#endif
#ifdef __WATCOMC__
  if (disp_type != CHARACTERS) {
    _setvideomode(_DEFAULTMODE);
  }
#endif
 
  printf("\nEnter the filename to save to: ");
  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  Buffer[strlen(Buffer)-1] = '\0'; /* remove the '\n' */
  psfp = fopen(Buffer, "w");

  write_prolog(psfp);   /* had second argument Buffer in Bill A's version */
  write_scale(psfp, tbeg, tdur);
  write_lines(psfp);
  
  fclose(psfp);

#ifdef __TURBOC__
  if (disp_type != CHARACTERS) {
    setgraphmode(getgraphmode());
    setcolor(linecolor);
    setbkcolor(backcolor);
  }
#endif

#ifdef __WATCOMC__
  if (disp_type != CHARACTERS) {
    _setvideomode(_VRES16COLOR);
    _clearscreen(_GCLEARSCREEN);
    _setcolor((long)backcolor);
    _floodfill( 100, 100, -1);
    _setcolor((long)linecolor);
  }
#endif
}


void reconfigure(disp_type)
     DisplayType disp_type;
{
  do {
    printf("Number of populations evolving simultaneously? currently:");
    printf("%2ld\n", lines);
    fgets(Buffer, LARGE_BUF_LENGTH, stdin);
    sscanf(Buffer, "%ld", &lines);
    if ((disp_type == GRAPHICS) && (lines > MAX_POPULATIONS))
      printf("The program does not allow more than %ld populations.\n",
             MAX_POPULATIONS);
  } while ((disp_type == GRAPHICS) && (lines > MAX_POPULATIONS));
#ifdef __TURBOC__
  printf("Background color (0-15)? currently:");
  printf("%3ld\n", backcolor);
  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  sscanf(Buffer, "%ld", &backcolor);

  printf("Line color (0-15)? currently:");
  printf("%3ld\n", linecolor);
  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  sscanf(Buffer, "%ld", &linecolor);
#endif

#ifdef __WATCOMC__
  printf("Background color (0-15)? currently:");
  printf("%3ld\n", backcolor);
  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  sscanf(Buffer, "%ld", &backcolor);

  printf("Line color (0-15)? currently:");
  printf("%3ld\n", linecolor);
  fgets(Buffer, LARGE_BUF_LENGTH, stdin);
  sscanf(Buffer, "%ld", &linecolor);
#endif
  if (disp_type == CHARACTERS && lines > 8) {
    printf("No more than 8 lines allowed in character graph. Number of lines set to 8\n");
    lines = 8;
  }
}


DisplayType get_display_type()
{
  DisplayType z;

  /* get the display mode */
  do {
    printf("\nSelect what type of display you will have:\n");
    printf("  1  Graphics (not text)\n");
    printf("  2  Graph made from characters\n");
#ifndef X
    if (z != RECONFIGURE) {
      printf("  3  (if you first want to change colors or number of populations)\n");
    }
#endif
    printf("Select one of these: ");
    fgets(Buffer, LARGE_BUF_LENGTH, stdin);
    sscanf(Buffer, "%d", &z);
    
#ifndef X
    if (z == RECONFIGURE) {
      reconfigure(z);
    }
#endif
    
  } while (z != GRAPHICS && z != CHARACTERS);
  
  if (z == CHARACTERS && lines > 8) {
    printf("No more than 8 lines allowed in character graph. Number of lines set to 8\n");
    lines = 8;
  }

  return z;
 
}


void initialize_display(disp_type, argc, argv)
     int argc;
     char *argv[];
     DisplayType disp_type;
{
  int errorcode;
        
  if (disp_type == GRAPHICS) {
#ifdef X
    if ((display=XOpenDisplay(getenv("DISPLAY"))) == NULL) {
      fprintf(stderr,"%s:  Can't open display %s\n",argv[0],getenv("DISPLAY"));
      exit(0);
    }
    fontrsc = XGetDefault(display,APPNAME,"font");
    if (fontrsc) {
      strcpy(fontname,fontrsc);
    }
    else {
      strcpy(fontname,FONT);
    }
    XParseGeometry(DEFGEOMETRY,&x,&y,&width,&height); 
    /* Try and get a font from the server: */
    if ((fontst = XLoadQueryFont(display,fontname)) == NULL) {
      fprintf(stderr,"Can't open font %s\n",FONT);
      exit(0);
    }
    mainwin=XCreateSimpleWindow(display,DefaultRootWindow(display),x,y,
                                width,height,4,
                                BlackPixel(display,DefaultScreen(display)),
                                WhitePixel(display,DefaultScreen(display)));
    if (!mainwin) {
      fprintf(stderr,"Can't create simple window\n");
      exit(0);
    }
    {
      XSetWindowAttributes winAttr;
      winAttr.backing_store = Always;
      XChangeWindowAttributes(display,mainwin,CWBackingStore,&winAttr);
    }
    gcv.font=fontst->fid;
    gcv.foreground=WhitePixel(display,DefaultScreen(display));
    gcv.background=BlackPixel(display,DefaultScreen(display));
    gc1=XCreateGC(display,mainwin,(GCFont|GCForeground|GCBackground),&gcv);
    XSetFont(display,gc1,fontst->fid);
    XSetForeground(display,gc1,BlackPixel(display,DefaultScreen(display)));
    XStoreName(display,mainwin,APPNAME);
    XSetIconName(display,mainwin,APPNAME);
    XSelectInput(display,mainwin,ExposureMask|KeyPressMask|ButtonPressMask|StructureNotifyMask|KeyPressMask|KeyReleaseMask);
    XMapWindow(display,mainwin);
    HalfTextHeight = (fontst->ascent + fontst->descent)/2;
    XFlush(display);
/*    strcpy(fontname,"Hershey");   debug */
    strcpy(fontname,"Times");
#endif
#ifdef __TURBOC__
  if ((registerbgidriver(EGAVGA_driver) <0) ||
      (registerbgidriver(Herc_driver) <0)   ||
      (registerbgidriver(CGA_driver) <0)){
    fprintf(stderr,"Graphics error: %s ",grapherrormsg(graphresult()));
    exit(-1);}
    GraphDriver = 0;
    detectgraph(&GraphDriver,&GraphMode);
    getmoderange(GraphDriver,&LoMode,&HiMode);
    initgraph(&GraphDriver,&HiMode,"");
    errorcode = graphresult();
    if (errorcode != grOk) {  /* an error occurred */
      printf("Graphics error: %s\n", grapherrormsg(errorcode));
      printf("Press any key to halt:");
      getch();
      exit(1); /* terminate with an error code */
    }
    
    HalfTextHeight = (long)textheight("0") / 2;
    setcolor((long)linecolor);
    setbkcolor((long)backcolor);
#endif 
#ifdef __WATCOMC__
  _setvideomode(_VRES16COLOR);
  _setbkcolor((long)backcolor);
  _setcolor((long)linecolor);
  HalfTextHeight = 10;
#endif 
  }
  else if (disp_type == CHARACTERS) {
    /* text screen set up */
    HalfTextHeight = 7;                /* for CHARACTER when outputing ps. */
                                /* 1/2 of 14pt */
  }
  else {
    fprintf(stderr, "Unknown method to display.  Exiting.\n");
    exit(1);
  }
}


Boolean get_parameters(disp_type,
                       pop_size,
                       init_pop_size,
                       fit_AA, fit_Aa, fit_aa, 
                       mut_A_to_a, mut_a_to_A,
                       migration,
                       init_A_freq,
                       gen_to_run,
                       lines)
     DisplayType disp_type;
     long *pop_size;
     long *init_pop_size;
     double *fit_AA;
     double *fit_Aa;
     double *fit_aa;
     double *mut_A_to_a;
     double *mut_a_to_A;
     double *migration;
     double *init_A_freq;
     long *gen_to_run;
     long *lines;

{
  char answer;
  int i;

  static long prev_gen_to_run = -1;

  if (prev_gen_to_run == -1) {
    prev_gen_to_run = *gen_to_run;
  }
  else {
    *gen_to_run = prev_gen_to_run;
  }

  while (TRUE) { 
    
    /* re-initialize the populations */
    for (i = 0; i <= *lines; i++) {
      p1[i] = *init_A_freq;
    }
#ifdef __TURBOC__
    clrscr();
#endif
#ifdef __WATCOMC__
    _clearscreen(_GCLEARSCREEN);
    _setcolor((long)backcolor);
    _floodfill( 100, 100, -1);
    _setcolor((long)linecolor);
#endif

    printf("SIMUL8 settings\n");
    printf("We are simulating %d replicate populations\n\n", *lines);

    printf("Option Number                       Current Value\n\n");

    printf("   1  Population Size:                    %d\n\n", *pop_size/2);

    printf("   2  Fitness of genotype AA:             %lg\n", *fit_AA);
    printf("   3  Fitness of genotype Aa:             %lg\n", *fit_Aa);
    printf("   4  Fitness of genotype aa:             %lg\n\n", *fit_aa);

    printf("   5  Mutation rate from A to a:          %lg\n", *mut_A_to_a);
    printf("   6  Mutation rate from a to A:          %lg\n\n", *mut_a_to_A);

    printf("   7  Migration rate between populations: %lg\n\n", *migration);

    printf("   8  Initial freq. of allele A:          %lg\n\n", *init_A_freq);

    printf("   9  Generations to run:                 %d\n\n", *gen_to_run);

    printf("   0  Change configuration settings.\n\n");
    
    printf("Are these settings correct? ([Y], Q, or option #): ");
    
    fgets(Buffer, LARGE_BUF_LENGTH, stdin);
    answer = Buffer[0];
    
    uppercase(&answer);
    
    switch (answer) {
    case 'Y': case '\n': case '\0': /* done with setting the parameters */
      t1 = 0;                        /* reset the beggining time */
      return FALSE; /* we are NOT done with the run */
      break;
    case 'Q': /* done with the simulation */
      return TRUE;  /* the simulation is over */
      break;
    case '1': /* population */
      printf("\nNew population size (was %d): ", *pop_size/2);
      *pop_size = lgetnum();
      while (((unsigned long)*pop_size > MAX_POP_SIZE) && 
             ((unsigned long)*pop_size <= 0)) {
        printf("\nPlease enter a number between %d and %d: ", 1, MAX_POP_SIZE);
        *pop_size = lgetnum();
      }
      *init_pop_size = *pop_size;
      *pop_size *= 2;
      break;
    case '2': /* fitness AA */
      printf("\nFitness of genotype AA (was %f): ", *fit_AA);
      *fit_AA = dgetnum();
      while (*fit_AA < 0.0) {
        printf("\nPlease enter a number greater than or equal to 0.0: ");
        *fit_AA = dgetnum();
      }
      break;
    case '3': /* fitness Aa */
      printf("\nFitness of genotype Aa (was %f): ", *fit_Aa);
      *fit_Aa = dgetnum();
      while (*fit_Aa < 0.0) {
        printf("\nPlease enter a number greater than or equal to 0.0: ");
        *fit_Aa = dgetnum();
      }
      break;
    case '4':
      printf("\nFitness of genotype aa (was %f): ", *fit_aa);
      *fit_aa = dgetnum();
      while (*fit_aa < 0.0) {
        printf("\nPlease enter a number greater than or equal to 0.0: ");
        *fit_aa = dgetnum();
      }
      break;
    case '5': /* mutation A to a */
      printf("\nMutation rate from A to a (was %f): ", *mut_A_to_a);
      *mut_A_to_a = dgetnum();
      while ((unsigned)*mut_A_to_a > 1.0 || 
             (unsigned)*mut_A_to_a < 0.0) {
        printf("\nPlease enter a number between 0.0 and 1.0: ");
        *mut_A_to_a = dgetnum();
      }
      break;
    case '6': /* mutation a to A */
      printf("\nMutation rate from a to A (was %f): ", *mut_a_to_A);
      *mut_a_to_A = dgetnum();
      while ((unsigned)*mut_a_to_A > 1.0 ||
             (unsigned)*mut_A_to_a < 0.0) {
        printf("\nPlease enter a number between 0.0 and 1.0: ");
        *mut_a_to_A = dgetnum();
      }
      break;
    case '7': /* migration */
      printf("\nMigration rate from all the other populations? (0 to %4.2f) ",
             1 - 1.0 / *lines);
      *migration = dgetnum();
      while ((unsigned)*migration > 1.0 - 1.0 / *lines  ||
             (unsigned)*migration < 0.0) {
        printf("\nImpossible rate!");
        printf("\nPlease enter a number between 0.0 and %4.2f: ", 1.0-1.0/ *lines);
        *migration = dgetnum();
      }
      break;
    case '8': /* initial freq of A */
      printf("Initial freq of allele A (was %f): ", *init_A_freq);
      *init_A_freq = dgetnum();
      while (*init_A_freq > 1.0 || *init_A_freq < 0.0) {
        printf("\nPlease enter a number between 0.0 and 1.0: ");
        *init_A_freq = dgetnum();
      }
      break;
    case '9': /* generations to run */
      printf("How many generations: ");
      *gen_to_run = lgetnum();
      while (((unsigned long)*gen_to_run > MAX_GEN_RUN) ||
             ((unsigned long)*gen_to_run < 0)) {
        printf("\nPlease enter a number between 0 and %d: ", MAX_GEN_RUN);
        *gen_to_run = lgetnum();
      }
      prev_gen_to_run = *gen_to_run;
      break;
    case '0': /* other options */
      reconfigure(disp_type);
      break;
    default:
      printf("\nNot an option\n");
      break;
    }
    
  } /* end loop */

}


void do_n_generations(disp_type, n, n0, w1, w2, w3, u, v, m, t1, g9)
     DisplayType disp_type;
     long n;                        /* the size of the population * 2 */
     long n0;                        /* the size of the population (before repro.)*/
     double w1;                        /* fitness of AA */
     double w2;                        /* fitness of Aa */
     double w3;                        /* fitness of aa */
     double u;                        /* mut rate from A to a */
     double v;                        /* mut rate from a to A */
     double m;                        /* migration rate */
     long t1;                        /* the beggining generation for this run */
     long g9;                        /* generations to run */
     
{
  int i, j;
  int t;
  int k;

  int t2;


  double pbar;
  double p;
  double p2;
  double q;
  double w;
  double pp1;
  double pp2;

  long nx;
  long ny;

  /* 
   * Reset the saved runs space if needed
   */

  if (((g9+1) != last_saved_g) || (lines+1 != last_saved_lines)) {
    for (i=0; i<last_saved_lines; i++) {
      free(saved_run[i]);
    }
    free(saved_run);

    last_saved_g = g9+1;
    last_saved_lines = lines+1;
    
    saved_run = (point **)calloc(last_saved_lines, sizeof(point *));
    for (i=0; i<last_saved_lines; i++) {
      saved_run[i] = (point *)calloc(last_saved_g, sizeof(point));
    }
  }

  /* fill in the first set */
  for (i=1; i<last_saved_lines; i++) {
    saved_run[i][0].x = (float)(XSPACE*4);
    saved_run[i][0].y = (float)(YTOP + 
                                 (float)floor((YBOT - YTOP) * 
                                              (1.0 - p1[i]) + 0.5));
  }

  /*
   * Set up the display
   */
  
  if (disp_type == GRAPHICS) {
    ClearDisplay();
    OutTextXY((int)(XSPACE*2.5), (int)YTOP-HalfTextHeight/2, "1.0");
    for (i = 1; i <= 9; i++) {
      sprintf(Buffer, "%2.1f", 1 - i / 10.0);
      OutTextXY((int)(XSPACE*2.5),
                (int)(YTOP + i * PIXELS_PER_UNIT-HalfTextHeight/2), Buffer);
    }
    OutTextXY((int)(XSPACE*2.5),
              (int)(YTOP + PIXELS_PER_UNIT * 10-HalfTextHeight/2), "0.0");
    OutTextXY((int)(XSPACE/2),
              (int)((YTOP + YBOT) / 2)-HalfTextHeight/2, "P(A)");
    sprintf(Buffer, "%ld", t1);
    OutTextXY((int)(XSPACE*4), (int)(YBOT + 2*HalfTextHeight), Buffer);
    sprintf(Buffer, "%9ld", t1 + g9);
    OutTextXY((int)(XSPACE*23), (int)(YBOT + 2*HalfTextHeight), Buffer);
    OutTextXY((int)(XSPACE*13), (int)(YBOT + HalfTextHeight * 5), "Generation");
    Line((int)(XSPACE*4), (int)YTOP, (int)(XSPACE*4), (int)YBOT);
    /* draw dashed lines along top and bottom of the graph area */
    for (i = 1; i <= 50; i++) {
      Line((int)(XSPACE*4 + (i - 1) * 9),    (int)YTOP,
           (int)(XSPACE*4 + (i - 1) * 9 + 5),(int)YTOP);
      Line((int)(XSPACE*4 + (i - 1) * 9),    (int)YBOT,
           (int)(XSPACE*4 + (i - 1) * 9 + 5),(int)YBOT);
    }
  }  /* end if GRAPHICS display */
  /* if it is a CHARACTERS display and the first time */
  if (disp_type == CHARACTERS && t1 == 0) {
    printf("\n                           GENE FREQUENCIES\n");
    printf(" GEN.   0.0                      0.5                      1.0\n");
    printf("        +-----+----+----+----+----+----+----+----+----+-----+\n");
  }
  
  /* every 1/40 of the generation run time want to draw a dash at the */
  /* expected frequency if we had an infinite population.  t2 is used */
  /* to know when we have gone 1/40 of the generation run time. */
  t2 = g9 / 40;
  if (t2 < 2) {
    t2 = 2;
  }

   /* The section below is where all the population genetics happens.
      If you are trying to understand the simulation this loop is all
      you need to know about.  The rest is input/output */

  /* for all the generations */
  for (t = 0; t < g9; t++) {
    if (disp_type == CHARACTERS) {
      printf("%6ld", t1 + t);
      for (i = 1; i <= 51; i++) {
        Buffer[i - 1] = ' ';
      }
    }
    /* calculate the mean frequency of AA over all the populations */
    fixup = 0;
    fixdown = 0;
    pbar = 0.0;
    for (i = 1; i <= lines; i++) {
      pbar += p1[i];
      if (p1[i] == 0.0)
        fixdown += 1;
      if (p1[i] == 1.0)
        fixup += 1;
    }
    pbar /= lines;
    /* for each population ________________________ */
    for (i = 0; i <= lines; i++) {  /* get new frequency for population i */
      p = (double) p1[i];           /* the current gene frequency */
      p2 = p;                       /* save it in p2 */
      if (i > 0) {
        p = p * (1.0 - m) + m * pbar;   /* all but pop. 0 receive migrants */
      }
      p = (1 - u) * p + v * (1 - p);   /* and they all mutate at rates u, v */
      
      /* if the genotype is not fixed calculate the new frequency */
      if (p > 0.0 && p < 1.0) {
        q = 1 - p;
        w = p * p * w1 + 2.0 * p * q * w2 + q * q * w3;  /* get mean fitness */
        pp1 = p * p * w1 / w;             /* get frequency of AA after sel. */
        pp2 = 2.0 * p * q * w2 / w;       /* get frequency of Aa after sel. */
        if (i > 0) {        
          /* calculate the next generation */
          nx = binomial(n0, pp1);         /* draw how many AA's survive */
          if (pp1 < 1.0 && nx < n0) {
            ny = binomial(n0 - nx, pp2 / (1.0 - pp1));  /* and Aa's too */
          }
          else {
            ny = 0;
          }
          p1[i] = nx * 2.0 + ny;          /* compute new number of A's */
          p1[i] /= n;                     /* and make it a frequency */
        }
        else {                
          /* calculate what the "true" average would be.  What you */
          /* would expect with an infinite population. */
          p1[i] = pp1 + pp2 / 2.0;
        }
      }
   
     /* end of the important stuff */
      
      /* if we are displaying on text, modify the output line */
      if (disp_type == CHARACTERS) {
        k = (50 * p2 + 1.5);
        if (Buffer[k - 1] == ' ') {
          Buffer[k - 1] = '1';
        }
        else {
          Buffer[k - 1]++;
        }
      } 
      /* otherwise we are displaying graphics and should draw the line */
      else if (disp_type == GRAPHICS) {
        if (i > 0 || t % t2 == 0) { /* every t2 generations, draw */
                                    /* expected frequency */
                                        /* here it is. */
          Line((int)(XSPACE*4 + 450.0 * t / g9),
               (int)(YTOP + (long)floor((YBOT - YTOP) * (1 - p2) + 0.5)),
               (int)(XSPACE*4 + 450.0 * (t + 1) / g9),
               (int)(YTOP + (long)floor((YBOT - YTOP) * (1 - p1[i]) + 0.5)));
        }
      }

      /* enter the end point into the saved runs */
      if (i == 0 && t % t2 == 0) {
        saved_run[i][t].x = (float)(XSPACE*4 + 450.0 * t / g9);
        saved_run[i][t].y = (float)((float)YTOP + 
                                    (float)floor((YBOT - YTOP) * 
                                                 (1 - p2) + 0.5));
        saved_run[i][t+1].x = (float)(XSPACE*4 + 450.0 * (t + 1) / g9);
        saved_run[i][t+1].y = (float)((float)YTOP + 
                                        (float)floor((YBOT - YTOP) * 
                                                     (1 - p1[i]) + 0.5));
      }
      if (i > 0) {
        saved_run[i][t+1].x = (float)(XSPACE*4 + 450.0 * (t + 1) / g9);
        saved_run[i][t+1].y = (float)((float)YTOP + 
                                        (float)floor((YBOT - YTOP) * 
                                                     (1 - p1[i]) + 0.5));
      }

    }  /* end of for i<=lines : for each population _______________ */
    if (disp_type == CHARACTERS) {
      printf("  !");
      for (j = 1; j <= 51; j++) {
        putchar(Buffer[j - 1]);
      }
      printf("!\n");
    }
  }  /* end of for t<g9 -- end of running through the generations */
    if (disp_type == GRAPHICS) {   /* print how many fixed, how many lost */
      OutTextXY((int)(XSPACE*25), (int)(YBOT - HalfTextHeight/2), "Lost: ");
      sprintf(Buffer, "%3ld", fixdown);
      OutTextXY((int)(XSPACE*27), (int)(YBOT - HalfTextHeight/2), Buffer);
      OutTextXY((int)(XSPACE*25), (int)(YTOP - HalfTextHeight/2), "Fixed:");
      sprintf(Buffer, "%3ld", fixup);
      OutTextXY((int)(XSPACE*27.5), (int)(YTOP - HalfTextHeight/2), Buffer);
      }
}


long continue_with_more_generations(disp_type, last_additional_gen)
     DisplayType disp_type;
     long last_additional_gen;
{
  long more_generations;

  do {
    if (disp_type == CHARACTERS) {
      printf("\nP TO SAVE AS A POSTSCRIPT FILE OR\nHOW MANY MORE GENERATIONS (0 TO STOP)[%d]? ", 
             last_additional_gen);
    }
    else {
#ifdef X
      printf("\nP to save as a postscript file or the number of additional generations \n(0 to STOP)[%d]? ", 
             last_additional_gen);
      OutTextXY((int) XSPACE,
                (int)( YBOT + HalfTextHeight * 8),
                "HOW MANY MORE GENERATIONS?  ENTER VALUE IN THE STARTUP WINDOW.");
      XFlush(display);
#endif
#ifdef __TURBOC__
   sprintf(Buffer, "P to save as a postscript file or the number of additional generations");
   OutTextXY((int) XSPACE,
                (int)( YBOT + HalfTextHeight * 6), Buffer);
                        sprintf(Buffer, "(0 to STOP)[%d]?",
                                last_additional_gen);
                        OutTextXY((int) XSPACE,
                (int)( YBOT + HalfTextHeight * 8), Buffer);
   gotoxy(0,23);
#endif
#ifdef __WATCOMC__
   sprintf(Buffer, "P to save as a postscript file or the number of additional generations");
   OutTextXY((int) XSPACE,
                (int)( YBOT + HalfTextHeight * 6), Buffer);
                        sprintf(Buffer, "(0 to STOP)[%d]?",
                                last_additional_gen);
                        OutTextXY((int) XSPACE,
                (int)( YBOT + HalfTextHeight * 8), Buffer);
    /*   gotoxy(0,23);  */
#endif
    }

    fgets(Buffer, LARGE_BUF_LENGTH, stdin);
    while (sscanf(Buffer, "%ld", &more_generations) != 1 ||
           (Buffer[0] == 'p' || Buffer[0] == 'P')) {
      /* if they pressed 'p' or 'P' get save the data */
      if (Buffer[0] == 'p' || Buffer[0] == 'P') {
        save_to_postscript(t1-last_additional_gen, last_additional_gen);
      }
      /* if they just pressed enter get the default */
      if (Buffer[0] == '\n') {
        more_generations = last_additional_gen;
        break;
      }
                        printf("\nPlease enter P or the number of additional generations\n(0 to STOP)[%d]? ", last_additional_gen);
      fgets(Buffer, LARGE_BUF_LENGTH, stdin);
    }

  } while ((more_generations < 0) || (more_generations > MAX_GEN_RUN));
  
  return more_generations;
}


main(argc, argv)
     int argc;
     char *argv[];
{  /* main */
  int i;

  Boolean cont = TRUE;
  Boolean done = FALSE;

  /* default values for the parameters */
  n  = 200;  /* population*2 */
  n0 = 100;  /* population */
  w1 = 1.0;  /* fitness AA */
  w2 = 1.0;  /* fitness Aa */
  w3 = 1.0;  /* fitness aa */
  u  = 0.0;  /* mut rate from A to a */
  v  = 0.0;  /* mut rate from a to A */
  m  = 0.0;  /* migration rate */
  p0 = 0.5;  /* initial freq. of A */
  g9 = 100;  /* generations to run */

  printf("SIMUL8 (c) Copyright Joe Felsenstein 1990\n");

#ifdef X /* we are on unix */
  srandom((int)time(NULL));
#endif
#ifdef __TURBOC__
  srand((int)time(NULL));
#endif
#ifdef __WATCOMC__
  srand((int)time(NULL));
#endif

  last_saved_g = g9+1;
  last_saved_lines = lines+1;

  saved_run = (point **)calloc(last_saved_lines, sizeof(point *));
  for (i=0; i<last_saved_lines; i++) {
    saved_run[i] = (point *)calloc(last_saved_g, sizeof(point));
  }

  disp_type = get_display_type();

  initialize_display(disp_type, argc, argv);

  do {

#ifdef __TURBOC__
    if (disp_type != CHARACTERS) {
      restorecrtmode();
    }
#endif
#ifdef __WATCOMC__
    if (disp_type != CHARACTERS) {
      _setvideomode(_VRES16COLOR);
    }
#endif
    
    done = get_parameters(disp_type, 
                          &n, &n0, 
                          &w1, &w2, &w3, 
                          &u, &v, &m, 
                          &p0, &g9, 
                          &lines);

#ifdef __TURBOC__
    if (disp_type != CHARACTERS) {
      setgraphmode(getgraphmode());
      setbkcolor(backcolor);
      setcolor(linecolor);
    }
#endif
#ifdef __WATCOMC__
  _setvideomode(_VRES16COLOR);
  _setbkcolor((long)backcolor);
  _setcolor((long)linecolor);
#endif 
    
    if (!done) {
      cont = TRUE;
      while (cont) {
        do_n_generations(disp_type, n, n0, w1, w2, w3, u, v, m, t1, g9);
        
        /* update for next run and prompt to run more or stop */
        t1 += g9;
        g9 = continue_with_more_generations(disp_type, g9);
        if (g9) {
          cont = TRUE;
        }
        else {
          cont = FALSE;
        }
      }
    }
  } while (!done);
  
#ifdef __TURBOC__
  restorecrtmode();
  clrscr();
#endif
#ifdef __WATCOMC__
  _setvideomode(_DEFAULTMODE);
#endif
  printf("\nThat's all, folks\n\n");
  exit(0);

}

