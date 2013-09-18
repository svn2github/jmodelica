package EventIter

model EventMiddleIter
    Real x;
    Real y;
    Real z;
    parameter Real p1 = 1.0;
    parameter Real p2 = 2.0;
    parameter Real p3 = 3.0;
    parameter Real m1 = -1.0;
    parameter Real n = 0.0;
initial equation
    x = if p1>=3 then 1 else 2;
equation
    der(x) = if y>=p1 then p1 else m1;
    y = if z<=p1 then m1 else p3;
    z = if time <= p1 then n else p2;   
end EventMiddleIter;


model EventStartIter
  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
  Real w(start=0);
  parameter Real m1=-1.0;
  parameter Real m15=-1.5;
  parameter Real m3=-3.0;
  parameter Real p05=0.5;
  parameter Real p1=1.0;
  parameter Real p3=3.0;
equation
   x = if time>=p1 then (m1 + y) else  (- y);
   y = z + x +(if z>=m15 then m3 else p3);
   z = -y  - x + (if y>=p05 then m1 else p1);
   der(w) = -w;
end EventStartIter;

model EventInfiniteIteration1
    Real x;
    Real y;
equation
    x = if y >= 1 then 1 else 0;
    y = if x >= 1 then 0 else 1;
end EventInfiniteIteration1;

model EventInfiniteIteration2
    Real x;
    Real y;
    Real z;
initial equation
    x = if y >= 1 then 1 else 0;
    y = if x >= 1 then 0 else 1;
equation
    der(x) = -1;
    der(y) = -1;
    der(z) = -1;
end EventInfiniteIteration2;

model EventInfiniteIteration3
    Real x;
    Real y;
    Real z(start=1);
equation
    der(z) = -1;
    x = if (y >= 1 and time > 0.5) then 1 else 0;
    y = if x >= 1 then 0 else 1;
end EventInfiniteIteration3;

end EventIter;

