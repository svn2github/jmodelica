package VDP_pack

  optimization VDP_Opt (objective = cost(finalTime),
                         startTime = 0,
                         finalTime = 20)

    parameter Real p1 = 1;             // Parameter 1 
    parameter Real p2 = 1;             // Parameter 2 
    parameter Real p3 = 2;             // Parameter 3 

    // The states
    Real x1(start=0,fixed=true);
    Real x2(start=1,fixed=true);

    // The control signal
    input Real u;

    Real cost(start=0,fixed=true);

  equation
    der(x1) = (1 - x2^2) * x1 - x2 + u;
    der(x2) = p1*x1;
    der(cost) = exp(p3) * (x1^2 + x2^2 + u^2);
  constraint 
     u<=0.75;
  end VDP_Opt;

  optimization VDP_Opt_Min_Time (objective = finalTime,
                         startTime = 0,
                         finalTime(free=true,min=0.2,initialGuess=1)) 

    // The states
    Real x1(start=0,fixed=true);
    Real x2(start=1,fixed=true);
    
    // The control signal with bounds
    input Real u(min=-1,max=1);
  equation
    der(x1) = ((1 - x2^2) * x1 - x2 + u);
    der(x2) = x1;
  constraint
    // terminal constraints
    x1(finalTime)=0;
    x2(finalTime)=0;
  end VDP_Opt_Min_Time;


end VDP_pack;
