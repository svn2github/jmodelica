package CADCodeGenTests

model CADsin
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="CADsin",
         description="",
         generate_dae_jacobian=true,
         template="$C_DAE_equation_directional_derivative$",
         generatedCode="
jmi_ad_var_t v_0 = sin(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * cos(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = cos(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * -sin(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = tan(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * 1/(cos(_x1_1)*cos(_x1_1));
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = asin(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * 1/(sqrt(1 -_x1_1*_x1_1));
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = acos(_x1_1);
jmi_ad_var_t d_0 = -(*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * 1/(sqrt(1 -_x1_1*_x1_1));
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = atan(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * 1/(1 +_x1_1*_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = atan2(_x1_1,_x2_2);
jmi_ad_var_t d_0 = ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * _x2_2 - _x1_1 * (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] ) / ( _x2_2*_x2_2 + _x1_1*_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
jmi_ad_var_t v_1 = -1.5;
jmi_ad_var_t d_1 = -AD_WRAP_LITERAL(0);
(*res)[2] = v_1 - _x2_2;
(*dF)[2] = d_1 - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = sinh(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * cosh(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = cosh(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * sinh(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = tanh(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * (1 - tanh(_x1_1) * tanh(_x1_1));
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = exp(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * exp(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = log(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * 1/(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 2 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = log10(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * log10(exp(1))*1/(_x1_1);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = sqrt(_x1_1);
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * 1/(2*sqrt(_x1_1));
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 2 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = _x1_1 + _x2_2;
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] + (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
(*res)[2] = 3 - _x2_2;
(*dF)[2] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = _x1_1 - _x2_2;
jmi_ad_var_t d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
(*res)[2] = 3 - _x2_2;
(*dF)[2] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = _x1_1 * _x2_2;
jmi_ad_var_t d_0 = ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * _x2_2 + _x1_1 * (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
(*res)[2] = 3 - _x2_2;
(*dF)[2] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = _x1_1 / _x2_2;
jmi_ad_var_t d_0 = ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] * _x2_2 - _x1_1 * (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] ) / ( _x2_2 * _x2_2);
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 1 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
(*res)[2] = 3 - _x2_2;
(*dF)[2] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = pow(_x1_1 , _x2_2);
jmi_ad_var_t d_0;
if(_x1_1== 0){
d_0=0;
} else{
d_0 = v_0 * ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] * log(jmi_abs(_x1_1)) + _x2_2 * (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] / _x1_1);
}
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
(*res)[1] = 2 - _x1_1;
(*dF)[1] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
(*res)[2] = 3 - _x2_2;
(*dF)[2] = AD_WRAP_LITERAL(0) - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = jmi_abs(_x1_1);
jmi_ad_var_t d_0;
if(_x1_1 < 0){
    d_0 = -(*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
}else {
    d_0 = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
}
(*res)[0] = v_0 - _y_0;
(*dF)[0] = d_0 - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
jmi_ad_var_t v_1 = -1;
jmi_ad_var_t d_1 = -AD_WRAP_LITERAL(0);
(*res)[1] = v_1 - _x1_1;
(*dF)[1] = d_1 - (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = _time;
jmi_ad_var_t d_0 = (*dz)[jmi->offs_t];
jmi_ad_var_t v_1 = sin(v_0);
jmi_ad_var_t d_1 = d_0 * cos(v_0);
jmi_ad_var_t v_2 = _time;
jmi_ad_var_t d_2 = (*dz)[jmi->offs_t];
jmi_ad_var_t v_3 = AD_WRAP_LITERAL(3.141592653589793) / AD_WRAP_LITERAL(2);
jmi_ad_var_t d_3 = (AD_WRAP_LITERAL(0) * AD_WRAP_LITERAL(2) - AD_WRAP_LITERAL(3.141592653589793) * AD_WRAP_LITERAL(0) ) / ( AD_WRAP_LITERAL(2) * AD_WRAP_LITERAL(2));
jmi_ad_var_t v_4 = v_2 - v_3;
jmi_ad_var_t d_4 = d_2 - d_3;
jmi_ad_var_t v_5 = sin(v_4);
jmi_ad_var_t d_5 = d_4 * cos(v_4);
jmi_ad_var_t v_6= (COND_EXP_EQ(COND_EXP_LE(_time, jmi_divide(AD_WRAP_LITERAL(3.141592653589793),AD_WRAP_LITERAL(2),\"Divide by zero: ( 3.141592653589793 ) / ( 2 )\"), JMI_TRUE, JMI_FALSE),JMI_TRUE,v_1,(COND_EXP_EQ(COND_EXP_LE(_time, AD_WRAP_LITERAL(3.141592653589793), JMI_TRUE, JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(1),v_5))));
jmi_ad_var_t d_6= (COND_EXP_EQ(COND_EXP_LE(_time, jmi_divide(AD_WRAP_LITERAL(3.141592653589793),AD_WRAP_LITERAL(2),\"Divide by zero: ( 3.141592653589793 ) / ( 2 )\"), JMI_TRUE, JMI_FALSE),JMI_TRUE,d_1,(COND_EXP_EQ(COND_EXP_LE(_time, AD_WRAP_LITERAL(3.141592653589793), JMI_TRUE, JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(0),d_5))));
jmi_ad_var_t v_7 = v_6;
jmi_ad_var_t d_7 = d_6;
jmi_ad_var_t v_8 = AD_WRAP_LITERAL(3) * _x_0;
jmi_ad_var_t d_8 = (AD_WRAP_LITERAL(0) * _x_0 + AD_WRAP_LITERAL(3) * (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx]);
jmi_ad_var_t v_9 = sin(v_8);
jmi_ad_var_t d_9 = d_8 * cos(v_8);
jmi_ad_var_t v_10 = v_9;
jmi_ad_var_t d_10 = d_9;
jmi_ad_var_t v_11= (COND_EXP_EQ(_sw(0),JMI_TRUE,v_7,v_10));
jmi_ad_var_t d_11= (COND_EXP_EQ(_sw(0),JMI_TRUE,d_7,d_10));
(*res)[0] = v_11 - _u_1;
(*dF)[0] = d_11 - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
(*res)[1] = _u_1 - _der_x_2;
(*dF)[1] = (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
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
jmi_ad_var_t v_0 = _time;
jmi_ad_var_t d_0 = (*dz)[jmi->offs_t];
jmi_ad_var_t v_1 = sin(v_0);
jmi_ad_var_t d_1 = d_0 * cos(v_0);
jmi_ad_var_t v_2 = _time;
jmi_ad_var_t d_2 = (*dz)[jmi->offs_t];
jmi_ad_var_t v_3 = AD_WRAP_LITERAL(3.141592653589793) / AD_WRAP_LITERAL(2);
jmi_ad_var_t d_3 = (AD_WRAP_LITERAL(0) * AD_WRAP_LITERAL(2) - AD_WRAP_LITERAL(3.141592653589793) * AD_WRAP_LITERAL(0) ) / ( AD_WRAP_LITERAL(2) * AD_WRAP_LITERAL(2));
jmi_ad_var_t v_4 = v_2 - v_3;
jmi_ad_var_t d_4 = d_2 - d_3;
jmi_ad_var_t v_5 = sin(v_4);
jmi_ad_var_t d_5 = d_4 * cos(v_4);
jmi_ad_var_t v_6= (COND_EXP_EQ(_sw(0),JMI_TRUE,v_1,(COND_EXP_EQ(_sw(1),JMI_TRUE,AD_WRAP_LITERAL(1),v_5))));
jmi_ad_var_t d_6= (COND_EXP_EQ(_sw(0),JMI_TRUE,d_1,(COND_EXP_EQ(_sw(1),JMI_TRUE,AD_WRAP_LITERAL(0),d_5))));
(*res)[0] = v_6 - _u_1;
(*dF)[0] = d_6 - (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
(*res)[1] = _u_1 - _der_x_2;
(*dF)[1] = (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] - (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
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

model SparseJacTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="SparseJacTest2",
         description="Test that sparsity information is generated correctly",
	 generate_dae_jacobian=true,
         template="
$C_DAE_equation_sparsity$
",
         generatedCode="
static const int CAD_dae_real_p_opt_n_nz = 0;
static const int CAD_dae_real_dx_n_nz = 0;
static const int CAD_dae_real_x_n_nz = 0;
static const int CAD_dae_real_u_n_nz = 0;
static const int CAD_dae_real_w_n_nz = 4;
static int CAD_dae_n_nz = 4;
static const int CAD_dae_nz_rows[4] = {1,2,3,0};
static const int CAD_dae_nz_cols[4] = {0,1,2,3};
")})));
    function F1
      input Real x1[3];
      input Real x2;
      input Real x3;
      output Real y1;
      output Real y2[3];
    algorithm
      y1 := x1[1]+x2;
      y2 := {x1[1],x2,x3} + x1;
    end F1;
    Real y[3](start={1,2,3});
    Real a(start = 3);
    parameter Real x[3](start={3,2,2});
    parameter Real z(start=1);
    parameter Real w(start =3);
equation
    (a,y) = F1(x,z,w);

end SparseJacTest2;

model SparseJacTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="SparseJacTest3",
         description="Test that sparsity information is generated correctly",
	 generate_dae_jacobian=true,
         template="
$C_DAE_equation_sparsity$
",
         generatedCode="
static const int CAD_dae_real_p_opt_n_nz = 0;
static const int CAD_dae_real_dx_n_nz = 0;
static const int CAD_dae_real_x_n_nz = 0;
static const int CAD_dae_real_u_n_nz = 0;
static const int CAD_dae_real_w_n_nz = 12;
static int CAD_dae_n_nz = 12;
static const int CAD_dae_nz_rows[12] = {1,2,3,0,1,2,3,0,1,2,3,4};
static const int CAD_dae_nz_cols[12] = {0,1,2,3,3,3,3,4,4,4,4,4};
")})));
    function F1
      input Real x1[3];
      input Real x2;
      input Real x3;
      output Real y1;
      output Real y2[3];
    algorithm
      y1 := x1[1]+x2;
      y2 := {x1[1],x2,x3} + x1;
    end F1;
    Real y[3](start={1,2,3});
    Real a(start = 3);
    Real q = 3;
    parameter Real x[3](start={3,2,2});
    parameter Real z(start=1);
    parameter Real w(start =3);
equation
    (a,y) = F1(x,q,a);

end SparseJacTest3;

model SparseJacTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="SparseJacTest4",
         description="Test that sparsity information is generated correctly",
	 generate_dae_jacobian=true,
         template="
$C_DAE_equation_sparsity$
",
         generatedCode="
static const int CAD_dae_real_p_opt_n_nz = 0;
static const int CAD_dae_real_dx_n_nz = 0;
static const int CAD_dae_real_x_n_nz = 0;
static const int CAD_dae_real_u_n_nz = 12;
static const int CAD_dae_real_w_n_nz = 12;
static int CAD_dae_n_nz = 24;
static const int CAD_dae_nz_rows[24] = {0,1,2,3,0,1,2,3,0,1,2,3,1,2,3,0,1,2,3,0,1,2,3,4};
static const int CAD_dae_nz_cols[24] = {0,0,0,0,1,1,1,1,2,2,2,2,3,4,5,6,6,6,6,7,7,7,7,7};
")})));
    function F1
      input Real x1[3];
      input Real x2;
      input Real x3;
      output Real y1;
      output Real y2[3];
    algorithm
      y1 := x1[1]+x2;
      y2 := {x1[1],x2,x3} + x1;
    end F1;
    Real y[3](start={1,2,3});
    Real a(start = 3);
    Real q = 3;
    input Real x[3](start={3,2,2});
equation
    (a,y) = F1(x,q,a);

end SparseJacTest4;

model SparseJacTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CADCodeGenTestCase(
         name="SparseJacTest5",
         description="Test that sparsity information is generated correctly",
	 generate_dae_jacobian=true,
         template="
$C_DAE_equation_sparsity$
",
         generatedCode="
static const int CAD_dae_real_p_opt_n_nz = 0;
static const int CAD_dae_real_dx_n_nz = 15;
static const int CAD_dae_real_x_n_nz = 15;
static const int CAD_dae_real_u_n_nz = 0;
static const int CAD_dae_real_w_n_nz = 12;
static int CAD_dae_n_nz = 42;
static const int CAD_dae_nz_rows[42] = {0,1,2,3,4,0,1,2,3,5,0,1,2,3,6,0,1,2,3,4,0,1,2,3,5,0,1,2,3,6,1,2,3,0,1,2,3,0,1,2,3,7};
static const int CAD_dae_nz_cols[42] = {0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,7,8,9,9,9,9,10,10,10,10,10};

")})));
    function F1
      input Real x1[3];
      input Real x2;
      input Real x3;
      output Real y1;
      output Real y2[3];
    algorithm
      y1 := x1[1]+x2;
      y2 := {x1[1],x2,x3} + x1;
    end F1;
    Real y[3](start={1,2,3});
    Real a(start = 3);
    Real q = 3;
    Real x[3](start={3,2,2});
equation
    (a,y) = F1(der(x)+x,q,a);
    der(x) = -x;
end SparseJacTest5;


end CADCodeGenTests;
