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


end ComplianceTests;