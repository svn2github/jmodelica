/*
    Copyright (C) 2009-2013 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


package IndexReduction

  model IndexReduction1a_PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction1a_PlanarPendulum",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction1a_PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real der_y;
 Real der_vx;
 Real _der_x;
 Real der_2_y;
initial equation 
 x = 0.0;
 _der_x = 0.0;
equation
 der(x) = vx;
 der_vx = lambda * x;
 der_2_y = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * der_y = 0.0;
 der(_der_x) = der_vx;
 2 * x * der(_der_x) + 2 * der(x) * der(x) + (2 * y * der_2_y + 2 * der_y * der_y) = 0.0;
 _der_x = der(x);
end IndexReduction.IndexReduction1a_PlanarPendulum;
")})));
  end IndexReduction1a_PlanarPendulum;

  model IndexReduction1b_PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) + 0 = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction1b_PlanarPendulum",
            description="Test of index reduction. This test exposes a nasty bug caused by rewrites of FDerExp:s in different order.",
            flatModel="
fclass IndexReduction.IndexReduction1b_PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real der_y;
 Real der_vx;
 Real _der_x;
 Real der_2_y;
initial equation 
 x = 0.0;
 _der_x = 0.0;
equation
 der(x) = vx;
 der_vx = lambda * x;
 der_2_y = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * der_y = 0.0;
 der(_der_x) = der_vx;
 2 * x * der(_der_x) + 2 * der(x) * der(x) + (2 * y * der_2_y + 2 * der_y * der_y) = 0.0;
 _der_x = der(x);
end IndexReduction.IndexReduction1b_PlanarPendulum;
")})));
  end IndexReduction1b_PlanarPendulum;


  model IndexReduction2_Mechanical
    extends Modelica.Mechanics.Rotational.Examples.First(freqHz=5,amplitude=10,
    damper(phi_rel(stateSelect=StateSelect.always),w_rel(stateSelect=StateSelect.always)));


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction2_Mechanical",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction2_Mechanical
 parameter Modelica.SIunits.Torque amplitude = 10 \"Amplitude of driving torque\" /* 10 */;
 parameter Modelica.SIunits.Frequency freqHz = 5 \"Frequency of driving torque\" /* 5 */;
 parameter Modelica.SIunits.MomentOfInertia Jmotor(min = 0) = 0.1 \"Motor inertia\" /* 0.1 */;
 parameter Modelica.SIunits.MomentOfInertia Jload(min = 0) = 2 \"Load inertia\" /* 2 */;
 parameter Real ratio = 10 \"Gear ratio\" /* 10 */;
 parameter Real damping = 10 \"Damping in bearing of gear\" /* 10 */;
 parameter Modelica.SIunits.Angle fixed.phi0 = 0 \"Fixed offset angle of housing\" /* 0 */;
 Modelica.SIunits.Torque fixed.flange.tau \"Cut torque in the flange\";
 parameter Boolean torque.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 Modelica.SIunits.Torque torque.flange.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.MomentOfInertia inertia1.J(min = 0,start = 1) \"Moment of inertia\";
 parameter StateSelect inertia1.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia1.phi(stateSelect = inertia1.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia1.w(stateSelect = inertia1.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia1.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Real idealGear.ratio(start = 1) \"Transmission ratio (flange_a.phi/flange_b.phi)\";
 Modelica.SIunits.Angle idealGear.phi_a \"Angle between left shaft flange and support\";
 Modelica.SIunits.Angle idealGear.phi_b \"Angle between right shaft flange and support\";
 parameter Boolean idealGear.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 Modelica.SIunits.Torque idealGear.flange_a.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque idealGear.flange_b.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque idealGear.support.tau \"Reaction torque in the support/housing\";
 Modelica.SIunits.Torque inertia2.flange_b.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.MomentOfInertia inertia2.J(min = 0,start = 1) = 2 \"Moment of inertia\" /* 2 */;
 parameter StateSelect inertia2.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia2.phi(fixed = true,start = 0,stateSelect = inertia2.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia2.w(fixed = true,start = 0,stateSelect = inertia2.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia2.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.RotationalSpringConstant spring.c(final min = 0,start = 100000.0) = 10000.0 \"Spring constant\" /* 10000.0 */;
 parameter Modelica.SIunits.Angle spring.phi_rel0 = 0 \"Unstretched spring angle\" /* 0 */;
 Modelica.SIunits.Angle spring.phi_rel(fixed = true,start = 0) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.Torque spring.flange_b.tau \"Cut torque in the flange\";
 constant Modelica.SIunits.Torque inertia3.flange_b.tau = 0 \"Cut torque in the flange\";
 parameter Modelica.SIunits.MomentOfInertia inertia3.J(min = 0,start = 1) \"Moment of inertia\";
 parameter StateSelect inertia3.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia3.phi(stateSelect = inertia3.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia3.w(fixed = true,start = 0,stateSelect = inertia3.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia3.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.RotationalDampingConstant damper.d(final min = 0,start = 0) \"Damping constant\";
 Modelica.SIunits.Angle damper.phi_rel(stateSelect = StateSelect.always,start = 0,nominal = if damper.phi_nominal >= 1.0E-15 then damper.phi_nominal else 1) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.AngularVelocity damper.w_rel(stateSelect = StateSelect.always,start = 0) \"Relative angular velocity (= der(phi_rel))\";
 Modelica.SIunits.AngularAcceleration damper.a_rel(start = 0) \"Relative angular acceleration (= der(w_rel))\";
 Modelica.SIunits.Torque damper.flange_b.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.Angle damper.phi_nominal(displayUnit = \"rad\",min = 0.0) = 1.0E-4 \"Nominal value of phi_rel (used for scaling)\" /* 1.0E-4 */;
 parameter StateSelect damper.stateSelect = StateSelect.prefer \"Priority to use phi_rel and w_rel as states\" /* StateSelect.prefer */;
 parameter Boolean damper.useHeatPort = false \"=true, if heatPort is enabled\" /* false */;
 Modelica.SIunits.Power damper.lossPower \"Loss power leaving component via heatPort (> 0, if heat is flowing out of component)\";
 parameter Real sine.amplitude \"Amplitude of sine wave\";
 parameter Modelica.SIunits.Frequency sine.freqHz(start = 1) \"Frequency of sine wave\";
 parameter Modelica.SIunits.Angle sine.phase = 0 \"Phase of sine wave\" /* 0 */;
 parameter Real sine.offset = 0 \"Offset of output signal\" /* 0 */;
 parameter Modelica.SIunits.Time sine.startTime = 0 \"Output = offset for time < startTime\" /* 0 */;
 constant Real sine.pi = 3.141592653589793;
initial equation 
 inertia2.phi = 0;
 inertia2.w = 0;
 spring.phi_rel = 0;
 inertia3.w = 0;
parameter equation
 inertia1.J = Jmotor;
 idealGear.ratio = ratio;
 inertia3.J = Jload;
 damper.d = damping;
 sine.amplitude = amplitude;
 sine.freqHz = freqHz;
equation
 inertia1.J * inertia1.a = - torque.flange.tau + (- idealGear.flange_a.tau);
 idealGear.phi_a = inertia1.phi - fixed.phi0;
 idealGear.phi_b = inertia2.phi - fixed.phi0;
 idealGear.phi_a = idealGear.ratio * idealGear.phi_b;
 0 = idealGear.ratio * idealGear.flange_a.tau + idealGear.flange_b.tau;
 inertia2.J * inertia2.a = - idealGear.flange_b.tau + inertia2.flange_b.tau;
 spring.flange_b.tau = spring.c * (spring.phi_rel - spring.phi_rel0);
 spring.phi_rel = inertia3.phi - inertia2.phi;
 inertia3.w = inertia3.der(phi);
 inertia3.a = inertia3.der(w);
 inertia3.J * inertia3.a = - spring.flange_b.tau;
 damper.flange_b.tau = damper.d * damper.w_rel;
 damper.lossPower = damper.flange_b.tau * damper.w_rel;
 damper.phi_rel = fixed.phi0 - inertia2.phi;
 damper.w_rel = damper.der(phi_rel);
 damper.a_rel = damper.der(w_rel);
 - torque.flange.tau = sine.offset + (if time < sine.startTime then 0 else sine.amplitude * sin(6.283185307179586 * sine.freqHz * (time - sine.startTime) + sine.phase));
 - damper.flange_b.tau + inertia2.flange_b.tau + (- spring.flange_b.tau) = 0;
 damper.flange_b.tau + fixed.flange.tau + idealGear.support.tau + (- torque.flange.tau) = 0;
 idealGear.support.tau = - idealGear.flange_a.tau - idealGear.flange_b.tau;
 inertia1.w = idealGear.ratio * inertia2.w;
 inertia1.a = idealGear.ratio * inertia2.a;
 damper.der(phi_rel) = - inertia2.w;
 damper.der(w_rel) = - inertia2.a;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

 type Modelica.SIunits.Torque = Real(final quantity = \"Torque\",final unit = \"N.m\");
 type Modelica.SIunits.Frequency = Real(final quantity = \"Frequency\",final unit = \"Hz\");
 type Modelica.SIunits.MomentOfInertia = Real(final quantity = \"MomentOfInertia\",final unit = \"kg.m2\");
 type Modelica.SIunits.Angle = Real(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\");
 type Modelica.Blocks.Interfaces.RealInput = Real;
 type Modelica.SIunits.AngularVelocity = Real(final quantity = \"AngularVelocity\",final unit = \"rad/s\");
 type Modelica.SIunits.AngularAcceleration = Real(final quantity = \"AngularAcceleration\",final unit = \"rad/s2\");
 type Modelica.SIunits.RotationalSpringConstant = Real(final quantity = \"RotationalSpringConstant\",final unit = \"N.m/rad\");
 type Modelica.SIunits.RotationalDampingConstant = Real(final quantity = \"RotationalDampingConstant\",final unit = \"N.m.s/rad\");
 type Modelica.SIunits.Power = Real(final quantity = \"Power\",final unit = \"W\");
 type Modelica.SIunits.Time = Real(final quantity = \"Time\",final unit = \"s\");
 type Modelica.Blocks.Interfaces.RealOutput = Real;
end IndexReduction.IndexReduction2_Mechanical;

")})));
  end IndexReduction2_Mechanical;

  model IndexReduction3_Electrical
  parameter Real omega=100;
  parameter Real R[2]={10,5};
  parameter Real L=1;
  parameter Real C=0.05;
  Real iL (start=1);
  Real uC (start=1);
  Real u0,u1,u2,uL;
  Real i0,i1,i2,iC;
equation
  u0=220*sin(time*omega);
  u1=R[1]*i1;
  u2=R[2]*i2;
  uL=L*der(iL);
  iC=C*der(uC);
  u0= u1+uL;
  uC=u1+u2;
  uL=u2;
  i0=i1+iC;
  i1=i2+iL;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction3_Electrical",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction3_Electrical
 parameter Real omega = 100 /* 100 */;
 parameter Real R[1] = 10 /* 10 */;
 parameter Real R[2] = 5 /* 5 */;
 parameter Real L = 1 /* 1 */;
 parameter Real C = 0.05 /* 0.05 */;
 Real iL(start = 1);
 Real uC(start = 1);
 Real u0;
 Real u1;
 Real uL;
 Real i0;
 Real i1;
 Real i2;
 Real iC;
 Real der_uC;
 Real der_u0;
 Real der_u1;
 Real der_uL;
 Real der_i1;
 Real der_i2;
initial equation 
 iL = 1;
equation
 u0 = 220 * sin(time * omega);
 u1 = R[1] * i1;
 uL = R[2] * i2;
 uL = L * der(iL);
 iC = C * der_uC;
 u0 = u1 + uL;
 uC = u1 + uL;
 i0 = i1 + iC;
 i1 = i2 + iL;
 der_u0 = 220 * (cos(time * omega) * omega);
 der_u1 = R[1] * der_i1;
 der_uL = R[2] * der_i2;
 der_u0 = der_u1 + der_uL;
 der_uC = der_u1 + der_uL;
 der_i1 = der_i2 + der(iL);
end IndexReduction.IndexReduction3_Electrical;
")})));
  end IndexReduction3_Electrical;

model IndexReduction4_Err
  function F
    input Real x;
    output Real y;
  algorithm
    y := sin(x);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1; 

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction4_Err",
            description="Test error messages for unbalanced systems.",
			inline_functions="none",
            errorMessage="
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc8802960033354722744out/sources/IndexReduction.IndexReduction4_Err.mof':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative annotation 'IndexReduction.IndexReduction4_Err.F(x2)' in equation:
   x1 + IndexReduction.IndexReduction4_Err.F(x2) = 1

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc8802960033354722744out/sources/IndexReduction.IndexReduction4_Err.mof':
   Semantic error at line 0, column 0:
  The system is structurally singular. The following varible(s) could not be matched to any equation:
     der(x2)

  The following equation(s) could not be matched to any variable:
    x1 + IndexReduction.IndexReduction4_Err.F(x2) = 1
   ")})));
end IndexReduction4_Err;

model IndexReduction5_Err
  function F
    input Real x;
    output Real y1;
    output Real y2;
  algorithm
    y1 := sin(x);
    y1 := cos(x);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  (x1,x2) = F(x2); 

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction5_Err",
            description="Test error messages for unbalanced systems.",
            errorMessage="
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file 'IndexReduction.IndexReduction5_Err.mof':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative annotation 'IndexReduction.IndexReduction5_Err.F(x2)' in equation:
   (x1, x2) = IndexReduction.IndexReduction5_Err.F(x2)

Error: in file 'IndexReduction.IndexReduction5_Err.mof':
   Semantic error at line 0, column 0:
  The system is structurally singular. The following varible(s) could not be matched to any equation:
     der(x2)

  The following equation(s) could not be matched to any variable:
    (x1, x2) = IndexReduction.IndexReduction5_Err.F(x2)
    (x1, x2) = IndexReduction.IndexReduction5_Err.F(x2)
")})));
end IndexReduction5_Err;

  model IndexReduction6_Cos
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + cos(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction6_Cos",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction6_Cos
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + cos(x2) = 0;
 der_x1 + (- sin(x2) * der(x2)) = 0.0;
end IndexReduction.IndexReduction6_Cos;
")})));
  end IndexReduction6_Cos;

  model IndexReduction7_Sin
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + sin(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction7_Sin",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction7_Sin
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + sin(x2) = 0;
 der_x1 + cos(x2) * der(x2) = 0.0;
end IndexReduction.IndexReduction7_Sin;
")})));
  end IndexReduction7_Sin;

  model IndexReduction8_Neg
  Real x1,x2(stateSelect=StateSelect.prefer);
equation
  der(x1) + der(x2) = 1;
- x1 + 2*x2 = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction8_Neg",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction8_Neg
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 - x1 + 2 * x2 = 0;
 - der_x1 + 2 * der(x2) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction8_Neg;
")})));
  end IndexReduction8_Neg;

  model IndexReduction9_Exp
  Real x1,x2(stateSelect=StateSelect.prefer);
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + exp(x2*p*time) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction9_Exp",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction9_Exp
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + exp(x2 * p * time) = 0;
 der_x1 + exp(x2 * p * time) * (x2 * p + der(x2) * p * time) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction9_Exp;
")})));
  end IndexReduction9_Exp;

  model IndexReduction10_Tan
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + tan(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction10_Tan",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction10_Tan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + tan(x2) = 0;
 der_x1 + der(x2) / cos(x2) ^ 2 = 0.0;
end IndexReduction.IndexReduction10_Tan;
")})));
  end IndexReduction10_Tan;

  model IndexReduction11_Asin
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + asin(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction11_Asin",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction11_Asin
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + asin(x2) = 0;
 der_x1 + der(x2) / sqrt(1 - x2 ^ 2) = 0.0;
end IndexReduction.IndexReduction11_Asin;
")})));
  end IndexReduction11_Asin;

  model IndexReduction12_Acos
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + acos(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction12_Acos",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction12_Acos
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + acos(x2) = 0;
 der_x1 + (- der(x2)) / sqrt(1 - x2 ^ 2) = 0.0;
end IndexReduction.IndexReduction12_Acos;
")})));
  end IndexReduction12_Acos;

  model IndexReduction13_Atan
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + atan(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction13_Atan",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction13_Atan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + atan(x2) = 0;
 der_x1 + der(x2) / (1 + x2 ^ 2) = 0.0;
end IndexReduction.IndexReduction13_Atan;
")})));
  end IndexReduction13_Atan;

model IndexReduction14_Atan2
  Real x1,x2,x3;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
  der(x3) = time;
  x1 + atan2(x2,x3) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction14_Atan2",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction14_Atan2
 Real x1;
 Real x2;
 Real x3;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
 x3 = 0.0;
equation
 der_x1 + der(x2) = 1;
 der(x3) = time;
 x1 + atan2(x2, x3) = 0;
 der_x1 + (der(x2) * x3 - x2 * der(x3)) / (x2 * x2 + x3 * x3) = 0.0;
end IndexReduction.IndexReduction14_Atan2;
")})));
end IndexReduction14_Atan2;

  model IndexReduction15_Sinh
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + sinh(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction15_Sinh",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction15_Sinh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + sinh(x2) = 0;
 der_x1 + cosh(x2) * der(x2) = 0.0;
end IndexReduction.IndexReduction15_Sinh;
")})));
  end IndexReduction15_Sinh;

  model IndexReduction16_Cosh
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + cosh(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction16_Cosh",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction16_Cosh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + cosh(x2) = 0;
 der_x1 + sinh(x2) * der(x2) = 0.0;
end IndexReduction.IndexReduction16_Cosh;
")})));
  end IndexReduction16_Cosh;

  model IndexReduction17_Tanh
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + tanh(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction17_Tanh",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction17_Tanh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + tanh(x2) = 0;
 der_x1 + der(x2) / cosh(x2) ^ 2 = 0.0;
end IndexReduction.IndexReduction17_Tanh;
")})));
  end IndexReduction17_Tanh;

  model IndexReduction18_Log
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + log(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction18_Log",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction18_Log
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + log(x2) = 0;
 der_x1 + der(x2) / x2 = 0.0;
end IndexReduction.IndexReduction18_Log;
")})));
  end IndexReduction18_Log;

  model IndexReduction19_Log10
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + log10(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction19_Log10",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction19_Log10
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + log10(x2) = 0;
 der_x1 + der(x2) / (x2 * log(10)) = 0.0;
end IndexReduction.IndexReduction19_Log10;
")})));
  end IndexReduction19_Log10;

  model IndexReduction20_Sqrt
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + sqrt(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction20_Sqrt",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction20_Sqrt
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + sqrt(x2) = 0;
 der_x1 + der(x2) / (2 * sqrt(x2)) = 0.0;
end IndexReduction.IndexReduction20_Sqrt;
")})));
  end IndexReduction20_Sqrt;

  model IndexReduction21_If
  Real x1,x2(stateSelect=StateSelect.prefer);
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + (if p>3 then 3*x2 else if p<=3 then sin(x2) else 2*x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction21_If",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction21_If
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + (if p > 3 then 3 * x2 elseif p <= 3 then sin(x2) else 2 * x2) = 0;
 der_x1 + (if p > 3 then 3 * der(x2) elseif p <= 3 then cos(x2) * der(x2) else 2 * der(x2)) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction21_If;
")})));
  end IndexReduction21_If;

  model IndexReduction22_Pow
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + x2^p + x2^1.4 = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction22_Pow",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction22_Pow
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + x2 ^ p + x2 ^ 1.4 = 0;
 der_x1 + p * x2 ^ (p - 1) * der(x2) + 1.4 * x2 ^ 0.3999999999999999 * der(x2) = 0.0;
end IndexReduction.IndexReduction22_Pow;
")})));
  end IndexReduction22_Pow;

  model IndexReduction23_BasicVolume_Err
import Modelica.SIunits.*;
parameter SpecificInternalEnergy u_0 = 209058;
parameter SpecificHeatCapacity c_v = 717;
parameter Temperature T_0 = 293;
parameter Mass m_0 = 0.00119;
parameter SpecificHeatCapacity R = 287;
Pressure P;
Volume V;
Mass m(start=m_0);
Temperature T;
MassFlowRate mdot_in;
MassFlowRate mdot_out;
SpecificEnthalpy h_in, h_out;
SpecificEnthalpy h;
Enthalpy H;
SpecificInternalEnergy u;
InternalEnergy U(start=u_0*m_0);
equation

// Boundary equations
V=1e-3;
T=293;
mdot_in=0.1e-3;
mdot_out=0.01e-3;
h_in = 300190;
h_out = h;

// Conservation of mass
der(m) = mdot_in-mdot_out;

// Conservation of energy
der(U) = h_in*mdot_in - h_out*mdot_out;

// Specific internal energy (ideal gas)
u = U/m;
u = u_0+c_v*(T-T_0);

// Specific enthalpy
H = U+P*V;
h = H/m;

// Equation of state (ideal gas)
P*V=m*R*T;  

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction23_BasicVolume_Err",
            description="Test error messages for unbalanced systems.",
            variability_propagation=false,
            errorMessage="2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc2815301804134878885out/resources/BasicVolume.mof':
Semantic error at line 0, column 0:
  Index reduction failed

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc2815301804134878885out/resources/BasicVolume.mof':
Semantic error at line 0, column 0:
  The system is structurally singular. The following equation(s) could not be matched to any variable:
   u = u_0 + c_v * (T - T_0)
")})));
  end IndexReduction23_BasicVolume_Err;

model IndexReduction24_DerFunc
function f
  input Real x;
  output Real y;
algorithm
  y := x^2;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x;
  input Real der_x;
  output Real der_y;
algorithm
  der_y := 2*x*der_x;
end f_der;

  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + f(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction24_DerFunc",
            description="Test of index reduction",
			inline_functions="none",
            flatModel="
fclass IndexReduction.IndexReduction24_DerFunc
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + IndexReduction.IndexReduction24_DerFunc.f(x2) = 0;
 der_x1 + IndexReduction.IndexReduction24_DerFunc.f_der(x2, der(x2)) = 0.0;

public
 function IndexReduction.IndexReduction24_DerFunc.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x * der_x;
  return;
 end IndexReduction.IndexReduction24_DerFunc.f_der;

 function IndexReduction.IndexReduction24_DerFunc.f
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 end IndexReduction.IndexReduction24_DerFunc.f;

end IndexReduction.IndexReduction24_DerFunc;
")})));
end IndexReduction24_DerFunc;

model IndexReduction25_DerFunc
function f
  input Real x[2];
  input Real A[2,2];
  output Real y;
algorithm
  y := x*A*x;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output Real der_y;
algorithm
  der_y := 2*x*A*der_x + x*der_A*x;
end f_der;
  parameter Real A[2,2] = {{1,2},{3,4}};
  Real x1[2],x2[2];
equation
  der(x1) + der(x2) = {1,2};
  x1[1] + f(x2,A) = 0;
  x1[2] = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction25_DerFunc",
            description="Test of index reduction",
			inline_functions="none",
            flatModel="
fclass IndexReduction.IndexReduction25_DerFunc
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 constant Real x1[2] = 0;
 Real x2[1];
 Real x2[2];
 Real der_x1_1;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + IndexReduction.IndexReduction25_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}) = 0;
 der_x1_1 + IndexReduction.IndexReduction25_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}}) = 0.0;

public
 function IndexReduction.IndexReduction25_DerFunc.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output Real der_y;
 algorithm
  der_y := (2 * x[1] * A[1,1] + 2 * x[2] * A[2,1]) * der_x[1] + (2 * x[1] * A[1,2] + 2 * x[2] * A[2,2]) * der_x[2] + ((x[1] * der_A[1,1] + x[2] * der_A[2,1]) * x[1] + (x[1] * der_A[1,2] + x[2] * der_A[2,2]) * x[2]);
  return;
 end IndexReduction.IndexReduction25_DerFunc.f_der;

 function IndexReduction.IndexReduction25_DerFunc.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real y;
 algorithm
  y := (x[1] * A[1,1] + x[2] * A[2,1]) * x[1] + (x[1] * A[1,2] + x[2] * A[2,2]) * x[2];
  return;
 end IndexReduction.IndexReduction25_DerFunc.f;

end IndexReduction.IndexReduction25_DerFunc;

")})));
end IndexReduction25_DerFunc;

model IndexReduction26_DerFunc
function f
  input Real x[2];
  output Real y;
algorithm
  y := x[1]^2 + x[2]^3;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real der_x[2];
  output Real der_y;
algorithm
  der_y := 2*x[1]*der_x[1] + 3*x[2]^2*der_x[2];
end f_der;

  Real x1[2],x2[2];
equation
  der(x1) + der(x2) = {1,2};
  x1[1] + f(x2) = 0;
  x1[2] = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction26_DerFunc",
            description="Test of index reduction",
			inline_functions="none",
            flatModel="
fclass IndexReduction.IndexReduction26_DerFunc
 Real x1[1];
 constant Real x1[2] = 0;
 Real x2[1];
 Real x2[2];
 Real der_x1_1;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + IndexReduction.IndexReduction26_DerFunc.f({x2[1], x2[2]}) = 0;
 der_x1_1 + IndexReduction.IndexReduction26_DerFunc.f_der({x2[1], x2[2]}, {der(x2[1]), der(x2[2])}) = 0.0;

public
 function IndexReduction.IndexReduction26_DerFunc.f_der
  input Real[2] x;
  input Real[2] der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x[1] * der_x[1] + 3 * x[2] ^ 2 * der_x[2];
  return;
 end IndexReduction.IndexReduction26_DerFunc.f_der;

 function IndexReduction.IndexReduction26_DerFunc.f
  input Real[2] x;
  output Real y;
 algorithm
  y := x[1] ^ 2 + x[2] ^ 3;
  return;
 end IndexReduction.IndexReduction26_DerFunc.f;

end IndexReduction.IndexReduction26_DerFunc;

")})));
end IndexReduction26_DerFunc;


model IndexReduction27_DerFunc
function f
  input Real x[2];
  input Real A[2,2];
  output Real y[2];
algorithm
  y := A*x;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output Real der_y[2];
algorithm
  der_y := A*der_x;
end f_der;
  parameter Real A[2,2] = {{1,2},{3,4}};
  Real x1[2],x2[2](each stateSelect=StateSelect.prefer);
equation
  der(x1) + der(x2) = {2,3};
  x1 + f(x2,A) = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction27_DerFunc",
            description="Test of index reduction",
			inline_functions="none",
            flatModel="
fclass IndexReduction.IndexReduction27_DerFunc
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 Real x1[2];
 Real x2[1](stateSelect = StateSelect.prefer);
 Real x2[2](stateSelect = StateSelect.prefer);
 Real der_x1_1;
 Real der_x1_2;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 2;
 der_x1_2 + der(x2[2]) = 3;
 ({- x1[1], - x1[2]}) = IndexReduction.IndexReduction27_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 ({- der_x1_1, - der_x1_2}) = IndexReduction.IndexReduction27_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}});

public
 function IndexReduction.IndexReduction27_DerFunc.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output Real[2] der_y;
 algorithm
  der_y[1] := A[1,1] * der_x[1] + A[1,2] * der_x[2];
  der_y[2] := A[2,1] * der_x[1] + A[2,2] * der_x[2];
  return;
 end IndexReduction.IndexReduction27_DerFunc.f_der;

 function IndexReduction.IndexReduction27_DerFunc.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real[2] y;
 algorithm
  y[1] := A[1,1] * x[1] + A[1,2] * x[2];
  y[2] := A[2,1] * x[1] + A[2,2] * x[2];
  return;
 end IndexReduction.IndexReduction27_DerFunc.f;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction27_DerFunc;
")})));
end IndexReduction27_DerFunc;


model IndexReduction28_Record
record R
    Real[2] a;
end R;

function f
  input Real x[2];
  input Real A[2,2];
  output R y;
algorithm
  y := R(A*x);
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output R der_y;
algorithm
  der_y := R(A*der_x);
end f_der;

  parameter Real A[2,2] = {{1,2},{3,4}};
  R x1(a(stateSelect={StateSelect.prefer,StateSelect.default})),x2(a(stateSelect={StateSelect.prefer,StateSelect.default})),x3;
equation
  der(x1.a) + der(x2.a) = {2,3};
  x1.a + x3.a = {0,0};
  x3 = f(x2.a,A);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction28_Record",
            description="Index reduction: function with record input & output",
			inline_functions="none",
            flatModel="
fclass IndexReduction.IndexReduction28_Record
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1.a[1](stateSelect = StateSelect.prefer);
 Real x1.a[2](stateSelect = StateSelect.default);
 Real x2.a[1](stateSelect = StateSelect.prefer);
 Real x2.a[2](stateSelect = StateSelect.default);
 Real der_x1_a_2;
 Real der_x2_a_2;
initial equation 
 x1.a[1] = 0.0;
 x2.a[1] = 0.0;
equation
 x1.der(a[1]) + x2.der(a[1]) = 2;
 der_x1_a_2 + der_x2_a_2 = 3;
 (IndexReduction.IndexReduction28_Record.R({- x1.a[1], - x1.a[2]})) = IndexReduction.IndexReduction28_Record.f({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 (IndexReduction.IndexReduction28_Record.R({- x1.der(a[1]), - der_x1_a_2})) = IndexReduction.IndexReduction28_Record.f_der({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {x2.der(a[1]), der_x2_a_2}, {{0.0, 0.0}, {0.0, 0.0}});

public
 function IndexReduction.IndexReduction28_Record.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output IndexReduction.IndexReduction28_Record.R der_y;
 algorithm
  der_y.a[1] := A[1,1] * der_x[1] + A[1,2] * der_x[2];
  der_y.a[2] := A[2,1] * der_x[1] + A[2,2] * der_x[2];
  return;
 end IndexReduction.IndexReduction28_Record.f_der;

 function IndexReduction.IndexReduction28_Record.f
  input Real[2] x;
  input Real[2, 2] A;
  output IndexReduction.IndexReduction28_Record.R y;
 algorithm
  y.a[1] := A[1,1] * x[1] + A[1,2] * x[2];
  y.a[2] := A[2,1] * x[1] + A[2,2] * x[2];
  return;
 end IndexReduction.IndexReduction28_Record.f;

 record IndexReduction.IndexReduction28_Record.R
  Real a[2];
 end IndexReduction.IndexReduction28_Record.R;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction28_Record;
")})));
end IndexReduction28_Record;

model IndexReduction29_FunctionNoDerivative
function der_F
  import SI = Modelica.SIunits;

 input SI.Pressure p;
 input SI.SpecificEnthalpy h;
 input Integer phase=0;
 input Real z;
 input Real der_p;
 input Real der_h;
 output Real der_rho;

algorithm
     der_rho := der_p + der_h;
end der_F;

function F 
  import SI = Modelica.SIunits;

  input SI.Pressure p;
  input SI.SpecificEnthalpy h;
  input Integer phase=0;
  input Real z;
  output SI.Density rho;

algorithm
    rho := p + h;
  annotation(derivative(noDerivative=z)=der_F);
  
end F;

  Real x,y;
equation
  der(x) + der(y) = 0;
  x + F(y,x,0,x) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction29_FunctionNoDerivative",
            description="Index reduction: function with record input & output",
			inline_functions="none",
            flatModel="
fclass IndexReduction.IndexReduction29_FunctionNoDerivative
 Real x;
 Real y;
 Real der_x;
initial equation 
 y = 0.0;
equation
 der_x + der(y) = 0;
 x + IndexReduction.IndexReduction29_FunctionNoDerivative.F(y, x, 0, x) = 0;
 der_x + IndexReduction.IndexReduction29_FunctionNoDerivative.der_F(y, x, 0, x, der(y), der_x) = 0.0;

public
 function IndexReduction.IndexReduction29_FunctionNoDerivative.der_F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  input Real der_p;
  input Real der_h;
  output Real der_rho;
 algorithm
  der_rho := der_p + der_h;
  return;
 end IndexReduction.IndexReduction29_FunctionNoDerivative.der_F;

 function IndexReduction.IndexReduction29_FunctionNoDerivative.F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  output Real rho;
 algorithm
  rho := p + h;
  return;
 end IndexReduction.IndexReduction29_FunctionNoDerivative.F;

end IndexReduction.IndexReduction29_FunctionNoDerivative;
")})));
end IndexReduction29_FunctionNoDerivative;

  model IndexReduction30_PlanarPendulum_StatePrefer
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction30_PlanarPendulum_StatePrefer",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction30_PlanarPendulum_StatePrefer
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real der_y;
 Real der_2_x;
 Real der_2_y;
initial equation 
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 der(vx) = lambda * x;
 der_2_y = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * der_y = 0.0;
 der_2_x = der(vx);
 2 * x * der_2_x + 2 * der(x) * der(x) + (2 * y * der_2_y + 2 * der_y * der_y) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction30_PlanarPendulum_StatePrefer;
")})));
  end IndexReduction30_PlanarPendulum_StatePrefer;

model IndexReduction31_PlanarPendulum_StateAlways
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.always) "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
    

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction31_PlanarPendulum_StateAlways",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction31_PlanarPendulum_StateAlways
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.always) \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.always) \"Velocity in x coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real der_y;
 Real der_2_x;
 Real der_2_y;
initial equation 
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 der(vx) = lambda * x;
 der_2_y = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * der_y = 0.0;
 der_2_x = der(vx);
 2 * x * der_2_x + 2 * der(x) * der(x) + (2 * y * der_2_y + 2 * der_y * der_y) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction31_PlanarPendulum_StateAlways;
")})));
  end IndexReduction31_PlanarPendulum_StateAlways;

  model IndexReduction32_PlanarPendulum_StatePreferAlways
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.always) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction32_PlanarPendulum_StatePreferAlways",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction32_PlanarPendulum_StatePreferAlways
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
 Real y(stateSelect = StateSelect.always) \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
 Real vy(stateSelect = StateSelect.always) \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real der_2_x;
 Real der_2_y;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 der(y) = vy;
 der_2_x = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * vx + 2 * y * der(y) = 0.0;
 der_2_y = der(vy);
 2 * x * der_2_x + 2 * vx * vx + (2 * y * der_2_y + 2 * der(y) * der(y)) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StatePreferAlways;
")})));
  end IndexReduction32_PlanarPendulum_StatePreferAlways;

  model IndexReduction32_PlanarPendulum_StatePreferNever
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.never) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.always) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction32_PlanarPendulum_StatePreferNever",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction32_PlanarPendulum_StatePreferNever
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
 Real y(stateSelect = StateSelect.never) \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
 Real vy(stateSelect = StateSelect.always) \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real der_2_x;
 Real der_2_y;
initial equation 
 x = 0.0;
 vy = 0.0;
equation
 der(x) = vx;
 der_2_x = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * vy = 0.0;
 der_2_y = der(vy);
 2 * x * der_2_x + 2 * der(x) * der(x) + (2 * y * der_2_y + 2 * vy * vy) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StatePreferNever;
")})));
  end IndexReduction32_PlanarPendulum_StatePreferNever;

 model IndexReduction33_Div
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 (x1 + x2)/(x1 + p) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction33_Div",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction33_Div
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 (x1 + x2) / (x1 + p) = 0;
 ((der_x1 + der(x2)) * (x1 + p) - (x1 + x2) * der_x1) / (x1 + p) ^ 2 = 0.0;
end IndexReduction.IndexReduction33_Div;
")})));
  end IndexReduction33_Div;

 model IndexReduction34_Div
  Real x1,x2;
  parameter Real p1 = 2;
  parameter Real p2 = 5;
equation
  der(x1) + der(x2) = 1;
 (x1 + x2)/(p1*p2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction34_Div",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction34_Div
 Real x1;
 Real x2;
 parameter Real p1 = 2 /* 2 */;
 parameter Real p2 = 5 /* 5 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 (x1 + x2) / (p1 * p2) = 0;
 (der_x1 + der(x2)) / (p1 * p2) = 0.0;
end IndexReduction.IndexReduction34_Div;
")})));
  end IndexReduction34_Div;

model IndexReduction35_Boolean
    Real x,y;
    Boolean b = false;
equation
    x = if b then 1 else 2 + y;
    der(x) + der(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction35_Boolean",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction35_Boolean
 Real x;
 Real y;
 constant Boolean b = false;
 Real der_x;
initial equation 
 y = 0.0;
equation
 x = 2 + y;
 der_x + der(y) = 0;
 der_x = der(y);
end IndexReduction.IndexReduction35_Boolean;

")})));
end IndexReduction35_Boolean;

model IndexReduction36_Integer
    Real x,y;
    Integer b = 2;
equation
    x = if b==2 then 1 else 2 + y;
    der(x) + der(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction36_Integer",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction36_Integer
 Real x;
 Real y;
 constant Integer b = 2;
 Real der_x;
initial equation 
 y = 0.0;
equation
 x = 1;
 der_x + der(y) = 0;
 der_x = 0.0;
end IndexReduction.IndexReduction36_Integer;

")})));
end IndexReduction36_Integer;

model IndexReduction37_noEvent
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction37_noEvent",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction37_noEvent
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;
 noEvent(der_x1 + cos(x2) * der(x2)) = 0.0;
end IndexReduction.IndexReduction37_noEvent;
")})));
  end IndexReduction37_noEvent;


model IndexReduction38_ComponentArray
    model M
        parameter Real L = 1 "Pendulum length";
        parameter Real g =9.81 "Acceleration due to gravity";
        Real x "Cartesian x coordinate";
        Real y "Cartesian x coordinate";
        Real vx "Velocity in x coordinate";
        Real vy "Velocity in y coordinate";
        Real lambda "Lagrange multiplier";
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = lambda*x;
        der(vy) = lambda*y - g;
        x^2 + y^2 = L;
    end M;

    M m[1];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction38_ComponentArray",
			description="Name for der variables from FQNameString",
			flatModel="
fclass IndexReduction.IndexReduction38_ComponentArray
 parameter Real m[1].L = 1 \"Pendulum length\" /* 1 */;
 parameter Real m[1].g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real m[1].x \"Cartesian x coordinate\";
 Real m[1].y \"Cartesian x coordinate\";
 Real m[1].vx \"Velocity in x coordinate\";
 Real m[1].lambda \"Lagrange multiplier\";
 Real der_m_1_y;
 Real der_m_1_vx;
 Real m[1]._der_x;
 Real der_2_m_1_y;
initial equation 
 m[1].x = 0.0;
 m[1]._der_x = 0.0;
equation
 m[1].der(x) = m[1].vx;
 der_m_1_vx = m[1].lambda * m[1].x;
 der_2_m_1_y = m[1].lambda * m[1].y - m[1].g;
 m[1].x ^ 2 + m[1].y ^ 2 = m[1].L;
 2 * m[1].x * m[1].der(x) + 2 * m[1].y * der_m_1_y = 0.0;
 m[1].der(_der_x) = der_m_1_vx;
 2 * m[1].x * m[1].der(_der_x) + 2 * m[1].der(x) * m[1].der(x) + (2 * m[1].y * der_2_m_1_y + 2 * der_m_1_y * der_m_1_y) = 0.0;
 m[1]._der_x = m[1].der(x);
end IndexReduction.IndexReduction38_ComponentArray;
")})));
end IndexReduction38_ComponentArray;
	
end IndexReduction;
