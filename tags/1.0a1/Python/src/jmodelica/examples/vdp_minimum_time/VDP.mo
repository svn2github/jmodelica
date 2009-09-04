package VDP_pack
        
  optimization VDP_Opt (objective = tf,
                         startTime = 0,
                         finalTime = 1) 

    // The time is scaled so that the new
    // time variable, call it \tau,
    // is related to the original time,
    // call it t as \tau=tf*t where tf
    // is a parameter to be minimized 
    // subject to the dynamics
    // \dot x = tf*f(x,u)
    parameter Real tf(free=true,min=0.2)=1;

    // The states
    Real x1(start=0);
    Real x2(start=1);
    
    // The control signal with bounds
    input Real u(min=-1,max=1);
  equation
    der(x1) = 1*tf*((1 - x2^2) * x1 - x2 + u);
    der(x2) = 1*tf*(x1);
  constraint
    // terminal constraints
    x1(finalTime)=0;
    x2(finalTime)=0;
  end VDP_Opt;

end VDP_pack;
