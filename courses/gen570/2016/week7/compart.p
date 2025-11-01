
program compart (input, output);
{ complete-and-partial bootstrap calculation P limits for 0.05, 0.01 }
   var r, Pc, Pp, P, ff : real;

   function invnormal (Q : real) : real;
   { inverse normal.  Series from web site:
     http://www.dnv.com/Ocean/bk/c/a23/ec/e23A05.htm  }
      var x, t, a1, a2, a3, b1, b2, b3 : real;
         flip : boolean;
   begin
      a1 := 2.515517;
      a2 := 0.802853;
      a3 := 0.010328;
      b1 := 1.432788;
      b2 := 0.189269;
      b3 := 0.001308;
      flip := false;
      if Q < 0.5
      then begin
         flip := true;
         Q := 1.0 - Q;
         end;
      t := sqrt(-2*ln(Q));
      x := t - (a1+a2*t+a3*t*t)/(1.0+b1*t+b2*t*t+b3*t*t*t);
      if flip
      then x := -x;
      invnormal := x;
   end;

   FUNCTION phi (x : REAL) : REAL;
   (* from Kerridge, D. F., and G. W. Cook, "Yet another series for
        the normal integral", Biometrika  63: 401-403  1976. Normal integral 
        from -infinity to x *)
      VAR xabs, x24, theta, theta0, sum : REAL;
         m, n : INTEGER;
   BEGIN (* phi *) 
      xabs := ABS(x);
      x24 := SQR(xabs)/4.0;
      theta := 1.0;
      theta0 := 0.0;
      sum := 0.0;
      m := 10;
      IF xabs > 2.0
      THEN m := 5 * TRUNC(xabs);
      FOR n := 1 TO m DO BEGIN
         sum := sum + theta/(2*n-1);
         theta0 := x24 * (theta - theta0) / (2*n-1);
         theta := x24 * (theta0 - theta) / (2*n);
         END;
      phi := 0.5 + 0.398942280401 * x * EXP(-x24/2.0) * sum;
   END; (* phi *)

begin
   writeln('partial bootstrap is original size divided by ... ?');
   readln(r);
   writeln('complete bootstrap fraction, P value?');
   readln(Pc, P);
   ff := (invnormal(Pp)*sqrt(r) - invnormal(Pc))/(sqrt(r+1)-sqrt(2.0));
   P := phi(invnormal(Pc)-ff*sqrt(2.0));
   writeln('corrected P = ', P:10:7);
end.
