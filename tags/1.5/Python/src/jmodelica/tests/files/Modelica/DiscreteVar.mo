model DiscreteVar
  Real x = 3;
  Real y;
equation
  when sample(0,1) then
    y = pre(y) + 1;
  end when;
end DiscreteVar;