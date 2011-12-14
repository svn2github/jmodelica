model InitTest
  Real x(start=1,fixed=true);
  Real y;
  input Real u;
equation
  der(x) = -x + u;
  x=2*y;
end InitTest;