model VDP
  parameter Real p1 = 1;
  parameter Real p2 = 0;
  parameter Real p3 = 0.2;
  Real x1(start = 0);
  Real x2(start = 1);
  Real x3(start = 0);
  Real w;
  input Real u;
equation
  der(x1) = (1-x2^2)*x1-x2+u;
  der(x2) = p1*x1;
  der(x3) = exp(p3*time)*(x1^2 + x2^2 + u^2);
  w = x1 + x2;
end VDP;