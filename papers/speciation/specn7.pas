(*$S+*)
program specn;
   const loci = 3;
      lociminusone = 2;
      gamnumber = 8;
   type gamarray = array[1..gamnumber] of real;
      contvec = array[1..loci] of integer;
      contrvec = array[1..gamnumber] of integer;
   var i, j, k, l, m, n : integer;
      gambefore : array[1..2] of gamarray;
      gamafter : array[1..2] of gamarray;
      fitness : array[1..2] of gamarray;
      sum, s, delta, mig, kint : real;
      r : array[1..lociminusone] of real;
      recfrac : array [1..gamnumber] of real;
      contents : array[1..gamnumber] of contvec;
      contrib : array[1..gamnumber] of contrvec;
      t, tmax, gens, printint : integer;
      donegens, doneprintint, continue : boolean;
   procedure setuprec;
      var i, j : integer;
          prod : real;
   begin
      for i := 1 to gamnumber do begin
         prod := 0.5;
         for j := 2 to loci do
            if contents[i,j] = contents[i,j-1]
            then prod := prod * (1.0-r[j-1])
            else prod := prod * r[j-1];
         recfrac[i] := prod;
         end;
   end;
   procedure setupcontents;
      var n, i, m : integer;
   begin
      for n := 1 to gamnumber do begin
         m := n-1;
         for i := loci downto 1 do begin
            contents[n, i] := m mod 2;
            m := m div 2;
            end;
         end;
   end;
   procedure setupctrib;
      var i, j, k, l, m, n : integer;
   begin
      for i := 1 to gamnumber do begin
         for j := 1 to gamnumber do begin
            m := 0;
            n := 1;
            for l := loci downto 1 do begin
               k := contents[i,l] * contents[j,l];
               m := m + n * k;
               n := 2 * n;
               end;
            contrib[i,j] := m;
            end;
         end;
   end;
   procedure setupfit;
      var i, j, k : integer;
          prod : real;
   begin
      for i := 1 to gamnumber do begin
         for j := 1 to 2 do begin
            prod := 1.0;
            if contents[i,2] = j-1
            then prod := prod * (1.0+s);
            if contents[i,3] = j-1
            then prod := prod * (1.0+s);
            if prod > 1.0 + s
            then begin
               prod := prod - s*s;
               prod := prod + kint*s*s;
               end;
            fitness[j,i] := prod;
            end;
         end;
   end;
   procedure setuppop;
      var i, j : integer;
         prod, p2, p3 : real;
         p : array [1..2] of array [1..loci] of real;
   begin
      for i := 1 to loci do begin
         write('freq of locus ',i:1,'  ');
         for j := 1 to 2 do begin
            if j = 2
            then write('                 ');
            write(' in population ',j:1,'  ');
            read(p[j,i]);
            end;
         end;
      for j := 1 to 2 do
         for i := 1 to gamnumber do begin
            prod := 0.5;
            for k := 1 to loci do begin
               if contents[i,k] = 1
               then prod := prod * p[j,k]
               else prod := prod * (1-p[j,k]);
               end;
            gambefore[j,i] := prod;
            end;
   end;
   procedure getnextgen;
      procedure select;
         var i, j : integer;
             sum, x : real;
      begin
         for i := 1 to 2 do begin
            sum := 0.0;
            for j := 1 to gamnumber do begin
               x := gambefore[i,j] * fitness[i,j];
               sum := sum + x;
               gamafter[i,j] := x;
               end;
            for j := 1 to gamnumber do
               gambefore[i,j] := gamafter[i,j]/sum;
            end;
      end;
      procedure recombine;
         var i, j, k, l, n : integer;
             x, x1, p : real;
      begin
         for l := 1 to 2 do begin
            for i := 1 to gamnumber do
               gamafter[l,i] := 0.0;
            p := 0.0;
            for i := 1 to gamnumber do
               if contents[i,1] = 1
               then p := p + gambefore[l,i];
            for i := 1 to gamnumber do
               for j := 1 to gamnumber do begin 
                  if contents[i,1] = contents[j,1]
                  then begin
                     if contents[i,1] = 1
                     then x := 1 - delta + delta/p
                     else x := 1 - delta + delta/(1.0-p);
                     end
                  else x := 1 - delta;
                  x := x * gambefore[l,i] * gambefore[l,j];
                  for k := 1 to gamnumber do begin
                     x1 := x * recfrac[k];
                     n := contrib[i,k] +
                      contrib[j,gamnumber-k+1] + 1;
                     gamafter[l,n] := gamafter[l,n] + x1;
                     end;
                  end;
               end;
         for i := 1 to 2 do
            for j := 1 to gamnumber do gambefore[i,j] := gamafter[i,j];
      end;
      procedure migrate;
         var i, j : integer;
      begin
         for i := 1 to 2 do
            for j := 1 to gamnumber do
               gamafter[i,j] := gambefore[i,j];
         for i := 1 to 2 do
            for j := 1 to gamnumber do
               gambefore[i,j] := (1.0-mig)*gamafter[i,j]
                      + mig * gamafter[3-i,j];
      end;
   begin (* version for recombination before migration *)
      select;
      migrate;
      recombine;
   end;
   procedure printitout;
      var sum1, sum2, sum3, sum13 : real;
          i, j : integer;
   begin
      writeln('generation ',t:5);
      writeln('     P(A)      P(B)      P(C)      D(AC)');
      for j := 1 to 2 do begin
         sum1 := 0.0;
         sum2 := 0.0;
         sum3 := 0.0;
         sum13 := 0.0;
         for i := 1 to gamnumber do begin
            if contents[i,1] = 1
            then sum1 := sum1 + gambefore[j,i];
            if contents[i,2] = 1
            then sum2 := sum2 + gambefore[j,i];
            if contents[i,3] = 1
            then sum3 := sum3 + gambefore[j,i];
            if contents[i,1]*contents[i,3] = 1
            then sum13 := sum13 + gambefore[j,i];
            end;
         writeln(sum1:10:5,sum2:10:5,sum3:10:5,
            (sum13-sum1*sum3):10:5);
      end;
   end;
begin
   writeln('SIMULATION OF SPECIATION');
   writeln;
   continue := TRUE;
   while continue = TRUE do begin
      write('selection coefficient? ');
      readln(s);
      continue := false;
      if s>0 then begin
         continue := true;
         write('delta? ');
         readln(delta);
         writeln('recombination fractions: ');
         for i := 1 to (loci-1) do begin
            write('  ',i-1,' -',i:2,' ?');
            readln(r[i]);
            end;
         write('interaction? ');
         readln(kint);
         write('migration rate? ');
         readln(mig);
         setupcontents;
         setuprec;
         setupctrib;
         setuppop;
         setupfit;
         t:=0;
         doneprintint := false;
         while not doneprintint do begin
            write('print interval? ');
            readln(printint);
            if printint = 0
            then begin
               doneprintint := true;
               donegens := true;
               end
            else donegens := false;
            while (not doneprintint) and (not donegens) do begin
               write('generations? ');
               readln(gens);
               if gens = 0
               then donegens := true
               else donegens := false;
               tmax := t + gens;
               while t<tmax do begin
                  getnextgen;
                  t := t + 1;
                  if (t mod printint) = 0
                  then printitout;
                  end;
               write(chr(7));
               end;
            end;
         end;
      end;
end.
