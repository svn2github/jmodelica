package CADCodeGenTests

model CADsin
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADsin",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = sin(v_0);
jmi_ad_var_t d_1 = d_0 * cos(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = sin(x1);
	x1 = 1;
end CADsin;

model CADcos
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADcos",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = cos(v_0);
jmi_ad_var_t d_1 = d_0 * -sin(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

  Real y;
  Real x1(start=1.5); 
equation 
  y = cos(x1);
  x1 = 1;
end CADcos;

model CADtan
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADtan",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = tan(v_0);
jmi_ad_var_t d_1 = d_0 * 1/(cos(v_0)*cos(v_0));
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = tan(x1);
	x1 = 1;
end CADtan;

model CADasin
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADasin",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = asin(v_0);
jmi_ad_var_t d_1 = d_0 * 1/(sqrt(1 -v_0*v_0));
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = asin(x1);
	x1 = 1;
end CADasin;

model CADacos
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADacos",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = acos(v_0);
jmi_ad_var_t d_1 = -d_0 * 1/(sqrt(1 -v_0*v_0));
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = acos(x1);
	x1 = 1;
end CADacos;

model CADatan
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADatan",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = atan(v_0);
jmi_ad_var_t d_1 = d_0 * 1/(1 +v_0*v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = atan(x1);
	x1 = 1;
end CADatan;

model CADatan2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADatan2",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = _x2_2;
jmi_ad_var_t d_1 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_2 = atan2(v_0,v_1);
jmi_ad_var_t d_2 = (d_0 * v_1 - v_0 * d_1 ) / ( v_1*v_1 + v_0*v_0);
jmi_ad_var_t v_3 = _y_0;
jmi_ad_var_t d_3 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_2 - v_3;
(*dF)[0] = d_2 - d_3;
jmi_ad_var_t v_4 = 1;
jmi_ad_var_t d_4 = 0;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
jmi_ad_var_t v_6 = 1.5;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = -v_6;
jmi_ad_var_t d_7 = -d_6;
jmi_ad_var_t v_8 = _x2_2;
jmi_ad_var_t d_8 = (*dz)[2-jmi->offs_real_dx];
(*res)[2] = v_7 - v_8;
(*dF)[2] = d_7 - d_8;
")})));

	Real y;
	Real x1(start=1.5);
	Real x2(start=2.0);
equation
	y = atan2(x1,x2);
	x1 = 1;
	x2 = (-1.5);
end CADatan2;

model CADsinh
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADsinh",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = sinh(v_0);
jmi_ad_var_t d_1 = d_0 * cosh(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = sinh(x1);
	x1 = 1;
end CADsinh;

model CADcosh
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADcosh",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = cosh(v_0);
jmi_ad_var_t d_1 = d_0 * sinh(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = cosh(x1);
	x1 = 1;
end CADcosh;

model CADtanh
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADtanh",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = tanh(v_0);
jmi_ad_var_t d_1 = d_0 * (1 - tanh(v_0) * tanh(v_0));
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = tanh(x1);
	x1 = 1;
end CADtanh;

model CADexp
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADexp",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = exp(v_0);
jmi_ad_var_t d_1 = d_0 * exp(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = exp(x1);
	x1 = 1;
end CADexp;

model CADlog
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADlog",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = log(v_0);
jmi_ad_var_t d_1 = d_0 * 1/(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 2;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = log(x1);
	x1 = 2;
end CADlog;

model CADlog10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADlog10",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = log10(v_0);
jmi_ad_var_t d_1 = d_0 * log10(exp(1))*1/(v_0);
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = log10(x1);
	x1 = 1;
end CADlog10;

model CADsqrt
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADsqrt",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = sqrt(v_0);
jmi_ad_var_t d_1 = d_0 * 1/(2*sqrt(v_0));
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 2;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = _x1_1;
jmi_ad_var_t d_4 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_3 - v_4;
(*dF)[1] = d_3 - d_4;
")})));

 	Real y;
	Real x1(start=1.5);
equation
	y = sqrt(x1);
	x1 = 2;
end CADsqrt;

model CADadd
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADadd",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = _x2_2;
jmi_ad_var_t d_1 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_2 = v_0 + v_1;
jmi_ad_var_t d_2 = d_0 + d_1;
jmi_ad_var_t v_3 = _y_0;
jmi_ad_var_t d_3 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_2 - v_3;
(*dF)[0] = d_2 - d_3;
jmi_ad_var_t v_4 = 1;
jmi_ad_var_t d_4 = 0;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
jmi_ad_var_t v_6 = 3;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = _x2_2;
jmi_ad_var_t d_7 = (*dz)[2-jmi->offs_real_dx];
(*res)[2] = v_6 - v_7;
(*dF)[2] = d_6 - d_7;
")})));

	Real y;
	Real x1(start=1.5);
	Real x2(start=2.0);
equation
	y = x1 + x2;
	x1 = 1;
	x2 = 3;
end CADadd;

model CADsub
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADsub",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = _x2_2;
jmi_ad_var_t d_1 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_2 = v_0 - v_1;
jmi_ad_var_t d_2 = d_0 - d_1;
jmi_ad_var_t v_3 = _y_0;
jmi_ad_var_t d_3 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_2 - v_3;
(*dF)[0] = d_2 - d_3;
jmi_ad_var_t v_4 = 1;
jmi_ad_var_t d_4 = 0;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
jmi_ad_var_t v_6 = 3;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = _x2_2;
jmi_ad_var_t d_7 = (*dz)[2-jmi->offs_real_dx];
(*res)[2] = v_6 - v_7;
(*dF)[2] = d_6 - d_7;
")})));

	Real y;
	Real x1(start=1.5);
	Real x2(start=2.0);
equation
	y = x1 - x2;
	x1 = 1;
	x2 = 3;
end CADsub;

model CADmul
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADmul",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = _x2_2;
jmi_ad_var_t d_1 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_2 = v_0 * v_1;
jmi_ad_var_t d_2 = (d_0 * v_1 + v_0 * d_1);
jmi_ad_var_t v_3 = _y_0;
jmi_ad_var_t d_3 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_2 - v_3;
(*dF)[0] = d_2 - d_3;
jmi_ad_var_t v_4 = 1;
jmi_ad_var_t d_4 = 0;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
jmi_ad_var_t v_6 = 3;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = _x2_2;
jmi_ad_var_t d_7 = (*dz)[2-jmi->offs_real_dx];
(*res)[2] = v_6 - v_7;
(*dF)[2] = d_6 - d_7;
")})));

	Real y;
	Real x1(start=1.5);
	Real x2(start=2.0);
equation
	y = x1 * x2;
	x1 = 1;
	x2 = 3;
end CADmul;

model CADdiv
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADdiv",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = _x2_2;
jmi_ad_var_t d_1 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_2 = v_0 / v_1;
jmi_ad_var_t d_2 = (d_0 * v_1 - v_0 * d_1 ) / ( v_1 * v_1);
jmi_ad_var_t v_3 = _y_0;
jmi_ad_var_t d_3 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_2 - v_3;
(*dF)[0] = d_2 - d_3;
jmi_ad_var_t v_4 = 1;
jmi_ad_var_t d_4 = 0;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
jmi_ad_var_t v_6 = 3;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = _x2_2;
jmi_ad_var_t d_7 = (*dz)[2-jmi->offs_real_dx];
(*res)[2] = v_6 - v_7;
(*dF)[2] = d_6 - d_7;
")})));

	Real y;
	Real x1(start=1.5);
	Real x2(start=2.0);
equation
	y = x1 / x2;
	x1 = 1;
	x2 = 3;
end CADdiv;

model CADpow
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADpow",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = _x2_2;
jmi_ad_var_t d_1 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_2 = pow(v_0 , v_1);
jmi_ad_var_t d_2 = v_2 * (d_1 * log(fabs(v_0)) + v_1 * d_0 / v_0);
jmi_ad_var_t v_3 = _y_0;
jmi_ad_var_t d_3 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_2 - v_3;
(*dF)[0] = d_2 - d_3;
jmi_ad_var_t v_4 = 2;
jmi_ad_var_t d_4 = 0;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
jmi_ad_var_t v_6 = 3;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = _x2_2;
jmi_ad_var_t d_7 = (*dz)[2-jmi->offs_real_dx];
(*res)[2] = v_6 - v_7;
(*dF)[2] = d_6 - d_7;
")})));

	Real y;
	Real x1(start=1.5);
	Real x2(start=2.0);
equation
	y = x1^x2;
	x1 = 2;
	x2 = 3;
end CADpow;

model CADabs
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADabs",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = _x1_1;
jmi_ad_var_t d_0 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_1 = abs(v_0);
jmi_ad_var_t d_1;
if(v_0 < 0){
    d_1 = -d_0;
}else {
    d_1 = d_0;
}
jmi_ad_var_t v_2 = _y_0;
jmi_ad_var_t d_2 = (*dz)[0-jmi->offs_real_dx];
(*res)[0] = v_1 - v_2;
(*dF)[0] = d_1 - d_2;
jmi_ad_var_t v_3 = 1;
jmi_ad_var_t d_3 = 0;
jmi_ad_var_t v_4 = -v_3;
jmi_ad_var_t d_4 = -d_3;
jmi_ad_var_t v_5 = _x1_1;
jmi_ad_var_t d_5 = (*dz)[1-jmi->offs_real_dx];
(*res)[1] = v_4 - v_5;
(*dF)[1] = d_4 - d_5;
")})));

	Real y;
	Real x1(start=1.5);
equation
	y = abs(x1);
	x1 = -1;
end CADabs;

model SparseJacTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="SparseJacTest1",
         description="Test that sparsity information is generated correctly",
	 generate_dae_jacobian=true,
         template="
$C_DAE_equation_sparsity$
",
         generatedCode="
static const int CAD_dae_real_p_opt_n_nz = 0;
static const int CAD_dae_real_dx_n_nz = 5;
static const int CAD_dae_real_x_n_nz = 5;
static const int CAD_dae_real_u_n_nz = 5;
static const int CAD_dae_real_w_n_nz = 7;
static int CAD_dae_n_nz = 22;
static const int CAD_dae_nz_rows[22] = {0,1,2,3,4,0,1,2,3,4,2,3,4,8,8,2,5,3,6,4,7,8};
static const int CAD_dae_nz_cols[22] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,15,16,16,17,17,18};
")})));

 parameter Real p1=2;
 parameter Integer p2 = 1;
 parameter Boolean p3 = false;
 Real x[3]; 
 Real x2[2];
 Real y[3];
 Real y2;
 input Real u[3];
 input Real u2[2];
equation
 der(x2) = -x2;
 der(x) = x + y + u;
 y = {1,2,3};
 y2 = sum(u2);
end SparseJacTest1;

end CADCodeGenTests;
