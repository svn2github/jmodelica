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


package NameTests 

  model NameTest2
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


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest2",
			description="Basic test of name lookup",
			flatModel="
fclass NameTests.NameTest2
 Real a.b.x;
 Real a.b.c.y;
 Real a.b1.x;
 Real a.b1.c.y;
 Real a.c.y;
 Real a.y;
 Real a.x;
equation
 a.x = - 1 - (2 + 1) ^ 3 + a.x ^ (- 3 + 2);
 a.b.c.y + 1 = a.b.c.y;
 a.c.y = 0;
 a.b.x = a.b.c.y;
 a.b.c.y = 2;
 a.b1.c.y = 2;
 a.c.y = 2;
end NameTests.NameTest2;
")})));
  end NameTest2;



  model NameTest3_Err
  
  
A a;


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest3_Err",
			description="Basic test of name lookup",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 90, column 1:
  Cannot find class declaration for A
  
")})));
  end NameTest3_Err;



model NameTest4_Err
  
  
  model M
  	model A
  		Real x=3;
  	end A;
  	B a;
  end M;
  
  M m;


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest4_Err",
			description="Basic test of name lookup",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 100, column 4:
  Cannot find class declaration for B

")})));
  end NameTest4_Err;



model NameTest5_Err
  
  model A
    Real y = 4;
  end A;
  
  A a;
  Real y;
equation
  b.y = y + a.x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest5_Err",
			description="Basic test of name lookup",
			errorMessage="
2 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 151, column 5:
  Cannot find class or component declaration for b

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 151, column 15:
  Cannot find class or component declaration for x
")})));
end NameTest5_Err;

model NameTest55_Err
  
  
  model A
      Real y = 4;
    equation
      y = x;
  end A;
  
  A a;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest55_Err",
			description="Basic test of name lookup",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 181, column 11:
  Cannot find class or component declaration for x
")})));
end NameTest55_Err;


model NameTest6_Err
  
  
  model A
    Real x = y;
  end A;
  
  A a;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest6_Err",
			description="Basic test of name lookup",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 174, column 14:
  Cannot find class or component declaration for y
")})));
end NameTest6_Err;

model NameTest7_Err
  
  
  model A
    B x;
  end A;
  
  A a1;
  A a2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest7_Err",
			description="Basic test of name lookup",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 196, column 4:
  Cannot find class declaration for B

")})));
end NameTest7_Err;

model NameTest8_Err
  
  
  model C = D;
  
  C c;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest8_Err",
			description="Basic test of name lookup",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 196, column 4:
  Cannot find class declaration for D

")})));
end NameTest8_Err;

model NameTest9_Err
  
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


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest9_Err",
			description="Test that names are looked up in constraining clauses.",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 196, column 4:
  Cannot find component declaration for y

")})));
  end NameTest9_Err;

model NameTest10_Err
  
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
  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest10_Err",
			description="Test that names are looked up in constraining clauses.",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 297, column 4:
  Cannot find class declaration for B

")})));
  end NameTest10_Err;
  
  model NameTest11_Err
  
 model A
 	parameter Real p1 = 4;
 end A;
 
 parameter Real p = 5;
 A a(p1=p1);
  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest11_Err",
			description="Test that names are looked up correct.",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 320, column 9:
  Cannot find class or component declaration for p1
")})));
  end NameTest11_Err;
  
  
model NameTest12_Err
  
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

  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest12_Err",
			description="Test that names are looked up correct.",
			errorMessage="
1 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 346, column 15:
  Cannot find class declaration for B
")})));
end NameTest12_Err;
  
  
 model NameTest13_Err
  
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
 

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest13_Err",
			description="Test that names are looked up correct.",
			errorMessage="
2 errors found:

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 386, column 37:
  Cannot find class declaration for C

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 386, column 39:
  Cannot find component declaration for y
")})));
end NameTest13_Err;
  
 model NameTest14_Err
  
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
 

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest14_Err",
			description="Test that names are looked up correct.",
			errorMessage="
2 errors found:
 
Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 461, column 18:
  Cannot find component declaration for z

Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 461, column 20:
  Cannot find class or component declaration for pp

 
")})));
end NameTest14_Err;
  
class NameTest15
protected Real x=1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest15",
			description="Check correct flattening of protected variable",
			flatModel="
fclass NameTests.NameTest15
 Real x = 1;

end NameTests.NameTest15;
")})));
end NameTest15;


class NameTest16
constant Real c = 1.0;
parameter Real p = c;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest16",
			description="Check that constants are inlined.",
			flatModel="
fclass NameTests.NameTest16
constant Real c = 1.0;
parameter Real p = 1.0;

end NameTests.NameTest16;
")})));
end NameTest16;

model NameTest17
  Real x(fixed,start);
equation
  x=2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest17",
			description="Check that modifiers without binding expressions are accepted.",
			flatModel="
fclass NameTests.NameTest17
 Real x;
equation
 x = 2;

end NameTests.NameTest17;
")})));
end NameTest17;


model NameTest18
	package A
		package C
			model M
				Real x;
			end M;
		end C;
		
		package D
			extends C;
		end D;
	end A;
	
	package B
		model M
			Real x;
		end M;
	end B;
	
	package E
		replaceable package F = B constrainedby A.D;
	end E;
	
	E.F.M y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest18",
			description="Constraining class extending local class",
			flatModel="
fclass NameTests.NameTest18
 Real y.x;

end NameTests.NameTest18;
")})));
end NameTest18;


model NameTest19
    package A
        constant Integer b = 1;
    end A;
    
    model B
        Real x[1];
    end B;
    
    B y;
equation
    y.x[A.b] = 1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest19",
			description="Lookup of classes from array subscripts of dotted access",
			flatModel="
fclass NameTests.NameTest19
 Real y.x[1];
equation
 y.x[1] = 1;

end NameTests.NameTest19;
")})));
end NameTest19;


model NameTest20
	package A
		function f
			output Real z;
		algorithm
			z := 1;
		end f;
		
		model B
			Real x;
		equation
			x = f();
		end B;
	end A;
	
	model C
		extends A.B;
	end C;
	
	C y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest20",
			description="Extending class with call to function in surrounding class",
			flatModel="
fclass NameTests.NameTest20
 Real y.x;
equation
 y.x = NameTests.NameTest20.A.f();

public
 function NameTests.NameTest20.A.f
  output Real z;
 algorithm
  z := 1;
  return;
 end NameTests.NameTest20.A.f;

end NameTests.NameTest20;
")})));
end NameTest20;


model NameTest21
    model A
        replaceable package B = C;
        
        J c(redeclare package I = B);
    end A;
    
    package C
        constant Real a = 1;
    end C;
    
    model D
        package E = F;
        
        A b(redeclare package B = E.G);
    end D;
    
    package F
        package G
            extends C(a = 2);
        end G;
    end F;
    
    model J
        replaceable package I = C;
        
        Real x = I.a;
    end J;
    
    D d;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest21",
			description="Chain of redeclared short class declarations",
			flatModel="
fclass NameTests.NameTest21
 Real d.b.c.x = 2.0;

end NameTests.NameTest21;
")})));
end NameTest21;


model NameTest22
  model C
   constant Real a = 1;
  end C;
  
  package F
	package G
	  extends C(a=2);
	end G;
  end F;

  model D
   package E = F;
   package B = E.G(a=3);
   package I = B;
   Real x = I.a; 
  end D;

 D d;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest22",
			description="Chain of short class declarations",
			flatModel="
fclass NameTests.NameTest22
 Real d.x = 3.0;

end NameTests.NameTest22;
")})));
end NameTest22;


model NameTest23
	model A
		Real x;
	end A;
	
	model B
		parameter Integer n;
		A[n] a;
		Real[n] y = a.x;
	end B;
	
	model C
		parameter Integer m;
		B[m] b(n = 1:m);
	end C;
	
	C c(m = 4);
end NameTest23;


model NameTest24
    model A
        replaceable B b constrainedby B;
    end A;
    
    model B
        Real x;
    end B;
    
    model C
        Real x = 1;
        Real y = x;
    end C;
    
    A a(redeclare C b);
    Real z = a.b.y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="NameTest24",
			description="",
			flatModel="
fclass NameTests.NameTest24
 Real a.b.x = 1;
 Real a.b.y = a.b.x;
 Real z = a.b.y;
end NameTests.NameTest24;
")})));
end NameTest24;


model NameTest25_Err
    model A
        replaceable B b constrainedby B;
    end A;
    
    model B
        Real x;
    end B;
    
    model C
        Real x = 1;
        Real y = x;
    end C;
    
    A a(redeclare replaceable C b);
    Real z = a.b.y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NameTest25_Err",
			description="Check that member lookup is limited by constraining class when using redeclare replaceable",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 771, column 18:
  Cannot find class or component declaration for y
")})));
end NameTest25_Err;



/* Used for tests ConstantLookup1-3. */
constant Real constant_1 = 1.0;

class ConstantLookup1
 Real x = constant_1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup1",
			description="Constant lookup: simple lookup in enclosing class",
			flatModel="
fclass NameTests.ConstantLookup1
 Real x = 1.0;

end NameTests.ConstantLookup1;
")})));
end ConstantLookup1;


class ConstantLookup2
 model Inner
  Real x = constant_1;
 end Inner;
 
 Inner i;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup2",
			description="Constant lookup: lookup in second enclosing class",
			flatModel="
fclass NameTests.ConstantLookup2
 Real i.x = 1.0;

end NameTests.ConstantLookup2;
")})));
end ConstantLookup2;


class ConstantLookup3
 constant Real constant_1 = 2.0;
 
 model Inner
  Real x = constant_1;
 end Inner;
 
 Inner i;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup3",
			description="Constant lookup: enclosing class overriding constant in second enclosing class",
			flatModel="
fclass NameTests.ConstantLookup3
 constant Real constant_1 = 2.0;
 Real i.x = 2.0;

end NameTests.ConstantLookup3;
")})));
end ConstantLookup3;


class ConstantLookup4
 parameter Real p = Modelica.Constants.pi;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup4",
			description="Constant lookup: directly from package",
			flatModel="
fclass NameTests.ConstantLookup4
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;

end NameTests.ConstantLookup4;
")})));
end ConstantLookup4;


class ConstantLookup5
 import Modelica.Constants.*;
 parameter Real p = pi;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup5",
			description="Constant lookup: import all from enclosing class",
			flatModel="
fclass NameTests.ConstantLookup5
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;

end NameTests.ConstantLookup5;
")})));
end ConstantLookup5;


class ConstantLookup6
 import C = Modelica.Constants;
 parameter Real p = C.pi;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup6",
			description="Constant lookup: import enclosing package with rename",
			flatModel="
fclass NameTests.ConstantLookup6
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;

end NameTests.ConstantLookup6;
")})));
end ConstantLookup6;


class ConstantLookup7
 import Modelica.*;
 parameter Real p = Constants.pi;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup7",
			description="Constant lookup: import all in top package, access via enclosing class",
			flatModel="
fclass NameTests.ConstantLookup7
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;

end NameTests.ConstantLookup7;
")})));
end ConstantLookup7;


class ConstantLookup8 
 import pi2 = Modelica.Constants.pi;
 parameter Real p = pi2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup8",
			description="Constant lookup: named import of specific constant",
			flatModel="
fclass NameTests.ConstantLookup8
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;

end NameTests.ConstantLookup8;
")})));
end ConstantLookup8;


class ConstantLookup9
 import Modelica.Constants.pi;
 parameter Real p = pi;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup9",
			description="Constant lookup: import of specific constant",
			flatModel="
fclass NameTests.ConstantLookup9
 parameter Real p = 3.141592653589793 /* 3.141592653589793 */;

end NameTests.ConstantLookup9;
")})));
end ConstantLookup9;


// TODO: Maybe the last error message each in ConstantLookup10-11 are redundant - let lookup succeed?
class ConstantLookup10
 package P
  parameter Real x;
 end P;
 
 import NameTests.ConstantLookup10.P.x;
 parameter Real p = x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConstantLookup10",
			description="Constant lookup: trying to import non-constant component",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 904, column 2:
  Packages may only contain classes and constants
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 909, column 21:
  Cannot find class or component declaration for x
")})));
end ConstantLookup10;


class ConstantLookup11
 package P
  parameter Real x;
 end P;
 
 import x2 = NameTests.ConstantLookup11.P.x;
 parameter Real p = x2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConstantLookup11",
			description="Constant lookup: trying to import non-constant component (named import)",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 931, column 2:
  Packages may only contain classes and constants
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 936, column 21:
  Cannot find class or component declaration for x2
")})));
end ConstantLookup11;


// TODO: Maybe a better error message is needed here
class ConstantLookup12
 package P
  parameter Real x;
 end P;
 
 import NameTests.ConstantLookup12.P.*;
 parameter Real p = x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConstantLookup12",
			description="Constant lookup: trying to import non-constant component (unqualified import)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 740, column 21:
  Cannot find class or component declaration for x
")})));
end ConstantLookup12;


/* TODO: Tests ConstantLookup13-15 should produce errors. Add annotations  
 *       when there are error checks for accesses to protected elements. */
class ConstantLookup13
  package P
  protected
    constant Real prot = 1.0;
  end P;
  
  import NameTests.ConstantLookup13.P.*;
  parameter Real p = prot;
end ConstantLookup13;


class ConstantLookup14
  package P
  protected
    constant Real prot = 1.0;
  end P;
  
  import NameTests.ConstantLookup14.P.prot;
  parameter Real p = prot;
end ConstantLookup14;


class ConstantLookup15
  package P
  protected
    constant Real prot = 1.0;
  end P;
  
  import prot2 = NameTests.ConstantLookup15.P.prot;
  parameter Real p = prot2;
end ConstantLookup15;


model ConstantLookup16
	constant Real a = b[c];
	constant Real[3] b = {1, 2, 3};
	constant Integer c = d;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
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
Semantic error at line 799, column 23:
  Cannot find class or component declaration for d
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 799, column 19:
  Could not evaluate binding expression for constant 'c': 'd'
")})));
end ConstantLookup16;


model ConstantLookup17
	package A
		parameter Integer n = 2;
	end A;
	
	model B
		constant Integer n = 3;
	end B;
	
	Real a = A.n;
	Real b = B.n;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConstantLookup17",
			description="Illegal accesses of components in local classes",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1039, column 2:
  Packages may only contain classes and constants
")})));
end ConstantLookup17;


model ConstantLookup18
   model A
       parameter Integer n;
       Real x[n] = fill(1, n);
   end A;
   
   model B
       extends A(n = C.f.n);
       replaceable package C = D;
   end B;
   
   package D
       extends E;
   end D;
   
   package E
       constant F f = F(3);
   end E;
   
   record F
       Integer n;
   end F;
   
   B b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup18",
			description="Member of constant record, using record constructor, through inheritance and short class decl",
			flatModel="
fclass NameTests.ConstantLookup18
 parameter Integer b.n = 3 /* 3 */;
 constant Real b.x[1] = 1;
 constant Real b.x[2] = 1;
 constant Real b.x[3] = 1;
end NameTests.ConstantLookup18;
")})));
end ConstantLookup18;


model ConstantLookup19
    package A
        constant Integer n;
        model AA
            Real x[n] = fill(1, n);
        end AA;
    end A;
    
    package B
        extends A(n = C.f.n);
        replaceable package C = D;
    end B;
    
    package D
        extends E;
    end D;
    
    package E
        constant F f;
    end E;
    
    record F
        Integer n;
    end F;
    
    package G
        extends B(redeclare package C = H);
    end G;
    
    package H
        extends E(f(n=3));
    end H;
    
    G.AA y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup19",
			description="Using package constant set through redeclare and several levels of inheritance",
			flatModel="
fclass NameTests.ConstantLookup19
 Real y.x[3] = fill(1, 3);

end NameTests.ConstantLookup19;
")})));
end ConstantLookup19;


model ConstantLookup20
   package A
	   constant B b = B(3);
   end A;
   
   record B
	   Real x;
   end B;
   
   Real y = A.b.x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup20",
			description="Member of constant record, using record constructor",
			flatModel="
fclass NameTests.ConstantLookup20
 constant Real y = 3.0;
end NameTests.ConstantLookup20;
")})));
end ConstantLookup20;


model ConstantLookup21
    model A
        replaceable package B = C constrainedby D;
        Real x[B.n] = ones(B.n);
    end A;
    
    package C
        constant Integer n = 2;
    end C;
    
    package D
        constant Integer n;
    end D;
    
    A a;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup21",
			description="Lookup of package constant through short class decl with constrainedby",
			flatModel="
fclass NameTests.ConstantLookup21
 Real a.x[2] = ones(2);

end NameTests.ConstantLookup21;
")})));
end ConstantLookup21;


model ConstantLookup22
    partial package A
        replaceable partial model M = B;
	end A;
	
	partial model B
		replaceable package N = E;
		input Real[N.b] a;
	end B;
	
	model C
		extends B(redeclare replaceable package N = F constrainedby G);
	end C;
		
	package D
		extends F;
		extends A(redeclare model M = C(redeclare package N = F));
	end D;
	  
	partial package E
		constant Integer b(min=1);
	end E;
		  
	package F
		extends G(redeclare package O = H);
	end F;
		  
	package G
		extends E(b=O.c.g);
		replaceable package O = J;
	end G;
		  
	package H 
		extends I(c(g=2));
	end H;
			  
	package I
		extends J;
	end I;
			  
	package J
		constant K c;
	end J;
		  
	record K
		parameter Integer g;
	end K;
	
	model L
		replaceable package P = D constrainedby M;
		P.M d(a=e);
		Real[P.b] e = ones(P.b);
	end L;
	
	package M
		extends A;
		extends E;
	end M;
	
	L f;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup22",
			description="Class lookup through redeclares with constrainedby, complex example",
			flatModel="
fclass NameTests.ConstantLookup22
 Real f.d.a[2] = f.e[1:2];
 Real f.e[2] = ones(2);

end NameTests.ConstantLookup22;
")})));
end ConstantLookup22;


model ConstantLookup23
	package A
	end A;
	
	package B
		constant Real x = 1.0;
	end B;
	
	replaceable package C = B constrainedby A;
	
	Real y = C.x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConstantLookup23",
			description="Trying to use member that does not exist in constraining class (but does in actual)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1062, column 13:
  Cannot find class or component declaration for x
")})));
end ConstantLookup23;


// TODO: C.d is here evaluated to either 0.0 or 1.0, depending on the order of the extends clauses
model ConstantLookup24
    package A
        constant Real d = 1.0;
    end A;
    
    package B
        constant Real d;
    end B;
    
    package C
        extends A;
        extends B;
    end C;
    
    Real x = C.d;
end ConstantLookup24;


model ConstantLookup25
	record A
		Real a;
	end A;
	
	constant A x[:] = { A(1), A(2) };
    constant Real y[2] = x.a;
	Real z[2] = y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup25",
			description="Slice over array of components, declared with : size",
			flatModel="
fclass NameTests.ConstantLookup25
 constant NameTests.ConstantLookup25.A x[2] = {NameTests.ConstantLookup25.A(1),NameTests.ConstantLookup25.A(2)};
 constant Real y[2] = {1.0,2.0};
 Real z[2] = {1.0,2.0};

public
 record NameTests.ConstantLookup25.A
  Real a;
 end NameTests.ConstantLookup25.A;

end NameTests.ConstantLookup25;
")})));
end ConstantLookup25;


package ExtraForConstantLookup26
	partial package A
		extends B(d = size(b, 1), c = b[:].a);
		
		record C
			Real a;
		end C;
		
		constant C[:] b;
	end A;
	
	package B 
		constant Integer d;
		constant Real[d] c;
	end B;
	
	package D
		extends A;
	end D;
	
	package E
		constant F.G[:] e = { F.f, F.g };
		extends D(b = e);
	end E;
	
	package F
		record G
			Real a;
		end G;
		
		constant G f(a = 1);
		constant G g(a = 2);
	end F;
end ExtraForConstantLookup26;

model ConstantLookup26
    constant Real x[2] = ExtraForConstantLookup26.E.c;
	Real y[2] = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup26",
			description="Constant lookup in complex data structure",
			flatModel="
fclass NameTests.ConstantLookup26
 constant Real x[2] = {1.0,2.0};
 Real y[2] = {1.0,2.0};

end NameTests.ConstantLookup26;
")})));
end ConstantLookup26;


model ConstantLookup27
	record A
		Real a;
		Real b;
	end A;
	
	constant A c = A(1, 2);
	
	package B
		constant A d = A(3, 4);
	end B;
	
	package C
		extends B(d = c);
	end C;
	
	constant Real e[2] = { C.d.a, C.d.b };
	Real f[2] = e;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup27",
			description="Access to record as modification",
			flatModel="
fclass NameTests.ConstantLookup27
 constant NameTests.ConstantLookup27.A c = NameTests.ConstantLookup27.A(1, 2);
 constant Real e[2] = {1.0,2.0};
 Real f[2] = {1.0,2.0};

public
 record NameTests.ConstantLookup27.A
  Real a;
  Real b;
 end NameTests.ConstantLookup27.A;

end NameTests.ConstantLookup27;
")})));
end ConstantLookup27;


model ConstantLookup28
	package A
		constant Real a = 2;
	end A;
	
	package B
		extends C;
		
		model D
			Real x = a;
		end D;
	end B;
	
	package C
		extends A;
	end C;
	
	B.D y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup28",
			description="",
			flatModel="
fclass NameTests.ConstantLookup28
 Real y.x = 2.0;

end NameTests.ConstantLookup28;
")})));
end ConstantLookup28;


model ConstantLookup29
  package A
	  constant Real c1 = 1;
  end A;

  model B
	import NameTests.ConstantLookup29.A.*;
	Real x(start=c1)=2;
  end B;

  model C
	extends B;
  end C;
  
  C a;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup29",
			description="Extending class using imported constant",
			flatModel="
fclass NameTests.ConstantLookup29
 constant Real a.x(start = 1.0) = 2;
end NameTests.ConstantLookup29;
")})));
end ConstantLookup29;


model ConstantLookup30
	package Constants
		constant Real c = 3.1;
	end Constants;
	
	model M1
		import NameTests.ConstantLookup30.Constants.*;
		import SI = Modelica.SIunits;
		parameter Real p = c;
		SI.Force f=1; 
	end M1;
	
	extends M1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup30",
			description="",
			flatModel="
fclass NameTests.ConstantLookup30
 parameter Real p = 3.1 /* 3.1 */;
 constant Modelica.SIunits.Force f = 1;

public
 type Modelica.SIunits.Force = Real(final quantity = \"Force\",final unit = \"N\");
end NameTests.ConstantLookup30;
")})));
end ConstantLookup30;


package ConstantLookup31
	constant Integer c = 1;
	package NameTests
		package ConstantLookup31
			constant Integer c = 2;
			model ConstantLookup31_m
				constant Integer a = .NameTests.ConstantLookup31.c;
				constant Integer b = NameTests.ConstantLookup31.c;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup31_m",
			description="Lookup of names starting with .",
			flatModel="
fclass NameTests.ConstantLookup31.NameTests.ConstantLookup31.ConstantLookup31_m
 constant Integer a = 1;
 constant Integer b = 2;

end NameTests.ConstantLookup31.NameTests.ConstantLookup31.ConstantLookup31_m;
")})));
			end ConstantLookup31_m;
		end ConstantLookup31;
	end NameTests;
	
end ConstantLookup31;


model ConstantLookup32
    record A
        Real b;
    end A;
    
    package C
        constant A[2] d = { A(3), A(4) };
    end C;
    
    function f
        input Integer i;
        output Real x;
    algorithm
        x := C.d[i].b;
    end f;
    
    parameter Integer j = 1;
    Real y = f(j);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup32",
			description="Package constants in functions for complex accesses",
			flatModel="
fclass NameTests.ConstantLookup32
 parameter Integer j = 1 /* 1 */;
 Real y = NameTests.ConstantLookup32.f(j);

public
 function NameTests.ConstantLookup32.f
  NameTests.ConstantLookup32.A[2] d := {NameTests.ConstantLookup32.A(3),NameTests.ConstantLookup32.A(4)};
  input Integer i;
  output Real x;
 algorithm
  x := d[i].b;
  return;
 end NameTests.ConstantLookup32.f;

 record NameTests.ConstantLookup32.A
  Real b;
 end NameTests.ConstantLookup32.A;

end NameTests.ConstantLookup32;
")})));
end ConstantLookup32;


model ConstantLookup33
	package D
	    record A
	        Real b;
	    end A;
	end D;
	
	package F
		constant D.A[2] d;
	end F;
    
    package C 
		package E = D;
		constant E.A g = E.A(3);
		constant E.A h = E.A(4);
        extends F(d = { g, h });
    end C;
    
    function f
        input Integer i;
        output Real x;
    algorithm
        x := C.d[i].b;
    end f;
    
    parameter Integer j = 1;
    Real y = f(j);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup33",
			description="Package constants in functions for complex accesses",
			flatModel="
fclass NameTests.ConstantLookup33
 parameter Integer j = 1 /* 1 */;
 Real y = NameTests.ConstantLookup33.f(j);

public
 function NameTests.ConstantLookup33.f
  NameTests.ConstantLookup33.D.A[2] d := {NameTests.ConstantLookup33.D.A(3),NameTests.ConstantLookup33.D.A(4)};
  input Integer i;
  output Real x;
 algorithm
  x := d[i].b;
  return;
 end NameTests.ConstantLookup33.f;

 record NameTests.ConstantLookup33.D.A
  Real b;
 end NameTests.ConstantLookup33.D.A;

end NameTests.ConstantLookup33;
")})));
end ConstantLookup33;


model ConstantLookup34
    package A
        constant B[2] x = { B({1,2}), B({3,4}) };
        
        record B
            Real[2] y;
        end B;
    end A;
    
    function f
        input Integer i;
        output Real x;
    algorithm
        x := A.x[i].y[i];
    end f;
    
    parameter Integer j = 1;
    Real z = f(j);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup34",
			description="Constant in function being used in a manner that triggers the algorithm that includes packag constants in functions",
			flatModel="
fclass NameTests.ConstantLookup34
 parameter Integer j = 1 /* 1 */;
 parameter Real z;
parameter equation
 z = NameTests.ConstantLookup34.f(j);

public
 function NameTests.ConstantLookup34.f
  NameTests.ConstantLookup34.A.B[2] temp_1;
  input Integer i;
  output Real x;
 algorithm
  temp_1[1].y[1] := 1;
  temp_1[1].y[2] := 2;
  temp_1[2].y[1] := 3;
  temp_1[2].y[2] := 4;
  x := temp_1[i].y[i];
  return;
 end NameTests.ConstantLookup34.f;

 record NameTests.ConstantLookup34.A.B
  Real y[2];
 end NameTests.ConstantLookup34.A.B;

end NameTests.ConstantLookup34;
")})));
end ConstantLookup34;


model ConstantLookup35
	package A = B;
	D b(redeclare package C = A);
	
	model D
		replaceable package C = B constrainedby E;
		parameter Integer j = 1;
		Real z = C.F.f1(j);
	end D;
	
	package G
        replaceable package H = I;
	
		partial function f1
			input Integer i;
			output Real x;
		end f1;
	end G;
	
	package B
		extends E(redeclare package F = J);
	end B;
	
	package J
		extends K(redeclare package H = L);
	end J;
	
	package K
		extends G;
		
		redeclare function extends f1
		protected
			Real y = H.a[i];
		algorithm
			x := y;
		end f1;
	end K;
	
	package L
		extends I(a = {1,2});
	end L;
	
	package I
		constant Real[2] a = {3,4};
	end I;
	
	package E
		replaceable package F = G;
	end E;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup35",
			description="Package constants in functions where getFQName() gives two-part name",
			flatModel="
fclass NameTests.ConstantLookup35
 parameter Integer b.j = 1 /* 1 */;
 parameter Real b.z;
parameter equation
 b.z = NameTests.ConstantLookup35.J.f1(b.j);

public
 function NameTests.ConstantLookup35.J.f1
  Real[2] a;
  input Integer i;
  output Real x;
  Real y;
 algorithm
  a[1] := 1;
  a[2] := 2;
  y := a[i];
  x := y;
  return;
 end NameTests.ConstantLookup35.J.f1;

end NameTests.ConstantLookup35;
")})));
end ConstantLookup35;


model ConstantLookup36
    record B
        Real[2] b;
    end B;
    
    function f
        input Integer i;
        output Real x;
	protected
		constant B[2] a = { B({1,2}), B({3,4}) };
    algorithm
        x := a[i].b[i];
    end f;
    
    parameter Integer j = 1;
    Real z = f(j);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantLookup36",
			description="",
			flatModel="
fclass NameTests.ConstantLookup36
 parameter Integer j = 1 /* 1 */;
 parameter Real z;
parameter equation
 z = NameTests.ConstantLookup36.f(j);

public
 function NameTests.ConstantLookup36.f
  NameTests.ConstantLookup36.B[2] a;
  input Integer i;
  output Real x;
 algorithm
  a[1].b[1] := 1;
  a[1].b[2] := 2;
  a[2].b[1] := 3;
  a[2].b[2] := 4;
  x := a[i].b[i];
  return;
 end NameTests.ConstantLookup36.f;

 record NameTests.ConstantLookup36.B
  Real b[2];
 end NameTests.ConstantLookup36.B;

end NameTests.ConstantLookup36;
")})));
end ConstantLookup36;


model ConstantLookup37
    package A
        constant Real e = 2;
                
        package B
            constant Real g = 1;
            extends C(f = e);
        end B;
    end A;
    
    package C
        constant Real f = 1;
    end C;
    
    package D = A.B(g = 3);
    
    Real z = D.f;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup37",
			description="Package constant through hierarchical lookup from extended class",
			flatModel="
fclass NameTests.ConstantLookup37
 Real z = 2.0;
end NameTests.ConstantLookup37;
")})));
end ConstantLookup37;


model ConstantLookup38
    package A
        constant Real e = 2;
                
        package B
            constant Real g = 1;
			constant Real f = e;
        end B;
    end A;
    
    package D = A.B(g = 3);
    
    Real z = D.f;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConstantLookup38",
			description="Package constant through hierarchical lookup from extended class",
			flatModel="
fclass NameTests.ConstantLookup38
 Real z = 2.0;
end NameTests.ConstantLookup38;
")})));
end ConstantLookup38;


package ExtraForConstantLookup39
    package B
        extends C(f = e);
    end B;
        
    package C
        constant Real f = 1;
    end C;
end ExtraForConstantLookup39;

model ConstantLookup39
    package D = ExtraForConstantLookup39.B;
    
    Real z = D.f;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConstantLookup39",
			description="Error in constant used from other package",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1930, column 23:
  Cannot find class or component declaration for e

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1899, column 23:
  Could not evaluate binding expression for constant 'f': 'e'
")})));
end ConstantLookup39;


class ExtendsTest1
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ExtendsTest1",
			description="Simple use of extends",
			flatModel="
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
end ExtendsTest1;

class ExtendsTest2
  class C
    class D
      Real x;
    end D;
  end C;
  extends C;
  D d;
  equation
  d.x=3;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ExtendsTest2",
			description="Test component declaration using a local class that becomes visible through inheritance",
			flatModel="
fclass NameTests.ExtendsTest2
 Real d.x;
equation 
 d.x=3;

end NameTests.ExtendsTest2;
")})));
end ExtendsTest2;

class ExtendsTest3
  class C
    class D
      Real x;
    end D;
  end C;
  extends C;
  extends D;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExtendsTest3",
			description="Test that local classes that becomes visible through inheritance can not be used as super classes",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 164, column 11:
  Cannot find class declaration for D
  
")})));
end ExtendsTest3;

model ExtendsTest4
  package A
    model C
      Real d = 1;
    end C;
    model B
      extends A.C;
    end B;
  end A;

  A.B e[2];
  Real y;
equation
  y = e[1].d;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ExtendsTest4",
			description="Array of components of a class extending class with components",
			flatModel="
fclass NameTests.ExtendsTest4
 Real e[1].d = 1;
 Real e[2].d = 1;
 Real y;
equation
 y = e[1].d;

end NameTests.ExtendsTest4;
")})));
end ExtendsTest4;


model ImportTest1
  
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
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest1",
			description="Test circular dependency of unqualified import and extends.",
			flatModel="
fclass NameTests.ImportTest1
 Real a.x;
 Real b.y;
 Real x;
 Real y;

end NameTests.ImportTest1;
")})));
end ImportTest1;

model ImportTest2
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
  
  
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest2",
			description="Test of qualified import.",
			flatModel="
fclass NameTests.ImportTest2
 Real a.x;
 Real x;

end NameTests.ImportTest2;
")})));
end ImportTest2;

model ImportTest3
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
  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ImportTest3",
			description="Test that only a class imported with qualified import is visible.",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 253, column 3:
  Cannot find class declaration for B
  "
  )})));
end ImportTest3;


model ImportTest4
  package P
    model A
      Real x;
    end A;
  end P;
  
  import PP = NameTests.ImportTest1.P;
  PP.A a;
  extends PP.A;
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest4",
			description="Test alias import.",
			flatModel="
fclass NameTests.ImportTest4
 Real a.x;
 Real x;

end NameTests.ImportTest4;
")})));
end ImportTest4;

model ImportTest5
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
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest5",
			description="Test circular dependency between import and extends: import of class that becomes visible through inheritance",
			flatModel="
fclass NameTests.ImportTest5
 Real d.z=3;

end NameTests.ImportTest5;
")})));
end ImportTest5;


model ImportTest6
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


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest6",
			description="Test name lookup in a more complex case",
			flatModel="
fclass NameTests.ImportTest6
 NameTests.ImportTest6.P.SIunits.Resistance m.R(start = 1);

public
 type NameTests.ImportTest6.P.SIunits.Resistance = Real(unit = \"Ohm\");
end NameTests.ImportTest6;
")})));
end ImportTest6;

model ImportTest7
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


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest7",
			description="Test name lookup in a more complex case",
			flatModel="
fclass NameTests.ImportTest7
 NameTests.ImportTest7.P.SIunits.Resistance m.R(start = 1);

public
 type NameTests.ImportTest7.P.SIunits.Resistance = Real(unit = \"Ohm\");
end NameTests.ImportTest7;
")})));
end ImportTest7;

model ImportTest8
  Modelica.Electrical.Analog.Basic.Resistor r;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest8",
			description="Test name lookup in a structured library",
			flatModel="
fclass NameTests.ImportTest8
 parameter Modelica.SIunits.Resistance r.R(start = 1) \"Resistance at temperature T_ref\";
 parameter Modelica.SIunits.ThermodynamicTemperature r.T_ref = 300.15 \"Reference temperature\" /* 300.15 */;
 parameter Modelica.SIunits.LinearTemperatureCoefficient r.alpha = 0 \"Temperature coefficient of resistance (R_actual = R*(1 + alpha*(T_heatPort - T_ref))\" /* 0 */;
 Modelica.SIunits.Resistance r.R_actual \"Actual resistance = R*(1 + alpha*(T_heatPort - T_ref))\";
 Modelica.SIunits.ElectricPotential r.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Modelica.SIunits.ElectricCurrent r.i \"Current flowing from pin p to pin n\";
 Modelica.SIunits.ElectricPotential r.p.v \"Potential at the pin\";
 Modelica.SIunits.ElectricCurrent r.p.i \"Current flowing into the pin\";
 Modelica.SIunits.ElectricPotential r.n.v \"Potential at the pin\";
 Modelica.SIunits.ElectricCurrent r.n.i \"Current flowing into the pin\";
 parameter Boolean r.useHeatPort = false \"=true, if HeatPort is enabled\" /* false */;
 parameter Modelica.SIunits.ThermodynamicTemperature r.T = r.T_ref \"Fixed device temperature if useHeatPort = false\";
 Modelica.SIunits.Power r.LossPower \"Loss power leaving component via HeatPort\";
 Modelica.SIunits.ThermodynamicTemperature r.T_heatPort \"Temperature of HeatPort\";
equation
 assert(1 + r.alpha * (r.T_heatPort - r.T_ref) >= 1.0E-15, \"Temperature outside scope of model!\");
 r.R_actual = r.R * (1 + r.alpha * (r.T_heatPort - r.T_ref));
 r.v = r.R_actual * r.i;
 r.LossPower = r.v * r.i;
 r.v = r.p.v - r.n.v;
 0 = r.p.i + r.n.i;
 r.i = r.p.i;
 if not false then
  r.T_heatPort = r.T;
 end if;
 r.p.i = 0;
 r.n.i = 0;

public
 type Modelica.SIunits.Resistance = Real(final quantity = \"Resistance\",final unit = \"Ohm\");
 type Modelica.SIunits.ThermodynamicTemperature = Real(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0.0,start = 288.15,nominal = 300,displayUnit = \"degC\");
 type Modelica.SIunits.LinearTemperatureCoefficient = Real(final quantity = \"LinearTemperatureCoefficient\",final unit = \"1/K\");
 type Modelica.SIunits.ElectricPotential = Real(final quantity = \"ElectricPotential\",final unit = \"V\");
 type Modelica.SIunits.ElectricCurrent = Real(final quantity = \"ElectricCurrent\",final unit = \"A\");
 type Modelica.SIunits.Power = Real(final quantity = \"Power\",final unit = \"W\");
end NameTests.ImportTest8;
")})));
end ImportTest8;

model ImportTest9
	import Math = Modelica.Math;
	parameter Real p1 = Math.cos(9);
	parameter Real p2 = Modelica.Math.sin(9);
	parameter Real p3 = sqrt(3);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest9",
			description="Test of import of builtin mathematical functions.",
			flatModel="
 fclass NameTests.ImportTest9
  parameter Real p1 = cos(9) /* -0.9111302618846769 */;
  parameter Real p2 = sin(9) /* 0.4121184852417566 */;
  parameter Real p3 = sqrt(3) /* 1.7320508075688772 */;
 end NameTests.ImportTest9;
 ")})));
end ImportTest9;


model ImportTest10
	model A
		import C = Modelica.Constants;
		Real x = C.pi;
	end A;
	
	A y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest10",
			description="Using constant from imported package.",
			flatModel="
fclass NameTests.ImportTest10
 Real y.x = 3.141592653589793;

end NameTests.ImportTest10;
")})));
end ImportTest10;

model ImportTest11
  import mue_0 = Modelica.Constants.mue_0; 
  import SI = Modelica.SIunits;
  model M
    SI.Voltage v = 0;
    Real x = mue_0;
  end M;
  M m;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ImportTest11",
			description="Using constant from imported package.",
			flatModel="
fclass NameTests.ImportTest11
 Modelica.SIunits.ElectricPotential m.v = 0;
 Real m.x = 1.2566370614359173E-6;

public
 type Modelica.SIunits.ElectricPotential = Real(final quantity = \"ElectricPotential\",final unit = \"V\");
end NameTests.ImportTest11;
")})));
end ImportTest11;

model ShortClassDeclTest1
  model A
    Real x=2;
  end A;
  
  model AA = A;
  
  AA aa;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest1",
			description="Test simple use of short class declaration.",
			flatModel="
fclass NameTests.ShortClassDeclTest1
 Real aa.x=2;
end NameTests.ShortClassDeclTest1;
")})));
end ShortClassDeclTest1;



model ShortClassDeclTest2
  model A
    Real x=2;
  end A;
  
  model AA = A;

  model AAA = AA;
  
  AAA aa;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest2",
			description="Test simple use of multiple short class declaration.",
			flatModel="
fclass NameTests.ShortClassDeclTest2
 Real aa.x=2;
end NameTests.ShortClassDeclTest2;
")})));
end ShortClassDeclTest2;

model ShortClassDeclTest3
  type MyReal = Real(min=-3);
  MyReal x(start=3);


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest3",
			description="Short class declaration of Real",
			flatModel="
fclass NameTests.ShortClassDeclTest3
 NameTests.ShortClassDeclTest3.MyReal x(start = 3);

public
 type NameTests.ShortClassDeclTest3.MyReal = Real(min = - 3);
end NameTests.ShortClassDeclTest3;
")})));
end ShortClassDeclTest3;

model ShortClassDeclTest31
  Modelica.SIunits.Angle x(start=3);


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest31",
			description="Short class declaration of Real",
			flatModel="
fclass NameTests.ShortClassDeclTest31
 Modelica.SIunits.Angle x(start = 3);

public
 type Modelica.SIunits.Angle = Real(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\");
end NameTests.ShortClassDeclTest31;
")})));
end ShortClassDeclTest31;


model ShortClassDeclTest35_Err
  type MyReal = Real(min=-3,q=4);
  MyReal x(start=3,t=5);


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ShortClassDeclTest35_Err",
			description="Short class declaration of Real.",
			errorMessage="
2 errors found:
Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 549, column 4:
  Cannot find component declaration for q
Error: in file 'src/test/modelica/NameTests.mo':
Semantic error at line 550, column 4:
  Cannot find component declaration for t

")})));
end ShortClassDeclTest35_Err;


model ShortClassDeclTest4
connector MyRealInput = input MyRealSignal(max=5) "'input Real' as connector";
 
connector MyRealSignal 
  "Real port (both input/output possible)" 
  replaceable type SignalType = Real(unit="V");
  
  extends SignalType(nominal=34);
  
end MyRealSignal;
  
  MyRealInput u(min=3);
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest4",
			description="Test short class declarations and inheritance from primitive types",
			flatModel="
fclass NameTests.ShortClassDeclTest4
 input NameTests.ShortClassDeclTest4.MyRealInput u(min = 3);

public
 type NameTests.ShortClassDeclTest4.MyRealInput = Real(max = 5,nominal = 34,unit = \"V\");
end NameTests.ShortClassDeclTest4;
")})));
end ShortClassDeclTest4;

model ShortClassDeclTest5
connector MyRealInput = input MyRealSignal(start=3,nominal=3) "'input Real' as connector";
 
 type MyReal = Real(unit="V");
 
connector MyRealSignal 
  "Real port (both input/output possible)" 
  replaceable type SignalType = MyReal(min=1,max=1,start=1,nominal=1);
  
  extends SignalType(max=2,start=2,nominal=2);
  
end MyRealSignal;
  
  MyRealInput u(nominal=4);
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest5",
			description="Test short class declarations and inheritance from primitive types",
			flatModel="
fclass NameTests.ShortClassDeclTest5
 input NameTests.ShortClassDeclTest5.MyRealInput u(nominal = 4);

public
 type NameTests.ShortClassDeclTest5.MyRealInput = Real(start = 3,nominal = 3,max = 2,min = 1,unit = \"V\");
end NameTests.ShortClassDeclTest5;
")})));
end ShortClassDeclTest5;


model ShortClassDeclTest6
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
	

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest6",
			description="Test short class declarations.",
			flatModel="
fclass NameTests.ShortClassDeclTest6
 parameter Real R = 1;
 parameter Real a.R = R /*(0.0)*/;

end NameTests.ShortClassDeclTest6;
")})));
end ShortClassDeclTest6;


// TODO: These errors should be covered by a "Check for errors" that should 
//       be separate from the error check done when instantiating
//model ShortClassDeclTest7_Err
//  model A
//    Real x = 2;
//  end A;
//  
//  model B = A(y = 2.5);
//  
//  B b(x = 3);
//
//	annotation(__JModelica(UnitTesting(tests={
//		ErrorTestCase(
//			name="ShortClassDeclTest7_Err",
//			description="Short class declaration of Real.",
//			errorMessage="
//1 errors found:
//Error: in file 'src/test/modelica/NameTests.mo':
//Semantic error at line 834, column 14:
//  Cannot find component declaration for y
//")})));
//end ShortClassDeclTest7_Err;
//
//
//model ShortClassDeclTest75_Err
//  model A
//    Real x = 2;
//  end A;
//  
//  model B = A(y = 2.5);
//  
//  model C = B;
//  
//  model D
//	  extends B;
//  end D;
//  
//  B b(x = 3);
//
//	annotation(__JModelica(UnitTesting(tests={
//		ErrorTestCase(
//			name="ShortClassDeclTest75_Err",
//			description="",
//			errorMessage="
//1 errors found:
//Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
//Semantic error at line 2625, column 15:
//  Cannot find component declaration for y
//")})));
//end ShortClassDeclTest75_Err;


model ShortClassDeclTest8
 connector RealInput = input Real;

 RealInput u;
 Modelica.Blocks.Interfaces.RealInput u2;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclTest8",
			description="Test short class declarations",
			flatModel="
fclass NameTests.ShortClassDeclTest8
 input NameTests.ShortClassDeclTest8.RealInput u;
 input Modelica.Blocks.Interfaces.RealInput u2;

public
 type NameTests.ShortClassDeclTest8.RealInput = Real;
 type Modelica.Blocks.Interfaces.RealInput = Real;
end NameTests.ShortClassDeclTest8;
")})));
end ShortClassDeclTest8;


model ShortClassDeclTest9
    package B = A1;
    
    package A2
        function f
            output Real x = 1;
        algorithm
        end f;
    end A2;
    
    Real y = B.f();
end ShortClassDeclTest9;



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
 Real x[1];
equation
 x[end] = 2;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="EndExpTest1",
			description="Test of end expression",
			flatModel="
fclass NameTests.EndExpTest1
 Real x[1];
equation 
 x[end] = 2;

end NameTests.EndExpTest1;
")})));
end EndExpTest1;

model ForTest1
  Real x[3,3];
equation
  for i in 1:3, j in 1:3 loop
    x[i,j] = i + j;
  end for;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ForTest1",
			description="Test for equations.",
			flatModel="
fclass NameTests.ForTest1
 Real x[3,3];
equation 
 for i in 1:3, j in 1:3 loop
  x[i,j] = i + j;
 end for;

end NameTests.ForTest1;
")})));
end ForTest1;


model ForTest2_Err

  Real x[3,3];
equation
  for i in 1:3, j in 1:3 loop
    x[i,j] = i + k;
  end for;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ForTest2_Err",
			description="Test for equations.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1201, column 18:
  Cannot find class or component declaration for k
")})));
end ForTest2_Err;

model StateSelectTest 
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="StateSelectTest",
			description="Test for equations.",
			flatModel="
fclass NameTests.StateSelectTest
 Real x(stateSelect = StateSelect.never);
 Real y(stateSelect = StateSelect.avoid);
 Real z(stateSelect = StateSelect.default);
 Real w(stateSelect = StateSelect.prefer);
 Real v(stateSelect = StateSelect.always);
equation
 x = 2;
 y = 1;
 der(z) = 1;
 der(w) = 1;
 der(v) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end NameTests.StateSelectTest;
")})));
end StateSelectTest;



model IndexLookup1
  model B
    Real z[2] = {1, 2};
  end B;

  parameter Integer i = 2;
  B y;
  Real x = y.z[i];

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="IndexLookup1",
			description="Name lookup from within array subscript",
			flatModel="
fclass NameTests.IndexLookup1
 parameter Integer i = 2 /* 2 */;
 Real y.z[2] = {1,2};
 Real x = y.z[i];

end NameTests.IndexLookup1;
")})));
end IndexLookup1;


model IndexLookup2
  model B
    parameter Integer i = 1;
    Real z[2] = {1, 2};
  end B;

  parameter Integer i = 2;
  B y;
  Real x = y.z[i];

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
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
end IndexLookup2;

model ConditionalComponentTest1_Err
  parameter Real x = 1 if 1;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalComponentTest1_Err",
			description="Test of type checking of conditional components.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1939, column 18:
  The guard expression of a conditional component should be a boolean expression
")})));
end ConditionalComponentTest1_Err;

model ConditionalComponentTest2_Err
  parameter Boolean b[2] = {true,true};
  parameter Real x = 1 if b;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalComponentTest2_Err",
			description="Test of type checking of conditional components.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1954, column 18:
  The guard expression of a conditional component should be a scalar expression
")})));
end ConditionalComponentTest2_Err;

model ConditionalComponentTest3_Err
  parameter Integer b[2] = {1,1};
  parameter Real x = 1 if b;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalComponentTest3_Err",
			description="Test of type checking of conditional components.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1967, column 18:
  The guard expression of a conditional component should be a boolean expression
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 1967, column 18:
  The guard expression of a conditional component should be a scalar expression
")})));
end ConditionalComponentTest3_Err;


model ConditionalComponentTest4
  parameter Boolean b = true;
  parameter Real x = 1 if b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest4",
			description="Test flattening of conditional components.",
			flatModel="
fclass NameTests.ConditionalComponentTest4
 parameter Boolean b = true /* true */;
 parameter Real x = 1 /* 1 */;

end NameTests.ConditionalComponentTest4;
")})));
end ConditionalComponentTest4;


model ConditionalComponentTest5
  package P
    constant Boolean b = true;
  end P;
  parameter Real x = 1 if P.b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest5",
			description="Test flattening of conditional components.",
			flatModel="
fclass NameTests.ConditionalComponentTest5
 parameter Real x = 1 /* 1 */;

end NameTests.ConditionalComponentTest5;
")})));
end ConditionalComponentTest5;

model ConditionalComponentTest6_Err
  parameter Boolean b = false;
  parameter Real x = 1 if b;
  Real y = x;  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalComponentTest6_Err",
			description="Test of type checking of conditional components.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 2021, column 12:
  The component x is conditional: Access of conditional components is only valid in connect statements
")})));
end ConditionalComponentTest6_Err;

model ConditionalComponentTest7_Err
  model M
    Real x = 2;
  end M;
  parameter Boolean b = false;
  M m if b;
  Real y = m.x;  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalComponentTest7_Err",
			description="Test of type checking of conditional components.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 2036, column 12:
  The component m is conditional: Access of conditional components is only valid in connect statements
")})));
end ConditionalComponentTest7_Err;

model ConditionalComponentTest8
  parameter Boolean b = false;
  parameter Real x = 1 if b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest8",
			description="Test flattening of conditional components.",
			flatModel="
fclass NameTests.ConditionalComponentTest8
 parameter Boolean b = false /* false */;

end NameTests.ConditionalComponentTest8;
")})));
end ConditionalComponentTest8;

model ConditionalComponentTest9
  model N
   Real z;
   equation
   z^2 = 4;
  end N;

  model M
    Real x;
    N n;
    extends N;
    equation
    x = 3;
  end M;

  parameter Boolean b = false;
  M m if b;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest9",
			description="Test flattening of conditional components.",
			flatModel="
fclass NameTests.ConditionalComponentTest9
 parameter Boolean b = false /* false */;

end NameTests.ConditionalComponentTest9;
")})));
end ConditionalComponentTest9;

model ConditionalComponentTest10
  connector RealInput = input Real;
  connector RealOutput = output Real;

  model Source
    RealOutput y = p;
    parameter Real p = 1;
  end Source;

  model Sink 
    RealInput u;
  end Sink;

  model M
    parameter Boolean b = true;
    RealInput u1 if b;
    RealInput u2 if not b;
    RealOutput y;
  equation
    connect(u1,y);
    connect(u2,y);
  end M;

  parameter Boolean b = true;
  M m(b=b);
  Source source1 if b;
  Source source2 if not b;
  Sink sink;
  equation
  connect(source1.y,m.u1);
  connect(source2.y,m.u2);
  connect(m.y,sink.u);


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest10",
			description="Test flattening of conditional components",
			flatModel="
fclass NameTests.ConditionalComponentTest10
 parameter Boolean b = true /* true */;
 parameter Boolean m.b = b;
 NameTests.ConditionalComponentTest10.RealInput m.u1;
 NameTests.ConditionalComponentTest10.RealOutput m.y;
 NameTests.ConditionalComponentTest10.RealOutput source1.y = source1.p;
 parameter Real source1.p = 1 /* 1 */;
 NameTests.ConditionalComponentTest10.RealInput sink.u;
equation
 m.u1 = source1.y;
 m.y = sink.u;
 m.u1 = m.y;

public
 type NameTests.ConditionalComponentTest10.RealInput = Real;
 type NameTests.ConditionalComponentTest10.RealOutput = Real;
end NameTests.ConditionalComponentTest10;
")})));
end ConditionalComponentTest10;

model ConditionalComponentTest11
  connector RealInput = input Real;
  connector RealOutput = output Real;

  model Source
    RealOutput y = p;
    parameter Real p = 1;
  end Source;

  model Sink 
    RealInput u;
  end Sink;

  model M
    parameter Boolean b = true;
    RealInput u1 if b;
    RealInput u2 if not b;
    RealOutput y;
  equation
    connect(u1,y);
    connect(u2,y);
  end M;

  parameter Boolean b = false;
  M m(b=b);
  Source source1 if b;
  Source source2 if not b;
  Sink sink;
  equation
  connect(source1.y,m.u1);
  connect(source2.y,m.u2);
  connect(m.y,sink.u);


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest11",
			description="Test flattening of conditional components",
			flatModel="
fclass NameTests.ConditionalComponentTest11
 parameter Boolean b = false /* false */;
 parameter Boolean m.b = b;
 NameTests.ConditionalComponentTest11.RealInput m.u2;
 NameTests.ConditionalComponentTest11.RealOutput m.y;
 NameTests.ConditionalComponentTest11.RealOutput source2.y = source2.p;
 parameter Real source2.p = 1 /* 1 */;
 NameTests.ConditionalComponentTest11.RealInput sink.u;
equation
 m.u2 = source2.y;
 m.y = sink.u;
 m.u2 = m.y;

public
 type NameTests.ConditionalComponentTest11.RealInput = Real;
 type NameTests.ConditionalComponentTest11.RealOutput = Real;
end NameTests.ConditionalComponentTest11;
")})));
end ConditionalComponentTest11;


model ConditionalComponentTest12
	model A
		parameter Boolean flag = true;
		B b1 if flag;
		B b2 if not flag;
		Real z1 if flag;
		Real z2 if not flag;
	end A;
	
	model B
		Real x;
	end B;
	
	Real y = 1;
	A a(b1(x = y), b2(x = y), z1 = y, z2 = y);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalComponentTest12",
			description="Modifying conditional component",
			flatModel="
fclass NameTests.ConditionalComponentTest12
 Real y = 1;
 parameter Boolean a.flag = true /* true */;
 Real a.b1.x = y;
 Real a.z1 = y;
end NameTests.ConditionalComponentTest12;
")})));
end ConditionalComponentTest12;


model ConditionalComponentTest13_Err
	model A
		Real x;
	end A;
	
	model B
        parameter Boolean flag = true;
        A a1 if flag;
        A a2 if not flag;
	end B;
	
    Real y1 if b.flag;
    Real y2 if not b.flag;
	B b(a1(x = y1), a2(x = y2));

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalComponentTest13_Err",
			description="Using value of conditional component in modification for other conditional component",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 3159, column 13:
  The component y1 is conditional: Access of conditional components is only valid in connect statements
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 3159, column 25:
  The component y2 is conditional: Access of conditional components is only valid in connect statements
")})));
end ConditionalComponentTest13_Err;



model AttributeDot1
  Real x=1;
  parameter Real p = x.start;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AttributeDot1",
			description="Access to attribute with dot notation",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 2442, column 22:
  Can not access attribute of primitive with dot notation: x.start
")})));
end AttributeDot1;



model ComplexExpInDer1
 Real x;
 Real y;
equation
 der(x * y) = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ComplexExpInDer1",
			description="",
			flatModel="
fclass NameTests.ComplexExpInDer1
 Real x;
 Real y;
equation
 x * der(y) + der(x) * y = 0;
end NameTests.ComplexExpInDer1;
")})));
end ComplexExpInDer1;


model ComplexExpInDer2
 Real x;
 Real y;
equation
 der(der(x + 1) - y) = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ComplexExpInDer2",
			description="",
			flatModel="
fclass NameTests.ComplexExpInDer2
 Real x;
 Real y;
equation
 der(x,2) - der(y) = 0;
end NameTests.ComplexExpInDer2;
")})));
end ComplexExpInDer2;


model ComplexExpInDer3
 Real x;
 Real y;
equation
 der({x, y}) = zeros(2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ComplexExpInDer3",
			description="",
			flatModel="
fclass NameTests.ComplexExpInDer3
 Real x;
 Real y;
equation
 {der(x),der(y)} = zeros(2);
end NameTests.ComplexExpInDer3;
")})));
end ComplexExpInDer3;

model EmptyAnnotationTest
  
  model M
  annotation();
  end M;
  M m;
	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="EmptyAnnotationTest",
			description="Test that it is ok to have an empty annotation.",
			flatModel="
fclass NameTests.EmptyAnnotationTest
end NameTests.EmptyAnnotationTest;
")})));
end EmptyAnnotationTest;

model EmptyModificationTest
  
  model M
  Real x()=1;
  end M;
  M m;
	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="EmptyModificationTest",
			description="Test that it is ok to have an empty modification.",
			flatModel="
fclass NameTests.EmptyModificationTest
 Real m.x = 1;
end NameTests.EmptyModificationTest;
")})));
end EmptyModificationTest;

model FunctionCallLeftTest
  function f
   input Real x1;
   output Real y1;
  algorithm
   y1:=2*x1;
  end f;
  
   Real x;
  algorithm
   (x) := f(1);
	
	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="FunctionCallLeftTest",
			description="Test so that it is ok to have only one output argument in a function call left statement.",
			flatModel="
fclass NameTests.FunctionCallLeftTest
 Real x;
algorithm
 (x) := NameTests.FunctionCallLeftTest.f(1);

public
 function NameTests.FunctionCallLeftTest.f
  input Real x1;
  output Real y1;
 algorithm
  y1 := 2 * x1;
  return;
 end NameTests.FunctionCallLeftTest.f;

end NameTests.FunctionCallLeftTest;
")})));
end FunctionCallLeftTest;


model PreErrorTest
	Real x[3] = (1:3) .* time;
	discrete Real y(start = 0);
	Integer i(start = 1);
equation
	when { time > 1, time > 2, time > 3 } then
		y = x[pre(i)];
		i = pre(i) + 1;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="PreErrorTest",
			description="Provoking toString() of pre() in in stance tree - caused crash",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/NameTests.mo':
Semantic error at line 3271, column 9:
  Array index in equation must be constant, parameter or loop index: pre(i)
")})));
end PreErrorTest;

model PreAliasTest1
	discrete Real x;
	discrete Real y;
initial equation
	pre(x) = 42;
equation
	x = y;
	x = pre(x) * pre(y) + 3.14;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="PreAliasTest1",
			description="Test so that pre() variables are rewritten correctly",
			flatModel="
fclass NameTests.PreAliasTest1
 discrete Real x;
initial equation 
 pre(x) = 42;
equation
 x = pre(x) * pre(x) + 3.14;
end NameTests.PreAliasTest1;
")})));
end PreAliasTest1;


model AssignedInWhenRecursion
    model A
        parameter Boolean x = true;
    end A;
    
    model B
        Real y = 2;
    end B;
    
    parameter Integer n = if a.x then 2 else 3;
    A a;
    B b[n];
end AssignedInWhenRecursion;

model WhenInExtendsTest
	model A	
		Real x;
		Real y;
		Integer i;
		parameter Boolean b = false;
	equation
		i = 1;
		when initial() then
			if b then
				y = 2 + i;
			else
				y = 4;
			end if;
		end when;
		when time>=3 then
	  		x = 3;
		end when;
	end A;
	
	model B
		extends A;
	end B;
	
	B b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="WhenInExtendsTest",
			description="",
			flatModel="
fclass NameTests.WhenInExtendsTest
 discrete Real b.x;
 discrete Real b.y;
 discrete Integer b.i;
 parameter Boolean b.b = false /* false */;
equation
 b.i = 1;
 when initial() then
  if false then
   b.y = 2 + b.i;
  else
   b.y = 4;
  end if;
 end when;
 when time >= 3 then
  b.x = 3;
 end when;
end NameTests.WhenInExtendsTest;
")})));
end WhenInExtendsTest;

end NameTests;
