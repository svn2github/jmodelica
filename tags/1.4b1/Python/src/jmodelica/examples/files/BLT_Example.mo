model BLT_Example
  parameter Real A[2,2] = {{-1,0.1},{0.1,-1}};
  parameter Real C[2,2] = {{1,0.1},{0.1,1}};
  parameter Real E[2,2] = {{2,1},{1,2}};	
  Real x[2] (start={1,1});
  Real y[2];
equation
  y = C*x;
  E*der(x) = A*x;
end BLT_Example;