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
 Modelica.Blocks.Interfaces.RealInput torque.tau(unit = \"N.m\") \"Accelerating torque acting at flange (= -flange.tau)\";
 structural parameter Boolean torque.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 parameter Modelica.SIunits.MomentOfInertia inertia1.J(min = 0,start = 1) \"Moment of inertia\";
 parameter Real idealGear.ratio(start = 1) \"Transmission ratio (flange_a.phi/flange_b.phi)\";
 parameter StateSelect inertia1.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia1.phi(stateSelect = inertia1.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia1.w(stateSelect = inertia1.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia1.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.MomentOfInertia inertia3.J(min = 0,start = 1) \"Moment of inertia\";
 Modelica.SIunits.Angle idealGear.phi_a \"Angle between left shaft flange and support\";
 Modelica.SIunits.Angle idealGear.phi_b \"Angle between right shaft flange and support\";
 structural parameter Boolean idealGear.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
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
 Modelica.SIunits.Torque spring.tau \"Torque between flanges (= flange_b.tau)\";
 constant Modelica.SIunits.Torque inertia3.flange_b.tau = 0 \"Cut torque in the flange\";
 parameter Modelica.SIunits.RotationalDampingConstant damper.d(final min = 0,start = 0) \"Damping constant\";
 parameter StateSelect inertia3.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia3.phi(stateSelect = inertia3.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia3.w(fixed = true,start = 0,stateSelect = inertia3.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia3.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Real sine.amplitude \"Amplitude of sine wave\";
 Modelica.SIunits.Angle damper.phi_rel(stateSelect = StateSelect.always,start = 0,nominal = if damper.phi_nominal >= 1.0E-15 then damper.phi_nominal else 1) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.AngularVelocity damper.w_rel(stateSelect = StateSelect.always,start = 0) \"Relative angular velocity (= der(phi_rel))\";
 Modelica.SIunits.AngularAcceleration damper.a_rel(start = 0) \"Relative angular acceleration (= der(w_rel))\";
 Modelica.SIunits.Torque damper.tau \"Torque between flanges (= flange_b.tau)\";
 parameter Modelica.SIunits.Angle damper.phi_nominal(displayUnit = \"rad\",min = 0.0) = 1.0E-4 \"Nominal value of phi_rel (used for scaling)\" /* 1.0E-4 */;
 parameter StateSelect damper.stateSelect = StateSelect.prefer \"Priority to use phi_rel and w_rel as states\" /* StateSelect.prefer */;
 structural parameter Boolean damper.useHeatPort = false \"=true, if heatPort is enabled\" /* false */;
 Modelica.SIunits.Power damper.lossPower \"Loss power leaving component via heatPort (> 0, if heat is flowing out of component)\";
 parameter Modelica.SIunits.Frequency sine.freqHz(start = 1) \"Frequency of sine wave\";
 parameter Modelica.SIunits.Angle torque.phi_support \"Absolute angle of support flange\";
 parameter Modelica.SIunits.Angle sine.phase = 0 \"Phase of sine wave\" /* 0 */;
 parameter Real sine.offset = 0 \"Offset of output signal\" /* 0 */;
 parameter Modelica.SIunits.Time sine.startTime = 0 \"Output = offset for time < startTime\" /* 0 */;
 constant Real sine.pi = 3.141592653589793;
 parameter Modelica.SIunits.Angle damper.flange_b.phi \"Absolute rotation angle of flange\";
 parameter Modelica.SIunits.Angle fixed.flange.phi \"Absolute rotation angle of flange\";
 parameter Modelica.SIunits.Angle idealGear.support.phi \"Absolute rotation angle of the support/housing\";
 parameter Modelica.SIunits.Angle torque.support.phi \"Absolute rotation angle of the support/housing\";
 parameter Modelica.SIunits.Angle idealGear.phi_support \"Absolute angle of support flange\";
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
 torque.phi_support = fixed.phi0;
 damper.flange_b.phi = torque.phi_support;
 fixed.flange.phi = torque.phi_support;
 idealGear.support.phi = torque.phi_support;
 torque.support.phi = torque.phi_support;
 idealGear.phi_support = torque.phi_support;
equation
 inertia1.w = inertia1._der_phi;
 inertia1.a = inertia1._der_w;
 inertia1.J * inertia1.a = torque.tau + (- idealGear.flange_a.tau);
 idealGear.phi_a = inertia1.phi - torque.phi_support;
 idealGear.phi_b = inertia2.phi - torque.phi_support;
 idealGear.phi_a = idealGear.ratio * idealGear.phi_b;
 0 = idealGear.ratio * idealGear.flange_a.tau + idealGear.flange_b.tau;
 inertia2.w = inertia2._der_phi;
 inertia2.a = inertia2._der_w;
 inertia2.J * inertia2.a = - idealGear.flange_b.tau + inertia2.flange_b.tau;
 spring.tau = spring.c * (spring.phi_rel - spring.phi_rel0);
 spring.phi_rel = inertia3.phi - inertia2.phi;
 inertia3.w = der(inertia3.phi);
 inertia3.a = der(inertia3.w);
 inertia3.J * inertia3.a = - spring.tau;
 damper.tau = damper.d * damper.w_rel;
 damper.lossPower = damper.tau * damper.w_rel;
 damper.phi_rel = torque.phi_support - inertia2.phi;
 damper.w_rel = der(damper.phi_rel);
 damper.a_rel = der(damper.w_rel);
 torque.tau = sine.offset + (if time < sine.startTime then 0 else sine.amplitude * sin(6.283185307179586 * sine.freqHz * (time - sine.startTime) + sine.phase));
 - damper.tau + inertia2.flange_b.tau + (- spring.tau) = 0;
 damper.tau + fixed.flange.tau + idealGear.support.tau + torque.tau = 0;
 idealGear.support.tau = - idealGear.flange_a.tau - idealGear.flange_b.tau;
 idealGear._der_phi_a = inertia1._der_phi;
 idealGear._der_phi_b = inertia2._der_phi;
 idealGear._der_phi_a = idealGear.ratio * idealGear._der_phi_b;
 inertia1._der_w = inertia1._der_der_phi;
 inertia2._der_w = inertia2._der_der_phi;
 idealGear._der_der_phi_a = inertia1._der_der_phi;
 idealGear._der_der_phi_b = inertia2._der_der_phi;
 idealGear._der_der_phi_a = idealGear.ratio * idealGear._der_der_phi_b;
 der(damper.phi_rel) = - inertia2._der_phi;
 der(damper.w_rel) = damper._der_der_phi_rel;
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
 Real _der_i1;
initial equation 
 i2 = 0.0;
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
 _der_u1 = R[1] * _der_i1;
 _der_uL = R[2] * der(i2);
 _der_u0 = _der_u1 + _der_uL;
 _der_uC = _der_u1 + _der_uL;
 _der_i1 = der(i2) + _der_iL;
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
 _der_x1 + (- sin(x2) * der(x2)) = 0;
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
 _der_x1 + cos(x2) * der(x2) = 0;
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
 - _der_x1 + 2 * der(x2) = 0;

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
 _der_x1 + exp(x2 * p * time) * (x2 * p + der(x2) * p * time) = 0;

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
 _der_x1 + der(x2) / cos(x2) ^ 2 = 0;
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
 _der_x1 + der(x2) / sqrt(1 - x2 ^ 2) = 0;
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
 _der_x1 + (- der(x2)) / sqrt(1 - x2 ^ 2) = 0;
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
 _der_x1 + der(x2) / (1 + x2 ^ 2) = 0;
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
 _der_x1 + (der(x2) * x3 - x2 * der(x3)) / (x2 * x2 + x3 * x3) = 0;
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
 _der_x1 + cosh(x2) * der(x2) = 0;
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
 _der_x1 + sinh(x2) * der(x2) = 0;
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
 _der_x1 + der(x2) / cosh(x2) ^ 2 = 0;
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
 _der_x1 + der(x2) / x2 = 0;
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
 _der_x1 + der(x2) / (x2 * log(10)) = 0;
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
 _der_x1 + der(x2) / (2 * sqrt(x2)) = 0;
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
 _der_x1 + (if p > 3 then 3 * der(x2) elseif p <= 3 then cos(x2) * der(x2) else 2 * der(x2)) = 0;

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
 _der_x1 + p * x2 ^ (p - 1) * der(x2) + 1.4 * x2 ^ 0.3999999999999999 * der(x2) = 0;
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
  Index reduction failed: Maximum number of differentiations has been reached

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
 _der_x1 + IndexReduction.IndexReduction24_DerFunc.f_der(x2, der(x2)) = 0;

public
 function IndexReduction.IndexReduction24_DerFunc.f
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 annotation(derivative = IndexReduction.IndexReduction24_DerFunc.f_der);
 end IndexReduction.IndexReduction24_DerFunc.f;

 function IndexReduction.IndexReduction24_DerFunc.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x * der_x;
  return;
 end IndexReduction.IndexReduction24_DerFunc.f_der;

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
 Real _der_x1[1];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + IndexReduction.IndexReduction25_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}) = 0;
 _der_x1[1] + IndexReduction.IndexReduction25_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}}) = 0;

public
 function IndexReduction.IndexReduction25_DerFunc.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real y;
 algorithm
  y := (x[1] * A[1,1] + x[2] * A[2,1]) * x[1] + (x[1] * A[1,2] + x[2] * A[2,2]) * x[2];
  return;
 annotation(derivative = IndexReduction.IndexReduction25_DerFunc.f_der);
 end IndexReduction.IndexReduction25_DerFunc.f;

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
 Real _der_x1[1];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + IndexReduction.IndexReduction26_DerFunc.f({x2[1], x2[2]}) = 0;
 _der_x1[1] + IndexReduction.IndexReduction26_DerFunc.f_der({x2[1], x2[2]}, {der(x2[1]), der(x2[2])}) = 0;

public
 function IndexReduction.IndexReduction26_DerFunc.f
  input Real[2] x;
  output Real y;
 algorithm
  y := x[1] ^ 2 + x[2] ^ 3;
  return;
 annotation(derivative = IndexReduction.IndexReduction26_DerFunc.f_der);
 end IndexReduction.IndexReduction26_DerFunc.f;

 function IndexReduction.IndexReduction26_DerFunc.f_der
  input Real[2] x;
  input Real[2] der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x[1] * der_x[1] + 3 * x[2] ^ 2 * der_x[2];
  return;
 end IndexReduction.IndexReduction26_DerFunc.f_der;

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
 Real temp_4;
 Real temp_5;
 Real _der_temp_4;
 Real _der_temp_5;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 2;
 _der_x1[2] + der(x2[2]) = 3;
 ({temp_4, temp_5}) = IndexReduction.IndexReduction27_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 - x1[1] = temp_4;
 - x1[2] = temp_5;
 ({_der_temp_4, _der_temp_5}) = IndexReduction.IndexReduction27_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}});
 - _der_x1[1] = _der_temp_4;
 - _der_x1[2] = _der_temp_5;

public
 function IndexReduction.IndexReduction27_DerFunc.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real[2] y;
 algorithm
  y[1] := A[1,1] * x[1] + A[1,2] * x[2];
  y[2] := A[2,1] * x[1] + A[2,2] * x[2];
  return;
 annotation(derivative = IndexReduction.IndexReduction27_DerFunc.f_der);
 end IndexReduction.IndexReduction27_DerFunc.f;

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
 Real temp_4;
 Real temp_5;
 Real _der_temp_4;
 Real _der_temp_5;
initial equation 
 x1.a[1] = 0.0;
 x2.a[1] = 0.0;
equation
 der(x1.a[1]) + der(x2.a[1]) = 2;
 x1._der_a[2] + x2._der_a[2] = 3;
 (IndexReduction.IndexReduction28_Record.R({temp_4, temp_5})) = IndexReduction.IndexReduction28_Record.f({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 - x1.a[1] = temp_4;
 - x1.a[2] = temp_5;
 (IndexReduction.IndexReduction28_Record.R({_der_temp_4, _der_temp_5})) = IndexReduction.IndexReduction28_Record.f_der({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2.a[1]), x2._der_a[2]}, {{0.0, 0.0}, {0.0, 0.0}});
 - der(x1.a[1]) = _der_temp_4;
 - x1._der_a[2] = _der_temp_5;

public
 function IndexReduction.IndexReduction28_Record.f
  input Real[2] x;
  input Real[2, 2] A;
  output IndexReduction.IndexReduction28_Record.R y;
 algorithm
  y.a[1] := A[1,1] * x[1] + A[1,2] * x[2];
  y.a[2] := A[2,1] * x[1] + A[2,2] * x[2];
  return;
 annotation(derivative = IndexReduction.IndexReduction28_Record.f_der);
 end IndexReduction.IndexReduction28_Record.f;

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
 _der_x + IndexReduction.IndexReduction29_FunctionNoDerivative.der_F(y, x, 0, x, der(y), _der_x) = 0;

public
 function IndexReduction.IndexReduction29_FunctionNoDerivative.F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  output Real rho;
 algorithm
  rho := p + h;
  return;
 annotation(derivative(noDerivative = z) = IndexReduction.IndexReduction29_FunctionNoDerivative.der_F);
 end IndexReduction.IndexReduction29_FunctionNoDerivative.F;

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
 ((_der_x1 + der(x2)) * (x1 + p) - (x1 + x2) * _der_x1) / (x1 + p) ^ 2 = 0;
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
 (_der_x1 + der(x2)) / (p1 * p2) = 0;
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
 _der_x = 0;
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
 noEvent(_der_x1 + cos(x2) * der(x2)) = 0;
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
 Real m[1]._der_x;
 Real m[1]._der_vx;
 Real m[1]._der_der_x;
 Real m[1]._der_der_y;
initial equation 
 m[1].y = 0.0;
 m[1].vy = 0.0;
equation
 m[1]._der_x = m[1].vx;
 der(m[1].y) = m[1].vy;
 m[1]._der_vx = m[1].lambda * m[1].x;
 der(m[1].vy) = m[1].lambda * m[1].y - m[1].g;
 m[1].x ^ 2 + m[1].y ^ 2 = m[1].L;
 2 * m[1].x * m[1]._der_x + 2 * m[1].y * der(m[1].y) = 0.0;
 m[1]._der_der_x = m[1]._der_vx;
 m[1]._der_der_y = der(m[1].vy);
 2 * m[1].x * m[1]._der_der_x + 2 * m[1]._der_x * m[1]._der_x + (2 * m[1].y * m[1]._der_der_y + 2 * der(m[1].y) * der(m[1].y)) = 0.0;
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
 noEvent(if x1 < x2 then der(x1) else _der_x2) = 0;
 noEvent(if x1 < x3 then der(x1) else _der_x3) = 0;
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
 noEvent(if x1 > x2 then der(x1) else _der_x2) = 0;
 noEvent(if x1 > x3 then der(x1) else _der_x3) = 0;
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
 der(x2) = 1;
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
 _der_x + IndexReduction.IndexReduction43_Order.df(y, der(y)) = 0;
 _der_der_x = _der_dx;
 _der_der_y = der(dy);
 _der_der_x + IndexReduction.IndexReduction43_Order.ddf(y, der(y), _der_der_y) = 0;

public
 function IndexReduction.IndexReduction43_Order.f
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  y := y * x + 2 * y + 3 * x;
  return;
 annotation(derivative = IndexReduction.IndexReduction43_Order.df);
 end IndexReduction.IndexReduction43_Order.f;

 function IndexReduction.IndexReduction43_Order.df
  input Real x;
  input Real dx;
  output Real dy;
 algorithm
  dy := x * x;
  dy := dy + 2 * x + 3;
  return;
 annotation(derivative(order = 2) = IndexReduction.IndexReduction43_Order.ddf);
 end IndexReduction.IndexReduction43_Order.df;

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
        dy := dy * x2;
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
        ddy := ddy * x2;
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
 _der_x + IndexReduction.IndexReduction44_Order2Arg.df(y, time, der(y), 1.0) = 0;
 _der_der_x = _der_dx;
 _der_der_y = der(dy);
 _der_der_x + IndexReduction.IndexReduction44_Order2Arg.ddf(y, time, der(y), 1.0, _der_der_y, 0.0) = 0;

public
 function IndexReduction.IndexReduction44_Order2Arg.f
  input Real x1;
  input Real x2;
  output Real y;
 algorithm
  y := x1 * x1;
  y := y * x2;
  return;
 annotation(derivative = IndexReduction.IndexReduction44_Order2Arg.df);
 end IndexReduction.IndexReduction44_Order2Arg.f;

 function IndexReduction.IndexReduction44_Order2Arg.df
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  output Real dy;
 algorithm
  dy := x1 * x1;
  dy := dy * x2;
  return;
 annotation(derivative(order = 2) = IndexReduction.IndexReduction44_Order2Arg.ddf);
 end IndexReduction.IndexReduction44_Order2Arg.df;

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
  ddy := ddy * x2;
  return;
 end IndexReduction.IndexReduction44_Order2Arg.ddf;

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
 Real _der_x1[1];
 Real _der_x1[2];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] .* x2[1] = 0;
 x1[2] .* x2[2] = 0;
 x1[1] .* der(x2[1]) .+ _der_x1[1] .* x2[1] = 0;
 x1[2] .* der(x2[2]) .+ _der_x1[2] .* x2[2] = 0;
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
 (_der_x1[1] .* x2[1] .- x1[1] .* der(x2[1])) ./ x2[1] .^ 2 = 0;
 (_der_x1[2] .* x2[2] .- x1[2] .* der(x2[2])) ./ x2[2] .^ 2 = 0;
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
 x2[1] .* x1[1] .^ (x2[1] .- 1) .* _der_x1[1] = 0;
 x2[2] .* x1[2] .^ (x2[2] .- 1) .* _der_x1[2] = 0;
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
 _der_x1 = 0;
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
 Real c1_phi(stateSelect = c1_ss);
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
    y = 0*time;
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
			eliminate_alias_variables=true,
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
 Real _der_der_x;
initial equation 
 x = 2;
 c1_w = 0.0;
equation
 c1_w = der(x);
 c1_a = der(c1_w);
 c2_w = der(x);
 c2_a = _der_c2_w;
 c2_a * p = 0;
 der(c1_w) = _der_der_x;
 _der_c2_w = _der_der_x;

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
 Real _der_y;
 Real _der_dy;
 Real _der_a;
 Real _der_der_x;
 Real _der_der_y;
 Real _der_der_a;
 Real _der_der_b;
 Real temp_1;
 Real temp_4;
 Real _der_temp_1;
 Real _der_temp_4;
 Real _der_der_temp_1;
 Real _der_der_temp_4;
initial equation 
 dx = 0.0;
 b = 0.0;
equation
 sin(_der_x) = dx;
 cos(_der_y) = dy;
 der(dx) = v * x;
 _der_dy = v * y;
 a * b = 1;
 a = temp_1 * temp_4 + 42;
 b = temp_1 * temp_4 + y;
 temp_1 = x + 3.14;
 temp_4 = time;
 a * der(b) + _der_a * b = 0;
 _der_a = temp_1 * _der_temp_4 + _der_temp_1 * temp_4;
 der(b) = temp_1 * _der_temp_4 + _der_temp_1 * temp_4 + _der_y;
 _der_temp_1 = _der_x;
 _der_temp_4 = 1.0;
 cos(_der_x) * _der_der_x = der(dx);
 - sin(_der_y) * _der_der_y = _der_dy;
 a * _der_der_b + _der_a * der(b) + (_der_a * der(b) + _der_der_a * b) = 0;
 _der_der_a = temp_1 * _der_der_temp_4 + _der_temp_1 * _der_temp_4 + (_der_temp_1 * _der_temp_4 + _der_der_temp_1 * temp_4);
 _der_der_b = temp_1 * _der_der_temp_4 + _der_temp_1 * _der_temp_4 + (_der_temp_1 * _der_temp_4 + _der_der_temp_1 * temp_4) + _der_der_y;
 _der_der_temp_1 = _der_der_x;
 _der_der_temp_4 = 0.0;
end IndexReduction.IndexReduction52;
")})));
end IndexReduction52;

model IndexReduction53
    Real x,y(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction53",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.IndexReduction53
 Real x;
 Real y(stateSelect = StateSelect.prefer);
 Real _der_x;
initial equation 
 y = 0.0;
equation
 _der_x = - x;
 y = 100 * x;
 der(y) = 100 * _der_x;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction53;
")})));
end IndexReduction53;

model IndexReduction53b
    function F
        input Real i;
        output Real o;
    algorithm
        o := i * 42;
        annotation(Inline=false);
    end F;
    Real x,y(stateSelect=StateSelect.prefer);
    Real a,b(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;
    
    der(a) = -a;
    b=F(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction53b",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.IndexReduction53b
 Real x;
 Real y(stateSelect = StateSelect.prefer);
 Real a;
 Real b(stateSelect = StateSelect.prefer);
 Real _der_x;
initial equation 
 a = 0.0;
 y = 0.0;
equation
 _der_x = - x;
 y = 100 * x;
 der(a) = - a;
 b = IndexReduction.IndexReduction53b.F(a);
 der(y) = 100 * _der_x;

public
 function IndexReduction.IndexReduction53b.F
  input Real i;
  output Real o;
 algorithm
  o := i * 42;
  return;
 annotation(Inline = false);
 end IndexReduction.IndexReduction53b.F;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction53b;
")})));
end IndexReduction53b;

model IndexReduction54
    Real x(stateSelect=StateSelect.always),y(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction54",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.IndexReduction54
 Real x(stateSelect = StateSelect.always);
 Real y(stateSelect = StateSelect.prefer);
 Real _der_y;
initial equation 
 x = 0.0;
equation
 der(x) = - x;
 y = 100 * x;
 _der_y = 100 * der(x);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.IndexReduction54;
")})));
end IndexReduction54;

model SSPreferBackoff1
    function f
        input Real a;
        input Real b;
        output Real d = a + b;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x(stateSelect = StateSelect.prefer);
    Real y(stateSelect = StateSelect.prefer);
equation
    x = y - 1;
    0 = f(x, y);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SSPreferBackoff1",
            description="Test of system with non differentiated variable with StateSelect prefer and see if backoff works when it fails",
            flatModel="
fclass IndexReduction.SSPreferBackoff1
 Real x(stateSelect = StateSelect.prefer);
 Real y(stateSelect = StateSelect.prefer);
equation
 x = y - 1;
 0 = IndexReduction.SSPreferBackoff1.f(x, y);

public
 function IndexReduction.SSPreferBackoff1.f
  input Real a;
  input Real b;
  output Real d;
 algorithm
  d := a + b;
  return;
 annotation(Inline = false);
 end IndexReduction.SSPreferBackoff1.f;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.SSPreferBackoff1;
")})));
end SSPreferBackoff1;

model SSPreferBackoff2
    function f
        input Real a;
        output Real b = a * 42;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x(stateSelect = StateSelect.prefer),y,z;
equation
    0 = f(x);
    x = y * 3.12;
    z = der(y);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="SSPreferBackoff2",
            description="Test of system with non differentiated variable with StateSelect prefer that is differentiated by equation dependency. Check so that no infinite loop occures.",
            errorMessage="
1 errors found:

Error: in file '...':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative or smooth order annotation 'IndexReduction.SSPreferBackoff2.f(x)' in equation:
   0 = IndexReduction.SSPreferBackoff2.f(x)
")})));
end SSPreferBackoff2;

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
 0 = v1 * _der_b_v + _der_v1 * b_v;
 _der_a_v = _der_der_a_s;
 _der_der_b_v = _der_der_a_s;
 _der_der_v1 = 42 * _der_der_b_v;
 0 = v1 * _der_der_b_v + _der_v1 * _der_b_v + (_der_v1 * _der_b_v + _der_der_v1 * b_v);

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
 0 = v1 * _der_b_v + _der_v1 * b_v;
 _der_a_v = _der_der_a_s;
 _der_der_b_v = _der_der_a_s;
 _der_der_v1 = 42 * _der_der_b_v;
 0 = v1 * _der_der_b_v + _der_v1 * _der_b_v + (_der_v1 * _der_b_v + _der_der_v1 * b_v);

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
 _der_x1 + IndexReduction.AlgorithmDifferentiation.Simple._der_F(x2, der(x2)) = 0;

public
 function IndexReduction.AlgorithmDifferentiation.Simple.F
  input Real x;
  output Real y;
 algorithm
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.Simple._der_F);
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
 annotation(smoothOrder = 0);
 end IndexReduction.AlgorithmDifferentiation.Simple._der_F;

end IndexReduction.AlgorithmDifferentiation.Simple;
")})));
end Simple;

model RecordInput
  function F
    input R x;
    output Real y;
  algorithm
    y := sin(x.x[1]);
    annotation(Inline=false, smoothOrder=1);
  end F;
  record R
    Real x[1];
  end R;
  Real x1;
  R x2;
equation
  der(x1) + der(x2.x[1]) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_RecordInput",
            description="Test differentiation of function with record input",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.RecordInput
 Real x1;
 Real x2.x[1];
 Real _der_x1;
initial equation 
 x2.x[1] = 0.0;
equation
 _der_x1 + der(x2.x[1]) = 1;
 x1 + IndexReduction.AlgorithmDifferentiation.RecordInput.F(IndexReduction.AlgorithmDifferentiation.RecordInput.R({x2.x[1]})) = 1;
 _der_x1 + IndexReduction.AlgorithmDifferentiation.RecordInput._der_F(IndexReduction.AlgorithmDifferentiation.RecordInput.R({x2.x[1]}), IndexReduction.AlgorithmDifferentiation.RecordInput.R({der(x2.x[1])})) = 0;

public
 function IndexReduction.AlgorithmDifferentiation.RecordInput.F
  input IndexReduction.AlgorithmDifferentiation.RecordInput.R x;
  output Real y;
 algorithm
  y := sin(x.x[1]);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.RecordInput._der_F);
 end IndexReduction.AlgorithmDifferentiation.RecordInput.F;

 function IndexReduction.AlgorithmDifferentiation.RecordInput._der_F
  input IndexReduction.AlgorithmDifferentiation.RecordInput.R x;
  input IndexReduction.AlgorithmDifferentiation.RecordInput.R _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := cos(x.x[1]) * _der_x.x[1];
  y := sin(x.x[1]);
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.AlgorithmDifferentiation.RecordInput._der_F;

 record IndexReduction.AlgorithmDifferentiation.RecordInput.R
  Real x[1];
 end IndexReduction.AlgorithmDifferentiation.RecordInput.R;

end IndexReduction.AlgorithmDifferentiation.RecordInput;
")})));
end RecordInput;

model RecordOutput
  function F
    input Real x;
    output R y;
  algorithm
    y.x[1] := sin(x);
    annotation(Inline=false, smoothOrder=1);
  end F;
  record R
    Real x[1];
  end R;
  Real x1;
  Real x2;
  R r;
equation
  der(x1) + der(x2) = 1;
  r = F(x2);
  x1 + r.x[1] = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_RecordOutput",
            description="Test differentiation of function with record output",
            flatModel="
fclass IndexReduction.AlgorithmDifferentiation.RecordOutput
 Real x1;
 Real x2;
 Real r.x[1];
 Real _der_x1;
 Real _der_x2;
initial equation 
 r.x[1] = 0.0;
equation
 _der_x1 + _der_x2 = 1;
 (IndexReduction.AlgorithmDifferentiation.RecordOutput.R({r.x[1]})) = IndexReduction.AlgorithmDifferentiation.RecordOutput.F(x2);
 x1 + r.x[1] = 1;
 (IndexReduction.AlgorithmDifferentiation.RecordOutput.R({der(r.x[1])})) = IndexReduction.AlgorithmDifferentiation.RecordOutput._der_F(x2, _der_x2);
 _der_x1 + der(r.x[1]) = 0;

public
 function IndexReduction.AlgorithmDifferentiation.RecordOutput.F
  input Real x;
  output IndexReduction.AlgorithmDifferentiation.RecordOutput.R y;
 algorithm
  y.x[1] := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.RecordOutput._der_F);
 end IndexReduction.AlgorithmDifferentiation.RecordOutput.F;

 function IndexReduction.AlgorithmDifferentiation.RecordOutput._der_F
  input Real x;
  input Real _der_x;
  output IndexReduction.AlgorithmDifferentiation.RecordOutput.R _der_y;
  IndexReduction.AlgorithmDifferentiation.RecordOutput.R y;
 algorithm
  _der_y.x[1] := cos(x) * _der_x;
  y.x[1] := sin(x);
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.AlgorithmDifferentiation.RecordOutput._der_F;

 record IndexReduction.AlgorithmDifferentiation.RecordOutput.R
  Real x[1];
 end IndexReduction.AlgorithmDifferentiation.RecordOutput.R;

end IndexReduction.AlgorithmDifferentiation.RecordOutput;
")})));
end RecordOutput;

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
 _der_x1 + IndexReduction.AlgorithmDifferentiation.For._der_F(x2, der(x2)) = 0;

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
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.For._der_F);
 end IndexReduction.AlgorithmDifferentiation.For.F;

 function IndexReduction.AlgorithmDifferentiation.For._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0;
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
 annotation(smoothOrder = 0);
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
 IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F1(x1, x2, _der_x1, der(x2)) = 0;

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
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F1);
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
 annotation(derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.FunctionCall._der_F2);
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
 annotation(smoothOrder = 0);
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
 annotation(smoothOrder = 0);
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
 _der_x1 + IndexReduction.AlgorithmDifferentiation.If._der_F(x2, der(x2)) = 0;

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
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.If._der_F);
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
   _der_b := 0;
   b := 1;
  else
   _der_b := 0;
   b := 2;
  end if;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
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
 _der_x1 + IndexReduction.AlgorithmDifferentiation.InitArray._der_F({x2}, {der(x2)}) = 0;

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
 annotation(Inline = false,smoothOrder = 3,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.InitArray._der_F);
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
 annotation(smoothOrder = 2,derivative(order = 2) = IndexReduction.AlgorithmDifferentiation.InitArray._der_der_F);
 end IndexReduction.AlgorithmDifferentiation.InitArray._der_F;

end IndexReduction.AlgorithmDifferentiation.InitArray;
")})));
end InitArray;

model RecordArray
    record R
        Real x;
    end R;
    function F
        input R[1] x;
        output R[1] y;
    algorithm
        y := x;
        annotation(Inline=false, smoothOrder=3);
    end F;
    function e
        input R[:] r;
        output Real y = r[1].x;
        algorithm
    end e;
    Real x1;
    Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + e(F({R(x2)})) = 1;
            
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="AlgorithmDifferentiation_RecordArray",
            description="Test code gen of differentiated function with array of records #3611",
            template="$C_functions$",
            generatedCode="
void func_IndexReduction_AlgorithmDifferentiation_RecordArray_F_def0(R_0_ra* x_a, R_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, R_0_r, R_0_ra, y_an, 1, 1)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, y_an, 1, 1, 1)
        y_a = y_an;
    }
    jmi_array_rec_1(y_a, 1)->x = jmi_array_rec_1(x_a, 1)->x;
    JMI_DYNAMIC_FREE()
    return;
}

void func_IndexReduction_AlgorithmDifferentiation_RecordArray__der_F_def1(R_0_ra* x_a, R_0_ra* _der_x_a, R_0_ra* _der_y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, R_0_r, R_0_ra, _der_y_an, 1, 1)
    JMI_ARR(STAT, R_0_r, R_0_ra, y_a, 1, 1)
    if (_der_y_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, _der_y_an, 1, 1, 1)
        _der_y_a = _der_y_an;
    }
    JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, y_a, 1, 1, 1)
    jmi_array_rec_1(_der_y_a, 1)->x = jmi_array_rec_1(_der_x_a, 1)->x;
    jmi_array_rec_1(y_a, 1)->x = jmi_array_rec_1(x_a, 1)->x;
    JMI_DYNAMIC_FREE()
    return;
}
")})));
end RecordArray;

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
 _der_x1 + IndexReduction.AlgorithmDifferentiation.While._der_F(x2, der(x2)) = 0;

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
 annotation(Inline = false, smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.While._der_F);
 end IndexReduction.AlgorithmDifferentiation.While.F;

 function IndexReduction.AlgorithmDifferentiation.While._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0;
  c := 0;
  while c < x loop
   _der_c := _der_c;
   c := c + 0.5;
  end while;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
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
 IndexReduction.AlgorithmDifferentiation.Recursive._der_F1(x1, x2, _der_x1, der(x2)) = 0;

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
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.Recursive._der_F1);
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
 annotation(derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.Recursive._der_F2);
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
 annotation(smoothOrder = 0);
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
 annotation(smoothOrder = 0);
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
 _der_x1 + IndexReduction.AlgorithmDifferentiation.DiscreteComponents._der_F(x2, der(x2)) = 0;

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
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.DiscreteComponents._der_F);
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
 annotation(smoothOrder = 0);
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
 IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square(x) + IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square(y) = L;
 IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square(x, _der_x) + IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square(y, der(y)) = 0.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square(x, _der_x, _der_der_x) + IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square(y, der(y), _der_der_y) = 0.0;

public
 function IndexReduction.AlgorithmDifferentiation.PlanarPendulum.square
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 annotation(Inline = false,smoothOrder = 2,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_square);
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
 annotation(smoothOrder = 1,derivative(order = 2) = IndexReduction.AlgorithmDifferentiation.PlanarPendulum._der_der_square);
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
 annotation(smoothOrder = 0);
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
 annotation(smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F);
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
 annotation(smoothOrder = 0);
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
 annotation(smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1);
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
 annotation(smoothOrder = 1,derivative(order = 1) = IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2);
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
 annotation(smoothOrder = 0);
 end IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1;

 function IndexReduction.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := 0;
  y := 42;
  _der_z := x * _der_x + _der_x * x;
  z := x * x;
  _der_z := z * _der_x + _der_z * x;
  z := z * x;
  return;
 annotation(smoothOrder = 0);
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
 Real _der_x;
 Real _der_vx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 vy = 0.0;
 pre(i) = 0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
algorithm
 if y < 3.12 then
  i := 1;
 else
  i := -1;
 end if;
equation
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;
end IndexReduction.AlgorithmVariability1;")})));
  end AlgorithmVariability1;

    model Variability1
        function F1
            input Real a;
            output Real b;
            output Real c;
        algorithm
            b := a * 2;
            c := -a;
            annotation(Inline=false,derivative=F1_der);
        end F1;
        function F1_der
            input Real a;
            input Real a_der;
            output Real b;
            output Real c;
        algorithm
            (b,c) := F1(a * a_der);
            annotation(Inline=true);
        end F1_der;
        parameter Real p = 2;
        Real x,y,a;
    equation
        (x, p) = F1(y + a);
        der(x) = der(y) * 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Variability1",
            description="Test so that variability calculations are done propperly for function call equations with parameters in left hand side",
            flatModel="
fclass IndexReduction.Variability1
 parameter Real p = 2 /* 2 */;
 Real x;
 Real y;
 Real a;
 Real _der_x;
 Real _der_y;
 Real temp_3;
 Real temp_4;
initial equation 
 a = 0.0;
equation
 (x, p) = IndexReduction.Variability1.F1(y + a);
 _der_x = _der_y * 2;
 (temp_3, temp_4) = IndexReduction.Variability1.F1((y + a) * (_der_y + der(a)));
 _der_x = temp_3;
 0.0 = temp_4;

public
 function IndexReduction.Variability1.F1
  input Real a;
  output Real b;
  output Real c;
 algorithm
  b := a * 2;
  c := - a;
  return;
 annotation(derivative = IndexReduction.Variability1.F1_der,Inline = false);
 end IndexReduction.Variability1.F1;

end IndexReduction.Variability1;
")})));
    end Variability1;

model Functional1
    partial function partFunc
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x1;
      algorithm
        y := x1;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf();
        annotation(smoothOrder=1);
    end usePartFunc;
    
    Real x1,x2;
equation
    der(x1) + der(x2) = 1;
    x1 + usePartFunc(function fullFunc(x1=x2)) = 1;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Functional1",
            description="Test failing differentiation of functional input arguments",
            errorMessage="
1 errors found:
Error: in file '...':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative or smooth order annotation 'pf()' in equation:
   x1 + IndexReduction.Functional1.usePartFunc(function IndexReduction.Functional1.fullFunc(x2)) = 1
")})));
end Functional1;

model FunctionAttributeScalarization1
    function F1
        input Real x;
        input Real a[:];
        output Real y;
    algorithm
        y := x + sum(a);
    annotation(Inline=false,derivative(noDerivative=a)=F1_der);
    end F1;
    
    function F1_der
        input Real x;
        input Real a[:];
        input Real x_der;
        output Real y_der;
    algorithm
        y_der := x_der;
    annotation(Inline=false);
    end F1_der;
    
    Real x;
    Real der_y;
    Real y;
equation
    x * y = time;
    y + 42 = F1(x, {x , -x});
    der_y = der(y);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionAttributeScalarization1",
            description="Test so that it is possible to reference function variables with unknown size in function attributes",
            flatModel="
fclass IndexReduction.FunctionAttributeScalarization1
 Real x;
 Real der_y;
 Real y;
 Real _der_y;
 Real _der_x;
equation
 x * y = time;
 y + 42 = IndexReduction.FunctionAttributeScalarization1.F1(x, {x, - x});
 der_y = _der_y;
 x * _der_y + _der_x * y = 1.0;
 _der_y = IndexReduction.FunctionAttributeScalarization1.F1_der(x, {x, - x}, _der_x);

public
 function IndexReduction.FunctionAttributeScalarization1.F1
  input Real x;
  input Real[:] a;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + a[i1];
  end for;
  y := x + temp_1;
  return;
 annotation(derivative(noDerivative = a) = IndexReduction.FunctionAttributeScalarization1.F1_der,Inline = false);
 end IndexReduction.FunctionAttributeScalarization1.F1;

 function IndexReduction.FunctionAttributeScalarization1.F1_der
  input Real x;
  input Real[:] a;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionAttributeScalarization1.F1_der;

end IndexReduction.FunctionAttributeScalarization1;
")})));
end FunctionAttributeScalarization1;

model FunctionAttributeScalarization2
    function F1
        input Real x;
        input Real a[2];
        output Real y;
    algorithm
        y := x + sum(a);
    annotation(Inline=false,derivative(noDerivative=a)=F1_der);
    end F1;
    
    function F1_der
        input Real x;
        input Real a[2];
        input Real x_der;
        output Real y_der;
    algorithm
        y_der := x_der;
    annotation(Inline=false);
    end F1_der;
    
    Real x;
    Real der_y;
    Real y;
equation
    x * y = time;
    y + 42 = F1(x, {x , -x});
    der_y = der(y);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionAttributeScalarization2",
            description="Test so that it is possible to reference function variables with known size in function attributes",
            flatModel="
fclass IndexReduction.FunctionAttributeScalarization2
 Real x;
 Real der_y;
 Real y;
 Real _der_y;
 Real _der_x;
equation
 x * y = time;
 y + 42 = IndexReduction.FunctionAttributeScalarization2.F1(x, {x, - x});
 der_y = _der_y;
 x * _der_y + _der_x * y = 1.0;
 _der_y = IndexReduction.FunctionAttributeScalarization2.F1_der(x, {x, - x}, _der_x);

public
 function IndexReduction.FunctionAttributeScalarization2.F1
  input Real x;
  input Real[2] a;
  output Real y;
 algorithm
  y := x + (a[1] + a[2]);
  return;
 annotation(derivative(noDerivative = a) = IndexReduction.FunctionAttributeScalarization2.F1_der,Inline = false);
 end IndexReduction.FunctionAttributeScalarization2.F1;

 function IndexReduction.FunctionAttributeScalarization2.F1_der
  input Real x;
  input Real[2] a;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionAttributeScalarization2.F1_der;

end IndexReduction.FunctionAttributeScalarization2;
")})));
end FunctionAttributeScalarization2;

model NonDiffArgsTest1
    function F1
        input Real x;
        input Real r;
        output Real y;
    algorithm
        y := x + r;
    annotation(Inline=false,derivative(noDerivative=r)=F1_der);
    end F1;
    
    function F1_der
        input Real x;
        input Real r;
        input Real x_der;
        output Real y_der;
    algorithm
        y_der := x_der;
    annotation(Inline=false);
    end F1_der;
    
    function F2
        input Real x;
        output Real r;
    algorithm
        r := x;
    annotation(Inline=false);
    end F2;

    Real x;
    Real der_y;
    Real y;
    Real r;
equation
    x * y = time;
    r = F2(x);
    y + 42 = F1(x, r);
    der_y = der(y);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgsTest1",
            description="Test so that noDerivative and zeroDerivative augmenting are ignored in augmenting path",
            flatModel="
fclass IndexReduction.NonDiffArgsTest1
 Real x;
 Real der_y;
 Real y;
 Real r;
 Real _der_y;
 Real _der_x;
equation
 x * y = time;
 r = IndexReduction.NonDiffArgsTest1.F2(x);
 y + 42 = IndexReduction.NonDiffArgsTest1.F1(x, r);
 der_y = _der_y;
 x * _der_y + _der_x * y = 1.0;
 _der_y = IndexReduction.NonDiffArgsTest1.F1_der(x, r, _der_x);

public
 function IndexReduction.NonDiffArgsTest1.F2
  input Real x;
  output Real r;
 algorithm
  r := x;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgsTest1.F2;

 function IndexReduction.NonDiffArgsTest1.F1
  input Real x;
  input Real r;
  output Real y;
 algorithm
  y := x + r;
  return;
 annotation(derivative(noDerivative = r) = IndexReduction.NonDiffArgsTest1.F1_der,Inline = false);
 end IndexReduction.NonDiffArgsTest1.F1;

 function IndexReduction.NonDiffArgsTest1.F1_der
  input Real x;
  input Real r;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgsTest1.F1_der;

end IndexReduction.NonDiffArgsTest1;
")})));
end NonDiffArgsTest1;

model NonDiffArgsTest2
    record R
        Real a;
    end R;

    function F1
        input Real x;
        input R r;
        output Real y;
    algorithm
        y := x + r.a;
    annotation(Inline=false,derivative(noDerivative=r)=F1_der);
    end F1;
    
    function F1_der
        input Real x;
        input R r;
        input Real x_der;
        output Real y_der;
    algorithm
        y_der := x_der;
    annotation(Inline=false);
    end F1_der;
    
    function F2
        input Real x;
        output R r;
    algorithm
        r := R(x);
    annotation(Inline=false);
    end F2;

    Real x;
    Real der_y;
    Real y;
    R r;
equation
    x * y = time;
    r = F2(x);
    y + 42 = F1(x, r);
    der_y = der(y);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgsTest2",
            description="Test so that noDerivative and zeroDerivative augmenting are ignored in augmenting path",
            flatModel="
fclass IndexReduction.NonDiffArgsTest2
 Real x;
 Real der_y;
 Real y;
 Real r.a;
 Real _der_y;
 Real _der_x;
equation
 x * y = time;
 (IndexReduction.NonDiffArgsTest2.R(r.a)) = IndexReduction.NonDiffArgsTest2.F2(x);
 y + 42 = IndexReduction.NonDiffArgsTest2.F1(x, IndexReduction.NonDiffArgsTest2.R(r.a));
 der_y = _der_y;
 x * _der_y + _der_x * y = 1.0;
 _der_y = IndexReduction.NonDiffArgsTest2.F1_der(x, IndexReduction.NonDiffArgsTest2.R(r.a), _der_x);

public
 function IndexReduction.NonDiffArgsTest2.F2
  input Real x;
  output IndexReduction.NonDiffArgsTest2.R r;
 algorithm
  r.a := x;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgsTest2.F2;

 function IndexReduction.NonDiffArgsTest2.F1
  input Real x;
  input IndexReduction.NonDiffArgsTest2.R r;
  output Real y;
 algorithm
  y := x + r.a;
  return;
 annotation(derivative(noDerivative = r) = IndexReduction.NonDiffArgsTest2.F1_der,Inline = false);
 end IndexReduction.NonDiffArgsTest2.F1;

 function IndexReduction.NonDiffArgsTest2.F1_der
  input Real x;
  input IndexReduction.NonDiffArgsTest2.R r;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgsTest2.F1_der;

 record IndexReduction.NonDiffArgsTest2.R
  Real a;
 end IndexReduction.NonDiffArgsTest2.R;

end IndexReduction.NonDiffArgsTest2;
")})));
end NonDiffArgsTest2;

model FunctionCallEquation1
    function f
        input Real x;
        output Real y[2];
    algorithm
        y[1] := x;
        y[2] := -x;
    annotation(Inline=false, smoothOrder=1);
    end f;
    
    Real x[2];
    Real y;
    Real z;
equation
    x = f(time);
    y = x[1] + x[2];
    z = der(y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation1",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly",
            flatModel="
fclass IndexReduction.FunctionCallEquation1
 Real x[1];
 Real x[2];
 Real y;
 Real z;
 Real _der_y;
 Real _der_x[1];
 Real _der_x[2];
equation
 ({x[1], x[2]}) = IndexReduction.FunctionCallEquation1.f(time);
 y = x[1] + x[2];
 z = _der_y;
 ({_der_x[1], _der_x[2]}) = IndexReduction.FunctionCallEquation1._der_f(time, 1.0);
 _der_y = _der_x[1] + _der_x[2];

public
 function IndexReduction.FunctionCallEquation1.f
  input Real x;
  output Real[2] y;
 algorithm
  y[1] := x;
  y[2] := - x;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.FunctionCallEquation1._der_f);
 end IndexReduction.FunctionCallEquation1.f;

 function IndexReduction.FunctionCallEquation1._der_f
  input Real x;
  input Real _der_x;
  output Real[2] _der_y;
  Real[2] y;
 algorithm
  _der_y[1] := _der_x;
  y[1] := x;
  _der_y[2] := - _der_x;
  y[2] := - x;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.FunctionCallEquation1._der_f;

end IndexReduction.FunctionCallEquation1;
")})));
end FunctionCallEquation1;

model FunctionCallEquation2
    function f
        input Real x;
        output Real y = x;
        output Real z = x;
      algorithm
        annotation(Inline=false, smoothOrder=1);
    end f;
    
    Real a,b,c,d;
  equation
    der(c) = d;
    (a,c) = f(time);
    der(a) = b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation2",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly",
            flatModel="
fclass IndexReduction.FunctionCallEquation2
 Real a;
 Real b;
 Real c;
 Real d;
 Real _der_c;
 Real _der_a;
equation
 _der_c = d;
 (a, c) = IndexReduction.FunctionCallEquation2.f(time);
 _der_a = b;
 (_der_a, _der_c) = IndexReduction.FunctionCallEquation2._der_f(time, 1.0);

public
 function IndexReduction.FunctionCallEquation2.f
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := x;
  z := x;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.FunctionCallEquation2._der_f);
 end IndexReduction.FunctionCallEquation2.f;

 function IndexReduction.FunctionCallEquation2._der_f
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := _der_x;
  y := x;
  _der_z := _der_x;
  z := x;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.FunctionCallEquation2._der_f;

end IndexReduction.FunctionCallEquation2;
")})));
end FunctionCallEquation2;

model FunctionCallEquation3
    function f
        input Real x;
        output Real y = x;
        output Real z = x;
      algorithm
        annotation(Inline=false, smoothOrder=1);
    end f;
    
    Real a,b,c,d;
  equation
    c = d + 1;
    (a,c) = f(time);
    der(a) = b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation3",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly",
            flatModel="
fclass IndexReduction.FunctionCallEquation3
 Real a;
 Real b;
 Real c;
 Real d;
 Real _der_a;
 Real _der_c;
equation
 c = d + 1;
 (a, c) = IndexReduction.FunctionCallEquation3.f(time);
 _der_a = b;
 (_der_a, _der_c) = IndexReduction.FunctionCallEquation3._der_f(time, 1.0);

public
 function IndexReduction.FunctionCallEquation3.f
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := x;
  z := x;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.FunctionCallEquation3._der_f);
 end IndexReduction.FunctionCallEquation3.f;

 function IndexReduction.FunctionCallEquation3._der_f
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := _der_x;
  y := x;
  _der_z := _der_x;
  z := x;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.FunctionCallEquation3._der_f;

end IndexReduction.FunctionCallEquation3;
")})));
end FunctionCallEquation3;

model FunctionCallEquation4
    function F2
        input Real[2] a;
        output Real[2] y;
    algorithm
        y[1] := a[1] + a[2];
        y[2] := a[1] - a[2];
        annotation(Inline=false,derivative=F2_der);
    end F2;

    function F2_der
        input Real[2] a;
        input Real[2] a_der;
        output Real[2] y_der;
    algorithm
        y_der[1] := a_der[1] + a_der[2];
        y_der[2] := a_der[1] - a_der[2];
        annotation(Inline=false);
    end F2_der;

    Real x[2];
    Real y[2];
    Real a;
    
equation
    der(x) = der(y) * 2;
    y[1] = a + 1;
    ({a, y[2]}) = F2(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation4",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"y[1] = a + 1\" should be differentiated",
            flatModel="
fclass IndexReduction.FunctionCallEquation4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real a;
 Real _der_x[1];
 Real _der_y[1];
 Real _der_x[2];
initial equation 
 y[2] = 0.0;
 a = 0.0;
equation
 _der_x[1] = _der_y[1] * 2;
 _der_x[2] = der(y[2]) * 2;
 y[1] = a + 1;
 ({a, y[2]}) = IndexReduction.FunctionCallEquation4.F2({x[1], x[2]});
 ({der(a), der(y[2])}) = IndexReduction.FunctionCallEquation4.F2_der({x[1], x[2]}, {_der_x[1], _der_x[2]});
 _der_y[1] = der(a);

public
 function IndexReduction.FunctionCallEquation4.F2
  input Real[2] a;
  output Real[2] y;
 algorithm
  y[1] := a[1] + a[2];
  y[2] := a[1] - a[2];
  return;
 annotation(derivative = IndexReduction.FunctionCallEquation4.F2_der,Inline = false);
 end IndexReduction.FunctionCallEquation4.F2;

 function IndexReduction.FunctionCallEquation4.F2_der
  input Real[2] a;
  input Real[2] a_der;
  output Real[2] y_der;
 algorithm
  y_der[1] := a_der[1] + a_der[2];
  y_der[2] := a_der[1] - a_der[2];
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionCallEquation4.F2_der;

end IndexReduction.FunctionCallEquation4;
")})));
end FunctionCallEquation4;

model FunctionCallEquation5
    function F2
        input Real[2] a;
        output Real[2] y;
    algorithm
        y[1] := a[1] + a[2];
        y[2] := a[1] - a[2];
        annotation(Inline=false,derivative=F2_der);
    end F2;

    function F2_der
        input Real[2] a;
        input Real[2] a_der;
        output Real[2] y_der;
    algorithm
        y_der[1] := a_der[1] + a_der[2];
        y_der[2] := a_der[1] - a_der[2];
        annotation(Inline=false);
    end F2_der;

    Real x[2];
    Real y[2];
    Real a;
    Real b;
    
equation
    der(x) = der(y) * 2;
    b = a + 1;
    ({a, y[2]}) = F2(x);
    y[1] = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation5",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"b = a + 1;\" should not be differentiated",
            flatModel="
fclass IndexReduction.FunctionCallEquation5
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real a;
 Real b;
 Real _der_x[1];
 Real _der_y[1];
 Real _der_x[2];
initial equation 
 y[2] = 0.0;
 a = 0.0;
equation
 _der_x[1] = _der_y[1] * 2;
 _der_x[2] = der(y[2]) * 2;
 b = a + 1;
 ({a, y[2]}) = IndexReduction.FunctionCallEquation5.F2({x[1], x[2]});
 y[1] = time;
 ({der(a), der(y[2])}) = IndexReduction.FunctionCallEquation5.F2_der({x[1], x[2]}, {_der_x[1], _der_x[2]});
 _der_y[1] = 1.0;

public
 function IndexReduction.FunctionCallEquation5.F2
  input Real[2] a;
  output Real[2] y;
 algorithm
  y[1] := a[1] + a[2];
  y[2] := a[1] - a[2];
  return;
 annotation(derivative = IndexReduction.FunctionCallEquation5.F2_der,Inline = false);
 end IndexReduction.FunctionCallEquation5.F2;

 function IndexReduction.FunctionCallEquation5.F2_der
  input Real[2] a;
  input Real[2] a_der;
  output Real[2] y_der;
 algorithm
  y_der[1] := a_der[1] + a_der[2];
  y_der[2] := a_der[1] - a_der[2];
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionCallEquation5.F2_der;

end IndexReduction.FunctionCallEquation5;
")})));
end FunctionCallEquation5;

model FunctionCallEquation6
    function f
        input Real x;
        output Integer a1;
        output Real a2;
      algorithm
        a1 := 3;
        a2 := x;
        annotation(smoothOrder=1);
    end f;
    Integer a;
    Real b,c,d;
  equation
    (a,b) = f(time);
    der(c) = der(d);
    d = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation6",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"b = a + 1;\" should not be differentiated",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.FunctionCallEquation6
 discrete Integer a;
 Real b;
 Real c;
 Real d;
 Real _der_d;
initial equation 
 c = 0.0;
 pre(a) = 0;
equation
 (a, b) = IndexReduction.FunctionCallEquation6.f(time);
 der(c) = _der_d;
 d = time;
 _der_d = 1.0;

public
 function IndexReduction.FunctionCallEquation6.f
  input Real x;
  output Integer a1;
  output Real a2;
 algorithm
  a1 := 3;
  a2 := x;
  return;
 annotation(smoothOrder = 1);
 end IndexReduction.FunctionCallEquation6.f;

end IndexReduction.FunctionCallEquation6;
")})));
end FunctionCallEquation6;

model FunctionCallEquation7
    function f
        input Real x;
        input Real e;
        output Integer a1;
        output Real a2;
      algorithm
        a1 := 3;
        a2 := x + e;
        annotation(smoothOrder=1);
    end f;
    Integer a;
    Real b,c,d;
    Real e;
  equation
    (a,b) = f(time, e);
    der(c) = der(d);
    d = time;
    e = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation7",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"b = a + 1;\" should not be differentiated",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.FunctionCallEquation7
 discrete Integer a;
 Real b;
 Real c;
 Real d;
 Real e;
 Real _der_d;
initial equation 
 c = 0.0;
 pre(a) = 0;
equation
 (a, b) = IndexReduction.FunctionCallEquation7.f(time, e);
 der(c) = _der_d;
 d = time;
 e = time;
 _der_d = 1.0;

public
 function IndexReduction.FunctionCallEquation7.f
  input Real x;
  input Real e;
  output Integer a1;
  output Real a2;
 algorithm
  a1 := 3;
  a2 := x + e;
  return;
 annotation(smoothOrder = 1);
 end IndexReduction.FunctionCallEquation7.f;

end IndexReduction.FunctionCallEquation7;
")})));
end FunctionCallEquation7;

model Algorithm1
    Integer a;
    Real b;
    Real x,y;
  algorithm
    a := 3;
    a := a + 1;
    b := y;
  equation
    der(x) = der(y);
    y = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm1",
            description="Test so that non scalar equations such as Algorithms are handled correctly.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.Algorithm1
 discrete Integer a;
 Real b;
 Real x;
 Real y;
 Real _der_y;
initial equation 
 x = 0.0;
 pre(a) = 0;
equation
 der(x) = _der_y;
 y = time;
algorithm
 a := 3;
 a := a + 1;
 b := y;
equation
 _der_y = 1.0;
end IndexReduction.Algorithm1;
")})));
end Algorithm1;

model DoubleDifferentiationWithSS1
    parameter Real L = 1 "Pendulum length";
    parameter Real g = 9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.never) "Cartesian x coordinate";
    Real x2;
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
equation
    der(x2) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
    x = x2 + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DoubleDifferentiationWithSS1",
            description="Test double differentiation whit state select avoid or never during index reductio",
            flatModel="
fclass IndexReduction.DoubleDifferentiationWithSS1
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.never) \"Cartesian x coordinate\";
 Real x2;
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x2;
 Real _der_vx;
 Real _der_x;
 Real _der_der_x2;
 Real _der_der_y;
 Real _der_der_x;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x2 = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 x = x2 + 1;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_x = _der_x2;
 _der_der_x2 = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;
 _der_der_x = _der_der_x2;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.DoubleDifferentiationWithSS1;
")})));
end DoubleDifferentiationWithSS1;


model MaxNumFExpError1
    Real x1;
    Real x2;
equation
    der(x1) + der(x2) = 1;
    x1 + x2 = 1;
    atan2(atan2(x1 * x2, sqrt(x1 ^ 2 + x2 ^ 2)), x1 / x2) = 2;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="MaxNumFExpError1",
            description="Test error check that prevents runaway index reduction",
            errorMessage="
2 errors found:

Error: in file '...':
Semantic error at line 0, column 0:
  Index reduction failed: Maximum number of expressions in a single equation has been reached

Error: in file '...':
Semantic error at line 0, column 0:
  The system is structurally singular. The following varible(s) could not be matched to any equation:
     der(x2)

  The following equation(s) could not be matched to any variable:
    x1 + x2 = 1
    atan2(atan2(x1 * x2, sqrt(x1 ^ 2 + x2 ^ 2)), x1 / x2) = 2

")})));
end MaxNumFExpError1;

model PartiallyPropagatedComposite1
    function f
        input Real x1;
        input Real x2;
        output Real[2] y;
      algorithm
        y[1] := x1;
        y[2] := x2;
        annotation(smoothOrder = 1);
    end f;
    Real[2] y;
    Real[2] x1;
equation
    y = f(2,time);
    x1 = der(y);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyPropagatedComposite1",
            description="Check that index reduction can handle FNoExp in LHS of function call equation",
            inline_functions="none",
            flatModel="
fclass IndexReduction.PartiallyPropagatedComposite1
 constant Real y[1] = 2;
 Real y[2];
 constant Real x1[1] = 0.0;
 Real x1[2];
 Real _der_y[2];
equation
 ({, y[2]}) = IndexReduction.PartiallyPropagatedComposite1.f(2, time);
 x1[2] = _der_y[2];
 ({, _der_y[2]}) = IndexReduction.PartiallyPropagatedComposite1._der_f(2, time, 0, 1.0);

public
 function IndexReduction.PartiallyPropagatedComposite1.f
  input Real x1;
  input Real x2;
  output Real[2] y;
 algorithm
  y[1] := x1;
  y[2] := x2;
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = IndexReduction.PartiallyPropagatedComposite1._der_f);
 end IndexReduction.PartiallyPropagatedComposite1.f;

 function IndexReduction.PartiallyPropagatedComposite1._der_f
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real[2] _der_y;
  Real[2] y;
 algorithm
  _der_y[1] := _der_x1;
  y[1] := x1;
  _der_y[2] := _der_x2;
  y[2] := x2;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.PartiallyPropagatedComposite1._der_f;

end IndexReduction.PartiallyPropagatedComposite1;
")})));
end PartiallyPropagatedComposite1;

package FunctionInlining
    model Test1
        function F
            input Real i;
            output Real o1;
        algorithm
            o1 := i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der;
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = F(time);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test1",
            description="Test function inlining during index reduction",
            flatModel="
fclass IndexReduction.FunctionInlining.Test1
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
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
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test1.F(time);
 2 * x * _der_x + 2 * y * der(y) = 1.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;

public
 function IndexReduction.FunctionInlining.Test1.F
  input Real i;
  output Real o1;
 algorithm
  o1 := i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test1.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test1.F;

end IndexReduction.FunctionInlining.Test1;
")})));
    end Test1;
    
    model Test2
    
        function F
            input Real i;
            output Real o1[2];
        algorithm
            o1[1] := i;
            o1[2] := -i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der[2];
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x[2];
        Real y[2];
        Real vx[2];
        Real vy[2];
        Real a[2];
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a.*x;
        der(vy) = a.*y;
        x.^2 .+ y.^2 = F(time);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test2",
            description="Test function inlining during index reduction",
            flatModel="
fclass IndexReduction.FunctionInlining.Test2
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real vx[1];
 Real vx[2];
 Real vy[1];
 Real vy[2];
 Real a[1];
 Real a[2];
 Real _der_x[1];
 Real _der_x[2];
 Real _der_vx[1];
 Real _der_vx[2];
 Real _der_der_x[1];
 Real _der_der_y[1];
 Real _der_der_x[2];
 Real _der_der_y[2];
 Real temp_1[1];
 Real temp_1[2];
initial equation 
 y[1] = 0.0;
 y[2] = 0.0;
 vy[1] = 0.0;
 vy[2] = 0.0;
equation
 _der_x[1] = vx[1];
 _der_x[2] = vx[2];
 der(y[1]) = vy[1];
 der(y[2]) = vy[2];
 _der_vx[1] = a[1] .* x[1];
 _der_vx[2] = a[2] .* x[2];
 der(vy[1]) = a[1] .* y[1];
 der(vy[2]) = a[2] .* y[2];
 ({temp_1[1], temp_1[2]}) = IndexReduction.FunctionInlining.Test2.F(time);
 x[1] .^ 2 .+ y[1] .^ 2 = temp_1[1];
 x[2] .^ 2 .+ y[2] .^ 2 = temp_1[2];
 2 .* x[1] .* _der_x[1] .+ 2 .* y[1] .* der(y[1]) = 1.0;
 _der_der_x[1] = _der_vx[1];
 _der_der_y[1] = der(vy[1]);
 2 .* x[1] .* _der_der_x[1] .+ 2 .* _der_x[1] .* _der_x[1] .+ (2 .* y[1] .* _der_der_y[1] .+ 2 .* der(y[1]) .* der(y[1])) = 0.0;
 2 .* x[2] .* _der_x[2] .+ 2 .* y[2] .* der(y[2]) = -1.0;
 _der_der_x[2] = _der_vx[2];
 _der_der_y[2] = der(vy[2]);
 2 .* x[2] .* _der_der_x[2] .+ 2 .* _der_x[2] .* _der_x[2] .+ (2 .* y[2] .* _der_der_y[2] .+ 2 .* der(y[2]) .* der(y[2])) = 0.0;

public
 function IndexReduction.FunctionInlining.Test2.F
  input Real i;
  output Real[2] o1;
 algorithm
  o1[1] := i;
  o1[2] := - i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test2.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test2.F;

end IndexReduction.FunctionInlining.Test2;
")})));
    end Test2;
    
    model Test3
    
        function F
            input Real i;
            output Real o1;
        algorithm
            o1 := i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der;
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        Real b;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = F(b);
        b = time;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test3",
            description="Test function inlining during index reduction",
            flatModel="
fclass IndexReduction.FunctionInlining.Test3
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real b;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_x;
 Real _der_der_y;
 Real _der_der_b;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test3.F(b);
 b = time;
 2 * x * _der_x + 2 * y * der(y) = IndexReduction.FunctionInlining.Test3.F(_der_b);
 _der_b = 1.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = IndexReduction.FunctionInlining.Test3.F(_der_der_b);
 _der_der_b = 0.0;

public
 function IndexReduction.FunctionInlining.Test3.F
  input Real i;
  output Real o1;
 algorithm
  o1 := i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test3.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test3.F;

end IndexReduction.FunctionInlining.Test3;
")})));
    end Test3;
    
    model Test4
    
        function F
            input Real i;
            output Real o1[2];
        algorithm
            o1[1] := i;
            o1[2] := -i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der[2];
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x[2];
        Real y[2];
        Real vx[2];
        Real vy[2];
        Real a[2];
        Real b;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a.*x;
        der(vy) = a.*y;
        x.^2 .+ y.^2 = F(b);
        b = time;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test4",
            description="Test function inlining during index reduction",
            flatModel="
fclass IndexReduction.FunctionInlining.Test4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real vx[1];
 Real vx[2];
 Real vy[1];
 Real vy[2];
 Real a[1];
 Real a[2];
 Real b;
 Real _der_x[1];
 Real _der_x[2];
 Real _der_vx[1];
 Real _der_vx[2];
 Real _der_b;
 Real _der_der_x[1];
 Real _der_der_y[1];
 Real _der_der_b;
 Real _der_der_x[2];
 Real _der_der_y[2];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_4;
 Real temp_5;
 Real temp_8;
 Real temp_9;
initial equation 
 y[1] = 0.0;
 y[2] = 0.0;
 vy[1] = 0.0;
 vy[2] = 0.0;
equation
 _der_x[1] = vx[1];
 _der_x[2] = vx[2];
 der(y[1]) = vy[1];
 der(y[2]) = vy[2];
 _der_vx[1] = a[1] .* x[1];
 _der_vx[2] = a[2] .* x[2];
 der(vy[1]) = a[1] .* y[1];
 der(vy[2]) = a[2] .* y[2];
 ({temp_1[1], temp_1[2]}) = IndexReduction.FunctionInlining.Test4.F(b);
 x[1] .^ 2 .+ y[1] .^ 2 = temp_1[1];
 x[2] .^ 2 .+ y[2] .^ 2 = temp_1[2];
 b = time;
 ({temp_4, temp_5}) = IndexReduction.FunctionInlining.Test4.F(_der_b);
 2 .* x[1] .* _der_x[1] .+ 2 .* y[1] .* der(y[1]) = temp_4;
 _der_b = 1.0;
 _der_der_x[1] = _der_vx[1];
 _der_der_y[1] = der(vy[1]);
 ({temp_8, temp_9}) = IndexReduction.FunctionInlining.Test4.F(_der_der_b);
 2 .* x[1] .* _der_der_x[1] .+ 2 .* _der_x[1] .* _der_x[1] .+ (2 .* y[1] .* _der_der_y[1] .+ 2 .* der(y[1]) .* der(y[1])) = temp_8;
 _der_der_b = 0.0;
 2 .* x[2] .* _der_x[2] .+ 2 .* y[2] .* der(y[2]) = temp_5;
 _der_der_x[2] = _der_vx[2];
 _der_der_y[2] = der(vy[2]);
 2 .* x[2] .* _der_der_x[2] .+ 2 .* _der_x[2] .* _der_x[2] .+ (2 .* y[2] .* _der_der_y[2] .+ 2 .* der(y[2]) .* der(y[2])) = temp_9;

public
 function IndexReduction.FunctionInlining.Test4.F
  input Real i;
  output Real[2] o1;
 algorithm
  o1[1] := i;
  o1[2] := - i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test4.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test4.F;

end IndexReduction.FunctionInlining.Test4;
")})));
    end Test4;

    model Test5
        function F
            input Real i1;
            input Real i2;
            output Real o1;
        algorithm
            o1 := i1 * i2;
            annotation(Inline=false,derivative(zeroDerivative=i2)=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            output Real o1_der;
        algorithm
            o1_der := F(i1_der, i2);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real b;
        parameter Real p = 2;
    equation
        der(x) = der(y) * 2;
        x^2 + y^2 = F(b, if p > 0 then p else 0);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test5",
            description="Test function inlining during index reduction",
            flatModel="
fclass IndexReduction.FunctionInlining.Test5
 Real x;
 Real y;
 Real b;
 parameter Real p = 2 /* 2 */;
 Real _der_x;
 Real _der_b;
 parameter Real temp_2;
initial equation 
 y = 0.0;
parameter equation
 temp_2 = if p > 0 then p else 0;
equation
 _der_x = der(y) * 2;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test5.F(b, if p > 0 then p else 0);
 b = time;
 2 * x * _der_x + 2 * y * der(y) = IndexReduction.FunctionInlining.Test5.F(_der_b, temp_2);
 _der_b = 1.0;

public
 function IndexReduction.FunctionInlining.Test5.F
  input Real i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := i1 * i2;
  return;
 annotation(derivative(zeroDerivative = i2) = IndexReduction.FunctionInlining.Test5.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test5.F;

end IndexReduction.FunctionInlining.Test5;
")})));
    end Test5;

    model Test6
        function F
            input Real i1;
            input Real i2;
            output Real o1;
        algorithm
            o1 := i1 * i2;
            annotation(Inline=false,derivative(zeroDerivative=i2)=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            output Real o1_der;
        algorithm
            o1_der := F(i1_der, i2);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        Real b;
        constant Real p = 2;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = F(b, if p > 0 then p else 0);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test6",
            description="Test function inlining during index reduction",
            flatModel="
fclass IndexReduction.FunctionInlining.Test6
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real b;
 constant Real p = 2;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_x;
 Real _der_der_y;
 Real _der_der_b;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test6.F(b, 2.0);
 b = time;
 2 * x * _der_x + 2 * y * der(y) = IndexReduction.FunctionInlining.Test6.F(_der_b, 2.0);
 _der_b = 1.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = IndexReduction.FunctionInlining.Test6.F(_der_der_b, 2.0);
 _der_der_b = 0.0;

public
 function IndexReduction.FunctionInlining.Test6.F
  input Real i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := i1 * i2;
  return;
 annotation(derivative(zeroDerivative = i2) = IndexReduction.FunctionInlining.Test6.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test6.F;

end IndexReduction.FunctionInlining.Test6;
")})));
    end Test6;

    model Test7
        function F
            input Real i1;
            input Real i2;
            output Real o1;
        algorithm
            o1 := if i1 > i2 then i1 else i2;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            input Real i2_der;
            output Real o1_der;
        algorithm
            o1_der := if i1 > i2 then i1_der else i2_der;
            annotation(Inline=false,derivative(order=2)=F_der2);
        end F_der;
    
        function F_der2
            input Real i1;
            input Real i2;
            input Real i1_der;
            input Real i2_der;
            input Real i1_der2;
            input Real i2_der2;
            output Real o1_der2;
        algorithm
            o1_der2 := if i1 > i2 then i1_der2 else i2_der2;
            annotation(Inline=true);
        end F_der2;
    
        Real x(stateSelect=StateSelect.prefer);
        Real y(stateSelect=StateSelect.prefer);
        Real vx(stateSelect=StateSelect.prefer);
        Real vy(stateSelect=StateSelect.prefer);
        Real a;
        Real b;
        constant Real p = 2;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = b;
        b = F(x, y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test7",
            description="Test function inlining during index reduction. This test requires that temporary equations and variables (introduced during index reduction) are hidden from munkres.",
            flatModel="
fclass IndexReduction.FunctionInlining.Test7
 Real x(stateSelect = StateSelect.prefer);
 Real y(stateSelect = StateSelect.prefer);
 Real vx(stateSelect = StateSelect.prefer);
 Real vy(stateSelect = StateSelect.prefer);
 Real a;
 Real b;
 constant Real p = 2;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_x;
 Real _der_der_y;
 Real _der_der_b;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = b;
 b = IndexReduction.FunctionInlining.Test7.F(x, y);
 2 * x * _der_x + 2 * y * der(y) = _der_b;
 _der_b = IndexReduction.FunctionInlining.Test7.F_der(x, y, _der_x, der(y));
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 2 * x * _der_der_x + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = _der_der_b;
 _der_der_b = noEvent(if x > y then _der_der_x else _der_der_y);

public
 function IndexReduction.FunctionInlining.Test7.F
  input Real i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := if i1 > i2 then i1 else i2;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test7.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test7.F;

 function IndexReduction.FunctionInlining.Test7.F_der
  input Real i1;
  input Real i2;
  input Real i1_der;
  input Real i2_der;
  output Real o1_der;
 algorithm
  o1_der := if i1 > i2 then i1_der else i2_der;
  return;
 annotation(derivative(order = 2) = IndexReduction.FunctionInlining.Test7.F_der2,Inline = false);
 end IndexReduction.FunctionInlining.Test7.F_der;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end IndexReduction.FunctionInlining.Test7;
")})));
    end Test7;

    model Test8
        function F
            input Real i1;
            input Real i2;
            output Real o1;
            output Integer o2;
        algorithm
            o1 := i1 + i2;
            o2 := 1;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            input Real i2_der;
            output Real o1_der;
        algorithm
            (o1_der, ) := F(i1_der, i2_der);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        Real b;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        (b,) = F(x, y);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test8",
            description="Test function inlining during index reduction. This test requires that temporary equations and variables (introduced during index reduction) are hidden from munkres.",
            flatModel="
fclass IndexReduction.FunctionInlining.Test8
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real b;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_x;
 Real _der_der_y;
 Real _der_der_b;
 Real temp_5;
 Real temp_10;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 (b, ) = IndexReduction.FunctionInlining.Test8.F(x, y);
 b = time;
 (temp_5, ) = IndexReduction.FunctionInlining.Test8.F(_der_x, der(y));
 _der_b = temp_5;
 _der_b = 1.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 (temp_10, ) = IndexReduction.FunctionInlining.Test8.F(_der_der_x, _der_der_y);
 _der_der_b = temp_10;
 _der_der_b = 0.0;

public
 function IndexReduction.FunctionInlining.Test8.F
  input Real i1;
  input Real i2;
  output Real o1;
  output Integer o2;
 algorithm
  o1 := i1 + i2;
  o2 := 1;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test8.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test8.F;

end IndexReduction.FunctionInlining.Test8;
")})));
    end Test8;

end FunctionInlining;

end IndexReduction;

