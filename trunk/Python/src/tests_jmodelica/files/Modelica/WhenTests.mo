within ;
package WhenTests

  model WhenTest1
    discrete Real x;
    discrete Real y;
  equation
    when time > 0.25 then
      x = 2*x + y + 1;
    end when;
    when time > 0.5 then
      y = 3*x - 4*y + 1;
    end when;
  end WhenTest1;

  model WhenTest2
    discrete Real x;
    discrete Real y;
  equation
    when time > 0.5 then
      x = 2*x + y + 1;
      y = 3*x - 4*y + 1;
    end when;

  end WhenTest2;

  model WhenTest4
    Real x(start=1);
    Real y(start=-1);
    Real z(start=0);
  equation
    when {time >= 0.25} then
      z = x + 1;
    end when;
    when pre(z) >= 1 then
      y = 3;
    end when;
    when pre(y) >= 1 then
      x = 1;
    end when;
  end WhenTest4;

end WhenTests;
