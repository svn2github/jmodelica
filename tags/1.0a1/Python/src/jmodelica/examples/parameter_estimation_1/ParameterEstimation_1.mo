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

  optimization ParEst (objective = cost(finalTime),
                       startTime = 0,
                       finalTime = 15)

    // Create second order system instance,
    // Set parameters w and z free and give 
    // initial guesses
    SecondOrder sys(w(free=true,initialGuess=2),
                   z(free=true,initialGuess=1));
    Real u = sys.u;
    
    // Measurement data time points
    parameter Real t0 = 0;
    parameter Real t1 = 1;
    parameter Real t2 = 2;
    parameter Real t3 = 3;
    parameter Real t4 = 4;
    parameter Real t5 = 5;
    parameter Real t6 = 6;
    parameter Real t7 = 7;
    parameter Real t8 = 8;
    parameter Real t9 = 9;
    parameter Real t10 = 10;

    // Measurement data output values
    parameter Real y0 = 0.;
    parameter Real y1 = 0.63212056;
    parameter Real y2 = 0.86466472;
    parameter Real y3 = 0.95021293; 
    parameter Real y4 = 0.98168436;
    parameter Real y5 = 0.99326205;  
    parameter Real y6 = 0.99752125;
    parameter Real y7 = 0.99908812;
    parameter Real y8 = 0.99966454;
    parameter Real y9 = 0.99987659;
    parameter Real y10 = 0.9999546; 

    // Cost function
    Real cost;

    equation 
      u=1;

    constraint
      // Squared sum of errors
      cost = (sys.y(t0) - y0)^2 +
             (sys.y(t1) - y1)^2 +
             (sys.y(t3) - y3)^2 +
             (sys.y(t4) - y4)^2 +
             (sys.y(t5) - y5)^2 +
             (sys.y(t6) - y6)^2 +
             (sys.y(t7) - y7)^2 +
             (sys.y(t8) - y8)^2 +
             (sys.y(t9) - y9)^2 +
             (sys.y(t10) - y10)^2;

  end ParEst;


end ParEst;