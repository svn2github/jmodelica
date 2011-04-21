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
jmi_ad_var_t d_2;
if(v_0== 0){
d_2=0;
} else{
d_2 = v_2 * (d_1 * log(jmi_abs(v_0)) + v_1 * d_0 / v_0);
}
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
jmi_ad_var_t v_1 = jmi_abs(v_0);
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

model IfExpExample1
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="IfExpExample1",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t temp_v_0;
jmi_ad_var_t temp_d_0;
if(_sw(0)){
jmi_ad_var_t temp_v_1;
jmi_ad_var_t temp_d_1;
if(COND_EXP_LE(time, jmi_divide(AD_WRAP_LITERAL(3.141592653589793),AD_WRAP_LITERAL(2),\"Divide by zero: ( 3.141592653589793 ) / ( 2 )\"), JMI_TRUE, JMI_FALSE)){
jmi_ad_var_t v_2 = time;
jmi_ad_var_t d_2 = 0;
jmi_ad_var_t v_3 = sin(v_2);
jmi_ad_var_t d_3 = d_2 * cos(v_2);
temp_v_1 = v_3;
temp_d_1 = d_3;
}
else if(COND_EXP_LE(time, AD_WRAP_LITERAL(3.141592653589793), JMI_TRUE, JMI_FALSE)){
jmi_ad_var_t v_5 = AD_WRAP_LITERAL(1);
jmi_ad_var_t d_5 = 0;
temp_v_1 = v_5;
temp_d_1 = d_5;
}
else{
jmi_ad_var_t v_7 = time;
jmi_ad_var_t d_7 = 0;
jmi_ad_var_t v_8 = AD_WRAP_LITERAL(3.141592653589793);
jmi_ad_var_t d_8 = 0;
jmi_ad_var_t v_9 = AD_WRAP_LITERAL(2);
jmi_ad_var_t d_9 = 0;
jmi_ad_var_t v_10 = v_8 / v_9;
jmi_ad_var_t d_10 = (d_8 * v_9 - v_8 * d_9 ) / ( v_9 * v_9);
jmi_ad_var_t v_11 = v_7 - v_10;
jmi_ad_var_t d_11 = d_7 - d_10;
jmi_ad_var_t v_12 = sin(v_11);
jmi_ad_var_t d_12 = d_11 * cos(v_11);
temp_v_1 = v_12;
temp_d_1 = d_12;
}
jmi_ad_var_t v_1 = temp_v_1;
jmi_ad_var_t d_1 = temp_d_1;
jmi_ad_var_t v_13 = v_1;
jmi_ad_var_t d_13 = d_1;
temp_v_0 = v_13;
temp_d_0 = d_13;
}
else{
jmi_ad_var_t v_15 = AD_WRAP_LITERAL(3);
jmi_ad_var_t d_15 = 0;
jmi_ad_var_t v_16 = _x_0;
jmi_ad_var_t d_16 = (*dz)[1-jmi->offs_real_dx];
jmi_ad_var_t v_17 = v_15 * v_16;
jmi_ad_var_t d_17 = (d_15 * v_16 + v_15 * d_16);
jmi_ad_var_t v_18 = sin(v_17);
jmi_ad_var_t d_18 = d_17 * cos(v_17);
jmi_ad_var_t v_19 = v_18;
jmi_ad_var_t d_19 = d_18;
temp_v_0 = v_19;
temp_d_0 = d_19;
}
jmi_ad_var_t v_0 = temp_v_0;
jmi_ad_var_t d_0 = temp_d_0;
jmi_ad_var_t v_20 = _u_1;
jmi_ad_var_t d_20 = (*dz)[2-jmi->offs_real_dx];
(*res)[0] = v_0 - v_20;
(*dF)[0] = d_0 - d_20;
jmi_ad_var_t v_21 = _u_1;
jmi_ad_var_t d_21 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_22 = _der_x_2;
jmi_ad_var_t d_22 = (*dz)[0-jmi->offs_real_dx];
(*res)[1] = v_21 - v_22;
(*dF)[1] = d_21 - d_22;
")})));   
    Real x,u;
  equation
    u = if(x > 3) then noEvent(if time<=Modelica.Constants.pi/2 then sin(time) elseif 
              noEvent(time<=Modelica.Constants.pi) then 1 else sin(time-Modelica.Constants.pi/2)) else noEvent(sin(3*x));
    der(x) = u;
end IfExpExample1;

model IfExpExample2
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="IfExpExample2",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t temp_v_0;
jmi_ad_var_t temp_d_0;
if(_sw(0)){
jmi_ad_var_t v_1 = time;
jmi_ad_var_t d_1 = 0;
jmi_ad_var_t v_2 = sin(v_1);
jmi_ad_var_t d_2 = d_1 * cos(v_1);
temp_v_0 = v_2;
temp_d_0 = d_2;
}
else if(_sw(1)){
jmi_ad_var_t v_4 = AD_WRAP_LITERAL(1);
jmi_ad_var_t d_4 = 0;
temp_v_0 = v_4;
temp_d_0 = d_4;
}
else{
jmi_ad_var_t v_6 = time;
jmi_ad_var_t d_6 = 0;
jmi_ad_var_t v_7 = AD_WRAP_LITERAL(3.141592653589793);
jmi_ad_var_t d_7 = 0;
jmi_ad_var_t v_8 = AD_WRAP_LITERAL(2);
jmi_ad_var_t d_8 = 0;
jmi_ad_var_t v_9 = v_7 / v_8;
jmi_ad_var_t d_9 = (d_7 * v_8 - v_7 * d_8 ) / ( v_8 * v_8);
jmi_ad_var_t v_10 = v_6 - v_9;
jmi_ad_var_t d_10 = d_6 - d_9;
jmi_ad_var_t v_11 = sin(v_10);
jmi_ad_var_t d_11 = d_10 * cos(v_10);
temp_v_0 = v_11;
temp_d_0 = d_11;
}
jmi_ad_var_t v_0 = temp_v_0;
jmi_ad_var_t d_0 = temp_d_0;
jmi_ad_var_t v_12 = _u_1;
jmi_ad_var_t d_12 = (*dz)[2-jmi->offs_real_dx];
(*res)[0] = v_0 - v_12;
(*dF)[0] = d_0 - d_12;
jmi_ad_var_t v_13 = _u_1;
jmi_ad_var_t d_13 = (*dz)[2-jmi->offs_real_dx];
jmi_ad_var_t v_14 = _der_x_2;
jmi_ad_var_t d_14 = (*dz)[0-jmi->offs_real_dx];
(*res)[1] = v_13 - v_14;
(*dF)[1] = d_13 - d_14;
")})));
Real x,u;
equation
    u = if time<=Modelica.Constants.pi/2 then sin(time) elseif 
              time<=Modelica.Constants.pi then 1 else sin(time-Modelica.Constants.pi/2);
    der(x) = u;
end IfExpExample2;

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
