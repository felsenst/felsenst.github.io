CTAX7                                                                      00050
C  DONT BE FRIGHTENED, ITS MOSTLY COMMENT CARDS                            00070
     0DIMENSION B(40,2),IC(79,70),ID(10,10,70),IE(10,10,70),IG(9),IH(79)   00080
     1,IJ(79),IK(79),IR(79),IL(79),ALPH(100),CAL(10)                       00090
      CAL(1)=1H0                                                           00100
      CAL(2)=1H1                                                           00110
      CAL(3)=1H2                                                           00120
      CAL(4)=1H3                                                           00130
      CAL(5)=1H4                                                           00140
      CAL(6)=1H5                                                           00150
      CAL(7)=1H6                                                           00160
      CAL(8)=1H7                                                           00170
      CAL(9)=1H8                                                           00180
C  READ CARD CONTAINING NUMBER OF OTUS AND CHARACTERS                      00190
    1 READ INPUT TAPE 5,2,NS,NC,INDIC                                      00200
    2 FORMAT(3I4)                                                          00210
      WRITE OUTPUT TAPE 6,830                                              00220
  830 FORMAT(1H1,21HCHARACTER STATE TREES//1X,4HCHAR,2X,17H0 1 2 3 4 5 6   00230
     1 7 8,2X,6HDELETE/2X)                                                 00240
C  NM IS THE NUMBER OF OTUS PLUS THE NUMBER OF HYPOTHETICAL ANCESTORS      00250
      NM=2*NS-1                                                            00260
C  FOR EACH CHARACTER READ IN CODED CHARACTER STATE TREE, SET UP THE       00270
C  CORRESPONDING PORTIONS OF THE ARRAYS ID AND IE                          00280
  450 DO 23 JA=1,NC                                                        00290
      READ INPUT TAPE 5,5,(IG(I),I=1,9),JB                                 00300
    5 FORMAT( 10I2)                                                        00310
      DO 837 I=1,9                                                         00320
      IF(IG(I)-10) 834,832,834                                             00330
  832 ALPH(I)=1H*                                                          00340
      GO TO 837                                                            00350
  834 IF(IG(I)) 835,836,836                                                00360
  835 ALPH(I)=1H                                                           00370
      GO TO 837                                                            00380
  836 J=IG(I)&1                                                            00390
      ALPH(I)=CAL(J)                                                       00400
  837 CONTINUE                                                             00410
      WRITE OUTPUT TAPE 6,838,JA,(ALPH(I),I=1,9),JB                        00420
  838 FORMAT(1X,I3,2X,9(1X,A1),5X,I1)                                      00430
C  IF CHARACTER IS TO BE IGNORED THEN JB=0, SO SET ID AND IE ENTRIES ZER   00440
      IF(JB) 6,8,8                                                         00450
    6 DO 7 JC=1,10                                                         00460
      DO 7 JD=1,10                                                         00470
      ID(JC,JD,JA)=0                                                       00480
    7 IE(JC,JD,JA)=0                                                       00490
      GO TO 23                                                             00500
    8 IF(JB-1) 85,6,6                                                      00510
   85 DO 9 JC=1,9                                                          00520
      DO 9 JD=1,9                                                          00530
    9 ID(JC,JD,JA)=-1                                                      00540
C  THE STATE ANCESTRAL TO STATES 9 AND JC-1 IS STATE JC-1, THE NUMBER OF   00550
C  TO EVOLVE STATE JC-1 FROM STATE 9 IS ZERO                               00560
      DO 10 JC=1,10                                                        00570
      IE(10,JC,JA)=JC-1                                                    00580
      IE(JC,10,JA)=JC-1                                                    00590
      ID(JC,10,JA)=0                                                       00600
   10 ID(10,JC,JA)=0                                                       00610
C  FROM EACH STATE WHICH IS PART OF THE CHARACTER STATE TREE, GO DOWN TH   00620
C  TREE STEP BY STEP, SETTING UP THE CORRESPONDING ENTRIES OF ID AS YOU    00630
      DO 14 JC=1,9                                                         00640
      IF(IG(JC)) 14,11,11                                                  00650
   11 ID(JC,JC,JA)=0                                                       00660
      JD=0                                                                 00670
      JE=JC                                                                00680
   12 IF(IG(JE)-10) 13,14,14                                               00690
   13 JD=JD&1                                                              00700
      JE=IG(JE)&1                                                          00710
      ID(JC,JE,JA)=JD                                                      00720
      GO TO 12                                                             00730
   14 CONTINUE                                                             00740
C  FOR EACH PAIR OF STATES JC-1 AND JD-1 WHICH ARE IN THE CHARACTER STAT   00750
C  TREE EXAMINE ALL OTHER STATES JF-1 WHICH ARE IN THE TREE AND PICK AS    00760
C  COMMON ANCESTOR OF JC-1 AND JD-1 THE STATE WHICH HAS THE SMALLEST       00770
C  SUM OF THE DISTANCE DOWN THE TREE FROM JC-1 AND FROM JD-1. THIS IS TH   00780
C  ENTRY USED IN IE                                                        00790
      DO 22 JC=1,9                                                         00800
      IF(IG(JC)) 22,15,15                                                  00810
   15 DO 21 JD=1,9                                                         00820
      IF(IG(JD)) 21,16,16                                                  00830
   16 JE=10                                                                00840
      DO 20 JF=1,9                                                         00850
      IF(ID(JC,JF,JA)) 20,17,17                                            00860
   17 IF(ID(JD,JF,JA)) 20,18,18                                            00870
   18 IF(ID(JC,JF,JA)&ID(JD,JF,JA)-JE) 19,20,20                            00880
   19 JE=ID(JC,JF,JA)&ID(JD,JF,JA)                                         00890
      IE(JC,JD,JA)=JF-1                                                    00900
   20 CONTINUE                                                             00910
   21 CONTINUE                                                             00920
   22 CONTINUE                                                             00930
C  PREPARE ARRAY GIVING PRIMITIVE STATE FOR EACH CHARACTER                 00940
      DO 256 I=1,9                                                         00950
      IF(IG(I)-10) 256,255,256                                             00960
  255 IR(JA)=I-1                                                           00970
  256 CONTINUE                                                             00980
C  NOW GO BACK AND TAKE THE NEXT CHARACTER                                 00990
   23 CONTINUE                                                             01000
      WRITE OUTPUT TAPE 6,799                                              01010
C  FOR EACH OTU READ NAME AND CHARACTERS                                   01020
  799 FORMAT(1H1,5X,4HNAME,20X,10HCHARACTERS/2X)                           01030
      DO 800 I=1,40                                                        01040
      DO 800 J=1,70                                                        01050
  800 IC(I,J)=9                                                            01060
      DO 813 I=1,NS                                                        01070
      READ INPUT TAPE 5,801,AAN,BBN,(IK(J),J=1,NC)                         01080
  801 FORMAT(2A5,70I1)                                                     01090
      IF(AAN-5H*****) 810,802,810                                          01100
  802 READ INPUT TAPE 5,803,ISP,AAN,BBN                                    01110
  803 FORMAT(I4,2A5)                                                       01120
      WRITE OUTPUT TAPE 6,804,AAN,BBN,ISP                                  01130
  804 FORMAT(2X/1X,8HGROUP - ,5X,2A5,5X,4HNEXT,I4/2X)                      01140
      B(I,1)=AAN                                                           01150
      B(I,2)=BBN                                                           01160
      KBB=1                                                                01170
      LUP=ISP                                                              01180
  855 IF(KBB-LUP) 805,805,856                                              01190
  805 READ INPUT TAPE 5,801,AAN,BBN,(IK(JA),JA=1,NC)                       01200
      IF(AAN-5H*****) 854,852,854                                          01210
  852 READ INPUT TAPE 5,803,NGG,AAN,BBN                                    01220
      WRITE OUTPUT TAPE 6,853,AAN,BBN,NGG                                  01230
  853 FORMAT(1X,8HGROUP - ,5X,2A5,5X,4HNEXT,I4)                            01240
      LUP=LUP-1&NGG                                                        01250
      GO TO 805                                                            01260
  854 DO 806 K=1,NC                                                        01270
      KKK=IK(K)&1                                                          01280
      KKL=IC(I,K)&1                                                        01290
  806 IC(I,K)=IE(KKK,KKL,K)                                                01300
      WRITE OUTPUT TAPE 6,807,AAN,BBN,(IK(JA),JA=1,NC)                     01310
  807 FORMAT(1X,2A5,5X,14(1X,5I1))                                         01320
      KBB=KBB&1                                                            01330
      GO TO 855                                                            01340
  856 WRITE OUTPUT TAPE 6,809                                              01350
  809 FORMAT(120X/2X)                                                      01360
      GO TO 813                                                            01370
  810 DO 811 J=1,NC                                                        01380
  811 IC(I,J)=IK(J)                                                        01390
      B(I,1)=AAN                                                           01400
      B(I,2)=BBN                                                           01410
      WRITE OUTPUT TAPE 6,807,AAN,BBN,(IK(JA),JA=1,NC)                     01420
  813 CONTINUE                                                             01430
C  IF INDIC IS 1,ORDER OTU@S IN ORDER OF INCREASING PRIMITIVENESS          01440
      IF(INDIC) 826,826,814                                                01450
  814 DO 816 I=1,NS                                                        01460
      IH(I)=0                                                              01470
      DO 816 J=1,NC                                                        01480
      IF(IC(I,J)-IR(J)) 816,815,816                                        01490
  815 IH(I)=IH(I)&1                                                        01500
  816 CONTINUE                                                             01510
  821 I=1                                                                  01520
  823 IF(I-NS&1) 817,817,824                                               01530
  817 IF(I) 821,821,818                                                    01540
  818 IF(IH(I)-IH(I&1)) 822,822,819                                        01550
  819 DO 820 J=1,NC                                                        01560
      III=IC(I,J)                                                          01570
      IC(I,J)=IC(I&1,J)                                                    01580
  820 IC(I&1,J)=III                                                        01590
      AAN=B(I,1)                                                           01600
      B(I,1)=B(I&1,1)                                                      01610
      B(I&1,1)=AAN                                                         01620
      AAN=B(I,2)                                                           01630
      B(I,2)=B(I&1,2)                                                      01640
      B(I&1,2)=AAN                                                         01650
      III=IH(I)                                                            01660
      IH(I)=IH(I&1)                                                        01670
      IH(I&1)=III                                                          01680
      I=I-1                                                                01690
      GO TO 817                                                            01700
  822 I=I&1                                                                01710
      GO TO 823                                                            01720
  824 WRITE OUTPUT TAPE 6,825                                              01730
  825 FORMAT(2X//1X,20HOTU ORDER REARRANGED)                               01740
C  INITIALIZE THE ARRAYS IH AND IR. THE INITIAL TREE HAS OTU 1 WITH ITS    01750
C  BEING NM&1, WHICH IS A NONEXISTENT COMMON ANCESTOR OF THE ENTIRE GROU   01760
C  NOTE THAT ONE OF THE ANCESTORS NUMBERED NS&1 TO NM WILL ALSO BE ANCES   01770
C  THE ENTIRE GROUP                                                        01780
  826 IH(1)=NM&1                                                           01790
      IR(1)=0                                                              01800
      IJ(1)=0                                                              01810
      DO 100 JA=2,NM                                                       01820
      IR(JA)=-1                                                            01830
  100 IH(JA)=0                                                             01840
C  WE WILL GO THROUGH THE FOLLOWING LOOP EACH TIME WE ADD ANOTHER OTU TO   01850
C  TREE. EACH OTU IS ADDED TO WHATEVER POSITION MAKES THE SMALLEST EXTRA   01860
C  NUMBER OF STEPS NECESSARY. THAT IS, WE TRY TO MINIMIZE THE ADDITIONAL   01870
C  WHICH MUST BE ADDED TO THE PREVIOUS TREE TO ACCOUNT FOR EVOLUTION OF    01880
C  NEWLY ADDED OTU                                                         01890
      DO 120 JA=2,NS                                                       01900
C   IBEST IS THE NUMBER OF EXTRA STEPS REQUIRED AT THE BEST POSITION       01910
C  FOUND SO FAR. IT IS INITIIALIZED AT 1000                                01920
      IBEST=1000                                                           01930
C  IBN TELLS US THE NUMBER OF THE OTU OR HYPOTHETICAL ANCESTOR IMMEDIATE   01940
C  BELOW WHICH IS THE BEST POSITION FOUND SO FAR                           01950
      IBN=1                                                                01960
C  DO OVER ALL OTUS AND ANCESTORS WHICH ARE ALREADY IN THE TREE            01970
      DO 112 JB=1,NM                                                       01980
      IF(IR(JB)) 112,101,101                                               01990
  101 ITOT=0                                                               02000
C  CALCULATE THE STEPS FROM THE OTU BEING ADDED TO ITS COMMON ANCESTOR W   02010
C  OTU JB, AND FROM JB TO THE COMMON ANCESTOR                              02020
      DO 102 JC=1,NC                                                       02030
      KA=IC(JA,JC)&1                                                       02040
      KB=IC(JB,JC)&1                                                       02050
      IK(JC)=IE(KA,KB,JC)                                                  02060
      KC=IK(JC)&1                                                          02070
  102 ITOT=ITOT&ID(KA,KC,JC)&ID(KB,KC,JC)                                  02080
      LA=JB                                                                02090
C  NOW CONTINUE DOWN THE TREE CALCULATING FOR EACH ANCESTOR LB THE EXTRA   02100
C  STEPS NEEDED BETWEEN IT AND ITS IMMEDIATE ANCESTOR LA,                  02110
  103 LB=LA                                                                02120
      LA=IH(LA)                                                            02130
      IF(LA-NM-1) 104,110,110                                              02140
  104 DO 105 JC=1,NC                                                       02150
      KA=IK(JC)&1                                                          02160
      KB=IC(LA,JC)&1                                                       02170
      IK(JC)=IE(KA,KB,JC)                                                  02180
      KC=IK(JC)&1                                                          02190
  105 ITOT=ITOT&ID(KA,KC,JC)                                               02200
C  AND THE EXTRA STEPS NEEDED ON THE OTHER BRANCH WHICH CONVERGES ON LA    02210
      DO 106 JC=1,NM                                                       02220
      IF(IH(JC)-LA) 106,107,106                                            02230
  107 IF(JC-LB) 108,106,108                                                02240
  106 CONTINUE                                                             02250
  108 DO 109 JD=1,NC                                                       02260
      KA=IC(JC,JD)&1                                                       02270
      KB=IK(JD)&1                                                          02280
  109 ITOT=ITOT&ID(KA,KB,JD)                                               02290
C  ACTUALLY WE HAVE BEEN CALCULATING THE TOTAL STEPS NEEDED, NOW WE SUBT   02300
C  PREVIOUS STEPS TO GET THE NUMBERS AS EXTRA STEPS                        02310
      ITOT=ITOT-IJ(JC)                                                     02320
      ITOT=ITOT-IJ(LB)                                                     02330
      GO TO 103                                                            02340
C  IT MAY SEEM THAT AT THE VERY BEGINNING OF THIS LAST PROCEDURE, AROUND   02350
C  STATEMENT 102 A MISTAKE WAS MADE. BUT THE PROCEDURE IS CORRECT.         02360
C  E PUR SI MUOVE                                                          02370
  110 IF(ITOT-IBEST) 111,112,112                                           02380
  111 IBEST=ITOT                                                           02390
      IBN=JB                                                               02400
  112 CONTINUE                                                             02410
C  NOW WE WANT TO ADD THE NEW OTU TO ITS BEST POSITION. AGAIN WE MUST GO   02420
C  DOWN THE TREE A STEP AT A TIME, MAKING MANY OF THE SAME CALCULATIONS,   02430
C  ONLY THIS TIME RECORDING THE STEPS NEEDED AND THE PHENOTYPES OF THE A   02440
C  FOR POSTERITY                                                           02450
      LA=NS&JA-1                                                           02460
      IH(LA)=IH(IBN)                                                       02470
      IH(JA)=LA                                                            02480
      IH(IBN)=LA                                                           02490
      IR(JA)=0                                                             02500
      IR(LA)=0                                                             02510
      DO 121 JB=1,NC                                                       02520
      KA=IC(JA,JB)&1                                                       02530
      KB=IC(IBN,JB)&1                                                      02540
  121 IC(LA,JB) = IE(KA,KB,JB)                                             02550
      LA=JA                                                                02560
  113 LB=LA                                                                02570
      LA=IH(LA)                                                            02580
      IF(LA-NM-1) 114,120,120                                              02590
  114 ISUM=0                                                               02600
      DO 115 JC=1,NC                                                       02610
      KA=IC(LB,JC)&1                                                       02620
      KB=IC(LA,JC)&1                                                       02630
      IC(LA,JC)=IE(KA,KB,JC)                                               02640
      KC=IC(LA,JC)&1                                                       02650
  115 ISUM=ISUM&ID(KA,KC,JC)                                               02660
      IJ(LB)=ISUM                                                          02670
      DO 116 JB=1,NM                                                       02680
      IF(IH(JB)-LA) 116,117,116                                            02690
  117 IF(JB-LB) 118,116,118                                                02700
  116 CONTINUE                                                             02710
  118 ISUM=0                                                               02720
      DO 119 JC=1,NC                                                       02730
      KA=IC(JB,JC)&1                                                       02740
      KB=IC(LA,JC)&1                                                       02750
  119 ISUM=ISUM&ID(KA,KB,JC)                                               02760
      IJ(JB)=ISUM                                                          02770
      GO TO 113                                                            02780
  120 IJ(LB)=0                                                             02790
C  NOW WE HAVE CONSTRUCTED THE TREE WHICH WE WILL REARRANGE. IF ONE IS A   02800
C  TO TERMINOLOGY ONE CAN CALL IT THE PROCLADOGRAM                         02810
C  WE WILL DO THE FOLLOWING OVER EACH ANCESTOR IN THE RANGE NS&1 TO NM,    02820
C  THE ONE AT THE BOTTOM OF THE TREE WHOSE IMMEDIATE ANCESTOR IS THE NON   02830
C  FORM NM&1                                                               02840
   33 JA=NS&1                                                              02850
   34 IF(JA-NM) 345,345,49                                                 02860
  345 IF(IH(JA)-NM-1) 35,482,482                                           02870
C  WE FIND THE TWO FORMS WHICH HAVE  JA AS THEIR ANCESTOR, AND THE FORM    02880
C  WHICH IS ANCESTRAL TO JA, AND THE FORM WHICH HAS THE SAME ANCESTOR AS   02890
C   THESE ARE RESPECTIVELY JB, JD, JF, AND JE                              02900
   35 DO 37 JB=1,NM                                                        02910
      IF(IH(JB)-JA) 37,38,37                                               02920
   37 CONTINUE                                                             02930
   38 JC=JB&1                                                              02940
      DO 39 JD=JC,NM                                                       02950
      IF(IH(JD)-JA) 39,40,39                                               02960
   39 CONTINUE                                                             02970
   40 DO 42 JE=1,NM                                                        02980
      IF(JE-JA) 41,42,41                                                   02990
   41 IF(IH(JE)-IH(JA)) 42,43,42                                           03000
   42 CONTINUE                                                             03010
   43 JF=IH(JA)                                                            03020
C  NOW WE TRY THE ARRANGEMENT IN WHICH JB BRANCHES OFF FIRST, FOLLOWED     03030
C  BY JD AND JE                                                            03040
C  WE CALCULATE THE STEPS REQUIRED IN THIS ARRANGEMENT                     03050
      JG=1                                                                 03060
  435 DO 44 KA=1,NC                                                        03070
      KB=IC(JD,KA)&1                                                       03080
      KC=IC(JE,KA)&1                                                       03090
      IK(KA)=IE(KB,KC,KA)                                                  03100
      KB=IC(JB,KA)&1                                                       03110
      KC=IK(KA)&1                                                          03120
   44 IL(KA)=IE(KB,KC,KA)                                                  03130
      KA=0                                                                 03140
      KB=0                                                                 03150
      KC=0                                                                 03160
      KE=0                                                                 03170
      DO 45 KD=1,NC                                                        03180
      LA=IK(KD)&1                                                          03190
      LB=IL(KD)&1                                                          03200
      LC=IC(JD,KD)&1                                                       03210
      LD=IC(JE,KD)&1                                                       03220
      LE=IC(JB,KD)&1                                                       03230
      KA=KA&ID(LC,LA,KD)                                                   03240
      KB=KB&ID(LD,LA,KD)                                                   03250
      KC=KC&ID(LA,LB,KD)                                                   03260
   45 KE=KE&ID(LE,LB,KD)                                                   03270
C  NOW WE TEST TO SEE WHETHER THIS IS AN IMPROVEMENT                       03280
      IF(IJ(JD)&IJ(JE)&IJ(JA)&IJ(JB)-KA-KB-KC-KE) 48,48,46                 03290
C  IF IT IS, RETAIN IT AND GO BACK AND START  REARRANGING BRANCHES AGAIN   03300
   46 IH(JE)=JA                                                            03310
      IH(JB)=JF                                                            03320
      IJ(JD)=KA                                                            03330
      IJ(JE)=KB                                                            03340
      IJ(JB)=KE                                                            03350
      IJ(JA)=KC                                                            03360
      DO 47 KD=1,NC                                                        03370
   47 IC(JA,KD)=IK(KD)                                                     03380
      GO TO 33                                                             03390
C  IF IT IS NOT AN IMPROVEMENT,AND IF WE HAVE NOT YET TRIED THE ALTERNAT   03400
C  REARRANGEMENT, TRY IT BY SWITCHING JB AND JD AND GOING BACK             03410
   48 IF(JG-1) 481,481,482                                                 03420
  481 JG=2                                                                 03430
      KA=JB                                                                03440
      JB=JD                                                                03450
      JD=KA                                                                03460
      GO TO 435                                                            03470
C  IF IT IS NOT AN IMPROVEMENT AND WE HAVE TRIED BOTH REARRANGEMENTS, GO   03480
C  TO THE NEXT ANCESTOR                                                    03490
  482 JA=JA&1                                                              03500
      GO TO 34                                                             03510
C  NOW WE HAVE OUR TREE. THE REST IS OUTPUT.                               03520
   49 WRITE OUTPUT TAPE 6,50                                               03530
   50 FORMAT(1H1,3X,4HNAME,3X,8HANCESTOR,2X,5HSTEPS,20X,10HCHARACTERS/2X   03540
     1)                                                                    03550
      DO 52 JA=1,NS                                                        03560
     0WRITE OUTPUT TAPE 6,51,B(JA,1),B(JA,2),IH(JA),IJ(JA),(IC(JA,N),      03570
     1N=1,NC)                                                              03580
   51 FORMAT(1X,2A5,5X,I2,2X,I3,5X,14(5I1,1X))                             03590
   52 CONTINUE                                                             03600
      WRITE OUTPUT TAPE 6,53                                               03610
   53 FORMAT(1X/20X,22HHYPOTHETICAL ANCESTORS/2X)                          03620
      JA=NS&1                                                              03630
      DO 55 JB=JA,NM                                                       03640
      WRITE OUTPUT TAPE 6,54,JB,IH(JB),IJ(JB),(IC(JB,N),N=1,NC)            03650
   54 FORMAT(1X,5X,I2,8X,I2,2X,I3,5X,14(5I1,1X))                           03660
   55 CONTINUE                                                             03670
      IS=0                                                                 03680
      DO 57 IT=1,NM                                                        03690
   57 IS=IS&IJ(IT)                                                         03700
      WRITE OUTPUT TAPE 6,58,IS                                            03710
   58 FORMAT(1X/1X,13X,6HTOTAL ,I3)                                        03720
C WRITE NUMBER OF STEPS IN EACH CHARACTER FROM THE IMMEDIATE ANCESTOR OF   03730
C  SPECIES OR HYPOTHETICAL ANCESTOR                                        03740
      WRITE OUTPUT TAPE 6,350                                              03750
  350 FORMAT(1H1,3X,4HNAME,3X,8HANCESTOR,2X,5HSTEPS,20X,47HSTEPS FROM IM   03760
     1MEDIATE ANCESTOR IN EACH CHARACTER/2X)                               03770
      DO 352 IA=1,NS                                                       03780
      JB=IH(IA)                                                            03790
      DO 360 IB=1,NC                                                       03800
      JA=IC(IA,IB)&1                                                       03810
      JC=IC(JB,IB)&1                                                       03820
      IK(IB)=ID(JA,JC,IB)                                                  03830
  360 CONTINUE                                                             03840
      WRITE OUTPUT TAPE 6,351,B(IA,1),B(IA,2),IH(IA),IJ(IA),(IK(I),I=1,    03850
     1NC)                                                                  03860
  351 FORMAT(1X,2A5,5X,I2,2X,I3,5X,14(5I1,1X))                             03870
  352 CONTINUE                                                             03880
      WRITE OUTPUT TAPE 6,355                                              03890
  355 FORMAT(1X,120X)                                                      03900
      NN=NS&1                                                              03910
      DO 359 IA=NN,NM                                                      03920
      JB=IH(IA)                                                            03930
      DO 357 IB=1,NC                                                       03940
      IF(JB-NM-1) 356,354,354                                              03950
  354 IK(IB)=0                                                             03960
      GO TO 357                                                            03970
  356 JA=IC(IA,IB)&1                                                       03980
      JC=IC(JB,IB)&1                                                       03990
      IK(IB)=ID(JA,JC,IB)                                                  04000
  357 CONTINUE                                                             04010
      WRITE OUTPUT TAPE 6,358,IA,JB,IJ(IA),(IK(I),I=1,NC)                  04020
  358 FORMAT(1X,I5,10X,I2,2X,I3,5X,14(5I1,1X))                             04030
  359 CONTINUE                                                             04040
C  PREPARE TREE SHOWING FINAL RESULT                                       04050
      DO 850 I=1,NM                                                        04060
      IJ(I)=I                                                              04070
      IK(I)=1                                                              04080
  850 IL(I)=0                                                              04090
      DO 302 I=1,NS                                                        04100
      KA=NS&1-I                                                            04110
      K=KA                                                                 04120
  300 IF(K-NM-1) 301,302,302                                               04130
  301 IL(K)=KA                                                             04140
      K=IH(K)                                                              04150
      GO TO 300                                                            04160
  302 CONTINUE                                                             04170
      DO 304 I=1,NM                                                        04180
      DO 304 J=1,NM                                                        04190
      IF(IH(J)-NM-1) 303,304,304                                           04200
  303 K=IH(J)                                                              04210
      IK(K)=XMAX0F(IK(J)&1,IK(K))                                          04220
  304 CONTINUE                                                             04230
      DO 338 I=2,NS                                                        04240
      KA=NS&2-I                                                            04250
      K=KA                                                                 04260
  335 IF(IL(K)-KA) 337,336,336                                             04270
  336 K=IH(K)                                                              04280
      GO TO 335                                                            04290
  337 IL(KA)=IL(K)                                                         04300
  338 IK(KA)=IK(K)                                                         04310
      KA=1                                                                 04320
  305 KB=2                                                                 04330
  306 IF(KB-NS&1) 307,307,313                                              04340
  307 IF(IL(KB&1)-KA) 312,308,312                                          04350
  308 IF(IL(KB&1)-IJ(KB)) 309,312,309                                      04360
  309 IF(IL(KB&1)-IL(KB)) 311,310,311                                      04370
  310 IF(IK(KB&1)-IK(KB)) 311,312,312                                      04380
  311 KC=IJ(KB)                                                            04390
      IJ(KB)=IJ(KB&1)                                                      04400
      IJ(KB&1)=KC                                                          04410
      KC=IK(KB)                                                            04420
      IK(KB)=IK(KB&1)                                                      04430
      IK(KB&1)=KC                                                          04440
      KC=IL(KB)                                                            04450
      IL(KB)=IL(KB&1)                                                      04460
      IL(KB&1)=KC                                                          04470
      GO TO 305                                                            04480
  312 KB=KB&1                                                              04490
      GO TO 306                                                            04500
  313 KA=KA&1                                                              04510
      IF(KA-NS) 305,314,314                                                04520
  314 WRITE OUTPUT TAPE 6,315,B(1,1),B(1,2)                                04530
  315 FORMAT(1H1/1X,100(1H-),2X,2A5)                                       04540
      KC=1                                                                 04550
      DO 317 KA=2,NS                                                       04560
      IF(IK(KA)-KC) 317,317,316                                            04570
  316 KC=IK(KA)                                                            04580
  317 CONTINUE                                                             04590
      DO 325 KA=2,NS                                                       04600
      LL=IK(KA)                                                            04610
      KD=(100*(KC-LL&1))/KC                                                04620
      KE=KD-1                                                              04630
      KF=KD&1                                                              04640
      DO 318 KG=1,KE                                                       04650
  318 ALPH(KG)=1H                                                          04660
      ALPH(KD)=1HL                                                         04670
      DO 319 KG=KF,100                                                     04680
  319 ALPH(KG)=1H-                                                         04690
      IF(KA-NS) 320,323,323                                                04700
  320 KB=KA&1                                                              04710
      KD=IK(KA)                                                            04720
      DO 322 KE=KB,NS                                                      04730
      IF(IK(KE)-KD) 322,322,321                                            04740
  321 LL=IK(KE)                                                            04750
      KF=(100*(KC-LL&1))/KC                                                04760
      ALPH(KF)=1HI                                                         04770
      KD=LL                                                                04780
  322 CONTINUE                                                             04790
  323 KD=IJ(KA)                                                            04800
      WRITE OUTPUT TAPE 6,324,(ALPH(I),I=1,100),B(KD,1),B(KD,2)            04810
  324 FORMAT(1X,100A1,2X,2A5)                                              04820
  325 CONTINUE                                                             04830
      WRITE OUTPUT TAPE 6,56                                               04840
C  INSTRUCT PRINTER TO SKIP TO TOP OF NEXT PAGE. READ IN ANOTHER SET OF    04850
   56 FORMAT(1H1)                                                          04860
      GO TO 1                                                              04870
      END                                                                  04880
