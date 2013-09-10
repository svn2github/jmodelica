/*
	Copyright (C) 2009-2013 Modelon AB

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
	parameter Integer n = 3;
	parameter Real z[n] = 1:n;
	parameter Real y[n] = n:-1:1;
	parameter Real x = z * y;
	Real q = x;

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="VectorMul",
			description="Constant evaluation of vector multiplication",
			variables="x",
			values="
10.0"
 )})));
end VectorMul;


model FunctionEval1
	function f
		input Real i;
		output Real o = i + 2.0;
		algorithm
	end f;
	
	parameter Real x = f(1.0);

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval1",
			description="Constant evaluation of functions: basic test",
			variables="x",
			values="
3.0"
 )})));
end FunctionEval1;


model FunctionEval2
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval2",
			description="Constant evaluation of functions: while and if",
			variables="
x[1]
x[2]
x[3]
x[4]
x[5]
x[6]
",
         values="
1.0
1.0
2.0
3.0
5.0
8.0
")})));
end FunctionEval2;


model FunctionEval3
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval3",
			description="Constant evaluation of functions: array inputs and for loops",
			variables="x",
			values="
48.0"
 )})));
end FunctionEval3;


model FunctionEval4
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval4",
			description="Constant evaluation of functions: unknown array sizes",
			variables="x",
			values="
48.0"
 )})));
end FunctionEval4;


model FunctionEval5
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval5",
			description="Constant evaluation of functions: using input as for index expression",
			variables="x",
			values="
6.0"
 )})));
end FunctionEval5;


model FunctionEval6
	parameter Real y[2] = {1, 2};
	parameter Real x[2] = f(y);
	
	function f
		input Real i[2];
		output Real o[2];
	algorithm
		o := i;
	end f;

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval6",
			description="Constant evaluation of functions: array output",
			variables="
x[1]
x[2]
",
         values="
1.0
2.0
")})));
end FunctionEval6;


model FunctionEval7
	parameter Real y[2] = {1, 2};
	parameter Real x[2] = f(y);
	
	function f
		input Real i[:];
		output Real o[size(i, 1)];
	algorithm
		o := i;
	end f;

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval7",
			description="Constant evaluation of functions: array output, unknown size",
			variables="
x[1]
x[2]
",
         values="
1.0
2.0
")})));
end FunctionEval7;


model FunctionEval8
	function f
		input Real i;
		output Real o = 2 * i;
	algorithm
	end f;
	
	parameter Real x[2] = { f(i) for i in 1:2 };

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval8",
			description="Constant evaluation and variability of iter exp containing function call",
			variables="
x[1]
x[2]
",
         values="
2.0
4.0
")})));
end FunctionEval8;


model FunctionEval9
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval9",
			description="Constant evaluation of functions: while loops (flat tree, independent param)",
			variables="x",
			values="
120.0"
 )})));
end FunctionEval9;


model FunctionEval10
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="FunctionEval10",
			description="Constant evaluation of functions: while loops (instance tree)",
			flatModel="
fclass EvaluationTests.FunctionEval10
 constant Real x = EvaluationTests.FunctionEval10.f(5);
 Real y = 120.0;

public
 function EvaluationTests.FunctionEval10.f
  input Real i;
  output Real o;
  Real x;
 algorithm
  x := 2;
  o := 1;
  while x <= i loop
   o := o * x;
   x := x + 1;
  end while;
  return;
 end EvaluationTests.FunctionEval10.f;

end EvaluationTests.FunctionEval10;
")})));
end FunctionEval10;


model FunctionEval11
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval11",
			description="Constant evaluation of functions: while loops (flat tree, dependent param)",
			variables="x",
			values="
120.0"
 )})));
end FunctionEval11;


model FunctionEval12
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="FunctionEval12",
			description="Constant evaluation of functions: records",
			flatModel="
fclass EvaluationTests.FunctionEval12
 constant Real x = EvaluationTests.FunctionEval12.f2(EvaluationTests.FunctionEval12.f1(2));
 Real y = 6.0;

public
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
  x := EvaluationTests.FunctionEval12.R(a, 2 * a);
  return;
 end EvaluationTests.FunctionEval12.f1;

 record EvaluationTests.FunctionEval12.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval12.R;

end EvaluationTests.FunctionEval12;
")})));
end FunctionEval12;


model FunctionEval13
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="FunctionEval13",
			description="Constant evaluation of functions: records",
			flatModel="
fclass EvaluationTests.FunctionEval13
 constant EvaluationTests.FunctionEval13.R x = EvaluationTests.FunctionEval13.f(2);
 EvaluationTests.FunctionEval13.R y = EvaluationTests.FunctionEval13.R(2, 4.0);

public
 function EvaluationTests.FunctionEval13.f
  input Real a;
  output EvaluationTests.FunctionEval13.R x;
 algorithm
  x := EvaluationTests.FunctionEval13.R(a, 2 * a);
  return;
 end EvaluationTests.FunctionEval13.f;

 record EvaluationTests.FunctionEval13.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval13.R;

end EvaluationTests.FunctionEval13;
")})));
end FunctionEval13;


model FunctionEval14
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="FunctionEval14",
			description="Constant evaluation of functions: records",
			flatModel="
fclass EvaluationTests.FunctionEval14
 constant Real x = EvaluationTests.FunctionEval14.f(EvaluationTests.FunctionEval14.R(1, 2));
 Real y = 3.0;

public
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
end FunctionEval14;


model FunctionEval15
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="FunctionEval15",
			description="",
			flatModel="
fclass EvaluationTests.FunctionEval15
 constant Real x = EvaluationTests.FunctionEval15.f1(EvaluationTests.FunctionEval15.f2());
 Real y = 50.0;

public
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
end FunctionEval15;


model FunctionEval16
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval16",
			description="Constant evaluation of functions: records",
			variables="x",
			values="
6.0"
 )})));
end FunctionEval16;


model FunctionEval17
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval17",
			description="Constant evaluation of functions: records",
			variables="
x.a
x.b
",
         values="
2.0
4.0
")})));
end FunctionEval17;


model FunctionEval18
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval18",
			description="Constant evaluation of functions: records",
			variables="x",
			values="
3.0"
 )})));
end FunctionEval18;


model FunctionEval19
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

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval19",
			description="Constant evaluation of functions: arrays of records",
			variables="x",
			values="
50.0"
 )})));
end FunctionEval19;


model FunctionEval20
	function f
		input Real x[:];
		output Real y;
	algorithm
		y := x * x;
	end f;
	
	parameter Real a = f({1, 2});
	parameter Real b = f({1, 2, 3});

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval20",
			description="",
			variables="
a
b
",
         values="
5.0
14.0
")})));
end FunctionEval20;


model FunctionEval21
	function f
		input Real a;
		output Real b;
	algorithm
		assert(true, "Test");
		b := a;
	end f;
	
	parameter Real x = f(1);

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval21",
			description="Evaluation of function containing assert()",
			variables="x",
			values="
1.0"
 )})));
end FunctionEval21;

    
model FunctionEval22
	function f1
		input Real x1;
		input Real x2;
		output Real y;
	protected
		Real z1;
		Real z2;
	algorithm
		(z1, z2) := f2(x1, x2);
		y := z1 + z2;
    end f1;
	
    function f2
        input Real x1;
		input Real x2;
		output Real y1;
		output Real y2;
	algorithm
		y1 := x1 * x2;
		y2 := x1 + x2;
    end f2;
	
    parameter Real x = f1(1,2);

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="FunctionEval22",
			description="Test evaluation of function containing function call statement using more than one output",
			variables="x",
			values="
5.0"
 )})));
end FunctionEval22;

model FunctionEval23
    function f
        input Real x;
        output Real y;
    algorithm
        z := 5;
        y := x + z;
    end f;
	
    constant Real p = f(3);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="FunctionEval23",
			description="",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EvaluationTests.mo':
Semantic error at line 792, column 9:
  Cannot find class or component declaration for z
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EvaluationTests.mo':
Semantic error at line 793, column 18:
  Cannot find class or component declaration for z
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EvaluationTests.mo':
Semantic error at line 796, column 23:
  Could not evaluate binding expression for constant 'p': 'f(3)'
")})));
end FunctionEval23;

model FunctionEval24
	function f
		input Real x;
		output Real y;
	algorithm
		y := x;
	end f;
	
	constant Real z = f();

	annotation(__JModelica(UnitTesting(tests={ 
		ErrorTestCase(
			name="FunctionEval24",
			description="",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EvaluationTests.mo':
Semantic error at line 846, column 20:
  Calling function f(): missing argument for required input x
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EvaluationTests.mo':
Semantic error at line 846, column 20:
  Could not evaluate binding expression for constant 'z': 'f()'
")})));
end FunctionEval24;


model StringConcat
 Real a = 1;
 parameter String b = "1" + "2";
 parameter String[2] c = { "1", "2" } .+ "3";
 parameter String[2] d = { "1", "2" } + { "3", "4" };

	annotation(__JModelica(UnitTesting(tests={
		EvalTestCase(
			name="StringConcat",
			description="",
			variables="
b
c[1]
c[2]
d[1]
d[2]
",
         values="
\"12\"
\"13\"
\"23\"
\"13\"
\"24\"
")})));
end StringConcat;

model ParameterEval1
	parameter Real[:,:] a = b;
	parameter Real[:,:] b = c;
	parameter Real[:,:] c = d;
	parameter Real[:,:] d = e;
	parameter Real[:,:] e = f;
	parameter Real[:,:] f = g;
	parameter Real[:,:] g = h;
	parameter Real[:,:] h = {{0,1,2,3,4,5,6,7,8,9},{10,11,12,13,14,15,16,17,18,19},{20,21,22,23,24,25,26,27,28,29},{30,31,32,33,34,35,36,37,38,39},{40,41,42,43,44,45,46,47,48,49},{50,51,52,53,54,55,56,57,58,59},{60,61,62,63,64,65,66,67,68,69},{70,71,72,73,74,75,76,77,78,79},{80,81,82,83,84,85,86,87,88,89},{90,91,92,93,94,95,96,97,98,99}};
	Boolean x;
equation
x = if a[1,1] > a[1,2] then true else false;

	annotation(__JModelica(UnitTesting(tests={ 
		TimeTestCase(
			name="ParameterEval1",
			description="Make sure time complexity of evaluation of array parameters is of an acceptable order",
			maxTime=2.0
 )})));
end ParameterEval1;


model EvaluateAnnotation
	parameter Real a = 1.0;
	parameter Real b = a annotation(Evaluate=true);
	Real c = a + b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="EvaluateAnnotation",
			description="Check that annotation(Evaluate=true) is honored",
			flatModel="
fclass EvaluationTests.EvaluateAnnotation
 parameter Real a = 1.0 /* 1.0 */;
 parameter Real b = 1.0 /* 1.0 */;
 Real c = 1.0 + 1.0;
end EvaluationTests.EvaluateAnnotation;
")})));
end EvaluateAnnotation;


model EvalColonSizeCell
    function f
        input Real[:] x;
        output Real[size(x, 1)] y;
    algorithm
        y := x / 2;
    end f;
    
    parameter Real a[1] = {1};
    parameter Real b[1] = f(a);
    parameter Real c[1] = if b[1] > 0.1 then {1} else {0} annotation (Evaluate=true);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvalColonSizeCell",
            description="Evaluation of function returning array dependent on colon size",
            checkAll=true,
            flatModel="
fclass EvaluationTests.EvalColonSizeCell
 parameter Real a[1] = {1} /* { 1 } */;
 parameter Real b[1] = EvaluationTests.EvalColonSizeCell.f({1.0});
 parameter Real c[1] = if 0.5 > 0.1 then {1} else {0} /* 1 */;

public
 function EvaluationTests.EvalColonSizeCell.f
  input Real[:] x;
  output Real[size(x, 1)] y;
 algorithm
  y := x / 2;
  return;
 end EvaluationTests.EvalColonSizeCell.f;

end EvaluationTests.EvalColonSizeCell;
")})));
end EvalColonSizeCell;

end EvaluationTests;
