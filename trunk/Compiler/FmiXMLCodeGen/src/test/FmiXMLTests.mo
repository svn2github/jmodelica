/*
    Copyright (C) 2014 Modelon AB

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

package FmiXMLTests

model DisplayUnit1
	type A = Real(unit="N", displayUnit="kN");
	A a = time;
	Real b(unit="J", displayUnit="kWh") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit1",
            description="Check that offset & gain are not generated incorrectly for units",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
	<BaseUnit unit=\"N\">
		<DisplayUnitDefinition displayUnit=\"kN\" />
	</BaseUnit>
	<BaseUnit unit=\"J\">
		<DisplayUnitDefinition displayUnit=\"kWh\" />
	</BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit1;

model DisplayUnit2
	type A = Real(unit="N", displayUnit="kN");
	A a = time;
	Real b(unit="J") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit2",
            description="Check that base units without display units are generated",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
	<BaseUnit unit=\"N\">
		<DisplayUnitDefinition displayUnit=\"kN\" />
	</BaseUnit>
	<BaseUnit unit=\"J\">
	</BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit2;

model DisplayUnit3
	type A = Real(unit="N", displayUnit="kN");
	A a = time;
	Real b(unit="J", displayUnit="kWh") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit3",
            description="Check that offset & gain are not generated incorrectly for units",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
	<Unit name=\"N\">
		<DisplayUnit name=\"kN\" />
	</Unit>
	<Unit name=\"J\">
		<DisplayUnit name=\"kWh\" />
	</Unit>
</UnitDefinitions>
")})));
end DisplayUnit3;

model DisplayUnit4
	type A = Real(unit="N", displayUnit="kN");
	A a = time;
	Real b(unit="J") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit4",
            description="Check that base units without display units are generated",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
	<Unit name=\"N\">
		<DisplayUnit name=\"kN\" />
	</Unit>
	<Unit name=\"J\">
	</Unit>
</UnitDefinitions>
")})));
end DisplayUnit4;

model Fmi1StartAttribute
    constant Real independent1(start=1);
    constant Real dependent1(fixed=false) = independent1*independent1;
    
    constant Real independent2(start=1);
    constant Real dependent2(fixed=true) = independent2*independent2;
    
    constant Real independent3(start=1);
    constant Real dependent3 = independent3*independent3;
    
    parameter Real independent4(start=1);
    parameter Real dependent4(fixed=false);
    
    parameter Real independent5(start=1);
    parameter Real dependent5(fixed=true) = independent5*independent5;
    
    parameter Real independent6(start=1);
    parameter Real dependent6 = independent6*independent6;
    
    Real x1(start=0);
    Real x2"start=0";
    Real x3(fixed=false, start=0);
    Real x4(fixed=true, start=0);
    Real x5"fixed=true";
  
  initial equation
    dependent4 = independent4*independent4;
    //x3*x3 = 4;

  equation
    der(x1) = x1;
    der(x2) = x2;
    der(x3) = x3;
    der(x4) = x4;
    der(x5) = x5;
    
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1StartAttribute",
            description="Check parameters without binding expressions",
            fmi_version="1.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"dependent1\" valueReference=\"1\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent2\" valueReference=\"3\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent3\" valueReference=\"5\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent4\" valueReference=\"9\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent5\" valueReference=\"10\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent6\" valueReference=\"11\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent1\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent2\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent3\" valueReference=\"4\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent4\" valueReference=\"6\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent5\" valueReference=\"7\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent6\" valueReference=\"8\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"x1\" valueReference=\"17\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x1)\" valueReference=\"12\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"x2\" valueReference=\"18\" description=\"start=0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x2)\" valueReference=\"13\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"x3\" valueReference=\"19\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x3)\" valueReference=\"14\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"x4\" valueReference=\"20\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x4)\" valueReference=\"15\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"x5\" valueReference=\"21\" description=\"fixed=true\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x5)\" valueReference=\"16\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1StartAttribute;

model Fmi2StartAttribute
    constant Real independent1(start=1);
    constant Real dependent1(fixed=false) = independent1*independent1;
    
    constant Real independent2(start=1);
    constant Real dependent2(fixed=true) = independent2*independent2;
    
    constant Real independent3(start=1);
    constant Real dependent3 = independent3*independent3;
    
    parameter Real independent4(start=1);
    parameter Real dependent4(fixed=false);
    
    parameter Real independent5(start=1);
    parameter Real dependent5(fixed=true) = independent5*independent5;
    
    parameter Real independent6(start=1);
    parameter Real dependent6 = independent6*independent6;
    
    Real x1(start=0);
    Real x2"start=0";
    Real x3(fixed=false, start=0);
    Real x4(fixed=true, start=0);
    Real x5"fixed=true";
  
  initial equation
    dependent4 = independent4*independent4;
    //x3*x3 = 4;

  equation
    der(x1) = x1;
    der(x2) = x2;
    der(x3) = x3;
    der(x4) = x4;
    der(x5) = x5;
    
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2StartAttribute",
            description="Check parameters without binding expressions",
            fmi_version="2.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"dependent1\" valueReference=\"1\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent2\" valueReference=\"3\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent3\" valueReference=\"5\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent4\" valueReference=\"9\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent5\" valueReference=\"10\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependent6\" valueReference=\"11\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent1\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent2\" valueReference=\"2\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent3\" valueReference=\"4\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent4\" valueReference=\"6\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent5\" valueReference=\"7\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent6\" valueReference=\"8\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"x1\" valueReference=\"17\" causality=\"local\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x1)\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"13\" />
    </ScalarVariable>
    <ScalarVariable name=\"x2\" valueReference=\"18\" description=\"start=0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x2)\" valueReference=\"13\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"15\" />
    </ScalarVariable>
    <ScalarVariable name=\"x3\" valueReference=\"19\" causality=\"local\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x3)\" valueReference=\"14\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"17\" />
    </ScalarVariable>
    <ScalarVariable name=\"x4\" valueReference=\"20\" causality=\"local\" variability=\"continuous\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x4)\" valueReference=\"15\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"19\" />
    </ScalarVariable>
    <ScalarVariable name=\"x5\" valueReference=\"21\" description=\"fixed=true\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x5)\" valueReference=\"16\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"21\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi2StartAttribute;

model Fmi1Enumerations
  type E = enumeration (A,B,C);
  
  E one(start = E.A);
  E two(start = E.B);
  E three(start = E.C);
  
  equation
    one = E.A;
    two = E.B;
    three = E.C;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1Enumerations",
            description="Check parameters without binding expressions",
            fmi_version="1.0",
            template="
$typeDefinitions$
$modelVariables$",
            generatedCode="
<TypeDefinitions>
    <Type name=\"FmiXMLTests.Fmi1Enumerations.E\">
        <EnumerationType min=\"1\" max=\"3\">
            <Item name=\"A\" />
            <Item name=\"B\" />
            <Item name=\"C\" />
        </EnumerationType>
    </Type>
</TypeDefinitions>
<ModelVariables>
    <ScalarVariable name=\"one\" valueReference=\"268435456\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi1Enumerations.E\" start=\"1\" />
    </ScalarVariable>
    <ScalarVariable name=\"three\" valueReference=\"268435458\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi1Enumerations.E\" start=\"3\" />
    </ScalarVariable>
    <ScalarVariable name=\"two\" valueReference=\"268435457\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi1Enumerations.E\" start=\"2\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1Enumerations;

model Fmi2Enumerations
  type E = enumeration (A,B,C);
  
  E one(start = E.A);
  E two(start = E.B);
  E three(start = E.C);
  
  equation
    one = E.A;
    two = E.B;
    three = E.C;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2Enumerations",
            description="Check parameters without binding expressions",
            fmi_version="2.0",
            template="
$typeDefinitions$
$modelVariables$",
            generatedCode="
<TypeDefinitions>
    <SimpleType name=\"FmiXMLTests.Fmi2Enumerations.E\">
        <Enumeration>
            <Item name=\"A\" value=\"1\" />
            <Item name=\"B\" value=\"2\" />
            <Item name=\"C\" value=\"3\" />
        </Enumeration>
    </SimpleType>
</TypeDefinitions>
<ModelVariables>
    <ScalarVariable name=\"one\" valueReference=\"268435456\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi2Enumerations.E\" start=\"1\" />
    </ScalarVariable>
    <ScalarVariable name=\"three\" valueReference=\"268435458\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi2Enumerations.E\" start=\"3\" />
    </ScalarVariable>
    <ScalarVariable name=\"two\" valueReference=\"268435457\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi2Enumerations.E\" start=\"2\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi2Enumerations;

model Fmi1Aliases1

    parameter Real original(start = 1.0);
    parameter Real alias = original;
    parameter Real negatedAlias = - original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1Aliases1",
            description="FMI 1.0 alias test for parameters",
            fmi_version="1.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"alias\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"negatedAlias\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"original\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1Aliases1;

model Fmi1Aliases2

    Real original(start = 1.0);
    Real alias;
    Real negatedAlias;
    
    equation
        alias = original;
        negatedAlias = -original;
        der(original) = original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1Aliases2",
            description="FMI 1.0 alias test for reals",
            fmi_version="1.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"alias\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"negatedAlias\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"negatedAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"original\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" fixed=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(original)\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1Aliases2;

model Fmi2Aliases1

    parameter Real original(start = 1.0);
    parameter Real alias = original;
    parameter Real negatedAlias = - original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2Aliases1",
            description="FMI 2.0 alias test for parameters",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"alias\" valueReference=\"1\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"negatedAlias\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"original\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"3\" />
        <Unknown index=\"2\" dependencies=\"3\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end Fmi2Aliases1;

model Fmi2Aliases2

    Real original(start = 1.0);
    Real alias;
    Real negatedAlias;
    
    equation
        alias = original;
        negatedAlias = -original;
        der(original) = original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2Aliases2",
            description="FMI 2.0 alias test for reals",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"alias\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"negatedAlias\" valueReference=\"134217729\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"original\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(original)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"3\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"4\" dependencies=\"3\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"3\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end Fmi2Aliases2;

model FixedParameters2

    parameter Real fixed1(fixed=false);
    parameter Real independent = 4;
  
  initial equation
    fixed1 = independent;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="FixedParameters2",
            description="Check parameters with binding expressions",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"fixed1\" valueReference=\"1\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"4.0\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"2\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end FixedParameters2;

model FixedParameters3

    parameter Real independent1 = 1.0;
    parameter Real fixed1(fixed=true) = independent1*independent1;
    
    parameter Real independent2 = 1.0;
    parameter Real fixed2 = independent2*independent2 "fixed=true is default";
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="FixedParameters3",
            description="Check parameters with and without the fixed attribute",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"fixed1\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"fixed2\" valueReference=\"3\" description=\"fixed=true is default\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent1\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independent2\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"3\" />
        <Unknown index=\"2\" dependencies=\"4\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end FixedParameters3;

model ParameterDependencies1
  function f1
    input Real x;
    output Real y;
  algorithm
    y := x*x;
    annotation(Inline=false);
  end f1;

    Real x1, x2, x3, x4;
    parameter Real independentParameter1 = 1.0;
    parameter Real independentParameter2 = 1.0;
    parameter Real dependentParameter(fixed=true) = independentParameter1 * independentParameter1;
  
  initial equation
    //Block 1
    x1 = f1(x1);
    //Block 2
    x2 = f1(x1 * x2) + independentParameter2;
    //Block 3
    x3 = f1(x2 * x3) + dependentParameter;
    //Block 4
    x4 = f1(x3 * x4); 
  equation
    der(x1) = x1;
    der(x2) = x2;
    der(x3) = x3;
    der(x4) = x4;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="ParameterDependencies1",
            description="Check that the initial unknowns are correct",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"dependentParameter\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"independentParameter1\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independentParameter2\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"x1\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x1)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"4\" />
    </ScalarVariable>
    <ScalarVariable name=\"x2\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x2)\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"6\" />
    </ScalarVariable>
    <ScalarVariable name=\"x3\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x3)\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"8\" />
    </ScalarVariable>
    <ScalarVariable name=\"x4\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x4)\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"10\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"5\" dependencies=\"4\" />
        <Unknown index=\"7\" dependencies=\"6\" />
        <Unknown index=\"9\" dependencies=\"8\" />
        <Unknown index=\"11\" dependencies=\"10\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"2\" />
        <Unknown index=\"4\" dependencies=\"\" />
        <Unknown index=\"5\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"3\" />
        <Unknown index=\"7\" dependencies=\"3\" />
        <Unknown index=\"8\" dependencies=\"2 3\" />
        <Unknown index=\"9\" dependencies=\"2 3\" />
        <Unknown index=\"10\" dependencies=\"2 3\" />
        <Unknown index=\"11\" dependencies=\"2 3\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end ParameterDependencies1;

model ParameterDependencies2
    Real x1, x2, x3;
    parameter Real independentParameter1 = 1.0;
    parameter Real independentParameter2 = 1.0;
    parameter Real dependentParameter1(fixed=false);
    parameter Real dependentParameter2(fixed=false);
    parameter Real dependentParameter3(fixed=false);
    parameter Real dependentParameter4(fixed=false);
    
    parameter Real dependentParameter5(fixed=true) = independentParameter2 * independentParameter2 "parameter equation";
  initial equation
    //Block 1
    dependentParameter1 = dependentParameter2 + independentParameter1;
    dependentParameter1 * dependentParameter2 = 1;
    //Block 2
    dependentParameter3 = dependentParameter4 + dependentParameter1 + dependentParameter5;
    dependentParameter3 * dependentParameter4 = 1;
  equation
    der(x1) = x1 + dependentParameter1;
    der(x2) = x2 + dependentParameter3;
    der(x3) = x3 + dependentParameter5;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="ParameterDependencies2",
            description="Check that the initial unknowns are correct",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"dependentParameter1\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependentParameter2\" valueReference=\"3\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependentParameter3\" valueReference=\"4\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependentParameter4\" valueReference=\"5\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"dependentParameter5\" valueReference=\"6\" description=\"parameter equation\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"independentParameter1\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"independentParameter2\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"x1\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x1)\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"8\" />
    </ScalarVariable>
    <ScalarVariable name=\"x2\" valueReference=\"11\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x2)\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"10\" />
    </ScalarVariable>
    <ScalarVariable name=\"x3\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x3)\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"12\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"9\" dependencies=\"8\" />
        <Unknown index=\"11\" dependencies=\"10\" />
        <Unknown index=\"13\" dependencies=\"12\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"6\" />
        <Unknown index=\"2\" dependencies=\"6\" />
        <Unknown index=\"3\" dependencies=\"6 7\" />
        <Unknown index=\"4\" dependencies=\"6 7\" />
        <Unknown index=\"5\" dependencies=\"7\" />
        <Unknown index=\"8\" dependencies=\"\" />
        <Unknown index=\"9\" dependencies=\"6\" />
        <Unknown index=\"10\" dependencies=\"\" />
        <Unknown index=\"11\" dependencies=\"6 7\" />
        <Unknown index=\"12\" dependencies=\"\" />
        <Unknown index=\"13\" dependencies=\"7\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end ParameterDependencies2;

model InitialUnknown1
  function f1
    input Real x;
    output Real y;
  algorithm
    y := x*x;
    annotation(Inline=false);
  end f1;
  
  function f2
    input Real x;
    output Real y;
  algorithm
    y := x*x;
    annotation(Inline=false);
  end f2;
  
  function f3
    input Real x1;
    input Real x2;
    input Real x3;
    input Real x4;
    input Real x5;
    output Real y;
  algorithm
    y := x1*x2*x3*x4*x5;
    annotation(Inline=false);
  end f3;
  
  function g1
    input Real x1;
    input Real x2;
    output Real y;
  algorithm
    y := x1*x1 + x2*x2;
    annotation(Inline=false);
  end g1;

    Real x1;
    Real x2;
    Real x3;
    output Real y;
    input Real u1,u2,u3;
    parameter Real p(start=1.0);
    Real t1,t2;
  initial equation
    y = 3.3;
    der(x2) = 0;
    x1 = 1.1;
  equation
    
    t1 + t2 = 1;
    t1      = p * p;
    
    der(x1) = f1(x2);
    der(x2) = f2(x1) + 3*p*p*x2 + 2*u1 + 3*u3;
    der(x3) = f3(x1,x3,u1,u2,u3);
    y = g1(x2, x3);

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="InitialUnknown1",
            description="Check that the initial unknowns are correct",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"p\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"t1\" valueReference=\"1\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"t2\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"u1\" valueReference=\"9\" causality=\"input\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"u2\" valueReference=\"10\" causality=\"input\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"u3\" valueReference=\"11\" causality=\"input\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <ScalarVariable name=\"x1\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x1)\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"7\" />
    </ScalarVariable>
    <ScalarVariable name=\"x2\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x2)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"9\" />
    </ScalarVariable>
    <ScalarVariable name=\"x3\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x3)\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"11\" />
    </ScalarVariable>
    <ScalarVariable name=\"y\" valueReference=\"12\" causality=\"output\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Outputs>
        <Unknown index=\"13\" dependencies=\"9 11\" />
    </Outputs>
    <Derivatives>
        <Unknown index=\"10\" dependencies=\"4 6 7 9\" />
        <Unknown index=\"8\" dependencies=\"9\" />
        <Unknown index=\"12\" dependencies=\"4 5 6 7 11\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"2\" dependencies=\"1\" />
        <Unknown index=\"3\" dependencies=\"1\" />
        <Unknown index=\"7\" dependencies=\"\" />
        <Unknown index=\"8\" dependencies=\"1 4 6\" />
        <Unknown index=\"9\" dependencies=\"1 4 6\" />
        <Unknown index=\"10\" dependencies=\"\" />
        <Unknown index=\"11\" dependencies=\"1 4 6\" />
        <Unknown index=\"12\" dependencies=\"1 4 5 6\" />
        <Unknown index=\"13\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end InitialUnknown1;

model SortingStates
    Real y,b,x,a;
  equation
    der(y) = time;
    der(x) = time;
    der(a) = time;
    der(b) = time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="SortingStatesXML",
            description="Check sorting of derivatives in model structure after value reference",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <ScalarVariable name=\"a\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(a)\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"1\" />
    </ScalarVariable>
    <ScalarVariable name=\"b\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(b)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"3\" />
    </ScalarVariable>
    <ScalarVariable name=\"x\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(x)\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"5\" />
    </ScalarVariable>
    <ScalarVariable name=\"y\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <ScalarVariable name=\"der(y)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"7\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"8\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"\" />
        <Unknown index=\"2\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"\" />
        <Unknown index=\"2\" dependencies=\"\" />
        <Unknown index=\"3\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
        <Unknown index=\"5\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"\" />
        <Unknown index=\"7\" dependencies=\"\" />
        <Unknown index=\"8\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end SortingStates;

end FmiXMLTests;
