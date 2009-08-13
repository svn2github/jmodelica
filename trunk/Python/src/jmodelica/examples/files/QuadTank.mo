package QuadTank_pack
	
	optimization QuadTank_Opt (objective = cost(finalTime),
                         startTime = 0,
                         finalTime = 50000)

    // Process parameters
	parameter Real A1=28, A2=32, A3=28, A4=32;
	parameter Real a1=0.071, a2=0.057, a3=0.071, a4=0.057;
	parameter Real kc=0.5;
	parameter Real g=9.81;
	parameter Real k1_nmp=3.14, k2_nmp=3.29;
	parameter Real g1_nmp=0.30, g2_nmp=0.30;

    // Tank levels
	Real x1(start=1,min=0.1,max=20);
	Real x2(start=1,min=0.1,max=20);
	Real x3(start=1,min=0.1,max=20);
	Real x4(start=1,min=0.1,max=20);

	// Inputs
	input Real u1;
	input Real u2;

    Real cost(start=0);

  equation
    	der(x1) = -a1/A1*sqrt(2*g*x1) + a3/A1*sqrt(2*g*x3) +
					g1_nmp*k1_nmp/A1*u1;
		der(x2) = -a2/A2*sqrt(2*g*x2) + a4/A2*sqrt(2*g*x4) +
					g2_nmp*k2_nmp/A2*u2;
		der(x3) = -a3/A3*sqrt(2*g*x3) + (1-g2_nmp)*k2_nmp/A3*u2;
		der(x4) = -a4/A4*sqrt(2*g*x4) + (1-g1_nmp)*k1_nmp/A4*u1;
		
		/* see https://trac.jmodelica.org/ticket/274#comment:4 for background
		 * on these values
		 */
		der(cost) = ((4.82630404e+02 /*x3_B*/ - x3)^2 + (6.82088796e+02 /*x4_B*/ - x4)^2 + (3 - u1)^2 + (3 - u2)^2) / 10^8;
  end QuadTank_Opt;

end QuadTank_pack;
