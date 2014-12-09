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

model EnhancedEventIteration1

  Real x[7](each start=4);
    parameter Real b_locked[7] = {0.94,0,0,0,0,0,0.5};
    parameter Real b_startforward[7] = {0.94,0,0,1.0,1.0,0.0,0.5};
    parameter Real b_startbackward[7] = {0.94,0,0,-1.0,-1.0,0.0,0.5};
    parameter Real b[7] = {2,2,2,2,2,2,2};

  parameter Real A_locked[7,7] = {{1,0,0,0,0,0,1},
                 {-1,1,0,0,0,0,0},
                 {0,-1,1,0,0,0,0},
                 {0,0,-1,0,0,0,0},
                 {0,0,0,-1,1,0,0},
                 {0,0,0,0,-1,1,0},
                 {0,0,0,0,0,-1,0.1}};

 parameter Real A_not_locked[7,7] = {{1,0,0,0,0,0,1},
                        {-1,1,0,0,0,0,0},
                        {0,-1,1,0,0,0,0},
                        {0,0,-1,1,0,0,0},
                        {0,0,0,0,1,0,0},
                        {0,0,0,0,-1,1,0},
                        {0,0,0,0,0,-1,0.1}};
 Real y(start=1);
equation 
  der(y) = -y;
  if y > 0.5 then
    x = b;
  elseif x[4]>1.0 then
    A_not_locked*x=b_startforward;
  elseif x[4]<-1.0 then
    A_not_locked*x=b_startbackward;
  else
    A_locked*x = b_locked;
  end if;

end EnhancedEventIteration1;

model EnhancedEventIteration2
    Real x(start = 0);
    Real y(start = 1);
    Real z(start = 0);
    Real w(start = 0);
equation 
    x = time;
    y = cos(x)  + ( if z+cos(x) <= 0 then 2 else 0);
    z = ( if y-w<=1.5 then 0 else 1);
    w = ( if y <= 1.5 then 0 else 1);
end EnhancedEventIteration2;

model SingularSystem1
  Real sa(start=0);
  Boolean backward(start=false),forward(start=false),locked;
  Integer mode;
  parameter Real tau0_max = 0.5;
  parameter Real w_small = 1e10;
  parameter Real tau0= 0.5;
  parameter Real w_relfric=0, a_relfric=0;
initial equation 
  pre(mode)=3;
equation 
  a_relfric = if locked then 0 elseif forward then sa - tau0_max elseif backward then sa + tau0_max elseif pre(mode) == 1 then sa - tau0_max else sa + tau0_max;
  backward = pre(mode) == 0 and (sa < - tau0_max or pre(backward) and sa < - tau0) or pre(mode) == 1 and w_relfric < - w_small or initial() and w_relfric < 0;
  forward = pre(mode) == 0 and (sa > tau0_max or pre(forward) and sa > tau0) or pre(mode) == -1 and w_relfric > w_small or initial() and w_relfric > 0;
  locked = true and not (pre(mode) == 1 or forward or pre(mode) == -1 or backward);
  mode = if (pre(mode) == 1 or pre(mode) == 2 or forward) and w_relfric > 0 then 1 elseif (pre(mode) == -1 or pre(mode) == 2 or backward) and w_relfric < 0 then -1 else 0;
end SingularSystem1;

model InitialPhasing1
    Boolean b1 = time <= 0;
    Boolean b2;
  initial equation
    b2 = b1;
  equation
    when time > 1 then
      b2 = b1;
    end when;
end InitialPhasing1;

end EventIter;

