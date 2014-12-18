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
 eval parameter Boolean torque.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 parameter Modelica.SIunits.MomentOfInertia inertia1.J(min = 0,start = 1) \"Moment of inertia\";
 parameter Real idealGear.ratio(start = 1) \"Transmission ratio (flange_a.phi/flange_b.phi)\";
 parameter StateSelect inertia1.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia1.phi(stateSelect = inertia1.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia1.w(stateSelect = inertia1.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia1.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.MomentOfInertia inertia3.J(min = 0,start = 1) \"Moment of inertia\";
 Modelica.SIunits.Angle idealGear.phi_a \"Angle between left shaft flange and support\";
 Modelica.SIunits.Angle idealGear.phi_b \"Angle between right shaft flange and support\";
 eval parameter Boolean idealGear.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
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
 eval parameter Boolean damper.useHeatPort = false \"=true, if heatPort is enabled\" /* false */;
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
            description="Test double differentiation whit state select avoid or never during index reduction",
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

