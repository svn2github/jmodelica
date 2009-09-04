package VDP_pack

  optimization VDP_Opt (objective = cost(finalTime),
                         startTime = 0,
                         finalTime = 20)


    // Parameters
    parameter Real p1 = 1;             // Parameter 1
    parameter Real p2 = 1;             // Parameter 2
    parameter Real p3 = 2;             // Parameter 3

    // The states
    Real x1(start=0);
    Real x2(start=1);

    // The control signal
    input Real u;

    Real cost(start=0);

  equation
    der(x1) = (1 - x2^2) * x1 - x2 + u;
    der(x2) = p1 * x1;
    der(cost) = exp(p3 * 1/*time*/) * (x1^2 + x2^2 + u^2);
  constraint 
     u<=0.75;
  end VDP_Opt;

end VDP_pack;
