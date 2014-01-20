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
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vx;
 Real _der_vy;
 Real _der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 _der_x = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 _der_vx = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 der(_der_x) = _der_vx;
 _der_der_y = _der_vy;
 2 * x * der(_der_x) + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;
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
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vx;
 Real _der_vy;
 Real _der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 _der_x = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 _der_vx = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 der(_der_x) = _der_vx;
 _der_der_y = _der_vy;
 2 * x * der(_der_x) + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;
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
 Real inertia1._der_phi;
 Real inertia1._der_w;
 Real inertia2._der_phi;
 Real inertia2._der_w;
 Real idealGear._der_phi_a;
 Real idealGear._der_phi_b;
 Real inertia1._der_der_phi;
 Real inertia2._der_der_phi;
 Real idealGear._der_der_phi_a;
 Real idealGear._der_der_phi_b;
 Real damper._der_der_phi_rel;
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
 inertia1.w = inertia1._der_phi;
 inertia1.a = inertia1._der_w;
 inertia1.J * inertia1.a = - torque.flange.tau + (- idealGear.flange_a.tau);
 idealGear.phi_a = inertia1.phi - fixed.phi0;
 idealGear.phi_b = inertia2.phi - fixed.phi0;
 idealGear.phi_a = idealGear.ratio * idealGear.phi_b;
 0 = idealGear.ratio * idealGear.flange_a.tau + idealGear.flange_b.tau;
 inertia2.w = inertia2._der_phi;
 inertia2.a = inertia2._der_w;
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
 idealGear._der_phi_a = inertia1._der_phi;
 idealGear._der_phi_b = inertia2._der_phi;
 idealGear._der_phi_a = idealGear.ratio * idealGear._der_phi_b;
 inertia1._der_w = inertia1._der_der_phi;
 inertia2._der_w = inertia2._der_der_phi;
 idealGear._der_der_phi_a = inertia1._der_der_phi;
 idealGear._der_der_phi_b = inertia2._der_der_phi;
 idealGear._der_der_phi_a = idealGear.ratio * idealGear._der_der_phi_b;
 damper.der(phi_rel) = - inertia2._der_phi;
 damper.der(w_rel) = damper._der_der_phi_rel;
 damper._der_der_phi_rel = - inertia2._der_der_phi;

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
 Real _der_iL;
 Real _der_uC;
 Real _der_u0;
 Real _der_u1;
 Real _der_uL;
 Real _der_i2;
initial equation 
 i1 = 0.0;
equation
 u0 = 220 * sin(time * omega);
 u1 = R[1] * i1;
 uL = R[2] * i2;
 uL = L * _der_iL;
 iC = C * _der_uC;
 u0 = u1 + uL;
 uC = u1 + uL;
 i0 = i1 + iC;
 i1 = i2 + iL;
 _der_u0 = 220 * (cos(time * omega) * omega);
 _der_u1 = R[1] * der(i1);
 _der_uL = R[2] * _der_i2;
 _der_u0 = _der_u1 + _der_uL;
 _der_uC = _der_u1 + _der_uL;
 der(i1) = _der_i2 + _der_iL;
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
  Cannot differentiate call to function without derivative or smooth order annotation 'IndexReduction.IndexReduction4_Err.F(x2)' in equation:
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
  Cannot differentiate call to function without derivative or smooth order annotation 'IndexReduction.IndexReduction5_Err.F(x2)' in equation:
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + cos(x2) = 0;
 _der_x1 + (- sin(x2) * der(x2)) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sin(x2) = 0;
 _der_x1 + cos(x2) * der(x2) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 - x1 + 2 * x2 = 0;
 - _der_x1 + 2 * der(x2) = 0.0;

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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + exp(x2 * p * time) = 0;
 _der_x1 + exp(x2 * p * time) * (x2 * p + der(x2) * p * time) = 0.0;

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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + tan(x2) = 0;
 _der_x1 + der(x2) / cos(x2) ^ 2 = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + asin(x2) = 0;
 _der_x1 + der(x2) / sqrt(1 - x2 ^ 2) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + acos(x2) = 0;
 _der_x1 + (- der(x2)) / sqrt(1 - x2 ^ 2) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + atan(x2) = 0;
 _der_x1 + der(x2) / (1 + x2 ^ 2) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
 x3 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 der(x3) = time;
 x1 + atan2(x2, x3) = 0;
 _der_x1 + (der(x2) * x3 - x2 * der(x3)) / (x2 * x2 + x3 * x3) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sinh(x2) = 0;
 _der_x1 + cosh(x2) * der(x2) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + cosh(x2) = 0;
 _der_x1 + sinh(x2) * der(x2) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + tanh(x2) = 0;
 _der_x1 + der(x2) / cosh(x2) ^ 2 = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + log(x2) = 0;
 _der_x1 + der(x2) / x2 = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + log10(x2) = 0;
 _der_x1 + der(x2) / (x2 * log(10)) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sqrt(x2) = 0;
 _der_x1 + der(x2) / (2 * sqrt(x2)) = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + (if p > 3 then 3 * x2 elseif p <= 3 then sin(x2) else 2 * x2) = 0;
 _der_x1 + (if p > 3 then 3 * der(x2) elseif p <= 3 then cos(x2) * der(x2) else 2 * der(x2)) = 0.0;

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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + x2 ^ p + x2 ^ 1.4 = 0;
 _der_x1 + p * x2 ^ (p - 1) * der(x2) + 1.4 * x2 ^ 0.3999999999999999 * der(x2) = 0.0;
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
            errorMessage="
Error: in file '...':
Semantic error at line 0, column 0:
  Index reduction failed: Maximum number of differentiations reached

Error: in file '...':
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.IndexReduction24_DerFunc.f(x2) = 0;
 _der_x1 + IndexReduction.IndexReduction24_DerFunc.f_der(x2, der(x2)) = 0.0;

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
 Real _der_x2[2];
initial equation 
 x1[1] = 0.0;
 x2[1] = 0.0;
equation
 der(x1[1]) + der(x2[1]) = 1;
 _der_x2[2] = 2;
 x1[1] + IndexReduction.IndexReduction25_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}) = 0;
 der(x1[1]) + IndexReduction.IndexReduction25_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), _der_x2[2]}, {{0.0, 0.0}, {0.0, 0.0}}) = 0.0;

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
 Real _der_x2[2];
initial equation 
 x1[1] = 0.0;
 x2[1] = 0.0;
equation
 der(x1[1]) + der(x2[1]) = 1;
 _der_x2[2] = 2;
 x1[1] + IndexReduction.IndexReduction26_DerFunc.f({x2[1], x2[2]}) = 0;
 der(x1[1]) + IndexReduction.IndexReduction26_DerFunc.f_der({x2[1], x2[2]}, {der(x2[1]), _der_x2[2]}) = 0.0;

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
 Real _der_x1[1];
 Real _der_x1[2];
 Real temp_2;
 Real temp_3;
 Real _der_temp_2;
 Real _der_temp_3;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 2;
 _der_x1[2] + der(x2[2]) = 3;
 ({temp_2, temp_3}) = IndexReduction.IndexReduction27_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 - x1[1] = temp_2;
 - x1[2] = temp_3;
 ({_der_temp_2, _der_temp_3}) = IndexReduction.IndexReduction27_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}});
 - _der_x1[1] = _der_temp_2;
 - _der_x1[2] = _der_temp_3;

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
 Real x1._der_a[2];
 Real x2._der_a[2];
 Real temp_2;
 Real temp_3;
 Real _der_temp_2;
 Real _der_temp_3;
initial equation 
 x1.a[1] = 0.0;
 x2.a[1] = 0.0;
equation
 x1.der(a[1]) + x2.der(a[1]) = 2;
 x1._der_a[2] + x2._der_a[2] = 3;
 (IndexReduction.IndexReduction28_Record.R({temp_2, temp_3})) = IndexReduction.IndexReduction28_Record.f({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 - x1.a[1] = temp_2;
 - x1.a[2] = temp_3;
 (IndexReduction.IndexReduction28_Record.R({_der_temp_2, _der_temp_3})) = IndexReduction.IndexReduction28_Record.f_der({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {x2.der(a[1]), x2._der_a[2]}, {{0.0, 0.0}, {0.0, 0.0}});
 - x1.der(a[1]) = _der_temp_2;
 - x1._der_a[2] = _der_temp_3;

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
 Real _der_x;
initial equation 
 y = 0.0;
equation
 _der_x + der(y) = 0;
 x + IndexReduction.IndexReduction29_FunctionNoDerivative.F(y, x, 0, x) = 0;
 _der_x + IndexReduction.IndexReduction29_FunctionNoDerivative.der_F(y, x, 0, x, der(y), _der_x) = 0.0;

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
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vy;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 der(vx) = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 _der_der_x = der(vx);
 _der_der_y = _der_vy;
 2 * x * _der_der_x + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;

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
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vy;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 der(vx) = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 _der_der_x = der(vx);
 _der_der_y = _der_vy;
 2 * x * _der_der_x + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;

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
 Real _der_x;
 Real _der_vx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;

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
 Real _der_y;
 Real _der_vx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 vy = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StatePreferNever;
")})));
  end IndexReduction32_PlanarPendulum_StatePreferNever;

model IndexReduction32_PlanarPendulum_StateAvoidNever
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.never) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.avoid) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.avoid) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.avoid) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction32_PlanarPendulum_StateAvoidNever",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction32_PlanarPendulum_StateAvoidNever
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.never) \"Cartesian x coordinate\";
 Real y(stateSelect = StateSelect.avoid) \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.avoid) \"Velocity in x coordinate\";
 Real vy(stateSelect = StateSelect.avoid) \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_vy;
 Real _der_der_x;
 Real _der_y;
initial equation 
 y = 0.0;
 _der_y = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_x = _der_vx;
 der(_der_y) = _der_vy;
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * der(_der_y) + 2 * der(y) * der(y)) = 0.0;
 _der_y = der(y);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StateAvoidNever;
")})));
end IndexReduction32_PlanarPendulum_StateAvoidNever;

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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 (x1 + x2) / (x1 + p) = 0;
 ((_der_x1 + der(x2)) * (x1 + p) - (x1 + x2) * _der_x1) / (x1 + p) ^ 2 = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 (x1 + x2) / (p1 * p2) = 0;
 (_der_x1 + der(x2)) / (p1 * p2) = 0.0;
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
 Real _der_x;
initial equation 
 y = 0.0;
equation
 x = 2 + y;
 _der_x + der(y) = 0;
 _der_x = der(y);
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
 Real _der_x;
initial equation 
 y = 0.0;
equation
 x = 1;
 _der_x + der(y) = 0;
 _der_x = 0.0;
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
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;
 noEvent(_der_x1 + cos(x2) * der(x2)) = 0.0;
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
 Real m[1].vy \"Velocity in y coordinate\";
 Real m[1].lambda \"Lagrange multiplier\";
 Real m[1]._der_y;
 Real m[1]._der_vx;
 Real m[1]._der_vy;
 Real m[1]._der_x;
 Real m[1]._der_der_y;
initial equation 
 m[1].x = 0.0;
 m[1]._der_x = 0.0;
equation
 m[1].der(x) = m[1].vx;
 m[1]._der_y = m[1].vy;
 m[1]._der_vx = m[1].lambda * m[1].x;
 m[1]._der_vy = m[1].lambda * m[1].y - m[1].g;
 m[1].x ^ 2 + m[1].y ^ 2 = m[1].L;
 2 * m[1].x * m[1].der(x) + 2 * m[1].y * m[1]._der_y = 0.0;
 m[1].der(_der_x) = m[1]._der_vx;
 m[1]._der_der_y = m[1]._der_vy;
 2 * m[1].x * m[1].der(_der_x) + 2 * m[1].der(x) * m[1].der(x) + (2 * m[1].y * m[1]._der_der_y + 2 * m[1]._der_y * m[1]._der_y) = 0.0;
 m[1]._der_x = m[1].der(x);
end IndexReduction.IndexReduction38_ComponentArray;
")})));
end IndexReduction38_ComponentArray;
	
model IndexReduction39_MinExp
  Real x1,x2,x3;
equation
  der(x1) + der(x2) + der(x3) = 1;
  min({x1,x2}) = 0;
  min(x1,x3) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction39_MinExp",
			description="Test of index reduction. Min expression.",
			flatModel="
fclass IndexReduction.IndexReduction39_MinExp
 Real x1;
 Real x2;
 Real x3;
 Real _der_x2;
 Real _der_x3;
initial equation 
 x1 = 0.0;
equation
 der(x1) + _der_x2 + _der_x3 = 1;
 min(x1, x2) = 0;
 min(x1, x3) = 0;
 noEvent(if x1 < x2 then der(x1) else _der_x2) = 0.0;
 noEvent(if x1 < x3 then der(x1) else _der_x3) = 0.0;
end IndexReduction.IndexReduction39_MinExp;
")})));
end IndexReduction39_MinExp;

model IndexReduction40_MaxExp
  Real x1,x2,x3;
equation
  der(x1) + der(x2) + der(x3) = 1;
  max({x1,x2}) = 0;
  max(x1,x3) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction40_MaxExp",
			description="Test of index reduction. Max expression.",
			flatModel="
fclass IndexReduction.IndexReduction40_MaxExp
 Real x1;
 Real x2;
 Real x3;
 Real _der_x2;
 Real _der_x3;
initial equation 
 x1 = 0.0;
equation
 der(x1) + _der_x2 + _der_x3 = 1;
 max(x1, x2) = 0;
 max(x1, x3) = 0;
 noEvent(if x1 > x2 then der(x1) else _der_x2) = 0.0;
 noEvent(if x1 > x3 then der(x1) else _der_x3) = 0.0;
end IndexReduction.IndexReduction40_MaxExp;
")})));
end IndexReduction40_MaxExp;

model IndexReduction41_Homotopy
  //TODO: this test should be updated when the homotopy operator is fully implemented.
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  homotopy(x1,x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction41_Homotopy",
            description="Test of index reduction. Homotopy expression.",
            flatModel="
fclass IndexReduction.IndexReduction41_Homotopy
 constant Real x1 = 0;
 Real x2;
initial equation 
 x2 = 0.0;
equation
 0.0 + der(x2) = 1;
end IndexReduction.IndexReduction41_Homotopy;

")})));
end IndexReduction41_Homotopy;

model IndexReduction42_Err
  Real x1;
  Real x2;
algorithm
  x1 := x2;
equation
  der(x1) + der(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction42_Err",
            description="Test error messages for algorithms.",
			inline_functions="none",
            errorMessage="
Error: in file '...':
Semantic error at line 0, column 0:
  Cannot differentate the equation:
   algorithm
 x1 := x2;
")})));
end IndexReduction42_Err;


model IndexReduction43_Order
	function f
		input Real x;
		output Real y;
	algorithm
		y := x * x;
		y := y * x + 2 * y + 3 * x;
		annotation(derivative=df);
	end f;

    function df
        input Real x;
        input Real dx;
        output Real dy;
    algorithm
        dy := x * x;
        dy := dy + 2 * x + 3;
        annotation(derivative(order=2)=ddf);
    end df;

    function ddf
        input Real x;
        input Real dx;
        input Real ddx;
        output Real ddy;
    algorithm
        ddy := x;
        ddy := ddy + 2;
    end ddf;
	
	Real x;
    Real dx;
    Real y;
    Real dy;
equation
	der(x) = dx;
    der(y) = dy;
    der(dx) + der(dy) = 0;
	x + f(y) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction43_Order",
			description="Test use of order argument to derivative annotation",
			flatModel="
fclass IndexReduction.IndexReduction43_Order
 Real x;
 Real dx;
 Real y;
 Real dy;
 Real _der_x;
 Real _der_dx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 dy = 0.0;
equation
 _der_x = dx;
 der(y) = dy;
 _der_dx + der(dy) = 0;
 x + IndexReduction.IndexReduction43_Order.f(y) = 0;
 _der_x + IndexReduction.IndexReduction43_Order.df(y, der(y)) = 0.0;
 _der_der_x = _der_dx;
 _der_der_y = der(dy);
 _der_der_x + IndexReduction.IndexReduction43_Order.ddf(y, der(y), _der_der_y) = 0.0;

public
 function IndexReduction.IndexReduction43_Order.ddf
  input Real x;
  input Real dx;
  input Real ddx;
  output Real ddy;
algorithm
  ddy := x;
  ddy := ddy + 2;
  return;
 end IndexReduction.IndexReduction43_Order.ddf;

 function IndexReduction.IndexReduction43_Order.df
  input Real x;
  input Real dx;
  output Real dy;
algorithm
  dy := x * x;
  dy := dy + 2 * x + 3;
  return;
 end IndexReduction.IndexReduction43_Order.df;

 function IndexReduction.IndexReduction43_Order.f
  input Real x;
  output Real y;
algorithm
  y := x * x;
  y := y * x + 2 * y + 3 * x;
  return;
 end IndexReduction.IndexReduction43_Order.f;

end IndexReduction.IndexReduction43_Order;
")})));
end IndexReduction43_Order;


model IndexReduction44_Order2Arg
    function f
        input Real x1;
        input Real x2;
        output Real y;
    algorithm
        y := x1 * x1;
        y := y * x2;
        annotation(derivative=df);
    end f;

    function df
        input Real x1;
        input Real x2;
        input Real dx1;
        input Real dx2;
        output Real dy;
    algorithm
        dy := x1 * x1;
        dy := y * x2;
        annotation(derivative(order=2)=ddf);
    end df;

    function ddf
        input Real x1;
        input Real x2;
        input Real dx1;
        input Real dx2;
        input Real ddx1;
        input Real ddx2;
        output Real ddy;
    algorithm
        ddy := x1 * x1;
        ddy := y * x2;
    end ddf;
    
    Real x;
    Real dx;
    Real y;
    Real dy;
equation
    der(x) = dx;
    der(y) = dy;
    der(dx) + der(dy) = 0;
    x + f(y, time) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction44_Order2Arg",
			description="Test use of order argument to derivative annotation for function with two arguments",
			flatModel="
fclass IndexReduction.IndexReduction44_Order2Arg
 Real x;
 Real dx;
 Real y;
 Real dy;
 Real _der_x;
 Real _der_dx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 dy = 0.0;
equation
 _der_x = dx;
 der(y) = dy;
 _der_dx + der(dy) = 0;
 x + IndexReduction.IndexReduction44_Order2Arg.f(y, time) = 0;
 _der_x + IndexReduction.IndexReduction44_Order2Arg.df(y, time, der(y), 1.0) = 0.0;
 _der_der_x = _der_dx;
 _der_der_y = der(dy);
 _der_der_x + IndexReduction.IndexReduction44_Order2Arg.ddf(y, time, der(y), 1.0, _der_der_y, 0.0) = 0.0;

public
 function IndexReduction.IndexReduction44_Order2Arg.ddf
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  input Real ddx1;
  input Real ddx2;
  output Real ddy;
algorithm
  ddy := x1 * x1;
  ddy := y * x2;
  return;
 end IndexReduction.IndexReduction44_Order2Arg.ddf;

 function IndexReduction.IndexReduction44_Order2Arg.df
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  output Real dy;
algorithm
  dy := x1 * x1;
  dy := y * x2;
  return;
 end IndexReduction.IndexReduction44_Order2Arg.df;

 function IndexReduction.IndexReduction44_Order2Arg.f
  input Real x1;
  input Real x2;
  output Real y;
algorithm
  y := x1 * x1;
  y := y * x2;
  return;
 end IndexReduction.IndexReduction44_Order2Arg.f;

end IndexReduction.IndexReduction44_Order2Arg;
")})));
end IndexReduction44_Order2Arg;

model IndexReduction45_DotAdd
  Real x1[2],x2[2];
equation
  der(x1) .+ der(x2) = {1,1};
 x1 .+ x2 = {0,0};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction45_DotAdd",
			description="Test of index reduction",
			flatModel="
fclass IndexReduction.IndexReduction45_DotAdd
 Real x1[1];
 Real x1[2];
initial equation 
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ (- der(x1[1])) = 1;
 der(x1[2]) .+ (- der(x1[2])) = 1;
end IndexReduction.IndexReduction45_DotAdd;
")})));
end IndexReduction45_DotAdd;

model IndexReduction46_DotSub
  Real x1[2],x2[2];
equation
  der(x1) .+ der(x2) = {1,1};
 x1 .- x2 = {0,0};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction46_DotSub",
			description="Test of index reduction",
			flatModel="
fclass IndexReduction.IndexReduction46_DotSub
 Real x1[1];
 Real x1[2];
initial equation 
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ der(x1[1]) = 1;
 der(x1[2]) .+ der(x1[2]) = 1;
end IndexReduction.IndexReduction46_DotSub;
")})));
end IndexReduction46_DotSub;

model IndexReduction47_DotMul
  Real x1[2],x2[2];
equation
  der(x1) .+ der(x2) = {1,1};
 x1 .* x2 = {0,0};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction47_DotMul",
			description="Test of index reduction",
			flatModel="
fclass IndexReduction.IndexReduction47_DotMul
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x2[1];
 Real _der_x2[2];
initial equation 
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ _der_x2[1] = 1;
 der(x1[2]) .+ _der_x2[2] = 1;
 x1[1] .* x2[1] = 0;
 x1[2] .* x2[2] = 0;
 x1[1] .* _der_x2[1] .+ der(x1[1]) .* x2[1] = 0.0;
 x1[2] .* _der_x2[2] .+ der(x1[2]) .* x2[2] = 0.0;
end IndexReduction.IndexReduction47_DotMul;
")})));
end IndexReduction47_DotMul;

model IndexReduction48_DotDiv
  Real x1[2],x2[2];
equation
  der(x1) .+ der(x2) = {1,1};
 x1 ./ x2 = {0,0};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction48_DotDiv",
			description="Test of index reduction",
			flatModel="
fclass IndexReduction.IndexReduction48_DotDiv
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] ./ x2[1] = 0;
 x1[2] ./ x2[2] = 0;
 (_der_x1[1] .* x2[1] .- x1[1] .* der(x2[1])) ./ x2[1] .^ 2 = 0.0;
 (_der_x1[2] .* x2[2] .- x1[2] .* der(x2[2])) ./ x2[2] .^ 2 = 0.0;
end IndexReduction.IndexReduction48_DotDiv;
")})));
end IndexReduction48_DotDiv;

model IndexReduction49_DotPow
  Real x1[2],x2[2];
equation
  der(x1) .+ der(x2) = {1,1};
 x1 .^ x2 = {0,0};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction49_DotPow",
			description="Test of index reduction",
			flatModel="
fclass IndexReduction.IndexReduction49_DotPow
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] .^ x2[1] = 0;
 x1[2] .^ x2[2] = 0;
 x2[1] .* x1[1] .^ (x2[1] .- 1) .* _der_x1[1] = 0.0;
 x2[2] .* x1[2] .^ (x2[2] .- 1) .* _der_x1[2] = 0.0;
end IndexReduction.IndexReduction49_DotPow;
")})));
end IndexReduction49_DotPow;

model DivFunc
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + div(x2, 3.14) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DivFunc",
            description="Test differentiation of div() operator. This model probably makes no sence in the real world!",
            flatModel="
fclass IndexReduction.DivFunc
 Real x1;
 Real x2;
 discrete Real temp_1;
 Real _der_x1;
initial equation 
 pre(temp_1) = 0.0;
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + temp_1 = 1;
 temp_1 = if div(x2, 3.14) < pre(temp_1) or div(x2, 3.14) >= pre(temp_1) + 1 or initial() then div(x2, 3.14) else pre(temp_1);
 _der_x1 = 0.0;
end IndexReduction.DivFunc;
")})));
end DivFunc;

model IndexReduction50
	parameter StateSelect c1_ss = StateSelect.default; 
	parameter StateSelect c2_ss = StateSelect.never; 
	parameter Real p = 0;
	Real c1_phi(stateSelect=c1_ss), c1_w(stateSelect=c1_ss), c1_a;
	Real c2_phi(stateSelect=c2_ss), c2_w(stateSelect=c2_ss), c2_a;
equation
	c1_phi = c2_phi;
	c1_w = der(c1_phi);
	c1_a = der(c1_w);
	c2_w = der(c1_phi);
	c2_a = der(c2_w);
	c2_a * p = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction50",
			description="Test of index reduction of differentiated variables with StateSelect.never",
			flatModel="
fclass IndexReduction.IndexReduction50
 parameter StateSelect c1_ss = StateSelect.default /* StateSelect.default */;
 parameter StateSelect c2_ss = StateSelect.never /* StateSelect.never */;
 parameter Real p = 0 /* 0 */;
 Real c1_phi(stateSelect = c2_ss);
 Real c1_w(stateSelect = c1_ss);
 Real c1_a;
 Real c2_w(stateSelect = c2_ss);
 Real c2_a;
 Real _der_c2_w;
 Real _der_der_c1_phi;
initial equation 
 c1_phi = 0.0;
 c1_w = 0.0;
equation
 c1_w = der(c1_phi);
 c1_a = der(c1_w);
 c2_w = der(c1_phi);
 c2_a = _der_c2_w;
 c2_a * p = 0;
 der(c1_w) = _der_der_c1_phi;
 _der_c2_w = _der_der_c1_phi;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction50;
")})));
end IndexReduction50;

model IndexReduction51
    parameter StateSelect c1_ss = StateSelect.default; 
    parameter StateSelect c2_ss = StateSelect.never; 
    parameter Real p = 0;
    Real c1_phi, c1_w(stateSelect=c1_ss), c1_a;
    Real c2_phi, c2_w(stateSelect=c2_ss), c2_a;
    Real x(start = 2);
    Real y;
equation
    y = 0 * time;
    c1_phi = x - y;
    c1_phi = c2_phi;
    c1_w = der(c1_phi);
    c1_a = der(c1_w);
    c2_w = der(c2_phi);
    c2_a = der(c2_w);
    c2_a * p = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction51",
            description="Test of complicated index reduction, alias elimination, expression simplification and variability propagation issue",
            flatModel="
fclass IndexReduction.IndexReduction51
 parameter StateSelect c1_ss = StateSelect.default /* StateSelect.default */;
 parameter StateSelect c2_ss = StateSelect.never /* StateSelect.never */;
 parameter Real p = 0 /* 0 */;
 Real c1_w(stateSelect = c1_ss);
 Real c1_a;
 Real c2_w(stateSelect = c2_ss);
 Real c2_a;
 Real x(start = 2);
 constant Real y = 0;
 Real _der_c2_w;
 Real _der_der_c1_phi;
initial equation 
 x = 2;
 c1_w = 0.0;
equation
 c1_w = der(x);
 c1_a = der(c1_w);
 c2_w = der(x);
 c2_a = _der_c2_w;
 c2_a * p = 0;
 der(c1_w) = _der_der_c1_phi;
 _der_c2_w = _der_der_c1_phi;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction51;
")})));
end IndexReduction51;

model IndexReduction52
    function F
        input Real v;
        input Real x;
        input Real y;
        input Real z;
        output Real ax;
        output Real ay;
    algorithm
        ax := v * z + x;
        ay := v * z + y;
    end F;
    Real x;
    Real y;
    Real dx;
    Real dy;
    Real v, a,b;
  equation
    sin(der(x)) = dx;
    cos(der(y)) = dy;
    der(dx) = v * x;
    der(dy) = v * y;
    a*b = 1;
    (a,b) = F(x + 3.14, 42, y, time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction52",
            description="Test of complicated index reduction, alias elimination and function inlining. temp_1 and _der_temp_1 is the smoking gun in this test",
            flatModel="
fclass IndexReduction.IndexReduction52
 Real x;
 Real y;
 Real dx;
 Real dy;
 Real v;
 Real a;
 Real b;
 Real _der_x;
 Real _der_dx;
 Real _der_dy;
 Real _der_a;
 Real _der_b;
 Real _der_der_x;
 Real _der_y;
 Real _der_der_a;
 Real _der_der_b;
 Real temp_1;
 Real temp_4;
 Real _der_temp_1;
 Real _der_temp_4;
 Real _der_der_temp_1;
 Real _der_der_temp_4;
initial equation 
 y = 0.0;
 _der_y = 0.0;
equation
 sin(_der_x) = dx;
 cos(der(y)) = dy;
 _der_dx = v * x;
 _der_dy = v * y;
 a * b = 1;
 a = temp_1 * temp_4 + 42;
 b = temp_1 * temp_4 + y;
 temp_1 = x + 3.14;
 temp_4 = time;
 a * _der_b + _der_a * b = 0.0;
 _der_a = temp_1 * _der_temp_4 + _der_temp_1 * temp_4;
 _der_b = temp_1 * _der_temp_4 + _der_temp_1 * temp_4 + der(y);
 _der_temp_1 = _der_x;
 _der_temp_4 = 1.0;
 cos(_der_x) * _der_der_x = _der_dx;
 - sin(der(y)) * der(_der_y) = _der_dy;
 a * _der_der_b + _der_a * _der_b + (_der_a * _der_b + _der_der_a * b) = 0.0;
 _der_der_a = temp_1 * _der_der_temp_4 + _der_temp_1 * _der_temp_4 + (_der_temp_1 * _der_temp_4 + _der_der_temp_1 * temp_4);
 _der_der_b = temp_1 * _der_der_temp_4 + _der_temp_1 * _der_temp_4 + (_der_temp_1 * _der_temp_4 + _der_der_temp_1 * temp_4) + der(_der_y);
 _der_der_temp_1 = _der_der_x;
 _der_der_temp_4 = 0.0;
 _der_y = der(y);
end IndexReduction.IndexReduction52;
")})));
end IndexReduction52;

model IndexReduction55
    Real a_s;
    Real a_v(stateSelect = StateSelect.always);
    Real a_a;
    Real b_s;
    Real b_v;
    Real v1;
equation
    b_s = a_s - 3.14;
    a_v = der(a_s);
    a_a = der(a_v);
    b_v = b_s;
    v1 = 42 * (b_s - 3.14);
    21 = v1 * b_v;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction55",
            description="Test of indexreduction with SS always",
            flatModel="
fclass IndexReduction.IndexReduction55
 Real a_s;
 Real a_v(stateSelect = StateSelect.always);
 Real a_a;
 Real b_v;
 Real v1;
 Real _der_a_s;
 Real _der_a_v;
 Real _der_b_v;
 Real _der_v1;
 Real _der_der_a_s;
 Real _der_der_b_v;
 Real _der_der_v1;
equation
 b_v = a_s - 3.14;
 a_v = _der_a_s;
 a_a = _der_a_v;
 v1 = 42 * (b_v - 3.14);
 21 = v1 * b_v;
 _der_b_v = _der_a_s;
 _der_v1 = 42 * _der_b_v;
 0.0 = v1 * _der_b_v + _der_v1 * b_v;
 _der_a_v = _der_der_a_s;
 _der_der_b_v = _der_der_a_s;
 _der_der_v1 = 42 * _der_der_b_v;
 0.0 = v1 * _der_der_b_v + _der_v1 * _der_b_v + (_der_v1 * _der_b_v + _der_der_v1 * b_v);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction55;
")})));
end IndexReduction55;

model IndexReduction56
    Real a_s(stateSelect = StateSelect.always);
    Real a_v;
    Real a_a;
    Real b_s;
    Real b_v;
    Real v1;
equation
    b_s = a_s - 3.14;
    a_v = der(a_s);
    a_a = der(a_v);
    b_v = b_s;
    v1 = 42 * (b_s - 3.14);
    21 = v1 * b_v;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction56",
            description="Test of indexreduction with SS always",
            flatModel="
fclass IndexReduction.IndexReduction56
 Real a_s(stateSelect = StateSelect.always);
 Real a_v;
 Real a_a;
 Real b_v;
 Real v1;
 Real _der_a_s;
 Real _der_a_v;
 Real _der_b_v;
 Real _der_v1;
 Real _der_der_a_s;
 Real _der_der_b_v;
 Real _der_der_v1;
equation
 b_v = a_s - 3.14;
 a_v = _der_a_s;
 a_a = _der_a_v;
 v1 = 42 * (b_v - 3.14);
 21 = v1 * b_v;
 _der_b_v = _der_a_s;
 _der_v1 = 42 * _der_b_v;
 0.0 = v1 * _der_b_v + _der_v1 * b_v;
 _der_a_v = _der_der_a_s;
 _der_der_b_v = _der_der_a_s;
 _der_der_v1 = 42 * _der_der_b_v;
 0.0 = v1 * _der_der_b_v + _der_v1 * _der_b_v + (_der_v1 * _der_b_v + _der_der_v1 * b_v);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction56;
")})));
end IndexReduction56;

model IndexReduction57
    Real a_s;
    Real a_v(stateSelect = StateSelect.always);
    Real a_a;
    Real b_s;
    Real b_v;
    Real v1;
equation
    b_s = a_s - 3.14;
    a_v = der(a_s);
    a_a = der(a_v);
    b_v = b_s;
    v1 = 42 * (b_s - 3.14);
    21 = v1 * b_v;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="IndexReduction57",
            description="Test warnings for state select.",
            automatic_tearing=false,
            errorMessage="
3 warnings found:

Warning: in file '...':
At line 0, column 0:
  Iteration variable \"b_v\" is missing start value!

Warning: in file '...':
At line 0, column 0:
  Iteration variable \"v1\" is missing start value!

Warning: in file '...':
At line 0, column 0:
  a_v has stateSelect=always, but could not be selected as state
")})));
end IndexReduction57;

package AlgorithmDifferentiation

model Simple
  function F
    input Real x;
    output Real y;
  algorithm
    y := sin(x);
    annotation(Inline=false, smoothOrder=1);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_Simple",
            description="Test differentiation of simple function",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.Simple
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.Simple.F(x2) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.Simple._der_F(x2, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.Simple.F
  input Real x;
  output Real y;
 algorithm
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.Simple.F;

 function IndexReduction.AlgorithmDifferentiation.Simple._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.Simple._der_F;

end IndexReduction.AlgorithmDifferentiation.Simple;
")})));
end Simple;

model For
  function F
    input Real x;
    output Real y;
    output Real c = 0;
  algorithm
    for i in 1:10 loop
        if i > x then
            break;
        end if;
        c := c + 0.5;
    end for;
    y := sin(x);
    annotation(Inline=false, smoothOrder=1);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_For",
            description="Test differentiation of function with for statement",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.For
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.For.F(x2) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.For._der_F(x2, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.For.F
  input Real x;
  output Real y;
  output Real c;
 algorithm
  c := 0;
  for i in 1:10 loop
   if i > x then
    break;
   end if;
   c := c + 0.5;
  end for;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.For.F;

 function IndexReduction.AlgorithmDifferentiation.For._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0.0;
  c := 0;
  for i in 1:10 loop
   if i > x then
    break;
   end if;
   _der_c := _der_c;
   c := c + 0.5;
  end for;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.For._der_F;

end IndexReduction.AlgorithmDifferentiation.For;
")})));
end For;

model FunctionCall
  function F1
    input Real x1;
    input Real x2;
    output Real y;
    Real a;
    Real b;
  algorithm
    (a, b) := F2(x1, x2);
    y := a + b;
    annotation(Inline=false, smoothOrder=1);
  end F1;
  function F2
    input Real x1;
    input Real x2;
    output Real a = x1;
    output Real b = sin(x2);
  algorithm
  end F2;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  F1(x1, x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_FunctionCall",
            description="Test differentiation of function with function call statement",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.FunctionCall
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 IndexReduction.AlgorithmDifferentiation.FunctionCall.F1(x1, x2) = 1;
 IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F1(x1, x2, _der_x1, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.FunctionCall.F1
  input Real x1;
  input Real x2;
  output Real y;
  Real a;
  Real b;
 algorithm
  (a, b) := IndexReduction.AlgorithmDifferentiation.FunctionCall.F2(x1, x2);
  y := a + b;
  return;
 end IndexReduction.AlgorithmDifferentiation.FunctionCall.F1;

 function IndexReduction.AlgorithmDifferentiation.FunctionCall.F2
  input Real x1;
  input Real x2;
  output Real a;
  output Real b;
 algorithm
  a := x1;
  b := sin(x2);
  return;
 end IndexReduction.AlgorithmDifferentiation.FunctionCall.F2;

 function IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F1
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_y;
  Real y;
  Real a;
  Real _der_a;
  Real b;
  Real _der_b;
 algorithm
  (_der_a, _der_b) := IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F2(x1, x2, _der_x1, _der_x2);
  (a, b) := IndexReduction.AlgorithmDifferentiation.FunctionCall.F2(x1, x2);
  _der_y := _der_a + _der_b;
  y := a + b;
  return;
 end IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F1;

 function IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F2
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_a;
  output Real _der_b;
  Real a;
  Real b;
 algorithm
  _der_a := _der_x1;
  a := x1;
  _der_b := cos(x2) * _der_x2;
  b := sin(x2);
  return;
 end IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F2;

end IndexReduction.AlgorithmDifferentiation.FunctionCall;
")})));
end FunctionCall;

model If
  function F
    input Real x;
    output Real y;
    output Real b;
  algorithm
    if 10 > x then
        b := 1;
    else
        b := 2;
    end if;
    y := sin(x);
    annotation(Inline=false, smoothOrder=1);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_If",
            description="Test differentiation of function with if statement",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.If
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.If.F(x2) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.If._der_F(x2, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.If.F
  input Real x;
  output Real y;
  output Real b;
 algorithm
  if 10 > x then
   b := 1;
  else
   b := 2;
  end if;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.If.F;

 function IndexReduction.AlgorithmDifferentiation.If._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_b;
  Real y;
  Real b;
 algorithm
  if 10 > x then
   _der_b := 0.0;
   b := 1;
  else
   _der_b := 0.0;
   b := 2;
  end if;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.If._der_F;

end IndexReduction.AlgorithmDifferentiation.If;
")})));
end If;

model InitArray
    function F
        input Real[:] x;
        output Real y;
        Real[:] a = x .^ 2;
    algorithm
        y := a[1];
        annotation(Inline=false, smoothOrder=3);
    end F;
    Real x1;
    Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F({x2}) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_InitArray",
            description="Test differentiation of function with initial array statement",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.InitArray
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.InitArray.F({x2}) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.InitArray._der_F({x2}, {der(x2)}) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.InitArray.F
  input Real[:] x;
  output Real y;
  Real[:] a;
 algorithm
  size(a) := {size(x, 1)};
  for i1 in 1:size(x, 1) loop
   a[i1] := x[i1] .^ 2;
  end for;
  y := a[1];
  return;
 end IndexReduction.AlgorithmDifferentiation.InitArray.F;

 function IndexReduction.AlgorithmDifferentiation.InitArray._der_F
  input Real[:] x;
  input Real[:] _der_x;
  output Real _der_y;
  Real y;
  Real[:] a;
  Real[:] _der_a;
 algorithm
  size(a) := {size(x, 1)};
  size(_der_a) := {size(x, 1)};
  for i1 in 1:size(x, 1) loop
   _der_a[i1] := 2 .* x[i1] .* _der_x[i1];
   a[i1] := x[i1] .^ 2;
  end for;
  _der_y := _der_a[1];
  y := a[1];
  return;
 end IndexReduction.AlgorithmDifferentiation.InitArray._der_F;

end IndexReduction.AlgorithmDifferentiation.InitArray;
")})));
end InitArray;

model While
  function F
    input Real x;
    output Real y;
    output Real c = 0;
  algorithm
    while c < x loop
        c := c + 0.5;
    end while;
    y := sin(x);
    annotation(Inline=false, smoothOrder=1);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_While",
            description="Test differentiation of function with while statement",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.While
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.While.F(x2) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.While._der_F(x2, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.While.F
  input Real x;
  output Real y;
  output Real c;
 algorithm
  c := 0;
  while c < x loop
   c := c + 0.5;
  end while;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.While.F;

 function IndexReduction.AlgorithmDifferentiation.While._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0.0;
  c := 0;
  while c < x loop
   _der_c := _der_c;
   c := c + 0.5;
  end while;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.While._der_F;

end IndexReduction.AlgorithmDifferentiation.While;
")})));
end While;

model Recursive
  function F1
    input Real x1;
    input Real x2;
    output Real y;
    Real a;
    Real b;
  algorithm
    (a, b) := F2(x1, x2, 0);
    y := a + b;
    annotation(Inline=false, smoothOrder=1);
  end F1;
  function F2
    input Real x1;
    input Real x2;
    input Integer c;
    output Real a;
    output Real b;
  algorithm
    if c < 10 then
        (a, b) := F2(x1, x2, c + 1);
    else
        a := x1;
        b := sin(x2);
    end if;
  end F2;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  F1(x1, x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_Recursive",
            description="Test differentiation of Recursive function",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.Recursive
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 IndexReduction.AlgorithmDifferentiation.Recursive.F1(x1, x2) = 1;
 IndexReduction.AlgorithmDifferentiation.Recursive._der_F1(x1, x2, _der_x1, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.Recursive.F1
  input Real x1;
  input Real x2;
  output Real y;
  Real a;
  Real b;
 algorithm
  (a, b) := IndexReduction.AlgorithmDifferentiation.Recursive.F2(x1, x2, 0);
  y := a + b;
  return;
 end IndexReduction.AlgorithmDifferentiation.Recursive.F1;

 function IndexReduction.AlgorithmDifferentiation.Recursive.F2
  input Real x1;
  input Real x2;
  input Integer c;
  output Real a;
  output Real b;
 algorithm
  if c < 10 then
   (a, b) := IndexReduction.AlgorithmDifferentiation.Recursive.F2(x1, x2, c + 1);
  else
   a := x1;
   b := sin(x2);
  end if;
  return;
 end IndexReduction.AlgorithmDifferentiation.Recursive.F2;

 function IndexReduction.AlgorithmDifferentiation.Recursive._der_F1
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_y;
  Real y;
  Real a;
  Real _der_a;
  Real b;
  Real _der_b;
 algorithm
  (_der_a, _der_b) := IndexReduction.AlgorithmDifferentiation.Recursive._der_F2(x1, x2, 0, _der_x1, _der_x2);
  (a, b) := IndexReduction.AlgorithmDifferentiation.Recursive.F2(x1, x2, 0);
  _der_y := _der_a + _der_b;
  y := a + b;
  return;
 end IndexReduction.AlgorithmDifferentiation.Recursive._der_F1;

 function IndexReduction.AlgorithmDifferentiation.Recursive._der_F2
  input Real x1;
  input Real x2;
  input Integer c;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_a;
  output Real _der_b;
  Real a;
  Real b;
 algorithm
  if c < 10 then
   (_der_a, _der_b) := IndexReduction.AlgorithmDifferentiation.Recursive._der_F2(x1, x2, c + 1, _der_x1, _der_x2);
   (a, b) := IndexReduction.AlgorithmDifferentiation.Recursive.F2(x1, x2, c + 1);
  else
   _der_a := _der_x1;
   a := x1;
   _der_b := cos(x2) * _der_x2;
   b := sin(x2);
  end if;
  return;
 end IndexReduction.AlgorithmDifferentiation.Recursive._der_F2;

end IndexReduction.AlgorithmDifferentiation.Recursive;
")})));
end Recursive;

model DiscreteComponents
  function F
    input Real x;
    output Real y;
    output Integer c = 0;
  algorithm
    c := if x > 23 then 2 else -2;
    c := c + 23;
    y := sin(x);
    annotation(Inline=false, smoothOrder=1);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_DiscreteComponents",
            description="Test differentiation of function with discrete components",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.DiscreteComponents
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.DiscreteComponents.F(x2) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.DiscreteComponents._der_F(x2, der(x2)) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.DiscreteComponents.F
  input Real x;
  output Real y;
  output Integer c;
 algorithm
  c := 0;
  c := if x > 23 then 2 else - 2;
  c := c + 23;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.DiscreteComponents.F;

 function IndexReduction.AlgorithmDifferentiation.DiscreteComponents._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
  Integer c;
 algorithm
  c := 0;
  c := if x > 23 then 2 else - 2;
  c := c + 23;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 end IndexReduction.AlgorithmDifferentiation.DiscreteComponents._der_F;

end IndexReduction.AlgorithmDifferentiation.DiscreteComponents;
")})));
end DiscreteComponents;

model PlanarPendulum
    function square
        input Real x;
        output Real y;
    algorithm
        y := x ^ 2;
        annotation(Inline=false, smoothOrder=2);
    end square;
  
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
    square(x) + square(y) = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_PlanarPendulum",
            description="Test differentiation of simple function twice",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vy;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 der(vx) = lambda * x;
 _der_vy = lambda * y - g;
 IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square(x) + IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square(y) = L;
 IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square(x, der(x)) + IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square(y, _der_y) = 0.0;
 _der_der_x = der(vx);
 _der_der_y = _der_vy;
 IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square(x, der(x), _der_der_x) + IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square(y, _der_y, _der_der_y) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 end IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square;

 function IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := 2 * x * _der_x;
  y := x ^ 2;
  return;
 end IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square;

 function IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square
  input Real x;
  input Real _der_x;
  input Real _der_der_x;
  output Real _der_der_y;
  Real _der_y;
  Real y;
 algorithm
  _der_der_y := 2 * x * _der_der_x + 2 * _der_x * _der_x;
  _der_y := 2 * x * _der_x;
  y := x ^ 2;
  return;
 end IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square;

end IndexReduction.AlgorithmDifferentiation.PlanarPendulum;
")})));
  end PlanarPendulum;

model SelfReference_AssignStmt
    function F
        input Real x;
        output Real y;
    algorithm
        y := x * x;
        y := y * x;
        annotation(smoothOrder=1);
    end F;
    Real a = F(time * 2);
    Real b = der(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_SelfReference_AssignStmt",
            description="Test differentiation of statements with lsh variable in rhs",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt
 Real a;
 Real b;
 Real _der_a;
equation
 a = IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt.F(time * 2);
 b = _der_a;
 _der_a = IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F(time * 2, 2);

public
 function IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt.F
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  y := y * x;
  return;
 end IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt.F;

 function IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := x * _der_x + _der_x * x;
  y := x * x;
  _der_y := y * _der_x + _der_y * x;
  y := y * x;
  return;
 end IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F;

end IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt;
")})));
end SelfReference_AssignStmt;

model SelfReference_FunctionCall
    function F1
        input Real x;
        output Real y;
    algorithm
        (,y) := F2(x);
        (,y) := F2(y);
        annotation(smoothOrder=1);
    end F1;
    function F2
        input Real x;
        output Real y;
        output Real z;
    algorithm
        y := 42;
        z := x * x;
        z := z * x;
        annotation(smoothOrder=1);
    end F2;
    Real a = F1(time * 2);
    Real b = der(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_SelfReference_FunctionCall",
            description="Test differentiation of statements with lsh variable in rhs",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall
 Real a;
 Real b;
 Real _der_a;
equation
 a = IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F1(time * 2);
 b = _der_a;
 _der_a = IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1(time * 2, 2);

public
 function IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F1
  input Real x;
  output Real y;
 algorithm
  (, y) := IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(x);
  (, y) := IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(y);
  return;
 end IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F1;

 function IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F2
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := 42;
  z := x * x;
  z := z * x;
  return;
 end IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F2;

 function IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  (, _der_y) := IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2(x, _der_x);
  (, y) := IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(x);
  (, _der_y) := IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2(y, _der_y);
  (, y) := IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(y);
  return;
 end IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1;

 function IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := 0.0;
  y := 42;
  _der_z := x * _der_x + _der_x * x;
  z := x * x;
  _der_z := z * _der_x + _der_z * x;
  z := z * x;
  return;
 end IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2;

end IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall;
")})));
end SelfReference_FunctionCall;

end AlgorithmDifferentiation;

  model AlgorithmVariability1
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
    Integer i;
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
algorithm
    if y < 3.12 then
        i := 1;
    else
        i := -1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmVariability1",
            description="Test so that variability calculations are done propperly for algorithms",
            flatModel="
fclass IndexReduction.AlgorithmVariability1
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 discrete Integer i;
 Real _der_y;
 Real _der_vx;
 Real _der_vy;
 Real _der_x;
 Real _der_der_y;
initial equation 
 x = 0.0;
 _der_x = 0.0;
 pre(i) = 0;
equation
 der(x) = vx;
 _der_y = vy;
 _der_vx = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
algorithm
 if y < 3.12 then
  i := 1;
 else
  i := - 1;
 end if;
equation
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 der(_der_x) = _der_vx;
 _der_der_y = _der_vy;
 2 * x * der(_der_x) + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;
 _der_x = der(x);
end IndexReduction.AlgorithmVariability1;
")})));
  end AlgorithmVariability1;

end IndexReduction;
