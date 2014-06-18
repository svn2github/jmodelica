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

end FmiXMLTests;
