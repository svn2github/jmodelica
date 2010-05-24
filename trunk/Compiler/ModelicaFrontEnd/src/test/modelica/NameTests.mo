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


package NameTests 
  
model NameTest0
 
annotation(__JModelica(UnitTesting(tests={FlatteningTestCase(name="NameTest0_Flattening",
                                               description="Basic test of name lookup",
                                               flatModel=
"fclass NameTests.NameTest0
  Real x;
equation
  x=1;
end NameTests.NameTest0;
")})));

    Real x;
    parameter Real p1 = 2.5;
    parameter Real p2 = 2*p1 annotation(__JModelica(UnitTesting(
             tests = {EvaluationTestCase(name="NameTest0_Eval1",
                                         description="Basic test of static evaluation",
                                         result = 5)})));
  equation
    x=1;
  end NameTest0;

  model NameTest2
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="NameTest2",
                                               description="Basic test of name lookup",
                                               flatModel=
"
fclass NameTests.NameTest2
 Real a.b.x;
 Real a.b.c.y;
 Real a.b1.x;
 Real a.b1.c.y;
 Real a.c.y;
 Real a.y;
 Real a.x;
equation 
 a.x=(-((1)/(1)))*((1)*(1))-((2+1)^3)+a.x^(-(3)+2);
 a.b.c.y+1=a.b.c.y;
 a.c.y=0;
 a.b.x=a.b.c.y;
 a.b.c.y=2;
 a.b1.c.y=2;
 a.c.y=2;
end NameTests.NameTest2;
")})));

class A

 class B 
 	Real x;
	
		class C
		  Real y;
		  equation
		  y=2;
		end C;

	  C c;

 end B;
 B b,b1;
 B.C c;
 Real y,x;
equation
x=-(1/1)*(1*1)-(2+1)^3+x^(-3+2);
b.c.y+1=b.c.y;
c.y=0;

b.x=b.c.y;

//c.y=1;

end A;

	A a;

  end NameTest2;



  model NameTest3_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest3_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 90, column 1:
  The class A is undeclared
  
")})));

A a;

  end NameTest3_Err;



model NameTest4_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest4_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 100, column 4:
  The class B is undeclared

")})));

  model M
  	model A
  		Real x=3;
  	end A;
  	B a;
  end M;
  
  M m;

  end NameTest4_Err;



model NameTest5_Err
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest5_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
2 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 151, column 5:
  Cannot find class or component declaration for b
Semantic error at line 151, column 15:
  Cannot find class or component declaration for x
")})));

  model A
    Real y = 4;
  end A;
  
  A a;
  Real y;
equation
  b.y = y + a.x;
end NameTest5_Err;

model NameTest55_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest55_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 181, column 11:
  Cannot find class or component declaration for x
")})));

  model A
      Real y = 4;
    equation
      y = x;
  end A;
  
  A a;
end NameTest55_Err;


model NameTest6_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest6_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 174, column 14:
  Cannot find class or component declaration for y
")})));

  model A
    Real x = y;
  end A;
  
  A a;
end NameTest6_Err;

model NameTest7_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest7_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 196, column 4:
  The class B is undeclared

")})));

  model A
    B x;
  end A;
  
  A a1;
  A a2;
end NameTest7_Err;

model NameTest8_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest8_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 196, column 4:
  The class D is undeclared

")})));
  
  model C = D;
  
  C c;
end NameTest8_Err;

model NameTest9_Err
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest9_Err",
                                               description="Test that names are looked up in constraining clauses.",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 196, column 4:
  The component y is undeclared

")})));

  model A
    Real x = 4;
  end A;
  
  model B
    Real x = 6;
    Real y = 7;
  end B;
  
  model C
    replaceable B b constrainedby A;
  end C;

  C c(b(y=3));

  end NameTest9_Err;

model NameTest10_Err
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest10_Err",
                                               description="Test that names are looked up in constraining clauses.",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 297, column 4:
  The class B is undeclared

")})));

  package P1
  model A
    Real x = 4;
  end A;
    
  end P1;

  package P2
  model A
    Real x = 4;
  end A;
  
  model B
    Real x = 6;
    Real y = 7;
  end B;
  
  end P2;

  replaceable package P = P2 constrainedby P1;
  
  P.B b;
  
  end NameTest10_Err;
  
  model NameTest11_Err
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest11_Err",
                                               description="Test that names are looked up correct.",
                                               errorMessage=
"
  1 error(s) found...
  Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 363, column 18:
  Could not evaluate binding expression for parameter 'a.p1': 'p1'
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 320, column 9:
  Cannot find class or component declaration for p1
")})));

 model A
 	parameter Real p1 = 4;
 end A;
 
 parameter Real p = 5;
 A a(p1=p1);
  
  end NameTest11_Err;
  
  
model NameTest12_Err
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest12_Err",
                                              description="Test that names are looked up correct.",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 346, column 15:
  The class B is undeclared
")})));

model M

 model A
 	Real x = 4;
 end A;

 model B
 	Real x = 4;
	Real y = 4;
 end B;
 
 replaceable A a;
 
end M;

M m(redeclare B a);

  
end NameTest12_Err;
  
  
 model NameTest13_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest13_Err",
                                              description="Test that names are looked up correct.",
                                               errorMessage=
"
 4 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 386, column 39:
  The component z is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 386, column 37:
  The class C is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 386, column 39:
  The component y is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 389, column 12:
  The component y is undeclared
 
")})));
  
  
   package P
   model A
    Real x=1;
   end A;
 
     model B
        Real x=2;
        Real y=3;
     end B;
 
     model C
        Real x=2;
        Real y=3;
        Real z=4;
     end C;
     
     replaceable model BB = B(z=3);
     
   end P;
 
   package PP = P(redeclare model BB 
     	                      extends C(y=4);
                            end BB);
 
  PP.BB bb(y=6);
 
end NameTest13_Err;
  
 model NameTest14_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest14_Err",
                                              description="Test that names are looked up correct.",
                                               errorMessage=
"
 6 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 454, column 18:
  The component z is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 454, column 20:
  Cannot find class or component declaration for pBB
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 459, column 18:
  The component z is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 459, column 20:
  Cannot find class or component declaration for p
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 461, column 18:
  The component z is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 461, column 20:
  Cannot find class or component declaration for pp

 
")})));
  
  
   package P
   model A
    Real x=1;
   end A;
 
     model B
        Real x=2;
        Real y=3;
     end B;
 
     model C
        Real x=2;
        Real y=3;
        Real z=4;
     end C;
     
     
     replaceable model BB 
     	 extends B(z=pBB);
     end BB;
           
   end P;
 
   package PP = P(redeclare replaceable model BB = P.B(z=p));
 
   PP.BB bb(z=pp);
 
end NameTest14_Err;
  
class NameTest15
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="NameTest15",
        description="Check correct flattening of protected variable",
                                               flatModel=
"
fclass NameTests.NameTest15
 protected Real x = 1;
end NameTests.NameTest15;
")})));

protected Real x=1;
end NameTest15;


class NameTest16
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="NameTest16",
        description="Check that constants are inlined.",
                                               flatModel=
"
fclass NameTests.NameTest16
constant Real c = 1.0;
parameter Real p = 1.0;
end NameTests.NameTest16;
")})));

constant Real c = 1.0;
parameter Real p = c;

end NameTest16;

model NameTest17
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="NameTest17",
        description="Check that modifiers without binding expressions are accepted.",
                                               flatModel=
"
fclass NameTests.NameTest17
 Real x;
equation
 x = 2;
end NameTests.NameTest17;
")})));

  Real x(fixed,start);
equation
  x=2;
end NameTest17;


/* Used for tests ConstantLookup1-3. */
constant Real constant_1 = 1.0;

/* Used for tests ConstantLookup10,13-15 */
package TestPackage
 parameter Real x;
protected
 constant Real prot = 1.0;
end TestPackage;

class ConstantLookup1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup1",
         description="Constant lookup: simple lookup in enclosing class",
         flatModel="
fclass NameTests.ConstantLookup1
 Real x = 1.0;
end NameTests.ConstantLookup1;
")})));

 Real x = constant_1;
end ConstantLookup1;


class ConstantLookup2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup2",
         description="Constant lookup: lookup in second enclosing class",
         flatModel="
fclass NameTests.ConstantLookup2
 Real i.x = 1.0;
end NameTests.ConstantLookup2;
")})));

 model Inner
  Real x = constant_1;
 end Inner;
 
 Inner i;
end ConstantLookup2;


class ConstantLookup3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup3",
         description="Constant lookup: enclosing class overriding constant in second enclosing class",
         flatModel="
fclass NameTests.ConstantLookup3
 constant Real constant_1 = 2.0;
 Real i.x = 2.0;
end NameTests.ConstantLookup3;
")})));

 constant Real constant_1 = 2.0;
 
 model Inner
  Real x = constant_1;
 end Inner;
 
 Inner i;
end ConstantLookup3;


class ConstantLookup4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup4",
         description="Constant lookup: directly from package",
         flatModel="
fclass NameTests.ConstantLookup4
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;
end NameTests.ConstantLookup4;
")})));

 parameter Real p = Modelica.Constants.pi;
end ConstantLookup4;


class ConstantLookup5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup5",
         description="Constant lookup: import all from enclosing class",
         flatModel="
fclass NameTests.ConstantLookup5
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;
end NameTests.ConstantLookup5;
")})));

 import Modelica.Constants.*;
 parameter Real p = pi;
end ConstantLookup5;


class ConstantLookup6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup6",
         description="Constant lookup: import enclosing package with rename",
         flatModel="
fclass NameTests.ConstantLookup6
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;
end NameTests.ConstantLookup6;
")})));

 import C = Modelica.Constants;
 parameter Real p = C.pi;
end ConstantLookup6;


class ConstantLookup7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup7",
         description="Constant lookup: import all in top package, access via enclosing class",
         flatModel="
fclass NameTests.ConstantLookup7
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;
end NameTests.ConstantLookup7;
")})));

 import Modelica.*;
 parameter Real p = Constants.pi;
end ConstantLookup7;


class ConstantLookup8 
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup8",
         description="Constant lookup: named import of specific constant",
         flatModel="
fclass NameTests.ConstantLookup8
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;
end NameTests.ConstantLookup8;
")})));

 import pi2 = Modelica.Constants.pi;
 parameter Real p = pi2;
end ConstantLookup8;


class ConstantLookup9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConstantLookup9",
         description="Constant lookup: import of specific constant",
         flatModel="
fclass NameTests.ConstantLookup9
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;
end NameTests.ConstantLookup9;
")})));

 import Modelica.Constants.pi;
 parameter Real p = pi;
end ConstantLookup9;


// TODO: Maybe a better error message is needed for the errors in ConstantLookup10-12
class ConstantLookup10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ConstantLookup10",
         description="Constant lookup: trying to import non-constant component",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 700, column 17:
  Could not evaluate binding expression for parameter 'p': 'x'
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 700, column 21:
  Cannot find class or component declaration for x
")})));

 import NameTests.TestPackage.x;
 parameter Real p = x;
end ConstantLookup10;


class ConstantLookup11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ConstantLookup11",
         description="Constant lookup: trying to import non-constant component (named import)",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 720, column 17:
  Could not evaluate binding expression for parameter 'p': 'x2'
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 720, column 21:
  Cannot find class or component declaration for x2
")})));

 import x2 = NameTests.TestPackage.x;
 parameter Real p = x2;
end ConstantLookup11;


class ConstantLookup12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ConstantLookup12",
         description="Constant lookup: trying to import non-constant component (unqualified import)",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 740, column 17:
  Could not evaluate binding expression for parameter 'p': 'x'
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 740, column 21:
  Cannot find class or component declaration for x
")})));

 import NameTests.TestPackage.*;
 parameter Real p = x;
end ConstantLookup12;


/* TODO: Tests ConstantLookup13-15 should produce errors. Add annotations  
 *       when there are error checks for accesses to protected elements. */
class ConstantLookup13
  import NameTests.TestPackage.*;
  parameter Real p = prot;
end ConstantLookup13;


class ConstantLookup14
  import NameTests.TestPackage.prot;
  parameter Real p = prot;
end ConstantLookup14;


class ConstantLookup15
  import prot2 = NameTests.TestPackage.prot;
  parameter Real p = prot2;
end ConstantLookup15;


model ConstantLookup16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ConstantLookup16",
         description="Using constant with bad value as array index",
         errorMessage="
4 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 797, column 16:
  Could not evaluate binding expression for constant 'a': 'b[c]'
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 797, column 22:
  Could not evaluate array index expression: c
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 799, column 19:
  Could not evaluate binding expression for constant 'c': 'd'
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 799, column 23:
  Cannot find class or component declaration for d
")})));

	constant Real a = b[c];
	constant Real[3] b = {1, 2, 3};
	constant Integer c = d;
end ConstantLookup16;


// TODO: Compiling this model causes an exception
model ConstantLookup17
	partial model A
		parameter Integer n = 2;
		Real x[n] = fill(1, n);
	end A;
	
	model B
		parameter Integer n = 3;
	end B;
	
	A a(n = B.n);
end ConstantLookup17;



class ExtendsTest1
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ExtendsTest1",
        description="Simple use of extends",
                                               flatModel=
"
 fclass NameTests.ExtendsTest1
 Real c2.c3.x;
 Real c2.x;
 Real x;
equation 
 x=3;
 c2.x=2;
 c2.c3.x=1;
end NameTests.ExtendsTest1;
 
")})));

  class C
    Real x;
  end C;
  
  class C2
    	extends C;
    class C3
      extends C;
      equation 
        x=1;
    end C3;
    C3 c3;
    equation
      x=2;
  end C2;
  extends C;
  C2 c2;
  equation
    x=3;
end ExtendsTest1;

class ExtendsTest2
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ExtendsTest2",
        description="Test component declaration using a local class that becomes visible
                     through inheritance",
                                               flatModel=
"
fclass NameTests.ExtendsTest2
 Real d.x;
equation 
 d.x=3;
end NameTests.ExtendsTest2;
")})));
  
  class C
    class D
      Real x;
    end D;
  end C;
  extends C;
  D d;
  equation
  d.x=3;
end ExtendsTest2;

class ExtendsTest3
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ExtendsTest3",
        description="Test that local classes that becomes visible
                     through inheritance can not be used as super classes",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 164, column 11:
  The class D is undeclared
  
"  )})));
  
  class C
    class D
      Real x;
    end D;
  end C;
  extends C;
  extends D;
end ExtendsTest3;

model ImportTest1
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ImportTest1",
        description="Test circular dependency of unqualified import and extends.",
                                               flatModel=
"
fclass NameTests.ImportTest1
 Real a.x;
 Real b.y;
 Real x;
 Real y;
end NameTests.ImportTest1;
")})));
  
  
  package P
    model A
      Real x;
    end A;
    model B
      Real y;
    end B;
  end P;
  
  import NameTests.ImportTest1.P.*;
  // import Modelica.SIunits.*;
  
  A a;
  extends A;
  B b;
  extends B;
  
end ImportTest1;

model ImportTest2
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ImportTest2",
        description="Test of qualified import.",
                                               flatModel=
"
fclass NameTests.ImportTest2
 Real a.x;
 Real x;
end NameTests.ImportTest2;
")})));

  package P
    model A
      Real x;
    end A;
    model B
      Real y;
    end B;
  end P;
  
  import NameTests.ImportTest2.P.A;
  A a;
  extends A;
  
  
  
end ImportTest2;

model ImportTest3
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ImportTest3",
        description="Test that only a class imported with qualified import is visible.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 253, column 3:
  The class B is undeclared
  "
  )})));
  package P
    model A
      Real x;
    end A;
    model B
      Real y;
    end B;
  end P;
  
  import NameTests.ImportTest1.P.A;
  A a;
  extends A;
  B b;
  
end ImportTest3;


model ImportTest4
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ImportTest4",
        description="Test alias import.",
                                               flatModel=
"
fclass NameTests.ImportTest4
 Real a.x;
 Real x;
end NameTests.ImportTest4;
")})));

  package P
    model A
      Real x;
    end A;
  end P;
  
  import PP = NameTests.ImportTest1.P;
  PP.A a;
  extends PP.A;
  
end ImportTest4;

model ImportTest5
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ImportTest5",
        description="Test circular dependency between import and extends: import of class that becomes visible through inheritance",
                                               flatModel=
"
fclass NameTests.ImportTest5
 Real d.z=3;
end NameTests.ImportTest5;
")})));
  package P 
    model A 
      Real x=0;
    end A;
    
    model B 
      Real y=1;
    end B;
    
    model C 
      model D 
        Real z=2;
      end D;
    end C;
    
  end P;
    
  import NameTests.ImportTest5.P.C.*;
  D d(z=3);
  
end ImportTest5;


model ImportTest6
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ImportTest6",
        description="Test name lookup in a more complex case.",
                                               flatModel=
"
fclass NameTests.ImportTest6
 Real m.R(start = 1,unit = \"Ohm\");
end NameTests.ImportTest6;
")})));

  package P
	model M
		import SI = NameTests.ImportTest6.P.SIunits;
		SI.Resistance R(start=1);
	end M;
	
    package SIunits
    	type Resistance = Real(unit="Ohm");
    end SIunits;
  
  end P;

  P.M m;

end ImportTest6;

model ImportTest7
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ImportTest7",
        description="Test name lookup in a more complex case.",
                                               flatModel=
"
fclass NameTests.ImportTest7
 Real m.R(start = 1,unit = \"Ohm\");
end NameTests.ImportTest7;
")})));

  package P
	package P1
		import SI = NameTests.ImportTest7.P.SIunits;
        model M
		  SI.Resistance R(start=1);
		end M;
	end P1;
	
    package SIunits
    	type Resistance = Real(unit="Ohm");
    end SIunits;
  
  end P;

  P.P1.M m;

end ImportTest7;

model ImportTest8
	annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	   JModelica.UnitTesting.FlatteningTestCase(name="ImportTest8",
		 description="Test name lookup in a structured library.",
												flatModel=
 "
 fclass NameTests.ImportTest8
  parameter Real r.R(start = 1,final quantity = \"Resistance\",final unit = \"Ohm\") \"Resistance\";
  Real r.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
  Real r.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
  Real r.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
  Real r.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
  Real r.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
  Real r.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 equation 
  ( r.R ) * ( r.i ) = r.v;
  r.v = r.p.v - ( r.n.v );
  0 = r.p.i + r.n.i;
  r.i = r.p.i; 
 r.p.i = 0.0;
 r.n.i = 0.0;
 end NameTests.ImportTest8;
 ")})));

  Modelica.Electrical.Analog.Basic.Resistor r;
	
end ImportTest8;

model ImportTest9
	annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	   JModelica.UnitTesting.FlatteningTestCase(name="ImportTest9",
		 description="Test of import of builtin mathematical functions.",
												flatModel=
 "
 fclass NameTests.ImportTest9
  parameter Real p1 = cos(9) /* -0.9111302618846769 */;
  parameter Real p2 = sin(9) /* 0.4121184852417566 */;
  parameter Real p3 = sqrt(3) /* 1.7320508075688772 */;
 end NameTests.ImportTest9;
 ")})));
		
	import Math = Modelica.Math;
	parameter Real p1 = Math.cos(9);
	parameter Real p2 = Modelica.Math.sin(9);
	parameter Real p3 = sqrt(3);
end ImportTest9;


model ShortClassDeclTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest1",
        description="Test simple use of short class declaration.",
                                               flatModel=
"fclass NameTests.ShortClassDeclTest1
 Real aa.x=2;
end NameTests.ShortClassDeclTest1;
")})));

  model A
    Real x=2;
  end A;
  
  model AA = A;
  
  AA aa;

end ShortClassDeclTest1;



model ShortClassDeclTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest2",
        description="Test simple use of multiple short class declaration.",
                                               flatModel=
"fclass NameTests.ShortClassDeclTest2
 Real aa.x=2;
end NameTests.ShortClassDeclTest2;
")})));
  model A
    Real x=2;
  end A;
  
  model AA = A;

  model AAA = AA;
  
  AAA aa;

end ShortClassDeclTest2;

model ShortClassDeclTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest3",
        description="Short class declaration of Real.",
                                               flatModel=
"fclass NameTests.ShortClassDeclTest3
 Real x(start=3,min=-(3));
end NameTests.ShortClassDeclTest3;
")})));
  
  type MyReal = Real(min=-3);
  MyReal x(start=3);

end ShortClassDeclTest3;

model ShortClassDeclTest31
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest31",
        description="Short class declaration of Real.",
                                               flatModel=
"
fclass NameTests.ShortClassDeclTest31
 Real x(start = 3,final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\");
end NameTests.ShortClassDeclTest31;
")})));
  
  Modelica.SIunits.Angle x(start=3);

end ShortClassDeclTest31;


model ShortClassDeclTest35_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ShortClassDeclTest35_Err",
        description="Short class declaration of Real.",
                                               errorMessage=
"
  2 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 549, column 4:
  The component q is undeclared
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 550, column 4:
  The component t is undeclared

")})));
  
  type MyReal = Real(min=-3,q=4);
  MyReal x(start=3,t=5);

end ShortClassDeclTest35_Err;


model ShortClassDeclTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest4",
        description="Test short class declarations and inheritance from primitive types",
                                               flatModel=
"fclass NameTests.ShortClassDeclTest4
 input Real u(min=3,max=5,nominal=34,unit=\"V\");
end NameTests.ShortClassDeclTest4;
")})));
  
connector MyRealInput = input MyRealSignal(max=5) "'input Real' as connector";
 
connector MyRealSignal 
  "Real port (both input/output possible)" 
  replaceable type SignalType = Real(unit="V");
  
  extends SignalType(nominal=34);
  
end MyRealSignal;
  
  MyRealInput u(min=3);
  
end ShortClassDeclTest4;

model ShortClassDeclTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest5",
        description="Test short class declarations and inheritance from primitive types",
                                               flatModel=
"
fclass NameTests.ShortClassDeclTest5
 input Real u(nominal=4,start=3,max=2,min=1,unit=\"V\");
end NameTests.ShortClassDeclTest5;
")})));
  
connector MyRealInput = input MyRealSignal(start=3,nominal=3) "'input Real' as connector";
 
 type MyReal = Real(unit="V");
 
connector MyRealSignal 
  "Real port (both input/output possible)" 
  replaceable type SignalType = MyReal(min=1,max=1,start=1,nominal=1);
  
  extends SignalType(max=2,start=2,nominal=2);
  
end MyRealSignal;
  
  MyRealInput u(nominal=4);
  
end ShortClassDeclTest5;


model ShortClassDeclTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest6",
        description="Test short class declarations.",
                                               flatModel=
"
fclass NameTests.ShortClassDeclTest6
 parameter Real R = 1;
 parameter Real a.R = R /*(0.0)*/;
end NameTests.ShortClassDeclTest6;
")})));
  
model Resistor
	parameter Real R;
end Resistor;

	parameter Real R=1;
	
	replaceable model Load=Resistor(R=R);
	// Correct, sets the R in Resistor to R from model A.
/*
	replaceable model LoadError
		extends Resistor(R=R);
		// Gives the singular equation R=R, since the right-hand side R
		// is searched for in LoadError and found in its base-class Resistor.
	end LoadError constrainedby TwoPin;
*/	
	Load a;
	
end ShortClassDeclTest6;

model ShortClassDeclTest7_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ShortClassDeclTest7_Err",
        description="Short class declaration of Real.",
                                               errorMessage=
"
  1 error(s) found...
In file 'src/test/modelica/NameTests.mo':
Semantic error at line 834, column 14:
  The component y is undeclared
")})));


  model A
    Real x=2;
  end A;
  
  model AA=A(y=2.5);
  
  AA aa(x=3);

end ShortClassDeclTest7_Err;

model ShortClassDeclTest8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest8",
        description="Test short class declarations.",
                                               flatModel=
"
fclass NameTests.ShortClassDeclTest8
 input Real u;
 input Real u2;
end NameTests.ShortClassDeclTest8;
")})));

 connector RealInput = input Real;

 RealInput u;
 Modelica.Blocks.Interfaces.RealInput u2;

end ShortClassDeclTest8;


model DerTest1
	Real x;
equation
    der(x)=1;
end DerTest1;

model InitialEquationTest1
  
  Real x;
  initial equation
  x = 1;
  equation
  der(x)=1;
  
end InitialEquationTest1;

model EndExpTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="EndExpTest1",
        description="Test of end expression",
                                               flatModel=
"
fclass NameTests.EndExpTest1
 Real x[1];
equation 
 x[end] = 2;
end NameTests.EndExpTest1;
")})));

 Real x[1];
equation
 x[end] = 2;

end EndExpTest1;

model ForTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ForTest1",
        description="Test for equations.",
                                               flatModel=
"
fclass NameTests.ForTest1
 Real x[3,3];
equation 
 for i in 1:3, j in 1:3 loop
  x[i,j] = i + j;
 end for;
end NameTests.ForTest1;
")})));

  Real x[3,3];
equation
  for i in 1:3, j in 1:3 loop
    x[i,j] = i + j;
  end for;
end ForTest1;


model ForTest2_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ForTest2_Err",
        description="Test for equations.",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1201, column 18:
  Cannot find class or component declaration for k
")})));


  Real x[3,3];
equation
  for i in 1:3, j in 1:3 loop
    x[i,j] = i + k;
  end for;
end ForTest2_Err;

model StateSelectTest 
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="StateSelectTest",
        description="Test for equations.",
                                               flatModel=
"fclass NameTests.StateSelectTest
 Real x(stateSelect = 0);
 Real y(stateSelect = 1);
 Real z(stateSelect = 2);
 Real w(stateSelect = 3);
 Real v(stateSelect = 4);
equation
 x = 2;
 y = 1;
 der(z) = 1;
 der(w) = 1;
 der(v) = 1;
end NameTests.StateSelectTest;
")})));

 Real x(stateSelect=StateSelect.never);
 Real y(stateSelect=StateSelect.avoid);
 Real z(stateSelect=StateSelect.default);
 Real w(stateSelect=StateSelect.prefer);
 Real v(stateSelect=StateSelect.always);
equation
 x = 2;
 y = 1;
 der(z) = 1;
 der(w) = 1;
 der(v) = 1;
end StateSelectTest;



model IndexLookup1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="IndexLookup1",
         description="Name lookup from within array subscript",
         flatModel="
fclass NameTests.IndexLookup1
 parameter Integer i = 2 /* 2 */;
 Real y.z[2] = {1,2};
 Real x = y.z[i];
end NameTests.IndexLookup1;
")})));

  model B
    Real z[2] = {1, 2};
  end B;

  parameter Integer i = 2;
  B y;
  Real x = y.z[i];
end IndexLookup1;


model IndexLookup2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="IndexLookup2",
         description="Name lookup from within array subscript",
         flatModel="
fclass NameTests.IndexLookup2
 parameter Integer i = 2 /* 2 */;
 parameter Integer y.i = 1 /* 1 */;
 Real y.z[2] = {1,2};
 Real x = y.z[i];
end NameTests.IndexLookup2;
")})));

  model B
    parameter Integer i = 1;
    Real z[2] = {1, 2};
  end B;

  parameter Integer i = 2;
  B y;
  Real x = y.z[i];
end IndexLookup2;

end NameTests;
