/*
	Copyright (C) 2009 Modelon AB

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

package EvaluationTests
	
	
	
model VectorMul
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="VectorMul",
         description="Constant evaluation of vector multiplication",
         template="$XML_variables$",
         generatedCode="

		<ScalarVariable name=\"n\" valueReference=\"268435463\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Integer start=\"0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[1]\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[3]\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[1]\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[2]\" valueReference=\"4\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[3]\" valueReference=\"5\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"z\" valueReference=\"6\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"10.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"q\" valueReference=\"6\" variability=\"continuous\" causality=\"internal\" alias=\"alias\" >
			<Real relativeQuantity=\"false\" start=\"0.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>algebraic</VariableCategory>
		</ScalarVariable>")})));

	parameter Integer n = 3;
	parameter Real x[n] = 1:n;
	parameter Real y[n] = n:-1:1;
	parameter Real z = x * y;
	Real q = z;
end VectorMul;


model FunctionEval1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval1",
         description="Constant evaluation of functions: basic test",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x\" value=\"3.0\"/>
")})));

	function f
		input Real i;
		output Real o = i + 2.0;
		algorithm
	end f;
	
	parameter Real x = f(1.0);
end FunctionEval1;


model FunctionEval2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval2",
         description="Constant evaluation of functions: while and if",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x[1]\" value=\"1.0\"/>
	 <RealParameter name=\"x[2]\" value=\"1.0\"/>
	 <RealParameter name=\"x[3]\" value=\"2.0\"/>
	 <RealParameter name=\"x[4]\" value=\"3.0\"/>
	 <RealParameter name=\"x[5]\" value=\"5.0\"/>
	 <RealParameter name=\"x[6]\" value=\"8.0\"/>
")})));

	function fib
		input Real n;
		output Real a;
	protected
		Real b;
		Real c;
		Real i;
	algorithm
		a := 1;
		b := 1;
		if n < 3 then
			return;
		end if;
		i := 2;
		while i < n loop
			c := b;
			b := a;
			a := b + c;
			i := i + 1;
		end while;
	end fib;

	parameter Real x[6] = { fib(1), fib(2), fib(3), fib(4), fib(5), fib(6) };
end FunctionEval2;


model FunctionEval3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval3",
         description="Constant evaluation of functions: array inputs and for loops",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x\" value=\"48.0\"/>
")})));

	function f
		input Real[3] i;
		output Real o = 1;
	protected
		Real[size(i,1)] x;
	algorithm
		x := i + (1:size(i,1));
		for j in 1:size(i,1) loop
			o := o * x[j];
		end for;
	end f;
	
	parameter Real x = f({1,2,3});
end FunctionEval3;


model FunctionEval4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval4",
         description="Constant evaluation of functions: unknown array sizes",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x\" value=\"48.0\"/>
")})));

	function f
		input Real[:] i;
		output Real o = 1;
	protected
		Real[size(i,1)] x;
	algorithm
		x := i + (1:size(i,1));
		for j in 1:size(i,1) loop
			o := o * x[j];
		end for;
	end f;
	
	parameter Real x = f({1,2,3});
end FunctionEval4;


model FunctionEval5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval5",
         description="Constant evaluation of functions: using input as for index expression",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x\" value=\"6.0\"/>
")})));

	function f
		input Real[3] i;
		output Real o;
	algorithm
		o := 0;
		for x in i loop
			o := o + x;
		end for;
	end f;
	
	parameter Real x = f({1,2,3});
end FunctionEval5;


model FunctionEval6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="FunctionEval6",
         description="Constant evaluation of functions: array output",
         template="$XML_variables$",
         generatedCode="
		<ScalarVariable name=\"x[1]\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"0.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"0.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1]\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2]\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[1]\" valueReference=\"4\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[2]\" valueReference=\"5\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
")})));

	parameter Real x[2] = {1, 2};
	parameter Real y[2] = f(x);
	
	function f
		input Real i[2];
		output Real o[2];
	algorithm
		o := i;
	end f;
end FunctionEval6;


model FunctionEval7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="FunctionEval7",
         description="Constant evaluation of functions: array output, unknown size",
         template="$XML_variables$",
         generatedCode="
		<ScalarVariable name=\"x[1]\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"0.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"0.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1]\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2]\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[1]\" valueReference=\"4\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y[2]\" valueReference=\"5\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
")})));

	parameter Real x[2] = {1, 2};
	parameter Real y[2] = f(x);
	
	function f
		input Real i[:];
		output Real o[size(i, 1)];
	algorithm
		o := i;
	end f;
end FunctionEval7;


model FunctionEval8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval8",
         description="Constant evaluation and variability of iter exp containing function call",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x[1]\" value=\"2.0\"/>
	 <RealParameter name=\"x[2]\" value=\"4.0\"/>
")})));

	function f
		input Real i;
		output Real o = 2 * i;
	algorithm
	end f;
	
	parameter Real x[2] = { f(i) for i in 1:2 };
end FunctionEval8;


model FunctionEval9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval9",
         description="Constant evaluation of functions: while loops (flat tree, independent param)",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x\" value=\"120.0\"/>
")})));

	function f
		input Real i;
		output Real o;
	protected
		Real x;
	algorithm
		x := 2;
		o := 1;
		while x <= i loop
			o := o * x;
			x := x + 1;
		end while;
	end f;

	parameter Real x = f(5);
end FunctionEval9;


model FunctionEval10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionEval10",
         description="Constant evaluation of functions: while loops (instance tree)",
         flatModel="
fclass EvaluationTests.FunctionEval10
 constant Real x = EvaluationTests.FunctionEval10.f(5);
 Real y = 120.0;

 function EvaluationTests.FunctionEval10.f
  input Real i;
  output Real o;
  Real x;
 algorithm
  x := 2;
  o := 1;
  while x <= i loop
   o := ( o ) * ( x );
   x := x + 1;
  end while;
  return;
 end EvaluationTests.FunctionEval10.f;
end EvaluationTests.FunctionEval10;
")})));

	function f
		input Real i;
		output Real o;
	protected
		Real x;
	algorithm
		x := 2;
		o := 1;
		while x <= i loop
			o := o * x;
			x := x + 1;
		end while;
	end f;

	constant Real x = f(5);
	Real y = x;
end FunctionEval10;


model FunctionEval11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="FunctionEval11",
         description="Constant evaluation of functions: while loops (flat tree, dependent param)",
         template="$XML_variables$",
         generatedCode="

		<ScalarVariable name=\"x\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"120.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"0.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>")})));

	function f
		input Real i;
		output Real o;
	protected
		Real x;
	algorithm
		x := 2;
		o := 1;
		while x <= i loop
			o := o * x;
			x := x + 1;
		end while;
	end f;

	parameter Real x = f(y);
	parameter Real y = 5;
end FunctionEval11;
	
	
end EvaluationTests;
