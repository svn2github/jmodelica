package ModificationTests 

class ModTest1
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest1",
                                               description="Test of Real attribute \"unit\".",
                                               flatModel=
"fclass ModificationTests.ModTest1
 parameter Real y=4;
 Real z(unit=\"m\")=y;
 Real x;
equation 
 x=4;
end ModificationTests.ModTest1;
")})));
  parameter Real y = 4;
  Real z(unit="m") = y;
  Real x;
equation
  x=4;
end ModTest1;

class ModTest2
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest2",
                                               description="Merging of modifications",
                                               flatModel=
"  fclass ModificationTests.ModTest2
 parameter Real c4.x1;
 parameter Real c4.x2=22;
 parameter Real c4.x3.a=33;
 parameter Real c4.x4.b=4;
 parameter Real c4.x4.c=44;
 parameter Real c4.x5.a=5;
 parameter Real c4.a=55;
 parameter Real c4.b=66;
 parameter Real c4.c=77;
equation 
end ModificationTests.ModTest2;
  ")})));
  
  class C1
    parameter Real a;
  end C1;
  
  class C2
    parameter Real b,c;
  end C2;
  
  class C3
    parameter Real x1;
    parameter Real x2 = 2;
    parameter C1 x3;
    parameter C2 x4(b=4);
    parameter C1 x5(a=5);
    extends C1;
    extends C2(b=6,c=77);
  end C3;
  
  class C4
    extends C3(x2=22, x3(a=33), x4(c=44), a=55, b=66);
  end C4;
  C4 c4;
end ModTest2;

class ModTest3
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest3",
                                               description="Simple modification test",
                                               flatModel=
"fclass ModificationTests.ModTest3
 Real c.x=5;
equation 
end ModificationTests.ModTest3;
 ")})));
  
  
  class C
    Real x=3;
  end C;
  
  C c(x=5);
  
end ModTest3;

class ModTest5
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest5",
                                               description="Test of start-attribute",
                                               flatModel=
" fclass ModificationTests.ModTest5
 parameter Real p=3;
 Real y(start=p)=5;
equation 
end ModificationTests.ModTest5;")})));

  
  
  parameter Real p=3;
  Real y(start=p)=5;
end ModTest5;

class ModTest6
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest6",
                                               description="Test merging of modifications",
                                               flatModel=
" fclass ModificationTests.ModTest6
 Real c2.p(nominal=4)=3;
 Real c2.c1.x(min=c2.p)=5;
equation 
end ModificationTests.ModTest6;")})));
  
class C1
 Real x;
end C1;

class C2
  Real p(nominal=4)=3;
  C1 c1 (x(min=p)=5);
end C2;

C2 c2;
end ModTest6;

class ModTest7 
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest7",
                                               description="Test merging of attributes",
                                               flatModel=
"fclass ModificationTests.ModTest7
 Real x=3;
 Real c2.y=3;
 Real c2.c3.z(max=4,nominal=2)=5;
equation 
end ModificationTests.ModTest7;")})));

  Real x=3;
  class C2 
    Real y;
    class C3 
      Real z(nominal=1)=1;
    end C3;
    C3 c3(z(nominal=2)=3);
  end C2;
  C2 c2(c3.z(max=4)=5, y=3);
end ModTest7;


class ModTest8
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest8",
                                               description="Merging of modifiers in extends clauses",
                                               flatModel=
"fclass ModificationTests.ModTest8
 Real c3.c1.x=44;
 Real c3.x=c3.c1.x;
equation 
end ModificationTests.ModTest8;
")})));
  
class C1
 Real x;
end C1;

class C2
  extends C1(x=4);
  C1 c1(x=6);
end C2;

class C3

	extends C2(x=c1.x,c1(x=44));  
  
end C3;
C3 c3;
end ModTest8;

class ModTest9
       annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest9",
                                               description="Test of attributes of Real",
                                               flatModel=
"fclass ModificationTests.ModTest9
 Real c3.c1.x(start=2,quantity=\"qwe\")=44;
 Real c3.x(quantity=\"qqq\",unit=\"m2\",displayUnit=\"m22\",start=4.2,min=4.1,max=9.0,nominal=0.2)=55;
equation 
end ModificationTests.ModTest9;
")})));
  
  
class C1
 Real x;
end C1;

class C2
  extends C1(x(unit="qwe",start=3.0)=4);
  C1 c1(x(start=2,quantity="qwe")=6);
end C2;

class C3
	extends C2(x(quantity="qqq",unit="m2",displayUnit="m22",start=4.2,
	             min=4.1,max=9.0,nominal=0.2)=55,c1(x=44));  
  
end C3;

C3 c3;

end ModTest9;

class ModTest10
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest10",
                                               description="Test of parameter-prefix in modifications.",
                                               flatModel=
"fclass ModificationTests.ModTest10
 parameter Real A=2;
 parameter Real c2a.B=1;
 Real c2a.x=c2a.B;
 parameter Real c2b.B=1;
 Real c2b.x=A;
equation 
end ModificationTests.ModTest10;
")})));
  parameter Real A=2;
  
	class C2
	  parameter Real B=1;
	  Real x=B;
	end C2;
  
  C2 c2a;
  C2 c2b(x=A);
  
end ModTest10;

class ModTest11
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest11",
                                               description="Additional merging tests",
                                               flatModel=
" fclass ModificationTests.ModTest11
 Real c2.c3.c4a.z=6;
 Real c2.c3.c4a.x=4;
 Real c2.c3.c4b.z=2;
 Real c2.c3.c4b.x=10;
 Real c3.c4a.z=6;
 Real c3.c4a.x=5;
 Real c3.c4b.z=8;
 Real c3.c4b.x=3;
equation 
end ModificationTests.ModTest11;
")})));
  
  class C2
    
    class C3
      
      class C4
        Real z=2;
        Real x=3;
      end C4;
    
      C4 c4a,c4b;
    
    end C3;
  	
  	C3 c3(c4a.z=6);
  	
  end C2;
  
  C2 c2(c3.c4a.x=4,c3.c4b.x=10);
  extends C2(c3.c4a.x=5,c3.c4b.z=8);
end ModTest11;
 
 model ModTest_PM_12
  
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest12",
                                               description="Additional merging tests",
                                               flatModel=
"fclass ModificationTests.ModTest_PM_12
 Real a;
 Real c0.c3.b=5;
 Real c0.c3.c4a.z=6;
 Real c0.c3.c4a.x=3;
 Real c0.c3.c4a.w=3;
 Real c0.c3.c4b.z=2;
 Real c0.c3.c4b.x=c0.c3.b;
 Real c0.c3.c4b.w=3;
 Real c2.c3.b=5;
 Real c2.c3.c4a.z=9;
 Real c2.c3.c4a.x=a;
 Real c2.c3.c4a.w=6;
 Real c2.c3.c4b.z=2;
 Real c2.c3.c4b.x=c3.b;
 Real c2.c3.c4b.w=3;
 Real c3.b=5;
 Real c3.c4a.z=6;
 Real c3.c4a.x=5;
 Real c3.c4a.w=3;
 Real c3.c4b.z=a;
 Real c3.c4b.x=c3.b;
 Real c3.c4b.w=3;
equation 
end ModificationTests.ModTest_PM_12;")})));
  
  extends C2(c3(c4a(x=5)),c3.c4b.z=a);
  //extends C2(c3.c4b.z=a);
  
  model C2
    
    model C3
      
      model C4
        Real z=2;
        Real x=3; 
        Real w=3;
      end C4;
    
        Real b=5;
    
      C4 c4a;
      C4 c4b(x=b); 
    
    end C3;
        
        C3 c3(c4a.z=6);
        
  end C2;
  
  Real a;
  
  C2 c0;
  C2 c2(c3.c4a.x=a,c3.c4b.x=c3.b,c3(c4a(w=6,z=9)));
  
end ModTest_PM_12;
 
model ModTest13_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ModTest13_Err",
        description="Test of lookup errors in modifications",
                                               flatModel=
"
1 error(s) found...
In file 'src/test/modelica/ModificationTests.mo':
Semantic error at line 351, column 7:
  Cannot find class or component declaration for y

")})));

  model A
    Real x=2;
  end A;

  A a(y=3);

end ModTest13_Err;
 

model ShortClassDeclModTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclModTest1",
        description="Test simple use of short class declaration and modification.",
                                               flatModel=
"
fclass ModificationTests.ShortClassDeclModTest1
 Real aa.x=3;
equation 
end ModificationTests.ShortClassDeclModTest1;
")})));

  model A
    Real x=2;
  end A;
  
  model AA=A;
  
  AA aa(x=3);

end ShortClassDeclModTest1;

 model ShortClassDeclModTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclModTest2",
        description="Test simple use of short class declaration and modification.",
                                               flatModel=
"
fclass ModificationTests.ShortClassDeclModTest2
 Real aa.x=2.5;
equation 
end ModificationTests.ShortClassDeclModTest2;
")})));

  model A
    Real x=2;
  end A;
  
  model AA=A(x=2.5);
  
  AA aa;

end ShortClassDeclModTest2;

model ShortClassDeclModTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ShortClassDeclModTest3",
        description="Test simple use of short class declaration and modification.",
                                               flatModel=
"
fclass ModificationTests.ShortClassDeclModTest3
 Real aa.x=3;
equation 
end ModificationTests.ShortClassDeclModTest3;
")})));

  model A
    Real x=2;
  end A;
  
  model AA=A(x=2.5);
  
  AA aa(x=3);

end ShortClassDeclModTest3;
 

end ModificationTests;