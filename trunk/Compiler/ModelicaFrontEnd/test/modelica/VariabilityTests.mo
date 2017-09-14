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

package VariabilityTests

model Structural1
    function f
        output Integer[2] y = {2,1};
      algorithm
    end f;
    parameter Integer y[2] = f();
    parameter Integer z = y[1];
    Real[z] a = {1,1};

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Structural1",
            description="Partially structural array",
            flatModel="
fclass VariabilityTests.Structural1
 structural parameter Integer y[2] = {2, 1} /* { 2, 1 } */;
 structural parameter Integer z = 2 /* 2 */;
 Real a[2] = {1, 1};

public
 function VariabilityTests.Structural1.f
  output Integer[:] y;
 algorithm
  init y as Integer[2];
  y := {2, 1};
  return;
 end VariabilityTests.Structural1.f;

end VariabilityTests.Structural1;
")})));
end Structural1;

model Structural2
    parameter Boolean b = true;
    parameter Real[:] x = if not b then 1:2 else 1:3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Structural2",
            description="If expression branch selection for size",
            flatModel="
fclass VariabilityTests.Structural2
 structural parameter Boolean b = true /* true */;
 structural parameter Real x[3] = {1, 2, 3} /* { 1, 2, 3 } */;
end VariabilityTests.Structural2;
")})));
end Structural2;


model EvaluateAnnotation1
	parameter Real a = 1.0;
	parameter Real b = a annotation(Evaluate=true);
	Real c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation1",
            description="Check that annotation(Evaluate=true) is honored",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation1
 structural parameter Real a = 1.0 /* 1.0 */;
 eval parameter Real b = 1.0 /* 1.0 */;
 Real c = 1.0 + 1.0;
end VariabilityTests.EvaluateAnnotation1;
")})));
end EvaluateAnnotation1;

model EvaluateAnnotation2
    parameter Real p(fixed=false) annotation (Evaluate=true);
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation2",
            description="Check that annotation(Evaluate=true) is ignored when fixed equals false",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation2
 initial parameter Real p(fixed = false);
initial equation 
 p = 1;
end VariabilityTests.EvaluateAnnotation2;
")})));
end EvaluateAnnotation2;

model EvaluateAnnotation2_Warn
    parameter Real p(fixed=false) annotation (Evaluate=true);
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="EvaluateAnnotation2_Warn",
            description="Check that a warning is given when annotation(Evaluate=true) and fixed equals false",
            errorMessage="
1 warnings found:

Warning at line 1684, column 30, in file 'Compiler/ModelicaFlatTree/test/modelica/VariabilityTests.mo':
  Evaluate annotation is ignored for parameters with fixed=false
")})));
end EvaluateAnnotation2_Warn;


model EvaluateAnnotation3
    parameter Real p[2](fixed={false, true}) annotation (Evaluate=true);
initial equation
    p[1] = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation3",
            description="Check that annotation(Evaluate=true) is ignored when fixed equals false",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation3
 initial parameter Real p[2](fixed = {false, true});
initial equation 
 p[1] = 1;
end VariabilityTests.EvaluateAnnotation3;
")})));
end EvaluateAnnotation3;

model EvaluateAnnotation4
    model A
        parameter Real p = 2 annotation(Evaluate=true);
    end A;
    A a(p=p);
    parameter Real p(fixed=false) annotation (Evaluate=true);
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation4",
            description="Check that annotation(Evaluate=true) is ignored when fixed equals false",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation4
 initial parameter Real a.p = p;
 initial parameter Real p(fixed = false);
initial equation 
 p = 1;
end VariabilityTests.EvaluateAnnotation4;
")})));
end EvaluateAnnotation4;

model EvaluateAnnotation5
    record R
        Real a;
    end R;
    
    parameter R r = R(1) annotation(Evaluate=true);
    Real x = r.a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation5",
            description="Check that annotation(Evaluate=true) is honored for components of recors with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation5
 eval parameter VariabilityTests.EvaluateAnnotation5.R r = VariabilityTests.EvaluateAnnotation5.R(1) /* VariabilityTests.EvaluateAnnotation5.R(1) */;
 Real x = 1.0;

public
 record VariabilityTests.EvaluateAnnotation5.R
  Real a;
 end VariabilityTests.EvaluateAnnotation5.R;

end VariabilityTests.EvaluateAnnotation5;
")})));
end EvaluateAnnotation5;

model EvaluateAnnotation6
    record R
        Real n = 1;
    end R;
    
    function f
        input R x;
        output R y = x;
      algorithm
    end f;
    
    parameter R r1 annotation(Evaluate=true);
    parameter R r2 = f(r1);
    Real x = r2.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation6",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation6
 eval parameter VariabilityTests.EvaluateAnnotation6.R r1 = VariabilityTests.EvaluateAnnotation6.R(1) /* VariabilityTests.EvaluateAnnotation6.R(1) */;
 structural parameter VariabilityTests.EvaluateAnnotation6.R r2 = VariabilityTests.EvaluateAnnotation6.R(1) /* VariabilityTests.EvaluateAnnotation6.R(1) */;
 Real x = 1.0;

public
 function VariabilityTests.EvaluateAnnotation6.f
  input VariabilityTests.EvaluateAnnotation6.R x;
  output VariabilityTests.EvaluateAnnotation6.R y;
 algorithm
  y := x;
  return;
 end VariabilityTests.EvaluateAnnotation6.f;

 record VariabilityTests.EvaluateAnnotation6.R
  Real n;
 end VariabilityTests.EvaluateAnnotation6.R;

end VariabilityTests.EvaluateAnnotation6;
")})));
end EvaluateAnnotation6;

model EvaluateAnnotation7
    record R
        Real n = 1;
    end R;
    
    record P
        extends R;
    end P;
    
    function f
        input P x;
        output P y = x;
      algorithm
    end f;
    
    parameter P r1 annotation(Evaluate=true);
    parameter P r2 = f(r1);
    Real x = r2.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation7",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation7
 eval parameter VariabilityTests.EvaluateAnnotation7.P r1 = VariabilityTests.EvaluateAnnotation7.P(1) /* VariabilityTests.EvaluateAnnotation7.P(1) */;
 structural parameter VariabilityTests.EvaluateAnnotation7.P r2 = VariabilityTests.EvaluateAnnotation7.P(1) /* VariabilityTests.EvaluateAnnotation7.P(1) */;
 Real x = 1.0;

public
 function VariabilityTests.EvaluateAnnotation7.f
  input VariabilityTests.EvaluateAnnotation7.P x;
  output VariabilityTests.EvaluateAnnotation7.P y;
 algorithm
  y := x;
  return;
 end VariabilityTests.EvaluateAnnotation7.f;

 record VariabilityTests.EvaluateAnnotation7.P
  Real n;
 end VariabilityTests.EvaluateAnnotation7.P;

end VariabilityTests.EvaluateAnnotation7;
")})));
end EvaluateAnnotation7;

model EvaluateAnnotation8
    record R
        Real y;
        Real x = y + 1 annotation(Evaluate=true);
    end R;
   
    parameter R r = R(y=3);
    Real x = r.x + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EvaluateAnnotation8",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation8
 parameter Real r.y = 3 /* 3 */;
 eval parameter Real r.x = 4 /* 4 */;
 constant Real x = 5.0;
end VariabilityTests.EvaluateAnnotation8;
")})));
end EvaluateAnnotation8;

model EvaluateAnnotation9
    function F
        input R i;
        output R o;
    algorithm
        o.p := i.p + 42;
    end F;
    record R
        parameter Real p = -41;
    end R;
    parameter R r1 annotation(Evaluate=true);
    parameter R r2 = F(r1);
    
    Real x = (r2.p - 1) * time;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation9",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation9
 eval parameter VariabilityTests.EvaluateAnnotation9.R r1 = VariabilityTests.EvaluateAnnotation9.R(-41) /* VariabilityTests.EvaluateAnnotation9.R(-41) */;
 structural parameter VariabilityTests.EvaluateAnnotation9.R r2 = VariabilityTests.EvaluateAnnotation9.R(1.0) /* VariabilityTests.EvaluateAnnotation9.R(1.0) */;
 Real x = (1.0 - 1) * time;

public
 function VariabilityTests.EvaluateAnnotation9.F
  input VariabilityTests.EvaluateAnnotation9.R i;
  output VariabilityTests.EvaluateAnnotation9.R o;
 algorithm
  o.p := -41;
  o.p := i.p + 42;
  return;
 end VariabilityTests.EvaluateAnnotation9.F;

 record VariabilityTests.EvaluateAnnotation9.R
  parameter Real p;
 end VariabilityTests.EvaluateAnnotation9.R;

end VariabilityTests.EvaluateAnnotation9;
")})));
end EvaluateAnnotation9;

model EvaluateAnnotation10
    record R
        parameter Real a = 1;
        parameter Real b = a;
        constant Real p = 3;
    end R;

    parameter R r1(a = 2);
    
    model M
        parameter R r2 annotation(Evaluate=true);
    end m;
    
    M m(r2 = r1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation10",
            description="Evaluate annotation on record with mixed variabilities",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation10
 structural parameter VariabilityTests.EvaluateAnnotation10.R r1 = VariabilityTests.EvaluateAnnotation10.R(2, 2, 3);
 eval parameter VariabilityTests.EvaluateAnnotation10.R m.r2 = VariabilityTests.EvaluateAnnotation10.R(2, 2, 3);

public
 record VariabilityTests.EvaluateAnnotation10.R
  parameter Real a;
  parameter Real b;
  constant Real p;
 end VariabilityTests.EvaluateAnnotation10.R;

end VariabilityTests.EvaluateAnnotation10;
")})));
end EvaluateAnnotation10;

model EvaluateAnnotation11
    parameter A[:] a1 = {A()};
    parameter A[:] a2 = a1;
      
    record A
        parameter Integer n = 1 annotation(Evaluate=true);
        parameter Integer x = 1;
    end A;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EvaluateAnnotation11",
            description="Evaluate annotation on record with mixed variabilities",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityTests.EvaluateAnnotation11
 eval parameter Integer a1[1].n = 1 /* 1 */;
 parameter Integer a1[1].x = 1 /* 1 */;
 eval parameter Integer a2[1].n = 1 /* 1 */;
 parameter Integer a2[1].x;
parameter equation
 a2[1].x = a1[1].x;
end VariabilityTests.EvaluateAnnotation11;
")})));
end EvaluateAnnotation11;

model EvaluateAnnotation12
    parameter Real p1 = 1;
    parameter Real p2 = p1 annotation(Evaluate=true);
    parameter Real p3 = p2;
    parameter Real p4 = p3 annotation(Evaluate=true);
    parameter Real p5 = p4;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation12",
            description="",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation12
 structural parameter Real p1 = 1 /* 1 */;
 eval parameter Real p2 = 1 /* 1 */;
 structural parameter Real p3 = 1 /* 1 */;
 eval parameter Real p4 = 1 /* 1 */;
 structural parameter Real p5 = 1 /* 1 */;
end VariabilityTests.EvaluateAnnotation12;

")})));
end EvaluateAnnotation12;



model FinalParameterEval1
    model A
        parameter Real p = 1;
        Real x = p;
    end A;
    
    A a(final p = 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval1",
            description="Check that parameters with final modification are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval1
 final parameter Real a.p = 2 /* 2 */;
 Real a.x = 2.0;
end VariabilityTests.FinalParameterEval1;
")})));
end FinalParameterEval1;


model FinalParameterEval2
    final parameter Real p = 1;
    Real x = p;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval2",
            description="Check that final parameters are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval2
 final parameter Real p = 1 /* 1 */;
 Real x = 1.0;
end VariabilityTests.FinalParameterEval2;
")})));
end FinalParameterEval2;


model FinalParameterEval3
    record R
        Real a;
    end R;
    
    final parameter R r = R(1);
    Real x = r.a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval3",
            description="Check that members of final record parameters are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval3
 final parameter VariabilityTests.FinalParameterEval3.R r = VariabilityTests.FinalParameterEval3.R(1) /* VariabilityTests.FinalParameterEval3.R(1) */;
 Real x = 1.0;

public
 record VariabilityTests.FinalParameterEval3.R
  Real a;
 end VariabilityTests.FinalParameterEval3.R;

end VariabilityTests.FinalParameterEval3;
")})));
end FinalParameterEval3;


model FinalParameterEval4
    record R
        Real a;
    end R;
    
    model A
        
        parameter R r;
        Real x = r.a;
    end A;
    
    A a(final r = R(1));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval4",
            description="Check that members of record parameters with final modification are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval4
 final parameter VariabilityTests.FinalParameterEval4.R a.r = VariabilityTests.FinalParameterEval4.R(1) /* VariabilityTests.FinalParameterEval4.R(1) */;
 Real a.x = 1.0;

public
 record VariabilityTests.FinalParameterEval4.R
  Real a;
 end VariabilityTests.FinalParameterEval4.R;

end VariabilityTests.FinalParameterEval4;
")})));
end FinalParameterEval4;


model FinalParameterEval5
    final parameter Real p(fixed = false);
    Real x = p;
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval5",
            description="Check that final parameters with fixed=false are not evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval5
 initial parameter Real p(fixed = false);
 Real x = p;
initial equation 
 p = 1;
end VariabilityTests.FinalParameterEval5;
")})));
end FinalParameterEval5;

model FinalParameterEval6
    record R
        Real n = 1;
    end R;
    
    function f
        input R x;
        output R y = x;
      algorithm
    end f;
    
    final parameter R r1;
    parameter R r2 = f(r1);
    Real x = r2.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval6",
            description="Check that final parameters with fixed=false are not evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval6
 final parameter VariabilityTests.FinalParameterEval6.R r1 = VariabilityTests.FinalParameterEval6.R(1) /* VariabilityTests.FinalParameterEval6.R(1) */;
 final parameter VariabilityTests.FinalParameterEval6.R r2 = VariabilityTests.FinalParameterEval6.R(1) /* VariabilityTests.FinalParameterEval6.R(1) */;
 Real x = 1.0;

public
 function VariabilityTests.FinalParameterEval6.f
  input VariabilityTests.FinalParameterEval6.R x;
  output VariabilityTests.FinalParameterEval6.R y;
 algorithm
  y := x;
  return;
 end VariabilityTests.FinalParameterEval6.f;

 record VariabilityTests.FinalParameterEval6.R
  Real n;
 end VariabilityTests.FinalParameterEval6.R;

end VariabilityTests.FinalParameterEval6;
")})));
end FinalParameterEval6;

package IfEquations

model SelectBranch1
    parameter Boolean p = false;
    Real x;
equation
    if p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SelectBranch1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.SelectBranch1
 structural parameter Boolean p = false /* false */;
 Real x;
equation
 if false then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.SelectBranch1;
")})));
end SelectBranch1;

model EvaluateAnnotation1
    parameter Boolean p = false annotation(Evaluate=false);
    Real x;
equation
    if p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation1
 parameter Boolean p = false /* false */;
 Real x;
equation
 if p then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotation1;
")})));
end EvaluateAnnotation1;

model EvaluateAnnotation2
    parameter Boolean p = false annotation(Evaluate=true);
    Real x;
equation
    if p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation2",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation2
 eval parameter Boolean p = false /* false */;
 Real x;
equation
 if false then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotation2;
")})));
end EvaluateAnnotation2;

model EvaluateAnnotation3
    record R
        parameter Boolean p = false annotation(Evaluate=true);
    end R;

    R r annotation(Evaluate=false);

    Real x;
equation
    if r.p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation3",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation3
 parameter VariabilityTests.IfEquations.EvaluateAnnotation3.R r(p=false);
 Real x;
equation
 if r.p then
  x = time;
 else
  x = time + 1;
 end if;

public
 record VariabilityTests.IfEquations.EvaluateAnnotation3.R
  parameter Boolean p;
 end VariabilityTests.IfEquations.EvaluateAnnotation3.R;

end VariabilityTests.IfEquations.EvaluateAnnotation3;
")})));
end EvaluateAnnotation3;

model EvaluateAnnotation4
    parameter Boolean p1 = false annotation(Evaluate=false);
    parameter Boolean p2 = p1;
    Real x;
equation
    if p2 then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation4",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation4
 parameter Boolean p1 = false /* false */;
 parameter Boolean p2 = p1 /* false */;
 Real x;
equation
 if p2 then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotation4;
")})));
end EvaluateAnnotation4;

model EvaluateAnnotation5
    parameter Real[:] p = {i for i in 1:1} annotation(Evaluate=false);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation5",
            description="For index in evaluate false",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation5
 parameter Real p[1] = {1};
end VariabilityTests.IfEquations.EvaluateAnnotation5;
")})));
end EvaluateAnnotation5;

model EvaluateAnnotationUnbalanced1
    parameter Boolean p = false annotation(Evaluate=false);
    Real x;
equation
    if p then
        
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotationUnbalanced1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotationUnbalanced1
 structural parameter Boolean p = false /* false */;
 Real x;
equation
 if false then
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotationUnbalanced1;
")})));
end EvaluateAnnotationUnbalanced1;

model EvaluateAnnotationOverride1
    parameter Integer p = 2 annotation(Evaluate=false);
    Real x;
    Real y;
equation
    if p > 3 then
        x = time;
    else
        x = time + 1;
    end if;
    y = x + sum(1:p);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotationOverride1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotationOverride1
 structural parameter Integer p = 2 /* 2 */;
 Real x;
 Real y;
equation
 if 2 > 3 then
  x = time;
 else
  x = time + 1;
 end if;
 y = x + sum(1:2);
end VariabilityTests.IfEquations.EvaluateAnnotationOverride1;
")})));
end EvaluateAnnotationOverride1;

model EvaluateAnnotationNoValue1
    parameter Boolean p1 = false annotation(Evaluate);
    Real x;
equation
    if p1 then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotationNoValue1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotationNoValue1
 structural parameter Boolean p1 = false /* false */;
 Real x;
equation
 if false then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotationNoValue1;
")})));
end EvaluateAnnotationNoValue1;

end IfEquations;



end VariabilityTests;
