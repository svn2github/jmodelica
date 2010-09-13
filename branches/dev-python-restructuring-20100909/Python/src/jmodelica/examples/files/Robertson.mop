optimization Robertson
    parameter Real p1(free=true,initialGuess=0.040)=0.040;
    parameter Real p2(free=true,initialGuess=1.0e4)=1.0e4;
    parameter Real p3(free=true,initialGuess=3.0e7)=3.0e7;
    Real y1(start=1.0, fixed=true);
    Real y2(start=0.0, fixed=true);
    Real y3(start=0.0);
  equation
    der(y1) = -p1*y1 + p2*y2*y3;
    der(y2) = p1*y1 - p2*y2*y3 - p3*(y2*y2);
    0.0 = y1 + y2 + y3 - 1;
end Robertson;
