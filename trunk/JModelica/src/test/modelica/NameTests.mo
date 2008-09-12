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



")})));

  model A
    Real x = 4;
  end A;
  
  A a;
  Real y;
equation
  a.y = y;
equation
 

  end NameTest5_Err;

model NameTest6_Err
  
  
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="NameTest6_Err",
                                               description="Basic test of name lookup",
                                               errorMessage=
"



")})));

  model A
    Real x = y;
  end A;
  
  A a;
equation
 

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
equation
 

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
equation
 

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
    replaceable B b extends A;
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

  replaceable package P = P2 extends P1;
  
  P.B b;
  
  end NameTest10_Err;



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
equation 
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
equation 
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
equation 
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
equation 
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
    
  extends P;
  import NameTests.ImportTest5.C.*;
  D d(z=3);
  
end ImportTest5;

model ShortClassDeclTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclTest1",
        description="Test simple use of short class declaration.",
                                               flatModel=
"fclass NameTests.ShortClassDeclTest1
 Real aa.x=2;
equation 
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
equation 
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
equation 
end NameTests.ShortClassDeclTest3;
")})));
  
  type MyReal = Real(min=-3);
  MyReal x(start=3);

end ShortClassDeclTest3;

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
equation 
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
equation 
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

model DerTest1
	Real x;
equation
    der(x)=1;
end DerTest1;


model InitialEquationTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="InitialEquationTest1",
        description="Test flattening of initial equations",flatModel=
"
fclass NameTests.InitialEquationTest1
 Real x;
initial equation 
 x = 1;
equation 
 der(x) = 1;
end NameTests.InitialEquationTest1;
")})));
  
  Real x;
  initial equation
  x = 1;
  equation
  der(x)=1;
  
end InitialEquationTest1;


end NameTests;