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

  optimization Pendulum_Opt (objective=cost(finalTime),
                             startTime = 0,
                             finalTime = 8)

    Pendulum pend;
    input Real u = pend.u;
    Real cost(start=0);
    parameter Real x_ref = 0;

  equation
    der(cost) = pend.theta^2 + pend.dtheta^2 + 
                (x_ref - pend.x)^2 + pend.dx^2+0.01*u^2;
  end Pendulum_Opt;

end Pendulum_pack;