package DISTLib 
  model Binary_Dist 
  // Import Modelica SI unit library
    import SI = Modelica.SIunits;
    type MolarFlowRate = Real(quantity = "Molar Flow Rate", unit = "mol/s");
    type Moles = Real(quantity = "Mols", unit = "mol", displayUnit = "mols");
    
  // The model has to be rescaled in order to enable
  // use of SI units.
    
  // Model parameters
    parameter MolarFlowRate Feed = 24/60 "Feed Flow Rate"; //mol/s
    parameter SI.MassFraction x_Feed = 0.5 "Mole Fraction of Feed";
    parameter MolarFlowRate D = x_Feed*Feed "Distillate Flowrate"; //mol/s
    parameter Real vol = 1.6 "Relative Volatility = KA/KB = (yA/xA)/(yB/xB)";
    parameter Moles atray = 0.25 "Total Molar Holdup in the Condenser"; //moles
    parameter Moles acond = 0.5 "Total Molar Holdup on each Tray"; //moles
    parameter Moles areb = 1.0 "Total Molar Holdup in the Reboiler"; //moles
    
  // Algebraic variables
    Real rr "Reflux Ratio (L/D)"; //step change with u1
    MolarFlowRate L "Flowrate of the Liquid in the Rectification Section"; //mol/s
    MolarFlowRate V "Vapor Flowrate in the Column"; //mol/s
    MolarFlowRate FL "Flowrate of the Liquid in the Stripping Section"; //mol/s
    
    SI.MoleFraction y1(min=0) "Reflux Drum Liquid Mole Fraction of Component A";
    SI.MoleFraction y2(min=0) "Tray 1 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y3(min=0) "Tray 2 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y4(min=0) "Tray 3 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y5(min=0) "Tray 4 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y6(min=0) "Tray 5 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y7(min=0) "Tray 6 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y8(min=0) "Tray 7 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y9(min=0) "Tray 8 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y10(min=0) "Tray 9 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y11(min=0) "Tray 10 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y12(min=0) "Tray 11 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y13(min=0) "Tray 12 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y14(min=0) "Tray 13 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y15(min=0) "Tray 14 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y16(min=0) "Tray 15 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y17(min=0) 
      "Tray 16 - Vapor Mole Fraction of Component A (Feed Location)";
    SI.MoleFraction y18(min=0) "Tray 17 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y19(min=0) "Tray 18 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y20(min=0) "Tray 19 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y21(min=0) "Tray 20 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y22(min=0) "Tray 21 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y23(min=0) "Tray 22 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y24(min=0) "Tray 23 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y25(min=0) "Tray 24 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y26(min=0) "Tray 25 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y27(min=0) "Tray 26 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y28(min=0) "Tray 27 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y29(min=0) "Tray 28 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y30(min=0) "Tray 29 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y31(min=0) "Tray 30 - Vapor Mole Fraction of Component A";
    SI.MoleFraction y32(min=0) "Reboiler Vapor Mole Fraction of Component A";
    
  // Initial values for the states
    parameter Real x1_0 = 0.9;   //Reflux Drum Liquid Mole Fraction of Component A
    parameter Real x2_0 = 0.9;   //Tray 1 - Liquid Mole Fraction of Component A
    parameter Real x3_0 = 0.8;
    parameter Real x4_0 = 0.8;
    parameter Real x5_0 = 0.7;
    parameter Real x6_0 = 0.7;
    parameter Real x7_0 = 0.6;
    parameter Real x8_0 = 0.6;
    parameter Real x9_0 = 0.6;
    parameter Real x10_0 = 0.5;
    parameter Real x11_0 = 0.5;
    parameter Real x12_0 = 0.5;
    parameter Real x13_0 = 0.5;
    parameter Real x14_0 = 0.5;
    parameter Real x15_0 = 0.5;
    parameter Real x16_0 = 0.5;
    parameter Real x17_0 = 0.4;   //Tray 16 - Liquid Mole Fraction of Component A (Feed Location)
    parameter Real x18_0 = 0.4;
    parameter Real x19_0 = 0.4;
    parameter Real x20_0 = 0.4;
    parameter Real x21_0 = 0.4;
    parameter Real x22_0 = 0.4;
    parameter Real x23_0 = 0.3;
    parameter Real x24_0 = 0.3;
    parameter Real x25_0 = 0.3;
    parameter Real x26_0 = 0.2;
    parameter Real x27_0 = 0.2;
    parameter Real x28_0 = 0.2;
    parameter Real x29_0 = 0.1;
    parameter Real x30_0 = 0.1;
    parameter Real x31_0 = 0.01;  //Tray 30 - Liquid Mole Fraction of Component A
    parameter Real x32_0 = 0;      //Reboiler Liquid Mole Fraction of Component A
    
  //Guess Values for steady-state solution to be
    SI.MoleFraction x1(start = x1_0, min = 0) 
      "Reflux Drum Liquid Mole Fraction of Component A";
    SI.MoleFraction x2(start= x2_0, min = 0) 
      "Tray 1 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x3(start= x3_0, min = 0) 
      "Tray 2 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x4(start= x4_0, min = 0) 
      "Tray 3 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x5(start= x5_0, min = 0) 
      "Tray 4 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x6(start= x6_0, min = 0) 
      "Tray 5 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x7(start= x7_0, min = 0) 
      "Tray 6 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x8(start= x8_0, min = 0) 
      "Tray 7 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x9(start= x9_0, min = 0) 
      "Tray 8 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x10(start= x10_0, min = 0) 
      "Tray 9 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x11(start= x11_0, min = 0) 
      "Tray 10 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x12(start= x12_0, min = 0) 
      "Tray 11 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x13(start= x13_0, min = 0) 
      "Tray 12 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x14(start= x14_0, min = 0) 
      "Tray 13 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x15(start= x15_0, min = 0) 
      "Tray 14 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x16(start= x16_0, min = 0) 
      "Tray 15 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x17(start= x17_0, min = 0) 
      "Tray 16 - Liquid Mole Fraction of Component A (Feed Location)";
    SI.MoleFraction x18(start= x18_0, min = 0) 
      "Tray 17 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x19(start= x19_0, min = 0) 
      "Tray 18 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x20(start= x20_0, min = 0) 
      "Tray 19 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x21(start= x21_0, min = 0) 
      "Tray 20 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x22(start= x22_0, min = 0) 
      "Tray 21 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x23(start= x23_0, min = 0) 
      "Tray 22 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x24(start= x24_0, min = 0) 
      "Tray 23 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x25(start= x25_0, min = 0) 
      "Tray 24 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x26(start= x26_0, min = 0) 
      "Tray 25 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x27(start= x27_0, min = 0) 
      "Tray 26 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x28(start= x28_0, min = 0) 
      "Tray 27 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x29(start= x29_0, min = 0) 
      "Tray 28 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x30(start= x30_0, min = 0) 
      "Tray 29 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x31(start= x31_0, min = 0) 
      "Tray 30 - Liquid Mole Fraction of Component A";
    SI.MoleFraction x32(start= x32_0, min = 0) 
      "Reboiler Liquid Mole Fraction of Component A";
    
  // Model inputs
    Modelica.Blocks.Interfaces.RealInput u1(start = 1) 
                                                     annotation (Placement(
             transformation(extent={{-100,20},{-60,60}}), iconTransformation(
               extent={{-100,20},{-60,60}})));
    
  equation 
    rr = u1;
    L = rr*D;
    V = L+D;
    FL = Feed + L;
    
    // Vapor Mole Fractions of Componenent A
    // From the equilibrium assumption and mole balances
    // 1) vol = (yA/xA)/(yB/xB)
    // 2) xA + xB = 1
    // 3) yA + yB = 1
    y1 = (x1*vol)/(1+((vol-1)*x1));
    y2 = (x2*vol)/(1+((vol-1)*x2));
    y3 = (x3*vol)/(1+((vol-1)*x3));
    y4 = (x4*vol)/(1+((vol-1)*x4));
    y5 = (x5*vol)/(1+((vol-1)*x5));
    y6 = (x6*vol)/(1+((vol-1)*x6));
    y7 = (x7*vol)/(1+((vol-1)*x7));
    y8 = (x8*vol)/(1+((vol-1)*x8));
    y9 = (x9*vol)/(1+((vol-1)*x9));
    y10 = (x10*vol)/(1+((vol-1)*x10));
    y11 = (x11*vol)/(1+((vol-1)*x11));
    y12 = (x12*vol)/(1+((vol-1)*x12));
    y13 = (x13*vol)/(1+((vol-1)*x13));
    y14 = (x14*vol)/(1+((vol-1)*x14));
    y15 = (x15*vol)/(1+((vol-1)*x15));
    y16 = (x16*vol)/(1+((vol-1)*x16));
    y17 = (x17*vol)/(1+((vol-1)*x17));
    y18 = (x18*vol)/(1+((vol-1)*x18));
    y19 = (x19*vol)/(1+((vol-1)*x19));
    y20 = (x20*vol)/(1+((vol-1)*x20));
    y21 = (x21*vol)/(1+((vol-1)*x21));
    y22 = (x22*vol)/(1+((vol-1)*x22));
    y23 = (x23*vol)/(1+((vol-1)*x23));
    y24 = (x24*vol)/(1+((vol-1)*x24));
    y25 = (x25*vol)/(1+((vol-1)*x25));
    y26 = (x26*vol)/(1+((vol-1)*x26));
    y27 = (x27*vol)/(1+((vol-1)*x27));
    y28 = (x28*vol)/(1+((vol-1)*x28));
    y29 = (x29*vol)/(1+((vol-1)*x29));
    y30 = (x30*vol)/(1+((vol-1)*x30));
    y31 = (x31*vol)/(1+((vol-1)*x31));
    y32 = (x32*vol)/(1+((vol-1)*x32));
    
    // ODE's
    der(x1) = (V*(y2-x1))/acond;
    der(x2) = ((L*(x1-x2))-(V*(y2-y3)))/atray;
    der(x3) = ((L*(x2-x3))-(V*(y3-y4)))/atray;
    der(x4) = ((L*(x3-x4))-(V*(y4-y5)))/atray;
    der(x5) = ((L*(x4-x5))-(V*(y5-y6)))/atray;
    der(x6) = ((L*(x5-x6))-(V*(y6-y7)))/atray;
    der(x7) = ((L*(x6-x7))-(V*(y7-y8)))/atray;
    der(x8) = ((L*(x7-x8))-(V*(y8-y9)))/atray;
    der(x9) = ((L*(x8-x9))-(V*(y9-y10)))/atray;
    der(x10) = ((L*(x9-x10))-(V*(y10-y11)))/atray;
    der(x11) = ((L*(x10-x11))-(V*(y11-y12)))/atray;
    der(x12) = ((L*(x11-x12))-(V*(y12-y13)))/atray;
    der(x13) = ((L*(x12-x13))-(V*(y13-y14)))/atray;
    der(x14) = ((L*(x13-x14))-(V*(y14-y15)))/atray;
    der(x15) = ((L*(x14-x15))-(V*(y15-y16)))/atray;
    der(x16) = ((L*(x15-x16))-(V*(y16-y17)))/atray;
    der(x17) = (D+(L*x16)-(FL*x17)-(V*(y17-y18)))/atray;
    der(x18) = ((FL*(x17-x18))-(V*(y18-y19)))/atray;
    der(x19) = ((FL*(x18-x19))-(V*(y19-y20)))/atray;
    der(x20) = ((FL*(x19-x20))-(V*(y20-y21)))/atray;
    der(x21) = ((FL*(x20-x21))-(V*(y21-y22)))/atray;
    der(x22) = ((FL*(x21-x22))-(V*(y22-y23)))/atray;
    der(x23) = ((FL*(x22-x23))-(V*(y23-y24)))/atray;
    der(x24) = ((FL*(x23-x24))-(V*(y24-y25)))/atray;
    der(x25) = ((FL*(x24-x25))-(V*(y25-y26)))/atray;
    der(x26) = ((FL*(x25-x26))-(V*(y26-y27)))/atray;
    der(x27) = ((FL*(x26-x27))-(V*(y27-y28)))/atray;
    der(x28) = ((FL*(x27-x28))-(V*(y28-y29)))/atray;
    der(x29) = ((FL*(x28-x29))-(V*(y29-y30)))/atray;
    der(x30) = ((FL*(x29-x30))-(V*(y30-y31)))/atray;
    der(x31) = ((FL*(x30-x31))-(V*(y31-y32)))/atray;
    der(x32) = ((FL*x31)-((Feed-D)*x32)-(V*y32))/areb;
    
  end Binary_Dist;
  
  model Binary_Dist_initial 
    extends Binary_Dist;
  initial equation 
  //steady state
  der(x1) = 0;
  der(x2) = 0;
  der(x3) = 0;
  der(x4) = 0;
  der(x5) = 0;
  der(x6) = 0;
  der(x7) = 0;
  der(x8) = 0;
  der(x9) = 0;
  der(x10) = 0;
  der(x11) = 0;
  der(x12) = 0;
  der(x13) = 0;
  der(x14) = 0;
  der(x15) = 0;
  der(x16) = 0;
  der(x17) = 0;
  der(x18) = 0;
  der(x19) = 0;
  der(x20) = 0;
  der(x21) = 0;
  der(x22) = 0;
  der(x23) = 0;
  der(x24) = 0;
  der(x25) = 0;
  der(x26) = 0;
  der(x27) = 0;
  der(x28) = 0;
  der(x29) = 0;
  der(x30) = 0;
  der(x31) = 0;
  der(x32) = 0;
    
  end Binary_Dist_initial;
  annotation (uses(Modelica(version="2.2.1")));
  package Examples 
    model Simulation 
      Binary_Dist binary_dist 
        annotation (Placement(transformation(extent={{6,6},{26,26}})));
      Modelica.Blocks.Sources.Step step(
        startTime=60,
        height=-1,
        offset=2.7) 
        annotation (Placement(transformation(extent={{-60,28},{-40,48}})));
      
      Binary_Dist_initial binary_dist_initial 
        annotation (Placement(transformation(extent={{8,-20},{28,0}})));
      
    equation 
      connect(step.y, binary_dist.u1) annotation (Line(
          points={{-39,38},{-16,38},{-16,20},{8,20}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(step.y,binary_dist_initial.u1) annotation (Line(
          points={{10,-6},{-16,-6},{-16,38},{-39,38}},
          color={0,0,127},
          smooth=Smooth.None));
    end Simulation;
  end Examples;
end DISTLib;
