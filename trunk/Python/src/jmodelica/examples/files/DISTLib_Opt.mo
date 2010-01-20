package DISTLib_Opt

  optimization Binary_Dist_Opt1(objective = cost(finalTime), startTime=0., finalTime=50.)
    extends DISTLib.Binary_Dist(u1(min=1,max=5));

    Real cost(start = 0);
    parameter Real alpha = 1000;
    parameter Real rho = 1; 

    parameter Real u1_ref = 2.7;
    parameter Real y1_ref = 0.8;

   equation
    der(cost)  = alpha*(y[1]-y1_ref)^2 + rho*(u1-u1_ref)^2 ; 

//   constraint
//     x32>=0.08;
  end Binary_Dist_Opt1;

end DISTLib_Opt;