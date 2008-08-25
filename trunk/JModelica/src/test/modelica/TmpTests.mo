package TmpTests


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

end TmpTests;