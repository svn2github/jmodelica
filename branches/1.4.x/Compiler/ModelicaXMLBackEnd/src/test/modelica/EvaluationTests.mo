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
			<Integer start=\"3\" />
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
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
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
		</ScalarVariable>")})));

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
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
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
		</ScalarVariable>")})));

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
			<Real relativeQuantity=\"false\" start=\"5.0\" />
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


model FunctionEval12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="FunctionEval12",
		 description="Constant evaluation of functions: records",
		 flatModel="
fclass EvaluationTests.FunctionEval12
 constant Real x = EvaluationTests.FunctionEval12.f2(EvaluationTests.FunctionEval12.f1(2));
 Real y = 6.0;

 function EvaluationTests.FunctionEval12.f2
  input EvaluationTests.FunctionEval12.R a;
  output Real x;
 algorithm
  x := a.a + a.b;
  return;
 end EvaluationTests.FunctionEval12.f2;

 function EvaluationTests.FunctionEval12.f1
  input Real a;
  output EvaluationTests.FunctionEval12.R x;
 algorithm
  x := EvaluationTests.FunctionEval12.R(a, ( 2 ) * ( a ));
  return;
 end EvaluationTests.FunctionEval12.f1;

 record EvaluationTests.FunctionEval12.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval12.R;
end EvaluationTests.FunctionEval12;
")})));

	record R
		Real a;
		Real b;
	end R;
	
	function f1
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f1;
	
	function f2
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f2;
	
	constant Real x = f2(f1(2));
	Real y = x;
end FunctionEval12;


model FunctionEval13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="FunctionEval13",
		 description="Constant evaluation of functions: records",
		 flatModel="
fclass EvaluationTests.FunctionEval13
 constant EvaluationTests.FunctionEval13.R x = EvaluationTests.FunctionEval13.f(2);
 EvaluationTests.FunctionEval13.R y = EvaluationTests.FunctionEval13.R(2, 4.0);

 function EvaluationTests.FunctionEval13.f
  input Real a;
  output EvaluationTests.FunctionEval13.R x;
 algorithm
  x := EvaluationTests.FunctionEval13.R(a, ( 2 ) * ( a ));
  return;
 end EvaluationTests.FunctionEval13.f;

 record EvaluationTests.FunctionEval13.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval13.R;
end EvaluationTests.FunctionEval13;
")})));

	record R
		Real a;
		Real b;
	end R;
	
	function f
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f;
	
	constant R x = f(2);
	R y = x;
end FunctionEval13;


model FunctionEval14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionEval14",
         description="Constant evaluation of functions: records",
         flatModel="
fclass EvaluationTests.FunctionEval14
 constant Real x = EvaluationTests.FunctionEval14.f(EvaluationTests.FunctionEval14.R(1, 2));
 Real y = 3.0;

 function EvaluationTests.FunctionEval14.f
  input EvaluationTests.FunctionEval14.R a;
  output Real x;
 algorithm
  x := a.a + a.b;
  return;
 end EvaluationTests.FunctionEval14.f;

 record EvaluationTests.FunctionEval14.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval14.R;
end EvaluationTests.FunctionEval14;
")})));

	record R
		Real a;
		Real b;
	end R;
	
	function f
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f;
	
	constant Real x = f(R(1, 2));
	Real y = x;
end FunctionEval14;


model FunctionEval15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionEval15",
         description="",
         flatModel="
fclass EvaluationTests.FunctionEval15
 constant Real x = EvaluationTests.FunctionEval15.f1(EvaluationTests.FunctionEval15.f2());
 Real y = 50.0;

 function EvaluationTests.FunctionEval15.f1
  input EvaluationTests.FunctionEval15.R2[2] a;
  output Real x;
 algorithm
  x := sum(a[1:2].a[1:2].a) + sum(a[1:2].a[1:2].b) + sum(a[1:2].b[1:3].a) + sum(a[1:2].b[1:3].b);
  return;
 end EvaluationTests.FunctionEval15.f1;

 function EvaluationTests.FunctionEval15.f2
  output EvaluationTests.FunctionEval15.R2[2] x;
 algorithm
  x[1:2].a[1:2].a := ones(2, 2, 2);
  for i in 1:2 loop
   for j in 1:2 loop
    x[i].a[j].b := {1,1,1};
    x[i].b[1:3].a[j] := x[i].a[j].b;
   end for;
  end for;
  x[1:2].b[1:3].b[1] := ones(2, 3);
  x[1:2].b[1].b := ones(2, 3);
  x[1:2].b[2:3].b[2:3] := ones(2, 2, 2);
  return;
 end EvaluationTests.FunctionEval15.f2;

 record EvaluationTests.FunctionEval15.R1
  Real a[2];
  Real b[3];
 end EvaluationTests.FunctionEval15.R1;

 record EvaluationTests.FunctionEval15.R2
  EvaluationTests.FunctionEval15.R1 a[2];
  EvaluationTests.FunctionEval15.R1 b[3];
 end EvaluationTests.FunctionEval15.R2;
end EvaluationTests.FunctionEval15;
")})));

	record R1
		Real a[2];
		Real b[3];
	end R1;
	
	record R2
		R1 a[2];
		R1 b[3];
	end R2;
	
	function f1
		input R2 a[2];
		output Real x;
	algorithm
		x := sum(a.a.a) + sum(a.a.b) + sum(a.b.a) + sum(a.b.b);
	end f1;
	
	function f2
		output R2 x[2];
	algorithm
		x.a.a := ones(2,2,2);
		for i in 1:2, j in 1:2 loop
			x[i].a[j].b := {1, 1, 1};
			x[i].b.a[j] := x[i].a[j].b;
		end for;
		x.b.b[1] := ones(2,3);
		x.b[1].b := ones(2,3);
		x.b[2:3].b[2:3] := ones(2,2,2);
	end f2;
	
	constant Real x = f1(f2());
	Real y = x;
end FunctionEval15;


model FunctionEval16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="FunctionEval16",
         description="Constant evaluation of functions: records",
         template="$XML_variables$",
         generatedCode="

		<ScalarVariable name=\"temp_1.a\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1.b\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"4.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"6.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>")})));

	record R
		Real a;
		Real b;
	end R;
	
	function f1
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f1;
	
	function f2
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f2;
	
	parameter Real x = f2(f1(2));
end FunctionEval16;


model FunctionEval17
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="FunctionEval17",
         description="Constant evaluation of functions: records",
         template="$XML_variables$",
         generatedCode="

		<ScalarVariable name=\"temp_1.a\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1.b\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"4.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x.a\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x.b\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"4.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>")})));

	record R
		Real a;
		Real b;
	end R;
	
	function f
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f;
	
	parameter R x = f(2);
end FunctionEval17;


model FunctionEval18
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLValueGenTestCase(
         name="FunctionEval18",
         description="Constant evaluation of functions: records",
         template="$XML_parameters$",
         generatedCode="
	 <RealParameter name=\"x\" value=\"3.0\"/>
")})));

	record R
		Real a;
		Real b;
	end R;
	
	function f
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f;
	
	parameter Real x = f(R(1, 2));
end FunctionEval18;


model FunctionEval19
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="FunctionEval19",
         description="",
         template="$XML_variables$",
         generatedCode="

		<ScalarVariable name=\"temp_1[1].a[1].a[1]\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[1].a[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[1].b[1]\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[1].b[2]\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[1].b[3]\" valueReference=\"4\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[2].a[1]\" valueReference=\"5\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[2].a[2]\" valueReference=\"6\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[2].b[1]\" valueReference=\"7\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[2].b[2]\" valueReference=\"8\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].a[2].b[3]\" valueReference=\"9\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[1].a[1]\" valueReference=\"10\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[1].a[2]\" valueReference=\"11\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[1].b[1]\" valueReference=\"12\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[1].b[2]\" valueReference=\"13\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[1].b[3]\" valueReference=\"14\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[2].a[1]\" valueReference=\"15\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[2].a[2]\" valueReference=\"16\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[2].b[1]\" valueReference=\"17\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[2].b[2]\" valueReference=\"18\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[2].b[3]\" valueReference=\"19\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[3].a[1]\" valueReference=\"20\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[3].a[2]\" valueReference=\"21\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[3].b[1]\" valueReference=\"22\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[3].b[2]\" valueReference=\"23\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[1].b[3].b[3]\" valueReference=\"24\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[1].a[1]\" valueReference=\"25\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[1].a[2]\" valueReference=\"26\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[1].b[1]\" valueReference=\"27\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[1].b[2]\" valueReference=\"28\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[1].b[3]\" valueReference=\"29\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[2].a[1]\" valueReference=\"30\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[2].a[2]\" valueReference=\"31\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[2].b[1]\" valueReference=\"32\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[2].b[2]\" valueReference=\"33\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].a[2].b[3]\" valueReference=\"34\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[1].a[1]\" valueReference=\"35\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[1].a[2]\" valueReference=\"36\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[1].b[1]\" valueReference=\"37\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[1].b[2]\" valueReference=\"38\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[1].b[3]\" valueReference=\"39\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[2].a[1]\" valueReference=\"40\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[2].a[2]\" valueReference=\"41\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[2].b[1]\" valueReference=\"42\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[2].b[2]\" valueReference=\"43\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[2].b[3]\" valueReference=\"44\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[3].a[1]\" valueReference=\"45\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[3].a[2]\" valueReference=\"46\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[3].b[1]\" valueReference=\"47\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[3].b[2]\" valueReference=\"48\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"temp_1[2].b[3].b[3]\" valueReference=\"49\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x\" valueReference=\"50\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"50.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>")})));

	record R1
		Real a[2];
		Real b[3];
	end R1;
	
	record R2
		R1 a[2];
		R1 b[3];
	end R2;
	
	function f1
		input R2 a[2];
		output Real x;
	algorithm
		x := sum(a.a.a) + sum(a.a.b) + sum(a.b.a) + sum(a.b.b);
	end f1;
	
	function f2
		output R2 x[2];
	algorithm
		x.a.a := ones(2,2,2);
		for i in 1:2, j in 1:2 loop
			x[i].a[j].b := {1, 1, 1};
			x[i].b.a[j] := x[i].a[j].b;
		end for;
		x.b.b[1] := ones(2,3);
		x.b[1].b := ones(2,3);
		x.b[2:3].b[2:3] := ones(2,2,2);
	end f2;
	
	parameter Real x = f1(f2());
end FunctionEval19;



end EvaluationTests;
