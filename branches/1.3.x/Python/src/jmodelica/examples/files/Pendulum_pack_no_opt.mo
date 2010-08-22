package Pendulum_pack

  model Pendulum
    parameter Real th0=0.1;
    parameter Real dth0 = 0;
    parameter Real x0=0;
    parameter Real dx0 = 0;

    Real theta(start=th0);
    Real dtheta(start=dth0);
    Real x(start=x0);
    Real dx(start=dx0);
    input Real u;

  equation
    der(theta) = dtheta;
    der(dtheta) = sin(theta) + u*cos(theta);
    der(x) = dx;
    der(dx) = u;
  end Pendulum;
  
end Pendulum_pack;