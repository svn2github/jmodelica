package ComplianceTests



model String_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ComplianceErrorTestCase(name="String_ComplErr",
        description="Compliance error for String variables",
                                               errorMessage=
"Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 73, column 9:
  String variables are not supported
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 74, column 19:
  String variables are not supported
")})));


 String str1="s1";
 parameter String str2="s2";

end String_ComplErr;

model IntegerVariable_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ComplianceErrorTestCase(name="IntegerVariable_ComplErr",
        description="Compliance error for integer variables",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 87, column 9:
  Integer variables are not supported, only constants and parameters
")})));


Integer i=1;

end IntegerVariable_ComplErr;

model BooleanVariable_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ComplianceErrorTestCase(name="BooleanVariable_ComplErr",
        description="Compliance error for boolean variables",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 103, column 10:
  Boolean variables are not supported, only constants and parameters
")})));

 Boolean b=true;

end BooleanVariable_ComplErr;

model ConditionalComponents_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ComplianceErrorTestCase(name="ConditionalComponents_ComplErr",
        description="Compliance error for conditional components",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 124, column 7:
  Conditional components are not supported

")})));

 Real x=1;
 Real y=1 if false;

end ConditionalComponents_ComplErr;


model ArrayOfRecords_Warn
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.WarningTestCase(
         name="ArrayOfRecords_Warn",
         description="Compliance warning for arrays of records with index variability > parameter",
         errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
At line 79, column 3:
  Using arrays of records with indices of higher than parameter variability is currently not supported when compiling with CppAD
")})));

 function f
  input Real i;
  output R[2] a;
 algorithm
  a := {R(1,2), R(3,4)};
  a[integer(i)].a := 0;
 end f;

 record R
  Real a;
  Real b;
 end R;
 
 R x[2] = f(1);
end ArrayOfRecords_Warn;


//model ExternalFunction_ComplErr
// annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
//     JModelica.UnitTesting.ComplianceErrorTestCase(
//         name="ExternalFunction_ComplErr",
//         description="Compliance error for external functions",
//         errorMessage="
//1 errors found:
//Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
//Compliance error at line 105, column 3:
//  External functions are not supported
//")})));

// function f
//  output Real x;
//  external "C";
// end f;
 
// Real x = f();
//end ExternalFunction_ComplErr;


model WhenStmt_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="WhenStmt_ComplErr",
         description="Compliance error for when statements",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 126, column 2:
  When statements are not supported
")})));

 Real x;
algorithm
 when (time < 2) then
  x := 5;
 end when;
end WhenStmt_ComplErr;


model WhenEqu_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="WhenEqu_ComplErr",
         description="Compliance error for when equations",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 146, column 2:
  Unsupported equation type
")})));

 Real x;
equation
 when (time < 2) then
  x = 5;
 end when;
end WhenEqu_ComplErr;


model UnsupportedBuiltins1_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="UnsupportedBuiltins1_ComplErr",
         description="Compliance error for unsupported builtins",
         errorMessage="
8 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 165, column 3:
  The scalar() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 166, column 3:
  The vector() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 167, column 3:
  The matrix() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 168, column 3:
  The diagonal() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 169, column 3:
  The product() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 170, column 3:
  The outerProduct() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 171, column 3:
  The symmetric() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 172, column 3:
  The skew() function-like operator is not supported
")})));

 equation
  scalar(1);
  vector(1);
  matrix(1);
  diagonal(1 + "2");
  product(1);
  outerProduct(1);
  symmetric(1);
  skew(1);
end UnsupportedBuiltins1_ComplErr;


model UnsupportedBuiltins2_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="UnsupportedBuiltins2_ComplErr",
         description="Compliance error for unsupported builtins",
         errorMessage="
10 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 210, column 3:
  The sign() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 211, column 3:
  The class Integer is not a function
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 212, column 3:
  The class String is not a function
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 213, column 3:
  The div() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 214, column 3:
  The mod() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 215, column 3:
  The rem() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 216, column 3:
  The ceil() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 217, column 3:
  The floor() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 218, column 3:
  The delay() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 219, column 3:
  The cardinality() function-like operator is not supported
")})));

 equation
  sign(1);
  Integer();
  String();
  div(1);
  mod();
  rem(1);
  ceil();
  floor();
  delay(1);
  cardinality();
end UnsupportedBuiltins2_ComplErr;


model UnsupportedBuiltins3_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="UnsupportedBuiltins3_ComplErr",
         description="Compliance error for unsupported builtins",
         errorMessage="
8 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 263, column 3:
  The semiLinear() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 265, column 3:
  The function initial() is undeclared
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 266, column 3:
  The terminal() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 267, column 3:
  The smooth() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 268, column 3:
  The sample() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 269, column 3:
  The pre() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 270, column 3:
  The edge() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 271, column 3:
  The reinit() function-like operator is not supported
")})));

 equation
  semiLinear();
  initial(1);
  terminal();
  smooth(1);
  sample();
  pre(1);
  edge();
  reinit(1);
end UnsupportedBuiltins3_ComplErr;


model UnsupportedBuiltins4_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="UnsupportedBuiltins4_ComplErr",
         description="Compliance error for unsupported builtins",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 263, column 3:
  The assert() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 266, column 3:
  The terminate() function-like operator is not supported
")})));

 equation
  assert(1);
  terminate();
end UnsupportedBuiltins4_ComplErr;


model StringConcat_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="StringConcat_ComplErr",
         description="Compliance error for string concatenation",
         errorMessage="
6 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 308, column 9:
  String variables are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 308, column 13:
  String concatenation is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 309, column 12:
  String variables are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 309, column 16:
  String concatenation is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 310, column 12:
  String variables are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 310, column 16:
  String concatenation is not supported
")})));

 Real a = 1 + 2;
 String b = "1" + "2";
 String[2] c = { "1", "2" } .+ "3";
 String[2] d = { "1", "2" } + { "3", "4" };
end StringConcat_ComplErr;


model ArrayCellMod_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="ArrayCellMod_ComplErr",
         description="Compliance error for modifiers of specific array elements",
         errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 361, column 8:
  Array size mismatch in declaration of b, size of declaration is [2] and size of binding expression is []
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 364, column 5:
  Modifiers of specific array elements are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 364, column 14:
  Modifiers of specific array elements are not supported
")})));

 model A
  Real b[2];
 end A;
 
 A a(b[1] = 1, b[1](start=2));
end ArrayCellMod_ComplErr;


end ComplianceTests;
