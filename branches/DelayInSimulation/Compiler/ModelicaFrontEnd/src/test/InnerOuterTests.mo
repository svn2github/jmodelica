/*
    Copyright (C) 2011-2013 Modelon AB

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

package InnerOuterTests
model InnerOuterTest1
model A 
  outer Real T0;
  Real z = sin(T0);
end A;
model B 
  inner Real T0;
  A a1, a2;	// B.T0, B.a1.T0 and B.a2.T0 is the same variable
equation
  T0 = time;
end B;
B b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest1",
			description="Basic test of inner outer.",
			equation_sorting=true,
			flatModel="
fclass InnerOuterTests.InnerOuterTest1
 Real b.T0;
 Real b.a1.z;
 Real b.a2.z;
equation
 b.T0 = time;
 b.a1.z = sin(b.T0);
 b.a2.z = sin(b.T0);
end InnerOuterTests.InnerOuterTest1;
")})));
end InnerOuterTest1;

model InnerOuterTest2
	model A
		outer Real TI = time;
		Real x=TI*2;
		model B
			Real TI=1;
			model C
				Real TI=2;
				model D
					outer Real TI;
					Real x = 3*TI;
				end D;
				D d;
			end C;
			C c;
		end B;
		B b;
	end A;
	model E
		inner Real TI=4*time;
		model F
			inner Real TI=5*time;			
			model G
				Real TI = 5;
				class H
					A a;
				end H;
				H h;
			end G;
			G g;
		end F;
		F f;
	end E;
	model I
		inner Real TI = 2*time;
		E e;
		A a;
	end I;
	I i;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest2",
			description="Basic test of inner outer.",
			equation_sorting=true,
			flatModel="
fclass InnerOuterTests.InnerOuterTest2
 Real i.TI;
 Real i.e.TI;
 Real i.e.f.TI;
 constant Real i.e.f.g.TI = 5;
 Real i.e.f.g.h.a.x;
 constant Real i.e.f.g.h.a.b.TI = 1;
 constant Real i.e.f.g.h.a.b.c.TI = 2;
 Real i.e.f.g.h.a.b.c.d.x;
 Real i.a.x;
 constant Real i.a.b.TI = 1;
 constant Real i.a.b.c.TI = 2;
 Real i.a.b.c.d.x;
equation
 i.TI = 2 * time;
 i.e.TI = 4 * time;
 i.e.f.TI = 5 * time;
 i.e.f.g.h.a.x = i.e.f.TI * 2;
 i.e.f.g.h.a.b.c.d.x = 3 * i.e.f.TI;
 i.a.x = i.TI * 2;
 i.a.b.c.d.x = 3 * i.TI;
end InnerOuterTests.InnerOuterTest2;
")})));
end InnerOuterTest2;

model InnerOuterTest3_Err
 model A
   outer Boolean x;
 end A;
 inner Integer x = 3;
 A a;
end InnerOuterTest3_Err;

model InnerOuterTest4
	model A
		Real x;
	end A;
	model B
		outer A a;
		Real x = 2*a.x;
	end B;
	model C
		inner A a(x=sin(time));
		B b;
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest4",
			description="Basic test of inner outer.",
			equation_sorting=true,
			flatModel="
fclass InnerOuterTests.InnerOuterTest4
 Real c.a.x;
 Real c.b.x;
equation
 c.a.x = sin(time);
 c.b.x = 2 * c.a.x;
end InnerOuterTests.InnerOuterTest4;
")})));
end InnerOuterTest4;

model InnerOuterTest5
model ConditionalIntegrator 
    "Simple differential equation if isEnabled"
outer Boolean isEnabled;
Real x(start=1);
equation 
  der(x)= if isEnabled then -x else 0;
end ConditionalIntegrator;

model SubSystem 
    "subsystem that 'enable' its conditional integrators"
Boolean enableMe = time<=1; // Set inner isEnabled to outer isEnabled and enableMe 
inner outer Boolean isEnabled = isEnabled and enableMe;
ConditionalIntegrator conditionalIntegrator;
ConditionalIntegrator conditionalIntegrator2;
end SubSystem;

model System
             SubSystem subSystem;
  inner Boolean isEnabled = time>=0.5; // subSystem.conditionalIntegrator.isEnabled will be
                                       // 'isEnabled and subSystem.enableMe'
end System;

System sys;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest5",
			description="Basic test of inner outer.",
			equation_sorting=true,
			flatModel="
fclass InnerOuterTests.InnerOuterTest5
 discrete Boolean sys.subSystem.enableMe;
 discrete Boolean sys.subSystem.isEnabled;
 Real sys.subSystem.conditionalIntegrator.x(start = 1);
 Real sys.subSystem.conditionalIntegrator2.x(start = 1);
 discrete Boolean sys.isEnabled;
initial equation 
 sys.subSystem.conditionalIntegrator.x = 1;
 sys.subSystem.conditionalIntegrator2.x = 1;
 sys.subSystem.pre(enableMe) = false;
 sys.subSystem.pre(isEnabled) = false;
 sys.pre(isEnabled) = false;
equation
 sys.subSystem.conditionalIntegrator.der(x) = if sys.subSystem.isEnabled then - sys.subSystem.conditionalIntegrator.x else 0;
 sys.subSystem.conditionalIntegrator2.der(x) = if sys.subSystem.isEnabled then - sys.subSystem.conditionalIntegrator2.x else 0;
 sys.subSystem.enableMe = time <= 1;
 sys.subSystem.isEnabled = sys.isEnabled and sys.subSystem.enableMe;
 sys.isEnabled = time >= 0.5;
end InnerOuterTests.InnerOuterTest5;
")})));
end InnerOuterTest5;

model InnerOuterTest6

function A
input Real u;
output Real y;
/*algorithm
	y := u;*/
end A;

function B
  input Real u;
output Real y;
algorithm 
  y := 3*u;
end B;
// B is a subtype of A
class D
  outer function fc = A;
  Real y;
  Real u = time;
equation 
y = fc(u);
end D;

class C
  inner function fc = B;
   D d; // The equation is now treated as y = B(u)
end C;
	C c;		
end InnerOuterTest6;

model InnerOuterTest7
	model A
		Real x = 4;
	end A;
	model B
		Real x = 6;
		Real y = 9;
	end B;
    model C
		outer model Q = A;	
		Q a;
		Real z = a.x;
	end C;
	model D
	 	inner model Q = B;
		B a; 
		C c;
	end D;
	D d;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest7",
			description="Basic test of inner outer.",
			equation_sorting=true,
			eliminate_alias_variables=false,
			flatModel="
fclass InnerOuterTests.InnerOuterTest7
 constant Real d.a.x = 6;
 constant Real d.a.y = 9;
 constant Real d.c.a.x = 6;
 constant Real d.c.a.y = 9;
 constant Real d.c.z = 6.0;
end InnerOuterTests.InnerOuterTest7;
")})));
end InnerOuterTest7;
	
model InnerOuterTest8
	package P1
    	model A 
	    	Real x = 4;
	    end A;
	end P1;
	package P2
		model A
			Real x = 6;
			Real y = 9;
		end A;
	end P2;
    model C
		outer package P = P1;	
		P.A a;
		Real z = a.x;
	end C;
	model D
	 	inner package P = P2;
		C c;
	end D;
	D d;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest8",
			description="Basic test of inner outer.",
			equation_sorting=true,
			eliminate_alias_variables=false,
			flatModel="
fclass InnerOuterTests.InnerOuterTest8
 constant Real d.c.a.x = 6;
 constant Real d.c.a.y = 9;
 constant Real d.c.z = 6.0;
end InnerOuterTests.InnerOuterTest8;
")})));
end InnerOuterTest8;


model InnerOuterTest9
    outer parameter Real T = 5;
    Real x = T * 23;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="InnerOuterTest9",
			description="Missing inner declaration",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/InnerOuterTests.mo':
Semantic error at line 319, column 21:
  Cannot find inner declaration for outer T
")})));
end InnerOuterTest9;


model InnerOuterTest10
    outer constant Real T = 5;
    constant Real x = T * 23;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="InnerOuterTest10",
			description="Missing inner declaration",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/InnerOuterTests.mo':
Semantic error at line 336, column 22:
  Cannot find inner declaration for outer T
")})));
end InnerOuterTest10;


model InnerOuterTest11
    model B
        Real x;
    end B;
    
    outer B b;
    
    Real y = b.x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="InnerOuterTest11",
			description="Missing inner declaration",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/InnerOuterTests.mo':
Semantic error at line 356, column 10:
  Cannot find inner declaration for outer b
")})));
end InnerOuterTest11;


model InnerOuterTest12
    model A
        parameter Integer b = 2;
    end A;
    
    inner A c(b = 1);
    
    model D
        outer A c;
        parameter Integer e = c.b;
        Real x[e] = zeros(e);
    end D;
    
    D f;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="InnerOuterTest12",
			description="Constant evaluation of inner/outer",
			flatModel="
fclass InnerOuterTests.InnerOuterTest12
 parameter Integer c.b = 1 /* 1 */;
 structural parameter Integer f.e = 1 /* 1 */;
 Real f.x[1] = zeros(1);
end InnerOuterTests.InnerOuterTest12;
")})));
end InnerOuterTest12;


model InnerOuterTest13_Err
    outer Real x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="InnerOuterTest13_Err",
			description="Check that error is generated for outer without inner",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/InnerOuterTests.mo':
Semantic error at line 407, column 10:
  Cannot find inner declaration for outer x
")})));
end InnerOuterTest13_Err;


model InnerOuterTest15
    model A
        Real x[2];      
    end A;
    
    model B
        outer A a;
        Real y[2];
    equation
        a.x = y;
    end B;
    
    inner A a;
    B b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="InnerOuterTest15",
			description="",
			flatModel="
fclass InnerOuterTests.InnerOuterTest15
 Real a.x[2];
 Real b.y[2];
equation
 a.x[1:2] = b.y[1:2];
end InnerOuterTests.InnerOuterTest15;
")})));
end InnerOuterTest15;


model InnerOuterTest16
    inner Real x[3] = {1, 2, 3} * time;
    
    model A
        outer Real x[3];
        parameter Integer y = 2;
        Real z = x[y];
    end A;
    
    A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest16",
            description="Flattening of accesses to outer array with array subscripts",
            flatModel="
fclass InnerOuterTests.InnerOuterTest16
 Real x[3] = {1, 2, 3} * time;
 parameter Integer a.y = 2 /* 2 */;
 Real a.z = x[a.y];
end InnerOuterTests.InnerOuterTest16;
")})));
end InnerOuterTest16;


model InnerOuterTest17
    model A
        parameter Real x;
    end A;
    
    model B
        outer A a;
    end B;
    
    model C
        B b;
        parameter Real y = b.a.x;
    end C;
    
    inner A a;
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest17",
            description="",
            flatModel="
fclass InnerOuterTests.InnerOuterTest17
 parameter Real a.x;
 parameter Real c.y = a.x;
end InnerOuterTests.InnerOuterTest17;
")})));
end InnerOuterTest17;


model InnerOuterTest18
    model A
        parameter Real x;
    end A;
    
    model B
        outer A a;
    end B;
    
    model D
        model C
            B b;
            parameter Real y = b.a.x;
        end C;
        
        inner A a;
        C c;
    end D;
    
    D d;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest18",
            description="",
            flatModel="
fclass InnerOuterTests.InnerOuterTest18
 parameter Real d.a.x;
 parameter Real d.c.y = d.a.x;
end InnerOuterTests.InnerOuterTest18;
")})));
end InnerOuterTest18;

end InnerOuterTests;
