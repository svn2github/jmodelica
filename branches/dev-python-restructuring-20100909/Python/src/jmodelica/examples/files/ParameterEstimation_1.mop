package ParEst

  model SecondOrder
    parameter Real w = 1;
    parameter Real z = 0.5;
    parameter Real x1_0 = 0;
    parameter Real x2_0 = 0;
    input Real u;
    Real x1(start=x1_0);
    Real x2(start=x2_0);
    Real y=x1;
  equation
    der(x1) = -2*w*z*x1 + x2;
    der(x2) = -w^2*x1 + w^2*u;
  end SecondOrder;

  optimization ParEst (objective = sum((sys.y(t[i]) - y[i])^2 for i in 1:11),
                       startTime = 0,
                       finalTime = 15)

    // Create second order system instance,
    // Set parameters w and z free and give 
    // initial guesses
    SecondOrder sys(w(free=true,initialGuess=2),
                    z(free=true,initialGuess=1),
                    x1(fixed=true),
                    x2(fixed=true));
    Real u = sys.u;
    
    // Measurement data time points
    parameter Real t[11] = {0,1,2,3,4,5,6,7,8,9,10};

    // Measurement data output values
    parameter Real y[11] = {0.,0.63212056,0.86466472,0.95021293, 0.98168436,0.99326205,  0.99752125,0.99908812,0.99966454,0.99987659,0.9999546}; 

    equation 
      u=1;

  end ParEst;

end ParEst;