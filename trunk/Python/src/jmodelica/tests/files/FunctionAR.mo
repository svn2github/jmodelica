package FunctionAR

  model UnknownArray1
    Real x[3](start={2,3,4}, each fixed=true);
    Real y[3](each fixed=true);
  equation
    der(y) = F(x);
    der(x) = y;
  end UnknownArray1;

  function F
    input Real[:] x;
    output Real[size(x,1)] y;
  protected 
    Real[size(x,1)] z;
    Real w;
  algorithm
    z := x;
    w := x * z;
    for i in 1:size(x,1) loop
      y[i] := - x[i] * w * i;
    end for;
  end F;

end FunctionAR;
