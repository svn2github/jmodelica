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
