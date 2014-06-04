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

package RecordTests


model RecordFlat1
 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordFlat1",
			description="Records: basic flattening test",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFlat1
 RecordTests.RecordFlat1.A x;
 RecordTests.RecordFlat1.A y;
equation
 y = x;

public
 record RecordTests.RecordFlat1.A
  Real a;
  Real b;
 end RecordTests.RecordFlat1.A;

end RecordTests.RecordFlat1;
")})));
end RecordFlat1;


model RecordFlat2
 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordFlat2",
			description="Records: accessing components",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFlat2
 RecordTests.RecordFlat2.A x;
 RecordTests.RecordFlat2.A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

public
 record RecordTests.RecordFlat2.A
  Real a;
  Real b;
 end RecordTests.RecordFlat2.A;

end RecordTests.RecordFlat2;
")})));
end RecordFlat2;


model RecordFlat3
 record A
  Real a;
  Real b;
 end A;
 
 A x(a=1, b=2);
 A y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordFlat3",
			description="Records: modification",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFlat3
 RecordTests.RecordFlat3.A x(a = 1,b = 2);
 RecordTests.RecordFlat3.A y;
equation
 y = x;

public
 record RecordTests.RecordFlat3.A
  Real a;
  Real b;
 end RecordTests.RecordFlat3.A;

end RecordTests.RecordFlat3;
")})));
end RecordFlat3;


model RecordFlat4
 record A
  Real a;
  Real b;
 end A;

 record B
  Real c;
  Real d;
 end B;
 
 B y;
 A x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordFlat4",
			description="Records: two records",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFlat4
 RecordTests.RecordFlat4.B y;
 RecordTests.RecordFlat4.A x;

public
 record RecordTests.RecordFlat4.B
  Real c;
  Real d;
 end RecordTests.RecordFlat4.B;

 record RecordTests.RecordFlat4.A
  Real a;
  Real b;
 end RecordTests.RecordFlat4.A;

end RecordTests.RecordFlat4;
")})));
end RecordFlat4;


model RecordFlat5
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
  Real d;
 end B;
 
 A x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordFlat5",
			description="Records: nestled records",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFlat5
 RecordTests.RecordFlat5.A x;

public
 record RecordTests.RecordFlat5.B
  Real c;
  Real d;
 end RecordTests.RecordFlat5.B;

 record RecordTests.RecordFlat5.A
  Real a;
  RecordTests.RecordFlat5.B b;
 end RecordTests.RecordFlat5.A;

end RecordTests.RecordFlat5;
")})));
end RecordFlat5;


model RecordFlat6
    record A
        Real a;
    end A;
    
    record B
        extends A;
        Real a;
        Real b;
    end B;
    
    B b(a = 1, b = 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat6",
            description="Merging of equivalent members when flattening records",
            flatModel="
fclass RecordTests.RecordFlat6
 RecordTests.RecordFlat6.B b(a = 1,b = 2);

public
 record RecordTests.RecordFlat6.B
  Real a;
  Real b;
 end RecordTests.RecordFlat6.B;

end RecordTests.RecordFlat6;
")})));
end RecordFlat6;


model RecordFlat7
    record A
        Real b = time;
    end A;

    model B
        A a;
    end B;

    model C
        extends B;
    end C;

    model D
        extends B;
        extends C;
    end D;

    D d;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordFlat7",
			description="Merging of equivalent record variables when flattening",
			flatModel="
fclass RecordTests.RecordFlat7
 RecordTests.RecordFlat7.A d.a;

public
 record RecordTests.RecordFlat7.A
  Real b = time;
 end RecordTests.RecordFlat7.A;

end RecordTests.RecordFlat7;
")})));
end RecordFlat7;



model RecordType1
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 A x;
 B y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordType1",
			description="Records: equivalent types",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordType1
 RecordTests.RecordType1.A x;
 RecordTests.RecordType1.B y;
equation
 y = x;

public
 record RecordTests.RecordType1.A
  Real a;
  Real b;
 end RecordTests.RecordType1.A;

 record RecordTests.RecordType1.B
  Real a;
  Real b;
 end RecordTests.RecordType1.B;

end RecordTests.RecordType1;
")})));
end RecordType1;


model RecordType2
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 A x;
 B y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordType2",
			description="Records: non-equivalent types (component name)",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 246, column 2:
  The right and left expression types of equation are not compatible
")})));
end RecordType2;


model RecordType3
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Boolean b;
 end B;
 
 A x;
 B y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordType3",
			description="Records: non-equivalent types (component type)",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 275, column 2:
  The right and left expression types of equation are not compatible
")})));
end RecordType3;


model RecordType4
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 record C
  A a;
  Real e;
 end C;

 record D
  B a;
  Real e;
 end D;
 
 C x;
 D y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordType4",
			description="Records: equivalent nested types",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordType4
 RecordTests.RecordType4.C x;
 RecordTests.RecordType4.D y;
equation
 y = x;

public
 record RecordTests.RecordType4.A
  Real a;
  Real b;
 end RecordTests.RecordType4.A;

 record RecordTests.RecordType4.C
  RecordTests.RecordType4.A a;
  Real e;
 end RecordTests.RecordType4.C;

 record RecordTests.RecordType4.B
  Real a;
  Real b;
 end RecordTests.RecordType4.B;

 record RecordTests.RecordType4.D
  RecordTests.RecordType4.B a;
  Real e;
 end RecordTests.RecordType4.D;

end RecordTests.RecordType4;
")})));
end RecordType4;


model RecordType5
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 record C
  A a;
  Real e;
 end C;

 record D
  B a;
  Real e;
 end D;
 
 C x;
 D y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordType5",
			description="Records: non-equivalent nested types",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 342, column 2:
  The right and left expression types of equation are not compatible
")})));
end RecordType5;


model RecordType6
 record A
  Real a;
  Real b;
 end A;

 record B
  extends C;
 end B;

 record C
  extends D;
  Real a;
 end C;

 record D
  Real b;
 end D;
 
 A x(a=1, b=2);
 B y;
equation
 y = x;		

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordType6",
			description="Records: Inheritance",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordType6
 RecordTests.RecordType6.A x(a = 1,b = 2);
 RecordTests.RecordType6.B y;
equation
 y = x;

public
 record RecordTests.RecordType6.A
  Real a;
  Real b;
 end RecordTests.RecordType6.A;

 record RecordTests.RecordType6.B
  Real b;
  Real a;
 end RecordTests.RecordType6.B;

end RecordTests.RecordType6;
")})));
end RecordType6;


model RecordType7
	record A 
		Real x;
	end A;
	
	A a[:];

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordType7",
			description="",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 458, column 7:
  Can not infer array size of the variable a
")})));
end RecordType7;



model RecordBinding1
 record A
  Real a;
  Real b;
 end A;
 
 A x = y;
 A y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordBinding1",
			description="Records: binding expression, same record type",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordBinding1
 RecordTests.RecordBinding1.A x = y;
 RecordTests.RecordBinding1.A y;

public
 record RecordTests.RecordBinding1.A
  Real a;
  Real b;
 end RecordTests.RecordBinding1.A;

end RecordTests.RecordBinding1;
")})));
end RecordBinding1;


model RecordBinding2
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 A x = y;
 B y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordBinding2",
			description="Records: binding expression, equivalent record type",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordBinding2
 RecordTests.RecordBinding2.A x = y;
 RecordTests.RecordBinding2.B y;

public
 record RecordTests.RecordBinding2.A
  Real a;
  Real b;
 end RecordTests.RecordBinding2.A;

 record RecordTests.RecordBinding2.B
  Real a;
  Real b;
 end RecordTests.RecordBinding2.B;

end RecordTests.RecordBinding2;
")})));
end RecordBinding2;


model RecordBinding3
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 A x = y;
 B y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordBinding3",
			description="Records: binding expression, wrong type (incompatible record)",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 466, column 4:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end RecordBinding3;


model RecordBinding4
 record A
  Real a;
  Real b;
 end A;
 
 A x = y;
 A y[2];

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordBinding4",
			description="Records: binding expression, wrong array size",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 499, column 4:
  Array size mismatch in declaration of x, size of declaration is scalar and size of binding expression is [2]
")})));
end RecordBinding4;


model RecordBinding5
 record A
  Real a;
  Real b;
 end A;
 
 A x(a = 1, b = "foo");

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding5",
            description="Records: wrong type of binding exp of component",
            variability_propagation=false,
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 507, column 8:
  The binding expression of the variable b does not match the declared type of the variable
")})));
end RecordBinding5;


model RecordBinding6
 record A
  Real a;
 end A;
 
 A x(a = y);
 Real y = time;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding6",
			description="Modification on record member with non-parameter expression",
			flatModel="
fclass RecordTests.RecordBinding6
 Real y;
equation
 y = time;
end RecordTests.RecordBinding6;
")})));
end RecordBinding6;


model RecordBinding7
 record A
  Real a;
 end A;
 
 A x(a(start = y));
 Real y = time;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordBinding7",
			description="Modification on attribute or record member with non-parameter expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 664, column 16:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: y
")})));
end RecordBinding7;


model RecordBinding8
	record A
		Real a;
		Real b;
	end A;
	
	function f
		input Real x;
		output A y;
	algorithm
		y := A(x, x*x);
	end f;
	
	Real[2] x = time * (1:2);
    A[2] y1 = { A(x[i], time) for i in 1:2 };
    A[2] y2 = { f(x[1]), f(x[2]) };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding8",
			description="Generating binding equations for records with array binding expressions that cannot be split",
			inline_functions="trivial",
			flatModel="
fclass RecordTests.RecordBinding8
 Real x[1];
 Real x[2];
 Real y1[1].b;
 Real y1[2].b;
 Real y2[1].b;
 Real y2[2].b;
equation
 x[1] = time;
 x[2] = time * 2;
 y1[1].b = time;
 y1[2].b = time;
 y2[1].b = x[1] * x[1];
 y2[2].b = x[2] * x[2];
end RecordTests.RecordBinding8;
")})));
end RecordBinding8;


model RecordBinding9
    record A
        constant Real a = 1;
        Real b;
    end A;
    
    parameter A x(b = 2);
    parameter A y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding9",
			description="Record containing constant as binding expression",
			flatModel="
fclass RecordTests.RecordBinding9
 constant Real x.a = 1;
 parameter Real x.b = 2 /* 2 */;
 constant Real y.a = 1;
 parameter Real y.b;
parameter equation
 y.b = x.b;
end RecordTests.RecordBinding9;
")})));
end RecordBinding9;


model RecordBinding10
    record A
        constant Real a = 1;
        Real b;
    end A;
    
    A x(b = time);
    A y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding10",
			description="Record containing constant as binding expression",
			flatModel="
fclass RecordTests.RecordBinding10
 constant Real x.a = 1;
 constant Real y.a = 1;
 Real y.b;
equation
 y.b = time;
end RecordTests.RecordBinding10;
")})));
end RecordBinding10;

model RecordBinding11
	record R
		parameter String s1 = "";
		parameter Boolean b1 = F(s1);
		Boolean b2 = F(s1);
	end R;
	function F
		input String name;
		output Boolean correct;
	algorithm
		if name == "foobar" then
			correct := true;
		else
			correct := false;
		end if;
	end F;
	parameter R r(s1="foobar");
	
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding11",
			description="Modification of string record member",
			flatModel="
fclass RecordTests.RecordBinding11
 parameter String r.s1 = \"foobar\" /* \"foobar\" */;
 parameter Boolean r.b1 = true /* true */;
 parameter Boolean r.b2 = true /* true */;
end RecordTests.RecordBinding11;
")})));
end RecordBinding11;


model RecordBinding12
	record A
		B b(c = 2 * d);
		Real d;
	end A;
	
	record B
		Real c;
	end B;
	
	parameter A a(d = 1);
	Real x = a.b.c * time;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding12",
			description="Modifications on nested records using members of outer record",
			flatModel="
fclass RecordTests.RecordBinding12
 parameter Real a.b.c;
 parameter Real a.d = 1 /* 1 */;
 Real x;
parameter equation
 a.b.c = 2 * a.d;
equation
 x = a.b.c * time;
end RecordTests.RecordBinding12;
")})));
end RecordBinding12;


model RecordBinding13
    record A
        B b = B(2 * d);
        Real d;
    end A;
    
    record B
        Real c;
    end B;
    
    parameter A a(d = 1);
    Real x = a.b.c * time;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordBinding13",
			description="Binding expressions on nested records using members of outer record",
			flatModel="
fclass RecordTests.RecordBinding13
 parameter Real a.b.c;
 parameter Real a.d = 1 /* 1 */;
 Real x;
parameter equation
 a.b.c = 2 * a.d;
equation
 x = a.b.c * time;
end RecordTests.RecordBinding13;
")})));
end RecordBinding13;


model RecordBinding14
    record R
        Real x1 = -1;
        constant Real y = 2;
        final parameter Real z = 3; 
        Real x2;
    end R;
    
    R rec = R(x2=4);
    R[2] recs = {R(1,4),R(1,4)};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding14",
            description="Record constructor for record of unmodifiable components",
            flatModel="
fclass RecordTests.RecordBinding14
 constant Real rec.x1 = -1;
 constant Real rec.y = 2;
 parameter Real rec.z = 3 /* 3 */;
 constant Real rec.x2 = 4;
 constant Real recs[1].x1 = 1;
 constant Real recs[1].y = 2;
 parameter Real recs[1].z = 3 /* 3 */;
 constant Real recs[1].x2 = 4;
 constant Real recs[2].x1 = 1;
 constant Real recs[2].y = 2;
 parameter Real recs[2].z = 3 /* 3 */;
 constant Real recs[2].x2 = 4;
end RecordTests.RecordBinding14;
")})));
end RecordBinding14;


model RecordArray1
 record A
  Real a[2];
  Real b;
 end A;
 
 A x(a={1,2}, b=1);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordArray1",
			description="Record containing array: modification",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordArray1
 RecordTests.RecordArray1.A x(a = {1,2},b = 1);

public
 record RecordTests.RecordArray1.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray1.A;

end RecordTests.RecordArray1;
")})));
end RecordArray1;


model RecordArray2
 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordArray2",
			description="Record containing array: equation with access",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordArray2
 RecordTests.RecordArray2.A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

public
 record RecordTests.RecordArray2.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray2.A;

end RecordTests.RecordArray2;
")})));
end RecordArray2;


model RecordArray3
 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
 A y;
equation
 x = y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordArray3",
			description="Record containing array: equation with other record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordArray3
 RecordTests.RecordArray3.A x;
 RecordTests.RecordArray3.A y;
equation
 x = y;

public
 record RecordTests.RecordArray3.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray3.A;

end RecordTests.RecordArray3;
")})));
end RecordArray3;


model RecordArray4
 record A
  Real a;
  Real b;
 end A;
 
 A x[2](each a=1, b={1,2});

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordArray4",
			description="Array of records: modification",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordArray4
 RecordTests.RecordArray4.A x[2](each a = 1,b = {1,2});

public
 record RecordTests.RecordArray4.A
  Real a;
  Real b;
 end RecordTests.RecordArray4.A;

end RecordTests.RecordArray4;
")})));
end RecordArray4;


model RecordArray5
 record A
  Real a;
  Real b;
 end A;
 
 A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordArray5",
			description="Array of records: accesses",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordArray5
 RecordTests.RecordArray5.A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

public
 record RecordTests.RecordArray5.A
  Real a;
  Real b;
 end RecordTests.RecordArray5.A;

end RecordTests.RecordArray5;
")})));
end RecordArray5;


model RecordArray6
    record A
        Real x;
        Real y;
        Real z;
    end A;
    
    constant A b[2,2];
    constant A c[2,2] = b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordArray6",
			description="Constant array of records with missing binding expression",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordArray6
 constant RecordTests.RecordArray6.A b[2,2];
 constant RecordTests.RecordArray6.A c[2,2] = {{RecordTests.RecordArray6.A(0.0, 0.0, 0.0), RecordTests.RecordArray6.A(0.0, 0.0, 0.0)}, {RecordTests.RecordArray6.A(0.0, 0.0, 0.0), RecordTests.RecordArray6.A(0.0, 0.0, 0.0)}};

public
 record RecordTests.RecordArray6.A
  Real x;
  Real y;
  Real z;
 end RecordTests.RecordArray6.A;

end RecordTests.RecordArray6;
")})));
end RecordArray6;


// TODO: entire record is here turned into a structural parameter, but should only be n
model RecordArray7
    record A
        parameter Integer n;
        Real x[n];
    end A;
    
    parameter Integer m = 2;
    parameter A a = A(m, 1:m);
    Real y[m] = a.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray7",
            description="Parameter in record controlling size of array in same record: record constructor",
            flatModel="
fclass RecordTests.RecordArray7
 parameter Integer m = 2 /* 2 */;
 parameter RecordTests.RecordArray7.A a = RecordTests.RecordArray7.A(2, 1:2) /* RecordTests.RecordArray7.A(2, { 1, 2 }) */;
 Real y[2] = {1.0, 2.0};

public
 record RecordTests.RecordArray7.A
  parameter Integer n;
  Real x[n];
 end RecordTests.RecordArray7.A;

end RecordTests.RecordArray7;
")})));
end RecordArray7;


model RecordArray8
    record A
        parameter Integer n;
        Real x[n];
    end A;
    
    function f
        input Integer n;
        output A a(n=n);
    algorithm
        a.x := 1:n;
    end f;
    
    parameter Integer m = 2;
    parameter A a = f(m);
    Real y[m] = a.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray8",
            description="Flattening of model with record that gets array size of member from function call that returns entire record",
            flatModel="
fclass RecordTests.RecordArray8
 parameter Integer m = 2 /* 2 */;
 parameter RecordTests.RecordArray8.A a = RecordTests.RecordArray8.f(2);
 Real y[2] = a.x[1:2];

public
 function RecordTests.RecordArray8.f
  input Integer n;
  output RecordTests.RecordArray8.A a;
 algorithm
  a.x := 1:n;
  return;
 end RecordTests.RecordArray8.f;

 record RecordTests.RecordArray8.A
  parameter Integer n;
  Real x[n];
 end RecordTests.RecordArray8.A;

end RecordTests.RecordArray8;
")})));
end RecordArray8;



model RecordConstructor1
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2, "foo");

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor1",
			description="Record constructors: basic test",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordConstructor1
 RecordTests.RecordConstructor1.A x = RecordTests.RecordConstructor1.A(1.0, 2, \"foo\");

public
 record RecordTests.RecordConstructor1.A
  Real a;
  discrete Integer b;
  parameter String c;
 end RecordTests.RecordConstructor1.A;

end RecordTests.RecordConstructor1;
")})));
end RecordConstructor1;


model RecordConstructor2
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(c="foo", a=1.0, b=2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor2",
			description="Record constructors: named args",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordConstructor2
 RecordTests.RecordConstructor2.A x = RecordTests.RecordConstructor2.A(1.0, 2, \"foo\");

public
 record RecordTests.RecordConstructor2.A
  Real a;
  discrete Integer b;
  parameter String c;
 end RecordTests.RecordConstructor2.A;

end RecordTests.RecordConstructor2;
")})));
end RecordConstructor2;


model RecordConstructor3
 record A
  Real a;
  Integer b = 0;
  constant String c = "foo";
 end A;
 
 A x = A(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor3",
			description="Record constructors: default args",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordConstructor3
 RecordTests.RecordConstructor3.A x = RecordTests.RecordConstructor3.A(1, 2);

public
 record RecordTests.RecordConstructor3.A
  Real a;
  discrete Integer b = 0;
  constant String c = \"foo\";
 end RecordTests.RecordConstructor3.A;

end RecordTests.RecordConstructor3;
")})));
end RecordConstructor3;


model RecordConstructor4
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordConstructor4",
            description="Record constructors: wrong type of arg",
            variability_propagation=false,
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/RecordTests.mo':
Semantic error at line 1335, column 18:
  Record constructor for A: types of positional argument 3 and input c are not compatible
    type of '3' is Integer
")})));
end RecordConstructor4;


model RecordConstructor5
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordConstructor5",
			description="Record constructors: too few args",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 786, column 8:
  Record constructor for A: missing argument for required input c
")})));
end RecordConstructor5;


model RecordConstructor6
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2, "foo", 0);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordConstructor6",
			description="Record constructors: too many args",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 808, column 25:
  Record constructor for A: too many positional arguments
")})));
end RecordConstructor6;


model RecordConstructor7
    record A
        Real x;
    end A;
    
    record B
        extends A;
        Real y;
    end B;
    
    constant B b = B(y=2, x=1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordConstructor7",
			description="Constant evaluation of record constructors for records with inherited components",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordConstructor7
 constant Real b.x = 1;
 constant Real b.y = 2;
end RecordTests.RecordConstructor7;
")})));
end RecordConstructor7;


model RecordConstructor8
    record A
        Real x;
        Real y = x + 2;
    end A;
    
    A a = A(time);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor8",
			description="Using default value in record constructor that depends on another member",
			flatModel="
fclass RecordTests.RecordConstructor8
 RecordTests.RecordConstructor8.A a = RecordTests.RecordConstructor8.A(time, time + 2);

public
 record RecordTests.RecordConstructor8.A
  Real x;
  Real y = x + 2;
 end RecordTests.RecordConstructor8.A;

end RecordTests.RecordConstructor8;
")})));
end RecordConstructor8;


model RecordConstructor9
    record A
        Integer x;
        Integer y = x + 2;
    end A;
    
    parameter A a = A(1);
    parameter Integer b = a.y;
    Real z[b] = (1:b) * time;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor9",
			description="Constant eval of default value in record constructor that depends on another member",
			flatModel="
fclass RecordTests.RecordConstructor9
 parameter RecordTests.RecordConstructor9.A a = RecordTests.RecordConstructor9.A(1, 1 + 2) /* RecordTests.RecordConstructor9.A(1, 3) */;
 parameter Integer b = 3 /* 3 */;
 Real z[3] = (1:3) * time;

public
 record RecordTests.RecordConstructor9.A
  discrete Integer x;
  discrete Integer y = x + 2;
 end RecordTests.RecordConstructor9.A;

end RecordTests.RecordConstructor9;
")})));
end RecordConstructor9;


model RecordConstructor10
    record A
        Real a;
        Real b;
    end A;

    model B
        parameter Real d = 2;
    
        record C = A(b = d);
        
        model E
            C f = C(1);
        end E;
        
        E e;
    end B;

    B b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor10",
			description="Using default value in record constructor that is set in short class decl",
			flatModel="
fclass RecordTests.RecordConstructor10
 parameter Real b.d = 2 /* 2 */;
 RecordTests.RecordConstructor10.b.C b.e.f(b = b.d) = RecordTests.RecordConstructor10.b.C(1, b.d);

public
 record RecordTests.RecordConstructor10.b.C
  Real a;
  Real b = b.d;
 end RecordTests.RecordConstructor10.b.C;

end RecordTests.RecordConstructor10;
")})));
end RecordConstructor10;


model RecordConstructor11
    record A
        Real x;
    end A;
    
    record B
        extends A;
        Real y = x + 2;
    end B;
    
    B b = B(time);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordConstructor11",
			description="Using default value in record constructor that depends on an inherited member",
			flatModel="
fclass RecordTests.RecordConstructor11
 RecordTests.RecordConstructor11.B b = RecordTests.RecordConstructor11.B(time, time + 2);

public
 record RecordTests.RecordConstructor11.B
  Real x;
  Real y = x + 2;
 end RecordTests.RecordConstructor11.B;

end RecordTests.RecordConstructor11;
")})));
end RecordConstructor11;


model RecordScalarize1
 record A
  Real a;
  Real b;
 end A;
 
 A x(a=1, b=2);
 A y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize1",
			description="Scalarization of records: modification",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize1
 Real x.a;
 Real x.b;
 Real y.a;
 Real y.b;
equation
 y.a = x.a;
 y.b = x.b;
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize1;
")})));
end RecordScalarize1;


model RecordScalarize2
 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize2",
			description="Scalarization of records: basic test",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize2
 Real x.a;
 Real x.b;
 Real y.a;
 Real y.b;
equation
 y.a = x.a;
 y.b = x.b;
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize2;
")})));
end RecordScalarize2;


model RecordScalarize3
 record A
  Real b;
  Real a;
 end A;
 
 A x = A(1, 2);
 A y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize3",
			description="Scalarization of records: record constructor",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize3
 Real x.b;
 Real x.a;
 Real y.b;
 Real y.a;
equation
 y.b = x.b;
 y.a = x.a;
 x.b = 1;
 x.a = 2;
end RecordTests.RecordScalarize3;
")})));
end RecordScalarize3;


model RecordScalarize4
 record A
  Real a;
  Real b;
 end A;

 record B
  Real c;
  Real d;
 end B;
 
 A x = A(1, 2);
 B y = B(3, 4);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize4",
			description="Scalarization of records: two different records, record constructors",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize4
 Real x.a;
 Real x.b;
 Real y.c;
 Real y.d;
equation
 x.a = 1;
 x.b = 2;
 y.c = 3;
 y.d = 4;
end RecordTests.RecordScalarize4;
")})));
end RecordScalarize4;


model RecordScalarize5

 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
  Real d;
 end B;
 
 A x = A(1, y);
 B y = B(2, 3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize5",
			description="Scalarization of records: nestled records",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize5
 Real x.a;
 Real x.b.c;
 Real x.b.d;
 Real y.c;
 Real y.d;
equation
 x.a = 1;
 x.b.c = y.c;
 x.b.d = y.d;
 y.c = 2;
 y.d = 3;
end RecordTests.RecordScalarize5;
")})));
end RecordScalarize5;


model RecordScalarize6
 record A
  Real a;
  Real b;
 end A;

 record B
  Real b;
  Real a;
 end B;
 
 A x = B(2, 1);
 B y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize6",
			description="Scalarization of records: equivalent records",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize6
 Real x.a;
 Real x.b;
 Real y.b;
 Real y.a;
equation
 y.b = x.b;
 y.a = x.a;
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize6;
")})));
end RecordScalarize6;


model RecordScalarize7
 record A
  Real b;
  Real a;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 record C
  Real c;
  A x;
 end C;

 record D
  B x;
  Real c;
 end D;
 
 C x = D(B(3, 2), 1);
 D y;
equation
 y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize7",
			description="Scalarization of records: equivalent nestled records",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize7
 Real x.c;
 Real x.x.b;
 Real x.x.a;
 Real y.x.a;
 Real y.x.b;
 Real y.c;
equation
 y.x.a = x.x.a;
 y.x.b = x.x.b;
 y.c = x.c;
 x.c = 1;
 x.x.b = 2;
 x.x.a = 3;
end RecordTests.RecordScalarize7;
")})));
end RecordScalarize7;


model RecordScalarize8
 record A
  Real a[2];
  Real b;
 end A;
 
 A x(a={1,2}, b=1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize8",
			description="Scalarization of records: modification of array component",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize8
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;
end RecordTests.RecordScalarize8;
")})));
end RecordScalarize8;


model RecordScalarize9
 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize9",
			description="Scalarization of records: record containing array",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize9
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;
end RecordTests.RecordScalarize9;
")})));
end RecordScalarize9;


model RecordScalarize10
 record A
  Real a[2];
  Real b;
 end A;
 
 A x = A({1,2}, 3);
 A y;
equation
 x = y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize10",
			description="Scalarization of records: record containing array, using record constructor",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize10
 Real x.a[1];
 Real x.a[2];
 Real x.b;
 Real y.a[1];
 Real y.a[2];
 Real y.b;
equation
 x.a[1] = y.a[1];
 x.a[2] = y.a[2];
 x.b = y.b;
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 3;
end RecordTests.RecordScalarize10;
")})));
end RecordScalarize10;


model RecordScalarize11
 record A
  Real a;
  Real b;
 end A;
 
 A x[2](each a=1, b={1,2});
end RecordScalarize11;


model RecordScalarize12
 record A
  Real a;
  Real b;
 end A;
 
 A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RecordScalarize12",
			description="Scalarization of records: array of records",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize12
 RecordTests.RecordScalarize12.A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

public
 record RecordTests.RecordScalarize12.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize12.A;

end RecordTests.RecordScalarize12;
")})));
end RecordScalarize12;


model RecordScalarize13
 record A
  Real a;
  Real b;
 end A;
 
 A x[2] = {A(1,2), A(3,4)};
 A y[2];
equation
 x = y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize13",
			description="Scalarization of records: arrays of records, binding exp + record equation",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize13
 Real x[1].a;
 Real x[1].b;
 Real x[2].a;
 Real x[2].b;
 Real y[1].a;
 Real y[1].b;
 Real y[2].a;
 Real y[2].b;
equation
 x[1].a = y[1].a;
 x[1].b = y[1].b;
 x[2].a = y[2].a;
 x[2].b = y[2].b;
 x[1].a = 1;
 x[2].a = 3;
 x[1].b = 2;
 x[2].b = 4;
end RecordTests.RecordScalarize13;
")})));
end RecordScalarize13;


model RecordScalarize14
 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 A y[2];
equation
 x = y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize14",
			description="Scalarization of records: nestled records and arrays",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize14
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[1].b[2].a[1];
 Real x[1].b[2].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y[1].b[1].a[1];
 Real y[1].b[1].a[2];
 Real y[1].b[2].a[1];
 Real y[1].b[2].a[2];
 Real y[2].b[1].a[1];
 Real y[2].b[1].a[2];
 Real y[2].b[2].a[1];
 Real y[2].b[2].a[2];
equation
 x[1].b[1].a[1] = y[1].b[1].a[1];
 x[1].b[1].a[2] = y[1].b[1].a[2];
 x[1].b[2].a[1] = y[1].b[2].a[1];
 x[1].b[2].a[2] = y[1].b[2].a[2];
 x[2].b[1].a[1] = y[2].b[1].a[1];
 x[2].b[1].a[2] = y[2].b[1].a[2];
 x[2].b[2].a[1] = y[2].b[2].a[1];
 x[2].b[2].a[2] = y[2].b[2].a[2];
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 x[1].b[2].a[1] = 3;
 x[1].b[2].a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;
end RecordTests.RecordScalarize14;
")})));
end RecordScalarize14;


model RecordScalarize15
 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 Real y = x[1].b[1].a[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize15",
			description="Scalarization of records: access of nestled primitive",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordScalarize15
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[1].b[2].a[1];
 Real x[1].b[2].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y;
equation
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 x[1].b[2].a[1] = 3;
 x[1].b[2].a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;
 y = x[1].b[1].a[2];
end RecordTests.RecordScalarize15;
")})));
end RecordScalarize15;


model RecordScalarize16
 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 B y = x[1].b[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize16",
			description="Scalarization of records: access of nested record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize16
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y.a[1];
 Real y.a[2];
equation
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 y.a[1] = 3;
 y.a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;
end RecordTests.RecordScalarize16;
")})));
end RecordScalarize16;


model RecordScalarize17
 record A
  Real a;
  Real b;
 end A;
 
 A x(b(start=3)) = A(1,2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize17",
			description="Scalarization of records: attribute on primitive in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize17
 Real x.a;
 Real x.b(start = 3);
equation
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize17;
")})));
end RecordScalarize17;


model RecordScalarize18
 record A
  Real a;
 end A;
 
 record B
  A b1;
  A b2;
 end B;
 
 B x(b1(a(start=3)), b2.a(start=4)) = B(A(1),A(2));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize18",
			description="Scalarization of records: attributes on primitives in nestled records",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize18
 Real x.b1.a(start = 3);
 Real x.b2.a(start = 4);
equation
 x.b1.a = 1;
 x.b2.a = 2;
end RecordTests.RecordScalarize18;
")})));
end RecordScalarize18;


model RecordScalarize19
    record A
        Real x[2];
    end A;
	
    A a1(x(stateSelect={StateSelect.default,StateSelect.default},start={1,2}));
equation
    der(a1.x) = -a1.x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize19",
			description="Scalarization of attributes of record members, from modification",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize19
 Real a1.x[1](stateSelect = StateSelect.default,start = 1);
 Real a1.x[2](stateSelect = StateSelect.default,start = 2);
initial equation 
 a1.x[1] = 1;
 a1.x[2] = 2;
equation
 a1.der(x[1]) = - a1.x[1];
 a1.der(x[2]) = - a1.x[2];

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end RecordTests.RecordScalarize19;
")})));
end RecordScalarize19;


model RecordScalarize20
    record A
        Real x[2](stateSelect={StateSelect.default,StateSelect.default},start={1,2});
    end A;

    A a1;
equation
    der(a1.x) = -a1.x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize20",
			description="Scalarization of attributes of record members, from record declaration",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize20
 Real a1.x[1](stateSelect = StateSelect.default,start = 1);
 Real a1.x[2](stateSelect = StateSelect.default,start = 2);
initial equation 
 a1.x[1] = 1;
 a1.x[2] = 2;
equation
 a1.der(x[1]) = - a1.x[1];
 a1.der(x[2]) = - a1.x[2];

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end RecordTests.RecordScalarize20;
")})));
end RecordScalarize20;


model RecordScalarize21
	record A
		Real x[2];
		Real y;
	end A;
	
	parameter Real y_start = 3;
	
	A a(y(start=y_start));
equation
	a = A({1,2}, 4);

	annotation(__JModelica(UnitTesting(tests={ 
		TransformCanonicalTestCase(
			name="RecordScalarize21",
			description="Modifiers on record members using parameters",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize21
 parameter Real y_start = 3 /* 3 */;
 Real a.x[1];
 Real a.x[2];
 Real a.y(start = y_start);
equation
 a.x[1] = 1;
 a.x[2] = 2;
 a.y = 4;
end RecordTests.RecordScalarize21;
")})));
end RecordScalarize21;


model RecordScalarize22
    function f1
        output Real o;
        input A x[3];
    algorithm
        o := x[1].b[2].c;
    end f1;

    function f2
        input Real o;
        output A x;
    algorithm
        x := A(o, {B(o + 1), B(o + 2)});
    end f2;

    function f3
        input Real o;
        output B x;
    algorithm
        x := B(o);
    end f3;
 
    record A
        Real a;
        B b[2];
    end A;
 
    record B
        Real c;
    end B;
 
    Real x = f1({A(1,{B(2),B(3)}),f2(4),A(7,{f3(8),f3(9)})});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize22",
			description="Array of records as argument to function",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordScalarize22
 Real x;
 Real temp_1.a;
 Real temp_1.b[1].c;
 Real temp_1.b[2].c;
 Real temp_2.c;
 Real temp_3.c;
equation
 (RecordTests.RecordScalarize22.A(temp_1.a, {RecordTests.RecordScalarize22.B(temp_1.b[1].c), RecordTests.RecordScalarize22.B(temp_1.b[2].c)})) = RecordTests.RecordScalarize22.f2(4);
 (RecordTests.RecordScalarize22.B(temp_2.c)) = RecordTests.RecordScalarize22.f3(8);
 (RecordTests.RecordScalarize22.B(temp_3.c)) = RecordTests.RecordScalarize22.f3(9);
 x = RecordTests.RecordScalarize22.f1({RecordTests.RecordScalarize22.A(1, {RecordTests.RecordScalarize22.B(2), RecordTests.RecordScalarize22.B(3)}), RecordTests.RecordScalarize22.A(temp_1.a, {RecordTests.RecordScalarize22.B(temp_1.b[1].c), RecordTests.RecordScalarize22.B(temp_1.b[2].c)}), RecordTests.RecordScalarize22.A(7, {RecordTests.RecordScalarize22.B(temp_2.c), RecordTests.RecordScalarize22.B(temp_3.c)})});

public
 function RecordTests.RecordScalarize22.f1
  output Real o;
  input RecordTests.RecordScalarize22.A[3] x;
 algorithm
  o := x[1].b[2].c;
  return;
 end RecordTests.RecordScalarize22.f1;

 function RecordTests.RecordScalarize22.f2
  input Real o;
  output RecordTests.RecordScalarize22.A x;
 algorithm
  x.a := o;
  x.b[1].c := o + 1;
  x.b[2].c := o + 2;
  return;
 end RecordTests.RecordScalarize22.f2;

 function RecordTests.RecordScalarize22.f3
  input Real o;
  output RecordTests.RecordScalarize22.B x;
 algorithm
  x.c := o;
  return;
 end RecordTests.RecordScalarize22.f3;

 record RecordTests.RecordScalarize22.B
  Real c;
 end RecordTests.RecordScalarize22.B;

 record RecordTests.RecordScalarize22.A
  Real a;
  RecordTests.RecordScalarize22.B b[2];
 end RecordTests.RecordScalarize22.A;

end RecordTests.RecordScalarize22;
")})));
end RecordScalarize22;


model RecordScalarize23
	record R
		Real[1] X;
	end R;
	
	final parameter Real p = -0.1;
	final parameter Real[1] s =  {0.4 - p};
	R r(X(start=s)) = R({1});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize23",
			description="",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize23
 parameter Real p = - 0.1 /* -0.1 */;
 parameter Real s[1];
 Real r.X[1](start = s[1]);
parameter equation
 s[1] = 0.4 - p;
equation
 r.X[1] = 1;
end RecordTests.RecordScalarize23;
")})));
end RecordScalarize23;


model RecordScalarize24
	record R
		Real[1] X;
	end R;
	
	final parameter Real p = -0.1;
	R r(X(start={0.4 - p})) = R({1});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize24",
			description="",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordScalarize24
 parameter Real p = - 0.1 /* -0.1 */;
 Real r.X[1](start = 0.4 - p);
equation
 r.X[1] = 1;
end RecordTests.RecordScalarize24;
")})));
end RecordScalarize24;


model RecordScalarize25
	type A = enumeration(a1, a2);
	
	record B
		Real x;
		A y;
	end B;
	
	B b(x = time, y = if b.x < 3 then A.a1 else A.a2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize25",
			description="Scalarization of enumeration variable in record",
			flatModel="
fclass RecordTests.RecordScalarize25
 Real b.x;
 discrete RecordTests.RecordScalarize25.A b.y;
initial equation 
 b.pre(y) = RecordTests.RecordScalarize25.A.a1;
equation
 b.x = time;
 b.y = if b.x < 3 then RecordTests.RecordScalarize25.A.a1 else RecordTests.RecordScalarize25.A.a2;

public
 type RecordTests.RecordScalarize25.A = enumeration(a1, a2);

end RecordTests.RecordScalarize25;
")})));
end RecordScalarize25;


model RecordScalarize26
	record R
	    parameter Real x[2] = { 1, 2 };
	    Real y;
	end R;
	
	R r(y = time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordScalarize26",
			description="Scalarization of array with binding expression in record declaration",
			flatModel="
fclass RecordTests.RecordScalarize26
 parameter Real r.x[1] = 1 /* 1 */;
 parameter Real r.x[2] = 2 /* 2 */;
 Real r.y;
equation
 r.y = time;
end RecordTests.RecordScalarize26;
")})));
end RecordScalarize26;

// TODO: Add more complicated combinations of arrays, records and modifiers



model RecordFunc1
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc1",
			description="Scalarization of records in functions: accesses of components",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc1
 Real q;
equation
 q = RecordTests.RecordFunc1.f(1, 2);

public
 function RecordTests.RecordFunc1.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc1.A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
  return;
 end RecordTests.RecordFunc1.f;

 record RecordTests.RecordFunc1.A
  Real x;
  Real y;
 end RecordTests.RecordFunc1.A;

end RecordTests.RecordFunc1;
")})));
end RecordFunc1;


model RecordFunc2
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
  protected A w;
 algorithm
  z.x := ix;
  z.y := iy;
  w := z;
  o := w.x * w.y;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc2",
			description="Scalarization of records in functions: assignment",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc2
 Real q;
equation
 q = RecordTests.RecordFunc2.f(1, 2);

public
 function RecordTests.RecordFunc2.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc2.A z;
  RecordTests.RecordFunc2.A w;
 algorithm
  z.x := ix;
  z.y := iy;
  w.x := z.x;
  w.y := z.y;
  o := w.x * w.y;
  return;
 end RecordTests.RecordFunc2.f;

 record RecordTests.RecordFunc2.A
  Real x;
  Real y;
 end RecordTests.RecordFunc2.A;

end RecordTests.RecordFunc2;
")})));
end RecordFunc2;


model RecordFunc3
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z := A(ix, iy);
  o := z.x * z.y;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc3",
			description="Scalarization of records in functions: record constructor",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc3
 Real q;
equation
 q = RecordTests.RecordFunc3.f(1, 2);

public
 function RecordTests.RecordFunc3.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc3.A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
  return;
 end RecordTests.RecordFunc3.f;

 record RecordTests.RecordFunc3.A
  Real x;
  Real y;
 end RecordTests.RecordFunc3.A;

end RecordTests.RecordFunc3;
")})));
end RecordFunc3;


model RecordFunc3b
 record A
  Real x;
  Real y;
 end A;
 
 record B
  Real x;
  Real y;
 end B;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z := B(ix, iy);
  o := z.x * z.y;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc3b",
			description="Scalarization of records in functions: record constructor for equivalent record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc3b
 Real q;
equation
 q = RecordTests.RecordFunc3b.f(1, 2);

public
 function RecordTests.RecordFunc3b.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc3b.A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
  return;
 end RecordTests.RecordFunc3b.f;

 record RecordTests.RecordFunc3b.A
  Real x;
  Real y;
 end RecordTests.RecordFunc3b.A;

end RecordTests.RecordFunc3b;
")})));
end RecordFunc3b;


model RecordFunc4
 record A
  Real x[2];
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  o := z.x[1] * z.x[2];
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc4",
			description="Scalarization of records in functions: inner array, access",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc4
 Real q;
equation
 q = RecordTests.RecordFunc4.f(1, 2);

public
 function RecordTests.RecordFunc4.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc4.A z;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  o := z.x[1] * z.x[2];
  return;
 end RecordTests.RecordFunc4.f;

 record RecordTests.RecordFunc4.A
  Real x[2];
 end RecordTests.RecordFunc4.A;

end RecordTests.RecordFunc4;
")})));
end RecordFunc4;


model RecordFunc5
 record A
  Real x[2];
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
  protected A w;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  w := z;
  o := w.x[1] * w.x[2];
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc5",
			description="Scalarization of records in functions: inner array, assignment",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc5
 Real q;
equation
 q = RecordTests.RecordFunc5.f(1, 2);

public
 function RecordTests.RecordFunc5.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc5.A z;
  RecordTests.RecordFunc5.A w;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  w.x[1] := z.x[1];
  w.x[2] := z.x[2];
  o := w.x[1] * w.x[2];
  return;
 end RecordTests.RecordFunc5.f;

 record RecordTests.RecordFunc5.A
  Real x[2];
 end RecordTests.RecordFunc5.A;

end RecordTests.RecordFunc5;
")})));
end RecordFunc5;


model RecordFunc6
 record A
  Real x[2];
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z := A({ix, iy});
  o := z.x[1] * z.x[2];
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc6",
			description="Scalarization of records in functions: record constructor",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc6
 Real q;
equation
 q = RecordTests.RecordFunc6.f(1, 2);

public
 function RecordTests.RecordFunc6.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc6.A z;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  o := z.x[1] * z.x[2];
  return;
 end RecordTests.RecordFunc6.f;

 record RecordTests.RecordFunc6.A
  Real x[2];
 end RecordTests.RecordFunc6.A;

end RecordTests.RecordFunc6;
")})));
end RecordFunc6;


model RecordFunc7
 record A
  Real x;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z[2];
 algorithm
  z[1].x := ix;
  z[2].x := iy;
  o := z[1].x * z[2].x;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc7",
			description="Scalarization of records in functions: array of records, access",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc7
 Real q;
equation
 q = RecordTests.RecordFunc7.f(1, 2);

public
 function RecordTests.RecordFunc7.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc7.A[2] z;
 algorithm
  z[1].x := ix;
  z[2].x := iy;
  o := z[1].x * z[2].x;
  return;
 end RecordTests.RecordFunc7.f;

 record RecordTests.RecordFunc7.A
  Real x;
 end RecordTests.RecordFunc7.A;

end RecordTests.RecordFunc7;
")})));
end RecordFunc7;


model RecordFunc8
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z[2];
  protected A w[2];
 algorithm
  z[1].x := ix;
  z[1].y := iy;
  z[2].x := ix;
  z[2].y := iy;
  w := z;
  o := w[1].x * w[2].x;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc8",
			description="Scalarization of records in functions: array of records, assignment",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc8
 Real q;
equation
 q = RecordTests.RecordFunc8.f(1, 2);

public
 function RecordTests.RecordFunc8.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc8.A[2] z;
  RecordTests.RecordFunc8.A[2] w;
 algorithm
  z[1].x := ix;
  z[1].y := iy;
  z[2].x := ix;
  z[2].y := iy;
  w[1].x := z[1].x;
  w[1].y := z[1].y;
  w[2].x := z[2].x;
  w[2].y := z[2].y;
  o := w[1].x * w[2].x;
  return;
 end RecordTests.RecordFunc8.f;

 record RecordTests.RecordFunc8.A
  Real x;
  Real y;
 end RecordTests.RecordFunc8.A;

end RecordTests.RecordFunc8;
")})));
end RecordFunc8;


model RecordFunc9
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z[2];
 algorithm
  z := {A(ix, iy), A(ix+2, iy+2)};
  o := z[1].x * z[2].x;
 end f;
 
 Real q = f(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordFunc9",
			description="Scalarization of records in functions: array of records, constructor",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordFunc9
 Real q;
equation
 q = RecordTests.RecordFunc9.f(1, 2);

public
 function RecordTests.RecordFunc9.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc9.A[2] z;
 algorithm
  z[1].x := ix;
  z[1].y := iy;
  z[2].x := ix + 2;
  z[2].y := iy + 2;
  o := z[1].x * z[2].x;
  return;
 end RecordTests.RecordFunc9.f;

 record RecordTests.RecordFunc9.A
  Real x;
  Real y;
 end RecordTests.RecordFunc9.A;

end RecordTests.RecordFunc9;
")})));
end RecordFunc9;



model RecordOutput1
 record A
  Real y;
  Real x;
 end A;
 
 function f
  output A o = A(1, 2);
 algorithm
 end f;
 
 A z = f();

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordOutput1",
			description="Scalarization of records in functions: record output: basic test",
			variability_propagation=false,
			inline_functions="none",
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordOutput1
 Real z.y;
 Real z.x;
 Real temp_1.y;
 Real temp_1.x;
equation
 (RecordTests.RecordOutput1.A(temp_1.y, temp_1.x)) = RecordTests.RecordOutput1.f();
 z.y = temp_1.y;
 z.x = temp_1.x;

public
 function RecordTests.RecordOutput1.f
  output RecordTests.RecordOutput1.A o;
 algorithm
  o.y := 1;
  o.x := 2;
  return;
 end RecordTests.RecordOutput1.f;

 record RecordTests.RecordOutput1.A
  Real y;
  Real x;
 end RecordTests.RecordOutput1.A;

end RecordTests.RecordOutput1;
")})));
end RecordOutput1;


model RecordOutput2
 record A
  Real x;
  Real y;
 end A;
 
 function f
  output A o[2] = {A(1, 2), A(3, 4)};
 algorithm
 end f;
 
 A x[2] = f();

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordOutput2",
			description="Scalarization of records in functions: record output: array of records",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordOutput2
 Real x[1].x;
 Real x[1].y;
 Real x[2].x;
 Real x[2].y;
equation
 ({RecordTests.RecordOutput2.A(x[1].x, x[1].y),RecordTests.RecordOutput2.A(x[2].x, x[2].y)}) = RecordTests.RecordOutput2.f();

public
 function RecordTests.RecordOutput2.f
  output RecordTests.RecordOutput2.A[2] o;
 algorithm
  o[1].x := 1;
  o[1].y := 2;
  o[2].x := 3;
  o[2].y := 4;
  return;
 end RecordTests.RecordOutput2.f;

 record RecordTests.RecordOutput2.A
  Real x;
  Real y;
 end RecordTests.RecordOutput2.A;

end RecordTests.RecordOutput2;
")})));
end RecordOutput2;


model RecordOutput3
 record A
  Real x[2];
  Real y[3];
 end A;
 
 function f
  output A o = A({1,2}, {3,4,5});
 algorithm
 end f;
 
 A x = f();

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordOutput3",
			description="Scalarization of records in functions: record output: record containing array",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordOutput3
 Real x.x[1];
 Real x.x[2];
 Real x.y[1];
 Real x.y[2];
 Real x.y[3];
equation
 (RecordTests.RecordOutput3.A({x.x[1],x.x[2]}, {x.y[1],x.y[2],x.y[3]})) = RecordTests.RecordOutput3.f();

public
 function RecordTests.RecordOutput3.f
  output RecordTests.RecordOutput3.A o;
 algorithm
  o.x[1] := 1;
  o.x[2] := 2;
  o.y[1] := 3;
  o.y[2] := 4;
  o.y[3] := 5;
  return;
 end RecordTests.RecordOutput3.f;

 record RecordTests.RecordOutput3.A
  Real x[2];
  Real y[3];
 end RecordTests.RecordOutput3.A;

end RecordTests.RecordOutput3;
")})));
end RecordOutput3;


model RecordOutput4
 record A
  Real x;
  Real y;
 end A;
 
 record B
  A x;
  Real y;
 end B;
 
 function f
  output B o = B(A(1, 2), 3);
 algorithm
 end f;
 
 B x = f();

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordOutput4",
			description="Scalarization of records in functions: record output: nestled records",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordOutput4
 Real x.x.x;
 Real x.x.y;
 Real x.y;
equation
 (RecordTests.RecordOutput4.B(RecordTests.RecordOutput4.A(x.x.x, x.x.y), x.y)) = RecordTests.RecordOutput4.f();

public
 function RecordTests.RecordOutput4.f
  output RecordTests.RecordOutput4.B o;
 algorithm
  o.x.x := 1;
  o.x.y := 2;
  o.y := 3;
  return;
 end RecordTests.RecordOutput4.f;

 record RecordTests.RecordOutput4.A
  Real x;
  Real y;
 end RecordTests.RecordOutput4.A;

 record RecordTests.RecordOutput4.B
  RecordTests.RecordOutput4.A x;
  Real y;
 end RecordTests.RecordOutput4.B;

end RecordTests.RecordOutput4;
")})));
end RecordOutput4;


model RecordOutput5
    record R
        Real x;
        Real y;
    end R;

    function f
        input Real u;
        output R ry;
        output Real y;
    algorithm
        ry := R(1,2);
        y := u;
    end f;

    R ry;
    Real z;
equation
    (ry,z) = f(3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordOutput5",
			description="Test scalarization of function call equation left of record type",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordOutput5
 Real ry.x;
 Real ry.y;
 Real z;
equation
 (RecordTests.RecordOutput5.R(ry.x, ry.y), z) = RecordTests.RecordOutput5.f(3);

public
 function RecordTests.RecordOutput5.f
  input Real u;
  output RecordTests.RecordOutput5.R ry;
  output Real y;
 algorithm
  ry.x := 1;
  ry.y := 2;
  y := u;
  return;
 end RecordTests.RecordOutput5.f;

 record RecordTests.RecordOutput5.R
  Real x;
  Real y;
 end RecordTests.RecordOutput5.R;

end RecordTests.RecordOutput5;
")})));
end RecordOutput5;


model RecordOutput6
    record R
        Real x;
        Real y;
    end R;

    function f
        input R rx;
        output R ry;
    algorithm
        ry := rx;
    end f;

    R ry = f(R(5,6));
    Real u;
    Real y = 3;
equation
    y = u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordOutput6",
			description="Test that access to record member with same name as alias variable isn't changed in alias elimination",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordOutput6
 Real ry.x;
 Real ry.y;
 Real y;
equation
 (RecordTests.RecordOutput6.R(ry.x, ry.y)) = RecordTests.RecordOutput6.f(RecordTests.RecordOutput6.R(5, 6));
 y = 3;

public
 function RecordTests.RecordOutput6.f
  input RecordTests.RecordOutput6.R rx;
  output RecordTests.RecordOutput6.R ry;
 algorithm
  ry.x := rx.x;
  ry.y := rx.y;
  return;
 end RecordTests.RecordOutput6.f;

 record RecordTests.RecordOutput6.R
  Real x;
  Real y;
 end RecordTests.RecordOutput6.R;

end RecordTests.RecordOutput6;
")})));
end RecordOutput6;



model RecordInput1
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f;
 
 Real x = f(A(1,{2,3}*{4,5}));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput1",
			description="Scalarization of records in functions: record input: record constructor",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput1
 Real x;
equation
 x = RecordTests.RecordInput1.f(RecordTests.RecordInput1.A(1, 2 * 4 + 3 * 5));

public
 function RecordTests.RecordInput1.f
  input RecordTests.RecordInput1.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput1.f;

 record RecordTests.RecordInput1.A
  Real x;
  Real y;
 end RecordTests.RecordInput1.A;

end RecordTests.RecordInput1;
")})));
end RecordInput1;


model RecordInput2
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f;
 
 A a = A(1,2);
 Real x = f(a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput2",
			description="Scalarization of records in functions: record input:",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput2
 Real a.x;
 Real a.y;
 Real x;
equation
 a.x = 1;
 a.y = 2;
 x = RecordTests.RecordInput2.f(RecordTests.RecordInput2.A(a.x, a.y));

public
 function RecordTests.RecordInput2.f
  input RecordTests.RecordInput2.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput2.f;

 record RecordTests.RecordInput2.A
  Real x;
  Real y;
 end RecordTests.RecordInput2.A;

end RecordTests.RecordInput2;
")})));
end RecordInput2;


// TODO: Dont create temporary here, just send the returned array into the next function (cf. arrays)
model RecordInput3
 record A
  Real x;
  Real y;
 end A;
 
 function f1
  output A o;
 algorithm
  o := A(1,2);
 end f1;
 
 function f2
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f2;
 
 Real x = f2(f1());

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput3",
			description="Scalarization of records in functions: record input: output from another function",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput3
 Real x;
 Real temp_1.x;
 Real temp_1.y;
equation
 (RecordTests.RecordInput3.A(temp_1.x, temp_1.y)) = RecordTests.RecordInput3.f1();
 x = RecordTests.RecordInput3.f2(RecordTests.RecordInput3.A(temp_1.x, temp_1.y));

public
 function RecordTests.RecordInput3.f2
  input RecordTests.RecordInput3.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput3.f2;

 function RecordTests.RecordInput3.f1
  output RecordTests.RecordInput3.A o;
 algorithm
  o.x := 1;
  o.y := 2;
  return;
 end RecordTests.RecordInput3.f1;

 record RecordTests.RecordInput3.A
  Real x;
  Real y;
 end RecordTests.RecordInput3.A;

end RecordTests.RecordInput3;
")})));
end RecordInput3;


model RecordInput4
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input A i[2];
  output Real o;
 algorithm
  o := i[1].x + i[2].y;
 end f;
 
 A a[2] = {A(1,2),A(3,4)};
 Real x = f(a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput4",
			description="Scalarization of records in functions: record input: array of records",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput4
 Real a[1].x;
 Real a[1].y;
 Real a[2].x;
 Real a[2].y;
 Real x;
equation
 a[1].x = 1;
 a[2].x = 3;
 a[1].y = 2;
 a[2].y = 4;
 x = RecordTests.RecordInput4.f({RecordTests.RecordInput4.A(a[1].x, a[1].y),RecordTests.RecordInput4.A(a[2].x, a[2].y)});

public
 function RecordTests.RecordInput4.f
  input RecordTests.RecordInput4.A[2] i;
  output Real o;
 algorithm
  o := i[1].x + i[2].y;
  return;
 end RecordTests.RecordInput4.f;

 record RecordTests.RecordInput4.A
  Real x;
  Real y;
 end RecordTests.RecordInput4.A;

end RecordTests.RecordInput4;
")})));
end RecordInput4;


model RecordInput5
 record A
  Real x[2];
  Real y;
 end A;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.x[1] + i.y;
 end f;
 
 A a = A({1,2}, 3);
 Real x = f(a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput5",
			description="Scalarization of records in functions: record input: record containing array",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput5
 Real a.x[1];
 Real a.x[2];
 Real a.y;
 Real x;
equation
 a.x[1] = 1;
 a.x[2] = 2;
 a.y = 3;
 x = RecordTests.RecordInput5.f(RecordTests.RecordInput5.A({a.x[1],a.x[2]}, a.y));

public
 function RecordTests.RecordInput5.f
  input RecordTests.RecordInput5.A i;
  output Real o;
 algorithm
  o := i.x[1] + i.y;
  return;
 end RecordTests.RecordInput5.f;

 record RecordTests.RecordInput5.A
  Real x[2];
  Real y;
 end RecordTests.RecordInput5.A;

end RecordTests.RecordInput5;
")})));
end RecordInput5;


model RecordInput6
 record A
  B z;
 end A;
 
 record B
  Real x;
  Real y;
 end B;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.z.x + i.z.y;
 end f;
 
 A a = A(B(1,2));
 Real x = f(a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput6",
			description="Scalarization of records in functions: record input: nestled records",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput6
 Real a.z.x;
 Real a.z.y;
 Real x;
equation
 a.z.x = 1;
 a.z.y = 2;
 x = RecordTests.RecordInput6.f(RecordTests.RecordInput6.A(RecordTests.RecordInput6.B(a.z.x, a.z.y)));

public
 function RecordTests.RecordInput6.f
  input RecordTests.RecordInput6.A i;
  output Real o;
 algorithm
  o := i.z.x + i.z.y;
  return;
 end RecordTests.RecordInput6.f;

 record RecordTests.RecordInput6.B
  Real x;
  Real y;
 end RecordTests.RecordInput6.B;

 record RecordTests.RecordInput6.A
  RecordTests.RecordInput6.B z;
 end RecordTests.RecordInput6.A;

end RecordTests.RecordInput6;
")})));
end RecordInput6;


model RecordInput7
 record A
  Real x;
  Real y;
 end A;
 
 function f1
  input A i;
  output Real o;
 algorithm
  o := f2(i);
 end f1;
  
 function f2
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f2;
 
 A a = A(1,2);
 Real x = f1(a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInput7",
			description="Scalarization of records in functions: record input: in functions",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordInput7
 Real a.x;
 Real a.y;
 Real x;
equation
 a.x = 1;
 a.y = 2;
 x = RecordTests.RecordInput7.f1(RecordTests.RecordInput7.A(a.x, a.y));

public
 function RecordTests.RecordInput7.f1
  input RecordTests.RecordInput7.A i;
  output Real o;
 algorithm
  o := RecordTests.RecordInput7.f2(i);
  return;
 end RecordTests.RecordInput7.f1;

 function RecordTests.RecordInput7.f2
  input RecordTests.RecordInput7.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput7.f2;

 record RecordTests.RecordInput7.A
  Real x;
  Real y;
 end RecordTests.RecordInput7.A;

end RecordTests.RecordInput7;
")})));
end RecordInput7;



model RecordParBexp1
	record R
		Real x = 1;
		Real y = 1;
	end R;
	
	parameter R[2] r = {R(3,3),R(4,6)};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParBexp1",
			description="Parameter with array-of-records type and literal binding expression",
			variability_propagation=false,
			checkAll=true,
			flatModel="
fclass RecordTests.RecordParBexp1
 parameter Real r[1].x = 3 /* 3 */;
 parameter Real r[1].y = 3 /* 3 */;
 parameter Real r[2].x = 4 /* 4 */;
 parameter Real r[2].y = 6 /* 6 */;
end RecordTests.RecordParBexp1;
")})));
end RecordParBexp1;



model RecordWithParam1
	record R
		parameter Real a;
		Real b;
	end R;
	
	R c(a = 1, b = 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordWithParam1",
			description="Record with independent parameter getting value from modification",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordWithParam1
 parameter Real c.a = 1 /* 1 */;
 Real c.b;
equation
 c.b = 2;
end RecordTests.RecordWithParam1;
")})));
end RecordWithParam1;


model RecordWithParam2
	record R
		parameter Real a;
		Real b;
	end R;
	
	R c(a = d, b = 2);
	parameter Real d = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordWithParam2",
			description="Record with dependent parameter getting value from modification",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordWithParam2
 parameter Real c.a;
 Real c.b;
 parameter Real d = 1 /* 1 */;
parameter equation
 c.a = d;
equation
 c.b = 2;
end RecordTests.RecordWithParam2;
")})));
end RecordWithParam2;



model RecordWithColonArray1
	record A
		Real a[:];
		Real b;
	end A;

	A c = A({1, 2, 3}, 4);
	A d = A({5, 6}, 7);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordWithColonArray1",
			description="Variable with : size in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordWithColonArray1
 Real c.a[1];
 Real c.a[2];
 Real c.a[3];
 Real c.b;
 Real d.a[1];
 Real d.a[2];
 Real d.b;
equation
 c.a[1] = 1;
 c.a[2] = 2;
 c.a[3] = 3;
 c.b = 4;
 d.a[1] = 5;
 d.a[2] = 6;
 d.b = 7;
end RecordTests.RecordWithColonArray1;
")})));
end RecordWithColonArray1;


model RecordWithColonArray2
	record A
		Real a[:];
		Real b;
	end A;

	A c;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecordWithColonArray2",
			description="Variable with : size without binding exp",
			variability_propagation=false,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 2794, column 8:
  Can not infer array size of the variable a
")})));
end RecordWithColonArray2;


model RecordWithColonArray3
	record A
		Real a[:];
		Real b;
	end A;

	A c(a = {1, 2, 3}, b = 4);
	A d(a = {5, 6}, b = 7);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordWithColonArray3",
			description="Variable with : size in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordWithColonArray3
 Real c.a[1];
 Real c.a[2];
 Real c.a[3];
 Real c.b;
 Real d.a[1];
 Real d.a[2];
 Real d.b;
equation
 c.a[1] = 1;
 c.a[2] = 2;
 c.a[3] = 3;
 c.b = 4;
 d.a[1] = 5;
 d.a[2] = 6;
 d.b = 7;
end RecordTests.RecordWithColonArray3;
")})));
end RecordWithColonArray3;


// TODO: causes exception during flattening
model RecordWithColonArray4
	record A
		B a[:];
		B b[:];
	end A;
	
	record B
		Real c[:];
		Real d[:];
	end B;

	// TODO: support different sizes for b[1].c & b[2].c, etc
	A e(a = {B(c = {1,2,3}, d = {1,2,3,4})}, b = {B(c = {1,2,3,4}, d = {1,2,3,4,5}), B(c = {1,2,3,4}, d = {1,2,3,4,5})});
end RecordWithColonArray4;



model RecordDer1
	record A
		Real x;
		Real y;
	end A;
	
	A a;
initial equation
	a = A(1, 0);
equation
	der(a.x) = -a.y;
	der(a.y) = -a.x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordDer1",
			description="der() on record members",
			variability_propagation=false,
			eliminate_alias_variables=false,
			flatModel="
fclass RecordTests.RecordDer1
 Real a.x;
 Real a.y;
initial equation 
 a.x = 1;
 a.y = 0;
equation
 a.der(x) = - a.y;
 a.der(y) = - a.x;
end RecordTests.RecordDer1;
")})));
end RecordDer1;



model RecordParam1
	record A
		parameter Real x = 1;
		Real y;
	end A;
	
	A a1(y=2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam1",
			description="Parameter with default value in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordParam1
 parameter Real a1.x = 1 /* 1 */;
 Real a1.y;
equation
 a1.y = 2;
end RecordTests.RecordParam1;
")})));
end RecordParam1;


model RecordParam2
	record A
		parameter Real x = 1;
		Real y;
	end A;
	
	A a1 = A(y=2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam2",
			description="Parameter with default value in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordParam2
 parameter Real a1.x = 1 /* 1 */;
 Real a1.y;
equation
 a1.y = 2;
end RecordTests.RecordParam2;
")})));
end RecordParam2;


model RecordParam3
	function f
		input Real i;
		output Real[2] o = { i, -i };
	algorithm
	end f;
	
	record A
		parameter Real[2] x = f(1);
		Real y;
	end A;
	
	A a1(y=2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam3",
			description="Parameter with default value in record",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordParam3
 parameter Real temp_1[1];
 parameter Real temp_1[2];
 Real a1.y;
 parameter Real a1.x[1];
 parameter Real a1.x[2];
parameter equation
 ({temp_1[1], temp_1[2]}) = RecordTests.RecordParam3.f(1);
 a1.x[1] = temp_1[1];
 a1.x[2] = temp_1[2];
equation
 a1.y = 2;

public
 function RecordTests.RecordParam3.f
  input Real i;
  output Real[2] o;
 algorithm
  o[1] := i;
  o[2] := - i;
  return;
 end RecordTests.RecordParam3.f;

end RecordTests.RecordParam3;
")})));
end RecordParam3;


model RecordParam4
	record A
		parameter Real x = 1;
		parameter Real z = x;
		Real y;
	end A;
	
	A a1(y=2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam4",
			description="Parameter with default value in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordParam4
 parameter Real a1.x = 1 /* 1 */;
 parameter Real a1.z;
 Real a1.y;
parameter equation
 a1.z = a1.x;
equation
 a1.y = 2;
end RecordTests.RecordParam4;
")})));
end RecordParam4;


model RecordParam5
	record A
		parameter Real x = 2;
		parameter Real z = 3;
		Real y;
	end A;
	
	A a1 = A(y = 2, x = 1, z = a1.x);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam5",
			description="Parameter with default value in record",
			variability_propagation=false,
			flatModel="
fclass RecordTests.RecordParam5
 parameter Real a1.x = 1 /* 1 */;
 parameter Real a1.z;
 Real a1.y;
parameter equation
 a1.z = a1.x;
equation
 a1.y = 2;
end RecordTests.RecordParam5;
")})));
end RecordParam5;


model RecordParam6
	function f
		output Real[2] o = {1,2};
	algorithm
	end f;
	
	record A
		parameter Real x[2] = f();
		parameter Real y[2] = x;
	end A;
	
	A a1;
	A a2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam6",
			description="",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordParam6
 parameter Real temp_1[1];
 parameter Real temp_1[2];
 parameter Real temp_2[1];
 parameter Real temp_2[2];
 parameter Real a1.x[1];
 parameter Real a1.x[2];
 parameter Real a2.x[1];
 parameter Real a2.x[2];
 parameter Real a1.y[1];
 parameter Real a1.y[2];
 parameter Real a2.y[1];
 parameter Real a2.y[2];
parameter equation
 ({temp_1[1], temp_1[2]}) = RecordTests.RecordParam6.f();
 ({temp_2[1], temp_2[2]}) = RecordTests.RecordParam6.f();
 a1.x[1] = temp_1[1];
 a1.x[2] = temp_1[2];
 a2.x[1] = temp_2[1];
 a2.x[2] = temp_2[2];
 a1.y[1] = a1.x[1];
 a1.y[2] = a1.x[2];
 a2.y[1] = a2.x[1];
 a2.y[2] = a2.x[2];

public
 function RecordTests.RecordParam6.f
  output Real[2] o;
 algorithm
  o[1] := 1;
  o[2] := 2;
  return;
 end RecordTests.RecordParam6.f;

end RecordTests.RecordParam6;
")})));
end RecordParam6;


model RecordParam7
    record A
        Integer n;
    end A;
    
    record B
        extends A;
    end B;
    
    parameter B b = B(2);
    Real x[b.n] = time * ones(b.n);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordParam7",
			description="Variability calculation for records involving inheritance",
			flatModel="
fclass RecordTests.RecordParam7
 parameter Integer b.n = 2 /* 2 */;
 Real x[1];
 Real x[2];
equation
 x[1] = time;
 x[2] = time;
end RecordTests.RecordParam7;
")})));
end RecordParam7;


model RecordParam8
    record A
        parameter Real x = 1;
        Real y;
    end A;
    
    parameter A a;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordParam8",
            description="Check that extra warnings aren't generated about binding expressions for record parameters",
            errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/RecordTests.mo':
At line 4233, column 29:
  The parameter a.y does not have a binding expression
")})));
end RecordParam8;


model RecordParam9
    record A
        parameter Real x;
        Real y;
    end A;
    
    parameter A a = A(1, 2);
    parameter Real z;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordParam9",
            description="Check that extra warnings aren't generated about binding expressions for record parameters, record has constuctor binding exp",
            errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/RecordTests.mo':
At line 4258, column 28:
  The parameter z does not have a binding expression
")})));
end RecordParam9;


model RecordParam10
    record A
        parameter Real x;
        Real y;
    end A;
	
	function f
		output A a;
	algorithm
		a := A(1,2);
	end f;
    
    parameter A a = f();
    parameter Real z;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordParam10",
            description="Check that extra warnings aren't generated about binding expressions for record parameters, record has function call binding exp",
            errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/RecordTests.mo':
At line 4286, column 24:
  The parameter z does not have a binding expression
")})));
end RecordParam10;


model RecordMerge1
    record R1
        Real x;
        Real y;
    end R1;
 
    record R2
        Real x;
        Real y;
    end R2;
 
    function F
        input R1 rin;
        output R2 rout;
    algorithm
        rout := rin;
    end F;
 
    R2 r2 = F(R1(1,2));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordMerge1",
			description="Check that equivalent records are merged",
			variability_propagation=false,
			inline_functions="none",
			flatModel="
fclass RecordTests.RecordMerge1
 Real r2.x;
 Real r2.y;
equation
 (RecordTests.RecordMerge1.R2(r2.x, r2.y)) = RecordTests.RecordMerge1.F(RecordTests.RecordMerge1.R2(1, 2));

public
 function RecordTests.RecordMerge1.F
  input RecordTests.RecordMerge1.R2 rin;
  output RecordTests.RecordMerge1.R2 rout;
 algorithm
  rout.x := rin.x;
  rout.y := rin.y;
  return;
 end RecordTests.RecordMerge1.F;

 record RecordTests.RecordMerge1.R2
  Real x;
  Real y;
 end RecordTests.RecordMerge1.R2;

end RecordTests.RecordMerge1;
")})));
end RecordMerge1;


model RecordMerge2
    record C
        Real a;
    end C;
    
    record B
        C b;
        Real c;
    end B;
    
    record A
        Real a;
    end A;
    
    B b = B(C(time), time + 1);
    C c = A(time);
    

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordMerge2",
			description="",
			flatModel="
fclass RecordTests.RecordMerge2
 Real b.b.a;
 Real b.c;
 Real c.a;
equation
 b.b.a = time;
 b.c = time + 1;
 c.a = time;
end RecordTests.RecordMerge2;
")})));
end RecordMerge2;


model RecordEval1
    record A
        Real x;
        Real y;
    end A;
    
    parameter A a(x = 1, y = 2);
    
    Real z[2] = { i * time for i in a.x:a.y };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordEval1",
			description="Test that evaluation before scalarization of record variable without binding expression works",
			flatModel="
fclass RecordTests.RecordEval1
 parameter Real a.x = 1 /* 1 */;
 parameter Real a.y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * time;
end RecordTests.RecordEval1;
")})));
end RecordEval1;


model RecordEval2
    record A
        Real x = 1;
        Real y = 2;
    end A;
    
    parameter A a;
    
    Real z[2] = { i * time for i in a.x:a.y };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordEval2",
			description="Test that evaluation before scalarization of record variable without binding expression works",
			flatModel="
fclass RecordTests.RecordEval2
 parameter Real a.x = 1 /* 1 */;
 parameter Real a.y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * time;
end RecordTests.RecordEval2;
")})));
end RecordEval2;


model RecordEval3
    record A
        Real x;
        Real y;
    end A;
    
    parameter A a[2](x = {1, 3}, each y = 2);
    
    Real z[2] = { i * time for i in a[1].x:a[2].y };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordEval3",
			description="Test that evaluation before scalarization of record variable without binding expression works",
			flatModel="
fclass RecordTests.RecordEval3
 parameter Real a[1].x = 1 /* 1 */;
 parameter Real a[1].y = 2 /* 2 */;
 parameter Real a[2].x = 3 /* 3 */;
 parameter Real a[2].y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * time;
end RecordTests.RecordEval3;
")})));
end RecordEval3;


model RecordEval4
    record A
        Real x = 1;
        Real y = 2;
    end A;
    
    parameter A a[2];
    
    Real z[2] = { i * time for i in a[1].x:a[2].y };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordEval4",
			description="Test that evaluation before scalarization of record variable without binding expression works",
			flatModel="
fclass RecordTests.RecordEval4
 parameter Real a[1].x = 1 /* 1 */;
 parameter Real a[1].y = 2 /* 2 */;
 parameter Real a[2].x = 1 /* 1 */;
 parameter Real a[2].y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * time;
end RecordTests.RecordEval4;
")})));
end RecordEval4;


model RecordEval5
    record A
        Real x[2];
        Real y = 2;
    end A;
	
	record B
		A a[2];
	end B;
    
    parameter B b[2](a(x = {{{1,2},{3,4}},{{5,6},{7,8}}}));
    
    Real z[2] = { i * time for i in b[1].a[1].x[1]:b[2].a[2].y };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordEval5",
			description="Test that evaluation before scalarization of record variable without binding expression works",
			flatModel="
fclass RecordTests.RecordEval5
 parameter Real b[1].a[1].x[1] = 1 /* 1 */;
 parameter Real b[1].a[1].x[2] = 2 /* 2 */;
 parameter Real b[1].a[1].y = 2 /* 2 */;
 parameter Real b[1].a[2].x[1] = 3 /* 3 */;
 parameter Real b[1].a[2].x[2] = 4 /* 4 */;
 parameter Real b[1].a[2].y = 2 /* 2 */;
 parameter Real b[2].a[1].x[1] = 5 /* 5 */;
 parameter Real b[2].a[1].x[2] = 6 /* 6 */;
 parameter Real b[2].a[1].y = 2 /* 2 */;
 parameter Real b[2].a[2].x[1] = 7 /* 7 */;
 parameter Real b[2].a[2].x[2] = 8 /* 8 */;
 parameter Real b[2].a[2].y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * time;
end RecordTests.RecordEval5;
")})));
end RecordEval5;

model RecordEval6
	record R
		parameter Integer n1 = 1;
		Real x;
	end R;
	R r(n1 = n2, x = time);
	parameter Integer n2 = 2;
	Real y[n2] = ones(n2) * time;
	Real z = y * (1:r.n1);
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordEval6",
			description="Test that evaluation before scalarization of record variable works",
			flatModel="
fclass RecordTests.RecordEval6
 parameter Integer r.n1 = 2 /* 2 */;
 Real r.x;
 parameter Integer n2 = 2 /* 2 */;
 Real y[1];
 Real y[2];
 Real z;
equation
 r.x = time;
 y[1] = time;
 y[2] = time;
 z = y[1] + y[2] * 2;
end RecordTests.RecordEval6;
")})));
end RecordEval6;


model RecordModification1
  record R
    Real x;
  end R;

  Real y = time;
  R z(x = y + 2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordModification1",
			description="Modification on record with continuous variability",
			flatModel="
fclass RecordTests.RecordModification1
 Real y;
 Real z.x;
equation
 y = time;
 z.x = y + 2;
end RecordTests.RecordModification1;
")})));
end RecordModification1;


model RecordConnector1
    record A
        Real x;
        Real y;
    end A;

    connector B = A;
    
    B b;
equation
    b = B(time, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConnector1",
            description="Check that class can be both record and connector",
            flatModel="
fclass RecordTests.RecordConnector1
 RecordTests.RecordConnector1.B b;
equation
 b = RecordTests.RecordConnector1.B(time, 2);

public
 record RecordTests.RecordConnector1.B
  Real x;
  Real y;
 end RecordTests.RecordConnector1.B;

end RecordTests.RecordConnector1;
")})));
end RecordConnector1;


model ExternalObjectStructural1
    class A
        extends ExternalObject;
        
        function constructor
            input String b;
            output A a;
            external;
        end constructor;
        
        function destructor
            input A a;
            external;
        end destructor;
    end A;
    
    function f
        input A a;
        output Real b;
        external;
    end f;
    
    parameter String b = "abc";
    parameter A a = A(b);
    parameter Real c = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExternalObjectStructural1",
            description="Check that external objects do not get converted to structural parameters",
            flatModel="
fclass RecordTests.ExternalObjectStructural1
 parameter String b = \"abc\" /* \"abc\" */;
 parameter RecordTests.ExternalObjectStructural1.A a = RecordTests.ExternalObjectStructural1.A.constructor(\"abc\") /* (unknown value) */;
 parameter Real c;
parameter equation
 c = RecordTests.ExternalObjectStructural1.f(a);

public
 function RecordTests.ExternalObjectStructural1.A.destructor
  input ExternalObject a;
 algorithm
  external \"C\" destructor(a);
  return;
 end RecordTests.ExternalObjectStructural1.A.destructor;

 function RecordTests.ExternalObjectStructural1.A.constructor
  input String b;
  output ExternalObject a;
 algorithm
  external \"C\" a = constructor(b);
  return;
 end RecordTests.ExternalObjectStructural1.A.constructor;

 function RecordTests.ExternalObjectStructural1.f
  input ExternalObject a;
  output Real b;
 algorithm
  external \"C\" b = f(a);
  return;
 end RecordTests.ExternalObjectStructural1.f;

 type RecordTests.ExternalObjectStructural1.A = ExternalObject;
end RecordTests.ExternalObjectStructural1;
")})));
end ExternalObjectStructural1;



end RecordTests;
