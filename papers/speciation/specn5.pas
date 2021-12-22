program specn5;
   const loci = 3;
      lociminusone = 2;
      gamnumber = 8;
   type gamarray = array[1..gamnumber] of real;
      zygarray = array[1..gamnumber] of gamarray;
      contvec = array[1..loci] of integer;
      contrvec = array[1..gamnumber] of integer;
   var i : integer;
      gambefore : array[1..2] of gamarray;
      gamafter : array[1..2] of gamarray;
      zygbefore : array[1..2] of zygarray;
      zygafter : array[1..2] of zygarray;
      fitness : array[1..2] of zygarray;
      assort : zygarray;
      sum, s, delta, mig : real;
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
      var i, j, k, l : integer;
          prod : real;
   begin
      for i := 1 to gamnumber do begin
         for l := 1 to gamnumber do begin
            for j := 1 to 2 do begin
               prod := 1.0;
               for k := 2 to loci do begin
                  if contents[i,k] = j-1
                  then prod := prod * (1.0 + s);
                  if contents[l,k] = j-1
                  then prod := prod * (1.0 + s);
                  end;
               fitness[j,i,l] := prod;
               end;
            end;
         end;
   end;
   procedure setupassort;
      var i, j : integer;
   begin
      for i := 1 to gamnumber do
          for j := 1 to gamnumber do begin
            case contents[i,1] + contents[j,1] of
               0 : assort[i,j] := (1.0-delta)/2.0;
               1 : assort[i,j] := 0.5;
               2 : assort[i,j] := (1.0+delta)/2.0
               end;
            end;
   end;
   procedure setuppop;
      var i, j, k : integer;
         prod : real;
         p : array[1..2] of array[1..loci] of real;
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
            prod := 1.0;
            for k := 1 to loci do begin
               if contents[i,k] = 1
               then prod := prod * p[j,k]
               else prod := prod * (1.0-p[j,k]);
               end;
            gambefore[j,i] := prod;
            end;
      for j := 1 to 2 do
         for i := 1 to gamnumber do
            for k := 1 to gamnumber do begin
               zygbefore[j,i,k] := gambefore[j,i]*gambefore[j,k];
               end;
   end;
   procedure getnextgen;
      procedure select;
         var i, j, k : integer;
             sum, x : real;
      begin
         for i := 1 to 2 do begin
            sum := 0.0;
            for j := 1 to gamnumber do
               for k := 1 to gamnumber do begin
                  x := zygbefore[i,j,k] * fitness[i,j,k];
                  sum := sum + x;
                  zygafter[i,j,k] := x;
                  end;
            for j := 1 to gamnumber do
               for k := 1 to gamnumber do begin
                  zygbefore[i,j,k] := zygafter[i,j,k]/sum;
                  end;
            end;
      end;
      procedure recombine;
         var i, j, k, l, n : integer;
             x, x1, p : real;
      begin
         for i := 1 to 2 do begin
            for j := 1 to gamnumber do begin
               gambefore[1,j] := 0.0;
               gambefore[2,j] := 0.0;
               end;
            for j := 1 to gamnumber do
               for k := 1 to gamnumber do begin
                  x := zygbefore[i,j,k];
                  p := assort[j,k];
                  for l := 1 to gamnumber do begin
                     x1 := x * recfrac[l];
                     n := contrib[j,l] +
                        contrib[k,gamnumber-l+1] + 1;
                     gambefore[1,n] := gambefore[1,n] + x1 * p;
                     gambefore[2,n] := gambefore[2,n] + x1 * (1.0-p);
                     end;
                  end;
            p := 0.0;
            for j := 1 to gamnumber do p := p + gambefore[1,j];
            for j := 1 to gamnumber do
               for k := 1 to gamnumber do
                  zygbefore[i,j,k] := (gambefore[1,j] * gambefore[1,k]
                     / p) + (gambefore[2,j] * gambefore[2,k] / (1.0-p));
            end;
      end;
      procedure migrate;
         var i, j : integer;
            x : real;
      begin
         for i := 1 to gamnumber do
            for j := 1 to gamnumber do begin
               x := zygbefore[1,i,j] - zygbefore[2,i,j];
               zygbefore[1,i,j] := zygbefore[1,i,j] - mig * x;
               zygbefore[2,i,j] := zygbefore[2,i,j] + mig * x;
               end;
      end;
   begin
      select;
      migrate;
      recombine;
   end;
   procedure printitout;
      var sum1, sum2, sum3, sum13 : real;
          i, j, k : integer;
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
            then for k := 1 to gamnumber do
               sum1 := sum1 + zygbefore[j,i,k];
            if contents[i,2] = 1
            then for k := 1 to gamnumber do
               sum2 := sum2 + zygbefore[j,i,k];
            if contents[i,3] = 1
            then for k := 1 to gamnumber do
               sum3 := sum3 + zygbefore[j,i,k];
            if contents[i,1]*contents[i,3] = 1
            then for k := 1 to gamnumber do
               sum13 := sum13 + zygbefore[j,i,k];
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
         write('migration rate? ');
         readln(mig);
         setupcontents;
         setuprec;
         setupctrib;
         setuppop;
         setupfit;
         setupassort;
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
               write(chr(7));
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
               end;
            end;
         end;
      end;
end.
