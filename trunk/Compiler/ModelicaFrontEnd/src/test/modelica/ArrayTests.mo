within ;
package ArrayTests

  model ArrayTest1
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ArrayTest1",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest1
 Real x[2];
equation 
 x[1] = 3;
 x[2] = 4;
end ArrayTests.ArrayTest1;
")})));
  
    Real x[2];
  equation
    x[1] = 3;
    x[2] = 4;
  end ArrayTest1;

  model ArrayTest1b
  
         annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ArrayTest1b",
        description="Flattening of arrays.",
                                               flatModel=
                                               " 
fclass ArrayTests.ArrayTest1b
 parameter Integer n = 2 /* 2 */;
 Real x[n];
equation 
 x[1] = 3;
 x[2] = 4; 
end ArrayTests.ArrayTest1b;
")})));

    parameter Integer n = 2;
    Real x[n];
  equation
    x[1] = 3;
    x[2] = 4;
  end ArrayTest1b;


  model ArrayTest1c

	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest1c",
        description="Test scalarization of variables",
                                               flatModel=
"
fclass ArrayTests.ArrayTest1c
 Real x[1];
 Real x[2];
equation 
 der(x[1]) = 3;
 der(x[2]) = 4;
end ArrayTests.ArrayTest1c;
")})));
  
    Real x[2];
  equation
    der(x[1]) = 3;
    der(x[2]) = 4;
  end ArrayTest1c;


  model ArrayTest2

	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest2",
        description="Test scalarization of variables",
                                               flatModel=
"
fclass ArrayTests.ArrayTest2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation 
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
end ArrayTests.ArrayTest2;
")})));

    Real x[2,2];
  equation
    x[1,1] = 1;
    x[1,2] = 2;
    x[2,1] = 3;
    x[2,2] = 4;
  end ArrayTest2;

  model ArrayTest3

    Real x[:] = {2,3};
    Real y[2];
  equation
    y[1] = x[1];
    y[2] = x[2];
  end ArrayTest3;

  model ArrayTest4


	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest4",
        description="Test scalarization of variables",
                                               flatModel=
"fclass ArrayTests.ArrayTest4
 Real m[1].x[1];
 Real m[1].x[2];
 Real m[2].x[1];
 Real m[2].x[2];
equation 
 m[1].x[1] = 1;
 m[1].x[2] = 2;
 m[2].x[1] = 3;
 m[2].x[2] = 4;
end ArrayTests.ArrayTest4;
")})));


    model M
      Real x[2];
    end M;
    M m[2];
  equation
    m[1].x[1] = 1;
    m[1].x[2] = 2;
    m[2].x[1] = 3;
    m[2].x[2] = 4;
  end ArrayTest4;

  model ArrayTest5
    model M
      Real x[3] = {-1,-2,-3};
    end M;
    M m[2](x={{1,2,3},{4,5,6}});
  end ArrayTest5;

  model ArrayTest6
    model M
      Real x[3];
    end M;
    M m[2];
  equation
    m.x = {{1,2,3},{4,5,6}};
  end ArrayTest6;

  model ArrayTest7
    Real x[3];
  equation
    x[1:2] = {1,2};
    x[3] = 3;
  end ArrayTest7;

  model ArrayTest8
    model M
      parameter Integer n = 3;
      Real x[n] = ones(n);
    end M;
      M m[2](n={1,2});
  end ArrayTest8;

      model ArrayTest9
        model M
              parameter Integer n1 = 2;
              Real x[n1] = ones(n1);
        end M;

        model N
              parameter Integer n2 = 2;
              M m[n2,n2+1];
        end N;
	    N nn;
      end ArrayTest9;

      model ArrayTest95
        model M
              parameter Integer n1 = 3;
              Real x = n1;
        end M;

        model N
              parameter Integer n2 = 2;
              M m;
        end N;
        N n(m(n={3,4}));
      end ArrayTest95;


   model ArrayTest10
    parameter Integer n;
    Real x[n];
   end ArrayTest10;

   model ArrayTest11
    model M
      Real x[2];
    end M;
      M m1[2];
      M m2[3];
   equation
      m1[:].x[:] = {{1,2},{3,4}};
      m2[1:2].x[:] = {{1,2},{3,4}};
      m2[3].x[:] = {1,2};
   end ArrayTest11;

      model ArrayTest12
        model M
              Real x[2];
        end M;

        model N
              M m[3];
        end N;
        N n;
      equation
        n.m.x={{{1,2},{3,4},{5,6}}};

      end ArrayTest12;

  model ArrayTest13
    model C
      parameter Integer n = 2;
    end C;
    C c;
    C cv[c.n];
  end ArrayTest13;

      model ArrayTest14
        model M
              Real x[1] = ones(1);
        end M;

        model N
              M m[3,2];
        end N;
        N n;
      equation

      end ArrayTest14;

model ArrayTest15_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayTest15_Err",
         description="Test type checking of arrays",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 251, column 9:
  Array size mismatch in declaration: x, size of declaration is [3] and size of binding expression is [3, 1]
")})));

   Real x[3] = {{2},{2},{3}};
end ArrayTest15_Err;

  model ArrayTest16
    model M
      Real x[2,1,1,1];
    end M;
    M m[2,1,2];
  equation
    m[1].x[1] = 1;
    m[1].x[2] = 2;
    m[2].x[1] = 3;
    m[2].x[2] = 4;
  end ArrayTest16;


model ArrayTest17
  model N
    model M
      Real x[2];
    end M;
    M m[2,1];
  end N;
  N n[2];
  equation
//  n.m.x=1;
  n.m.x[1]={{{1}},{{2}},{{3}},{{4}}};  

end ArrayTest17;

model ArrayTest18_Err
  Real x[1];
equation
  x[1] = 1;
  x[2] = 2;  
end ArrayTest18_Err;

model ArrayTest19_Err
  model N
    model M
      Real x[2];
    end M;
    M m[2,1];
  end N;
  N n[2];
  equation

  n[3].m[1,1].x[1] = 1;

end ArrayTest19_Err;

model ArrayTest20_Err
  model N
    model M
      Real x[2];
    end M;
    M m[2];
  end N;
  N n[2];
  equation

  n[2].m[1].x[0] = 1;

end ArrayTest20_Err;


model ArrayTest21
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest21",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest21
 Real x[1];
 Real x[2];
equation 
 x[1] = 0;
 x[2] = 0;
end ArrayTests.ArrayTest21;

")})));
  
  Real x[2];
  Real y[2];
equation
  x=y;
  x=zeros(2);
end ArrayTest21;

model ArrayTest22
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest22",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest22
 Real x[1];
 Real x[2];
equation 
 x[1] = 1;
 x[2] = 1;
end ArrayTests.ArrayTest22;

")})));
  
  Real x[2];
  Real y[2];
equation
  x=y;
  x=ones(2);
end ArrayTest22;

model ArrayTest23
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest23",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest23
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation 
 x[1,1] = 1;
 x[1,2] = 1;
 x[2,1] = 1;
 x[2,2] = 1;
end ArrayTests.ArrayTest23;
")})));
  
  Real x[2,2];
  Real y[2,2];
equation
  x=y;
  x=ones(2,2);
end ArrayTest23;

model ArrayTest24

        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest24",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest24
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = 1;
 y[1,1] = x[1,1] + 1;
 x[1,2] = 1;
 y[1,2] = x[1,2] + 2;
 x[2,1] = 2;
 y[2,1] = x[2,1] + 1;
 x[2,2] = 2;
 y[2,2] = x[2,2] + 2;
end ArrayTests.ArrayTest24;
")})));
  
  Real x[2,2];
  Real y[2,2];
equation
  for i in 1:2, j in 1:2 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
  end for;
end ArrayTest24;

model ArrayTest25

        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest25",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest25
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
equation
 x[1,1] = 1;
 y[1,1] = x[1,1] + 1;
 x[1,2] = 1;
 y[1,2] = x[1,2] + 2;
 x[1,3] = 1;
 y[1,3] = x[1,3] + 3;
 x[2,1] = 2;
 y[2,1] = x[2,1] + 1;
 x[2,2] = 2;
 y[2,2] = x[2,2] + 2;
 x[2,3] = 2;
 y[2,3] = x[2,3] + 3;
end ArrayTests.ArrayTest25;
")})));
  
  Real x[2,3];
  Real y[2,3];
equation
  for i in 1:2 loop
   for j in 1:3 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
   end for;
  end for;
end ArrayTest25;


model ArrayTest26

        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest26",
        description="Flattening of arrays.",
                                               flatModel=
"fclass ArrayTests.ArrayTest26
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[1,4];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[2,4];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
 Real x[3,4];
 Real x[4,1];
 Real x[4,2];
 Real x[4,3];
 Real x[4,4];
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[1,4];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 Real y[2,4];
 Real y[3,1];
 Real y[3,2];
 Real y[3,3];
 Real y[3,4];
 Real y[4,1];
 Real y[4,2];
 Real y[4,3];
 Real y[4,4];
equation
 x[2,2] = 2;
 y[2,2] = x[2,2] + 2;
 x[2,4] = 2;
 y[2,4] = x[2,4] + 4;
 x[4,2] = 4;
 y[4,2] = x[4,2] + 2;
 x[4,4] = 4;
 y[4,4] = x[4,4] + 4;
 x[1,1] = 1 + 2;
 y[1,1] = x[1,1] + 1 + 2;
 x[1,3] = 1 + 2;
 y[1,3] = x[1,3] + 3 + 2;
 x[3,1] = 3 + 2;
 y[3,1] = x[3,1] + 1 + 2;
 x[3,3] = 3 + 2;
 y[3,3] = x[3,3] + 3 + 2;
 x[3,1] = 3 + 2;
 y[3,1] = x[3,1] + 1 + 2;
 x[3,3] = 3 + 2;
 y[3,3] = x[3,3] + 3 + 2;
 x[1,1] = 1 + 2;
 y[1,1] = x[1,1] + 1 + 2;
 x[1,3] = 1 + 2;
 y[1,3] = x[1,3] + 3 + 2;
 x[2,3] = 2 + 2;
 y[2,3] = x[2,3] + 3 + 2;
 x[2,1] = 2 + 2;
 y[2,1] = x[2,1] + 1 + 2;
 x[4,3] = 4 + 2;
 y[4,3] = x[4,3] + 3 + 2;
 x[4,1] = 4 + 2;
 y[4,1] = x[4,1] + 1 + 2;
end ArrayTests.ArrayTest26;
")})));
  
  Real x[4,4];
  Real y[4,4];
equation
  for i in 2:2:4 loop
   for j in 2:2:4 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
   end for;
  end for;
  for i in 1:2:4 loop
   for j in 1:2:4 loop
    x[i,j] = i+2;
    y[i,j] = x[i,j]+j+2;
   end for;
  end for;
  for i in 3:-2:1 loop
   for j in 1:2:4 loop
    x[i,j] = i+2;
    y[i,j] = x[i,j]+j+2;
   end for;
  end for;
  for i in 2:2:4 loop
   for j in 3:-2:1 loop
    x[i,j] = i+2;
    y[i,j] = x[i,j]+j+2;
   end for;
  end for;

end ArrayTest26;


model ArrayTest27_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayTest27_Err",
         description="Test type checking of arrays",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 592, column 13:
  Array size mismatch for attribute: start, size of declaration is [3] and size of start expression is [2]
")})));

   Real x[3](start={1,2});
equation
   der(x) = ones(3);
end ArrayTest27_Err;


model ArrayTest28_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayTest28_Err",
         description="Test type checking of arrays",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 610, column 14:
  Array size mismatch for attribute: each start, declaration has 1 dimension(s) and expression has 1, expression must have fewer than declaration
")})));

   Real x[3](each start={1,2,3});
equation
   der(x) = ones(3);
end ArrayTest28_Err;


model ArrayTest29
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest29",
        description="Flattening of arrays.",
                                               flatModel=
"fclass ArrayTests.ArrayTest29
 Real x[1](start = 1);
 Real x[2](start = 2);
 Real x[3](start = 3);
equation
 der(x[1]) = 1;
 der(x[2]) = 1;
 der(x[3]) = 1;
end ArrayTests.ArrayTest29;
")})));

   Real x[3](start={1,2,3});
equation
   der(x) = ones(3);

end ArrayTest29;

model ArrayTest30

        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest30",
        description="Flattening of arrays.",
                                               flatModel=
"
fclass ArrayTests.ArrayTest30
 Real x[1,1](start = 1);
 Real x[1,2](start = 2);
 Real x[2,1](start = 3);
 Real x[2,2](start = 4);
 Real x[3,1](start = 5);
 Real x[3,2](start = 6);
equation
 der(x[1,1]) =  - ( 1 );
 der(x[1,2]) =  - ( 2 );
 der(x[2,1]) =  - ( 3 );
 der(x[2,2]) =  - ( 4 );
 der(x[3,1]) =  - ( 5 );
 der(x[3,2]) =  - ( 6 );
end ArrayTests.ArrayTest30;
")})));

   Real x[3,2](start={{1,2},{3,4},{5,6}});
equation
   der(x) = {{-1,-2},{-3,-4},{-5,-6}};

end ArrayTest30;




model ArrayModifiers1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayModifiers1",
         description="Modifiers to arrays: array attributes",
         flatModel="
fclass ArrayTests.ArrayModifiers1
 Real a[1](start = 3);
 Real a[2](start = 3);
 Real a[3](start = 3);
 Real b[1](start = 1);
 Real b[2](start = 2);
 Real b[3](start = 3);
equation
 a[1] = 0;
 a[2] = 0;
 a[3] = 0;
 b[1] = 0;
 b[2] = 0;
 b[3] = 0;
end ArrayTests.ArrayModifiers1;
")})));

 Real a[3](each start=3) = zeros(3);
 Real b[3](start={1,2,3}) = zeros(3);
end ArrayModifiers1;


model ArrayModifiers2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayModifiers2",
         description="Modifiers to arrays: [](start=[])",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 712, column 9:
  The 'each' keyword cannot be applied to attributes of scalar components
")})));

 Real a(each start=3) = zeros(3);
end ArrayModifiers2;


model ArrayModifiers3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayModifiers3",
         description="Modifiers to arrays: [3](start=[4])",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 728, column 11:
  Array size mismatch for attribute: start, size of declaration is [3] and size of start expression is [4]
")})));

 Real b[3](start={1,2,3,4}) = zeros(3);
end ArrayModifiers3;


model ArrayModifiers4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayModifiers4",
         description="Modifiers to arrays: [3](each start=[2])",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 744, column 12:
  Array size mismatch for attribute: each start, declaration has 1 dimension(s) and expression has 1, expression must have fewer than declaration
")})));

 Real a[3](each start={1,2}) = zeros(3);
end ArrayModifiers4;


model ArrayModifiers5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayModifiers5",
         description="Modifiers to arrays: members that are arrays",
         flatModel="
fclass ArrayTests.ArrayModifiers5
 Real b.x[1];
 Real b.x[2];
 Real b.x[3];
 Real b.y[1];
 Real b.y[2];
 Real b.y[3];
equation
 b.x[1] = 1;
 b.x[2] = 2;
 b.x[3] = 3;
 b.y[1] = 2;
 b.y[2] = 2;
 b.y[3] = 2;
end ArrayTests.ArrayModifiers5;
")})));

 model B
  Real x[3];
  Real y[3];
 end B;
 
 B b(x={1,2,3}, each y=2);
end ArrayModifiers5;


model ArrayModifiers6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayModifiers6",
         description="Modifiers to arrays: [3] = [4]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 792, column 8:
  Array size mismatch in declaration: x, size of declaration is [3] and size of binding expression is [4]
")})));

 model B
  Real x[3];
 end B;
 
 B b(x={1,2,3,4});
end ArrayModifiers6;


model ArrayModifiers7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayModifiers7",
         description="Modifiers to arrays: each [] = []",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 813, column 8:
  The 'each' keyword cannot be applied to scalar members of non-array components
")})));

 model B
  Real y;
 end B;
 
 B b(each y=2);
end ArrayModifiers7;


model ArrayModifiers8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayModifiers8",
         description="Modifiers to arrays: each [3] = [2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 833, column 8:
  Array size mismatch in declaration: each y, declaration has 1 dimension(s) and binding expression has 1, expression must have fewer than declaration
")})));

 model B
  Real y[3];
 end B;
 
 B b(each y={1,2});
end ArrayModifiers8;




model ArrayAdd1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayAdd1",
         description="Scalarization of addition: Real[2] + Integer[2]",
         flatModel="
fclass ArrayTests.ArrayAdd1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] + 10;
 x[2] = y[2] + 20;
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayAdd1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20 };
end ArrayAdd1;


model ArrayAdd2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayAdd2",
         description="Scalarization of addition: Real[2,2] + Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayAdd2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] + 10;
 x[1,2] = y[1,2] + 20;
 x[2,1] = y[2,1] + 30;
 x[2,2] = y[2,2] + 40;
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayAdd2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + { { 10, 20 }, { 30, 40 } };
end ArrayAdd2;


model ArrayAdd3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayAdd3",
         description="Scalarization of addition: Real[2,2,2] + Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayAdd3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] + 10;
 x[1,1,2] = y[1,1,2] + 20;
 x[1,2,1] = y[1,2,1] + 30;
 x[1,2,2] = y[1,2,2] + 40;
 x[2,1,1] = y[2,1,1] + 50;
 x[2,1,2] = y[2,1,2] + 60;
 x[2,2,1] = y[2,2,1] + 70;
 x[2,2,2] = y[2,2,2] + 80;
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayAdd3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayAdd3;


model ArrayAdd4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd4",
         description="Scalarization of addition: Real[2] + Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 796, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + 10;
end ArrayAdd4;


model ArrayAdd5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd5",
         description="Scalarization of addition: Real[2,2] + Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 815, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + 10;
end ArrayAdd5;


model ArrayAdd6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd6",
         description="Scalarization of addition: Real[2,2,2] + Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 834, column 6:
  Type error in expression
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + 10;
end ArrayAdd6;


model ArrayAdd7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd7",
         description="Scalarization of addition: Real + Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 853, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y = 1;
equation
 x = y + { 10, 20 };
end ArrayAdd7;


model ArrayAdd8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd8",
         description="Scalarization of addition: Real + Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 861, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y + { { 10, 20 }, { 30, 40 } };
end ArrayAdd8;


model ArrayAdd9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd9",
         description="Scalarization of addition: Real + Integer[2,2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 869, column 6:
  Type error in expression
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayAdd9;


model ArrayAdd10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd10",
         description="Scalarization of addition: Real[2] + Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 910, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20, 30 };
end ArrayAdd10;


model ArrayAdd11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd11",
         description="Scalarization of addition: Real[2] + Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 929, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { { 10, 20 }, { 30, 40 } };
end ArrayAdd11;


model ArrayAdd12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAdd12",
         description="Scalarization of addition: Real[2] + String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 948, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { "1", "2" };
end ArrayAdd12;



model ArraySub1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArraySub1",
         description="Scalarization of subtraction: Real[2] - Integer[2]",
         flatModel="
fclass ArrayTests.ArraySub1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] - ( 10 );
 x[2] = y[2] - ( 20 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArraySub1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { 10, 20 };
end ArraySub1;


model ArraySub2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArraySub2",
         description="Scalarization of subtraction: Real[2,2] - Integer[2,2]",
         flatModel="
fclass ArrayTests.ArraySub2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] - ( 10 );
 x[1,2] = y[1,2] - ( 20 );
 x[2,1] = y[2,1] - ( 30 );
 x[2,2] = y[2,2] - ( 40 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArraySub2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y - { { 10, 20 }, { 30, 40 } };
end ArraySub2;


model ArraySub3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArraySub3",
         description="Scalarization of subtraction: Real[2,2,2] - Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArraySub3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] - ( 10 );
 x[1,1,2] = y[1,1,2] - ( 20 );
 x[1,2,1] = y[1,2,1] - ( 30 );
 x[1,2,2] = y[1,2,2] - ( 40 );
 x[2,1,1] = y[2,1,1] - ( 50 );
 x[2,1,2] = y[2,1,2] - ( 60 );
 x[2,2,1] = y[2,2,1] - ( 70 );
 x[2,2,2] = y[2,2,2] - ( 80 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArraySub3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y - { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArraySub3;


model ArraySub4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub4",
         description="Scalarization of subtraction: Real[2] - Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1078, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - 10;
end ArraySub4;


model ArraySub5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub5",
         description="Scalarization of subtraction: Real[2,2] - Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1097, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y - 10;
end ArraySub5;


model ArraySub6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub6",
         description="Scalarization of subtraction: Real[2,2,2] - Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1116, column 6:
  Type error in expression
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y - 10;
end ArraySub6;


model ArraySub7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub7",
         description="Scalarization of subtraction: Real - Integer[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1135, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y = 1;
equation
 x = y - { 10, 20 };
end ArraySub7;


model ArraySub8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub8",
         description="Scalarization of subtraction: Real - Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1154, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y - { { 10, 20 }, { 30, 40 } };
end ArraySub8;


model ArraySub9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub9",
         description="Scalarization of subtraction: Real - Integer[2,2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1173, column 6:
  Type error in expression
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y - { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArraySub9;


model ArraySub10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub10",
         description="Scalarization of subtraction: Real[2] - Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1192, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { 10, 20, 30 };
end ArraySub10;


model ArraySub11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub11",
         description="Scalarization of subtraction: Real[2] - Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1211, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { { 10, 20 }, { 30, 40 } };
end ArraySub11;


model ArraySub12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArraySub12",
         description="Scalarization of subtraction: Real[2] - String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1230, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { "1", "2" };
end ArraySub12;



model ArrayMulOK1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK1",
         description="Scalarization of multiplication: Real[3] * Integer[3]",
         flatModel="
fclass ArrayTests.ArrayMulOK1
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = ( y[1] ) * ( 10 ) + ( y[2] ) * ( 20 ) + ( y[3] ) * ( 30 );
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
end ArrayTests.ArrayMulOK1;
")})));

 Real x;
 Real y[3] = { 1, 2, 3 };
equation
 x = y * { 10, 20, 30 };
end ArrayMulOK1;


model ArrayMulOK2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK2",
         description="Scalarization of multiplication: Real[2,2] * Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayMulOK2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) * ( 10 ) + ( y[1,2] ) * ( 30 );
 x[1,2] = ( y[1,1] ) * ( 20 ) + ( y[1,2] ) * ( 40 );
 x[2,1] = ( y[2,1] ) * ( 10 ) + ( y[2,2] ) * ( 30 );
 x[2,2] = ( y[2,1] ) * ( 20 ) + ( y[2,2] ) * ( 40 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayMulOK2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 }, { 30, 40 } };
end ArrayMulOK2;


model ArrayMulOK3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK3",
         description="Scalarization of multiplication: Integer[3,2] * Real[2,4]",
         flatModel="
fclass ArrayTests.ArrayMulOK3
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[1,4];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[2,4];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
 Real x[3,4];
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[1,4];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 Real y[2,4];
equation
 x[1,1] = ( 10 ) * ( y[1,1] ) + ( 20 ) * ( y[2,1] );
 x[1,2] = ( 10 ) * ( y[1,2] ) + ( 20 ) * ( y[2,2] );
 x[1,3] = ( 10 ) * ( y[1,3] ) + ( 20 ) * ( y[2,3] );
 x[1,4] = ( 10 ) * ( y[1,4] ) + ( 20 ) * ( y[2,4] );
 x[2,1] = ( 30 ) * ( y[1,1] ) + ( 40 ) * ( y[2,1] );
 x[2,2] = ( 30 ) * ( y[1,2] ) + ( 40 ) * ( y[2,2] );
 x[2,3] = ( 30 ) * ( y[1,3] ) + ( 40 ) * ( y[2,3] );
 x[2,4] = ( 30 ) * ( y[1,4] ) + ( 40 ) * ( y[2,4] );
 x[3,1] = ( 50 ) * ( y[1,1] ) + ( 60 ) * ( y[2,1] );
 x[3,2] = ( 50 ) * ( y[1,2] ) + ( 60 ) * ( y[2,2] );
 x[3,3] = ( 50 ) * ( y[1,3] ) + ( 60 ) * ( y[2,3] );
 x[3,4] = ( 50 ) * ( y[1,4] ) + ( 60 ) * ( y[2,4] );
 y[1,1] = 1;
 y[1,2] = 2;
 y[1,3] = 3;
 y[1,4] = 4;
 y[2,1] = 5;
 y[2,2] = 6;
 y[2,3] = 7;
 y[2,4] = 8;
end ArrayTests.ArrayMulOK3;
")})));

 Real x[3,4];
 Real y[2,4] = { { 1, 2, 3, 4 }, { 5, 6, 7, 8 } };
equation
 x = { { 10, 20 }, { 30, 40 }, { 50, 60 } } * y;
end ArrayMulOK3;


model ArrayMulOK4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK4",
         description="Scalarization of multiplication: Real[2] * Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayMulOK4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) * ( 10 ) + ( y[2] ) * ( 30 );
 x[2] = ( y[1] ) * ( 20 ) + ( y[2] ) * ( 40 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayMulOK4;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { { 10, 20 }, { 30, 40 } };
end ArrayMulOK4;


model ArrayMulOK5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK5",
         description="Scalarization of multiplication: Real[2,2] * Integer[2]",
         flatModel="
fclass ArrayTests.ArrayMulOK5
 Real x[1];
 Real x[2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1] = ( y[1,1] ) * ( 10 ) + ( y[1,2] ) * ( 20 );
 x[2] = ( y[2,1] ) * ( 10 ) + ( y[2,2] ) * ( 20 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayMulOK5;
")})));

 Real x[2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { 10, 20 };
end ArrayMulOK5;


model ArrayMulOK6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK6",
         description="Scalarization of multiplication: Real[2] * Integer",
         flatModel="
fclass ArrayTests.ArrayMulOK6
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) * ( 10 );
 x[2] = ( y[2] ) * ( 10 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayMulOK6;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * 10;
end ArrayMulOK6;


model ArrayMulOK7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK7",
         description="Scalarization of multiplication: Real[2,2] * Integer",
         flatModel="
fclass ArrayTests.ArrayMulOK7
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) * ( 10 );
 x[1,2] = ( y[1,2] ) * ( 10 );
 x[2,1] = ( y[2,1] ) * ( 10 );
 x[2,2] = ( y[2,2] ) * ( 10 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayMulOK7;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * 10;
end ArrayMulOK7;


model ArrayMulOK8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK8",
         description="Scalarization of multiplication: Real[2,2,2] * Integer",
         flatModel="
fclass ArrayTests.ArrayMulOK8
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = ( y[1,1,1] ) * ( 10 );
 x[1,1,2] = ( y[1,1,2] ) * ( 10 );
 x[1,2,1] = ( y[1,2,1] ) * ( 10 );
 x[1,2,2] = ( y[1,2,2] ) * ( 10 );
 x[2,1,1] = ( y[2,1,1] ) * ( 10 );
 x[2,1,2] = ( y[2,1,2] ) * ( 10 );
 x[2,2,1] = ( y[2,2,1] ) * ( 10 );
 x[2,2,2] = ( y[2,2,2] ) * ( 10 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayMulOK8;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y * 10;
end ArrayMulOK8;


model ArrayMulOK9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK9",
         description="Scalarization of multiplication: Real * Integer[2]",
         flatModel="
fclass ArrayTests.ArrayMulOK9
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = ( y ) * ( 10 );
 x[2] = ( y ) * ( 20 );
 y = 1;
end ArrayTests.ArrayMulOK9;
")})));

 Real x[2];
 Real y = 1;
equation
 x = y * { 10, 20 };
end ArrayMulOK9;


model ArrayMulOK10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK10",
         description="Scalarization of multiplication: Real * Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayMulOK10
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y;
equation
 x[1,1] = ( y ) * ( 10 );
 x[1,2] = ( y ) * ( 20 );
 x[2,1] = ( y ) * ( 30 );
 x[2,2] = ( y ) * ( 40 );
 y = 1;
end ArrayTests.ArrayMulOK10;
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y * { { 10, 20 }, { 30, 40 } };
end ArrayMulOK10;


model ArrayMulOK11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK11",
         description="Scalarization of multiplication: Real * Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayMulOK11
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y;
equation
 x[1,1,1] = ( y ) * ( 10 );
 x[1,1,2] = ( y ) * ( 20 );
 x[1,2,1] = ( y ) * ( 30 );
 x[1,2,2] = ( y ) * ( 40 );
 x[2,1,1] = ( y ) * ( 50 );
 x[2,1,2] = ( y ) * ( 60 );
 x[2,2,1] = ( y ) * ( 70 );
 x[2,2,2] = ( y ) * ( 80 );
 y = 1;
end ArrayTests.ArrayMulOK11;
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y * { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayMulOK11;


model ArrayMulOK12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK12",
         description="Scalarization of multiplication: Real[2,2] * Integer[2,1]",
         flatModel="
fclass ArrayTests.ArrayMulOK12
 Real x[1,1];
 Real x[2,1];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) * ( 10 ) + ( y[1,2] ) * ( 20 );
 x[2,1] = ( y[2,1] ) * ( 10 ) + ( y[2,2] ) * ( 20 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayMulOK12;
")})));

 Real x[2,1];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10 }, { 20 } };
end ArrayMulOK12;


model ArrayMulErr1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr1",
         description="Scalarization of multiplication: Real[2,2,2] * Integer[2,2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1602, column 6:
  Type error in expression
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y * { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayMulErr1;


model ArrayMulErr2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr2",
         description="Scalarization of multiplication: Real[2] * Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1621, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { 10, 20, 30 };
end ArrayMulErr2;


model ArrayMulErr3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr3",
         description="Scalarization of multiplication: Real[2] * String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1640, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { "1", "2" };
end ArrayMulErr3;


model ArrayMulErr4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr4",
         description="Scalarization of multiplication: Real[2,2] * Integer[3,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1659, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 }, { 30, 40 }, { 50, 60 } };
end ArrayMulErr4;


model ArrayMulErr5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr5",
         description="Scalarization of multiplication: Real[2,3] * Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1678, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,3] = { { 1, 2, 3 }, { 4, 5, 6 } };
equation
 x = y * { { 10, 20 }, { 30, 40 } };
end ArrayMulErr5;


model ArrayMulErr6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr6",
         description="Scalarization of multiplication: Real[2,3] * Integer[2,3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1697, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,3] = { { 1, 2, 3 }, { 4, 5, 6 } };
equation
 x = y * { { 10, 20, 30 }, { 40, 50, 60 } };
end ArrayMulErr6;


model ArrayMulErr7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr7",
         description="Scalarization of multiplication: Real[2,2] * Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1716, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { 10, 20, 30 };
end ArrayMulErr7;


model ArrayMulErr8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr8",
         description="Scalarization of multiplication: Real[3] * Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1735, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[3] = { 1, 2, 3 };
equation
 x = y * { { 10, 20 }, { 30, 40 } };
end ArrayMulErr8;


model ArrayMulErr9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayMulErr9",
         description="Scalarization of multiplication: Real[2,2] * Integer[1,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1754, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 } };
end ArrayMulErr9;



model ArrayDiv1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDiv1",
         description="Scalarization of division: Real[2] / Integer[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1994, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / { 10, 20 };
end ArrayDiv1;


model ArrayDiv2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDiv2",
         description="Scalarization of division: Real[2,2] / Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2013, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y / { { 10, 20 }, { 30, 40 } };
end ArrayDiv2;


model ArrayDiv3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDiv3",
         description="Scalarization of division: Real[2] / Integer",
         flatModel="
fclass ArrayTests.ArrayDiv3
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) / ( 10 );
 x[2] = ( y[2] ) / ( 10 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDiv3;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / 10;
end ArrayDiv3;


model ArrayDiv4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDiv4",
         description="Scalarization of division: Real[2,2] / Integer",
         flatModel="
fclass ArrayTests.ArrayDiv4
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) / ( 10 );
 x[1,2] = ( y[1,2] ) / ( 10 );
 x[2,1] = ( y[2,1] ) / ( 10 );
 x[2,2] = ( y[2,2] ) / ( 10 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDiv4;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y / 10;
end ArrayDiv4;


model ArrayDiv5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDiv5",
         description="Scalarization of division: Real[2,2,2] / Integer",
         flatModel="
fclass ArrayTests.ArrayDiv5
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = ( y[1,1,1] ) / ( 10 );
 x[1,1,2] = ( y[1,1,2] ) / ( 10 );
 x[1,2,1] = ( y[1,2,1] ) / ( 10 );
 x[1,2,2] = ( y[1,2,2] ) / ( 10 );
 x[2,1,1] = ( y[2,1,1] ) / ( 10 );
 x[2,1,2] = ( y[2,1,2] ) / ( 10 );
 x[2,2,1] = ( y[2,2,1] ) / ( 10 );
 x[2,2,2] = ( y[2,2,2] ) / ( 10 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDiv5;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y / 10;
end ArrayDiv5;


model ArrayDiv6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDiv6",
         description="Scalarization of division: Real / Integer[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2056, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y = 1;
equation
 x = y / { 10, 20 };
end ArrayDiv6;


model ArrayDiv7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDiv7",
         description="Scalarization of division: Real / Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2075, column 6:
  Type error in expression
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y / { { 10, 20 }, { 30, 40 } };
end ArrayDiv7;


model ArrayDiv8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDiv8",
         description="Scalarization of division: Real[2] / String",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2094, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / "1";
end ArrayDiv8;



model ArrayDotAdd1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd1",
         description="Scalarization of element-wise addition: Real[2] .+ Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotAdd1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .+ 10;
 x[2] = y[2] .+ 20;
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotAdd1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { 10, 20 };
end ArrayDotAdd1;


model ArrayDotAdd2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd2",
         description="Scalarization of element-wise addition: Real[2,2] .+ Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotAdd2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] .+ 10;
 x[1,2] = y[1,2] .+ 20;
 x[2,1] = y[2,1] .+ 30;
 x[2,2] = y[2,2] .+ 40;
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotAdd2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };
end ArrayDotAdd2;


model ArrayDotAdd3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd3",
         description="Scalarization of element-wise addition: Real[2,2,2] .+ Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotAdd3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] .+ 10;
 x[1,1,2] = y[1,1,2] .+ 20;
 x[1,2,1] = y[1,2,1] .+ 30;
 x[1,2,2] = y[1,2,2] .+ 40;
 x[2,1,1] = y[2,1,1] .+ 50;
 x[2,1,2] = y[2,1,2] .+ 60;
 x[2,2,1] = y[2,2,1] .+ 70;
 x[2,2,2] = y[2,2,2] .+ 80;
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotAdd3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .+ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotAdd3;


model ArrayDotAdd4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd4",
         description="Scalarization of element-wise addition: Real[2] .+ Integer",
         flatModel="
fclass ArrayTests.ArrayDotAdd4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .+ 10;
 x[2] = y[2] .+ 10;
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotAdd4;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ 10;
end ArrayDotAdd4;


model ArrayDotAdd5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd5",
         description="Scalarization of element-wise addition: Real[2,2] .+ Integer",
         flatModel="
fclass ArrayTests.ArrayDotAdd5
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] .+ 10;
 x[1,2] = y[1,2] .+ 10;
 x[2,1] = y[2,1] .+ 10;
 x[2,2] = y[2,2] .+ 10;
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotAdd5;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .+ 10;
end ArrayDotAdd5;


model ArrayDotAdd6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd6",
         description="Scalarization of element-wise addition: Real[2,2,2] .+ Integer",
         flatModel="
fclass ArrayTests.ArrayDotAdd6
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] .+ 10;
 x[1,1,2] = y[1,1,2] .+ 10;
 x[1,2,1] = y[1,2,1] .+ 10;
 x[1,2,2] = y[1,2,2] .+ 10;
 x[2,1,1] = y[2,1,1] .+ 10;
 x[2,1,2] = y[2,1,2] .+ 10;
 x[2,2,1] = y[2,2,1] .+ 10;
 x[2,2,2] = y[2,2,2] .+ 10;
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotAdd6;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .+ 10;
end ArrayDotAdd6;


model ArrayDotAdd7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd7",
         description="Scalarization of element-wise addition: Real .+ Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotAdd7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = y .+ 10;
 x[2] = y .+ 20;
 y = 1;
end ArrayTests.ArrayDotAdd7;
")})));

 Real x[2];
 Real y = 1;
equation
 x = y .+ { 10, 20 };
end ArrayDotAdd7;


model ArrayDotAdd8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd8",
         description="Scalarization of element-wise addition: Real .+ Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotAdd8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y;
equation
 x[1,1] = y .+ 10;
 x[1,2] = y .+ 20;
 x[2,1] = y .+ 30;
 x[2,2] = y .+ 40;
 y = 1;
end ArrayTests.ArrayDotAdd8;
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };
end ArrayDotAdd8;


model ArrayDotAdd9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotAdd9",
         description="Scalarization of element-wise addition: Real .+ Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotAdd9
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y;
equation
 x[1,1,1] = y .+ 10;
 x[1,1,2] = y .+ 20;
 x[1,2,1] = y .+ 30;
 x[1,2,2] = y .+ 40;
 x[2,1,1] = y .+ 50;
 x[2,1,2] = y .+ 60;
 x[2,2,1] = y .+ 70;
 x[2,2,2] = y .+ 80;
 y = 1;
end ArrayTests.ArrayDotAdd9;
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y .+ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotAdd9;


model ArrayDotAdd10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotAdd10",
         description="Scalarization of element-wise addition: Real[2] .+ Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2508, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { 10, 20, 30 };
end ArrayDotAdd10;


model ArrayDotAdd11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotAdd11",
         description="Scalarization of element-wise addition: Real[2] .+ Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2527, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };
end ArrayDotAdd11;


model ArrayDotAdd12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotAdd12",
         description="Scalarization of element-wise addition: Real[2] .+ String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2546, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { "1", "2" };
end ArrayDotAdd12;



model ArrayDotSub1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub1",
         description="Scalarization of element-wise subtraction: Real[2] .- Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotSub1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .- ( 10 );
 x[2] = y[2] .- ( 20 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotSub1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { 10, 20 };
end ArrayDotSub1;


model ArrayDotSub2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub2",
         description="Scalarization of element-wise subtraction: Real[2,2] .- Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotSub2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] .- ( 10 );
 x[1,2] = y[1,2] .- ( 20 );
 x[2,1] = y[2,1] .- ( 30 );
 x[2,2] = y[2,2] .- ( 40 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotSub2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .- { { 10, 20 }, { 30, 40 } };
end ArrayDotSub2;


model ArrayDotSub3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub3",
         description="Scalarization of element-wise subtraction: Real[2,2,2] .- Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotSub3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] .- ( 10 );
 x[1,1,2] = y[1,1,2] .- ( 20 );
 x[1,2,1] = y[1,2,1] .- ( 30 );
 x[1,2,2] = y[1,2,2] .- ( 40 );
 x[2,1,1] = y[2,1,1] .- ( 50 );
 x[2,1,2] = y[2,1,2] .- ( 60 );
 x[2,2,1] = y[2,2,1] .- ( 70 );
 x[2,2,2] = y[2,2,2] .- ( 80 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotSub3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .- { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotSub3;


model ArrayDotSub4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub4",
         description="Scalarization of element-wise subtraction: Real[2] .- Integer",
         flatModel="
fclass ArrayTests.ArrayDotSub4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .- ( 10 );
 x[2] = y[2] .- ( 10 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotSub4;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- 10;
end ArrayDotSub4;


model ArrayDotSub5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub5",
         description="Scalarization of element-wise subtraction: Real[2,2] .- Integer",
         flatModel="
fclass ArrayTests.ArrayDotSub5
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] .- ( 10 );
 x[1,2] = y[1,2] .- ( 10 );
 x[2,1] = y[2,1] .- ( 10 );
 x[2,2] = y[2,2] .- ( 10 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotSub5;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .- 10;
end ArrayDotSub5;


model ArrayDotSub6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub6",
         description="Scalarization of element-wise subtraction: Real[2,2,2] .- Integer",
         flatModel="
fclass ArrayTests.ArrayDotSub6
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] .- ( 10 );
 x[1,1,2] = y[1,1,2] .- ( 10 );
 x[1,2,1] = y[1,2,1] .- ( 10 );
 x[1,2,2] = y[1,2,2] .- ( 10 );
 x[2,1,1] = y[2,1,1] .- ( 10 );
 x[2,1,2] = y[2,1,2] .- ( 10 );
 x[2,2,1] = y[2,2,1] .- ( 10 );
 x[2,2,2] = y[2,2,2] .- ( 10 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotSub6;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .- 10;
end ArrayDotSub6;


model ArrayDotSub7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub7",
         description="Scalarization of element-wise subtraction: Real .- Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotSub7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = y .- ( 10 );
 x[2] = y .- ( 20 );
 y = 1;
end ArrayTests.ArrayDotSub7;
")})));

 Real x[2];
 Real y = 1;
equation
 x = y .- { 10, 20 };
end ArrayDotSub7;


model ArrayDotSub8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub8",
         description="Scalarization of element-wise subtraction: Real .- Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotSub8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y;
equation
 x[1,1] = y .- ( 10 );
 x[1,2] = y .- ( 20 );
 x[2,1] = y .- ( 30 );
 x[2,2] = y .- ( 40 );
 y = 1;
end ArrayTests.ArrayDotSub8;
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y .- { { 10, 20 }, { 30, 40 } };
end ArrayDotSub8;


model ArrayDotSub9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotSub9",
         description="Scalarization of element-wise subtraction: Real .- Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotSub9
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y;
equation
 x[1,1,1] = y .- ( 10 );
 x[1,1,2] = y .- ( 20 );
 x[1,2,1] = y .- ( 30 );
 x[1,2,2] = y .- ( 40 );
 x[2,1,1] = y .- ( 50 );
 x[2,1,2] = y .- ( 60 );
 x[2,2,1] = y .- ( 70 );
 x[2,2,2] = y .- ( 80 );
 y = 1;
end ArrayTests.ArrayDotSub9;
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y .- { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotSub9;


model ArrayDotSub10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotSub10",
         description="Scalarization of element-wise subtraction: Real[2] .- Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2638, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { 10, 20, 30 };
end ArrayDotSub10;


model ArrayDotSub11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotSub11",
         description="Scalarization of element-wise subtraction: Real[2] .- Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2657, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { { 10, 20 }, { 30, 40 } };
end ArrayDotSub11;


model ArrayDotSub12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotSub12",
         description="Scalarization of element-wise subtraction: Real[2] .- String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2676, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { "1", "2" };
end ArrayDotSub12;



model ArrayDotMul1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul1",
         description="Scalarization of element-wise multiplication: Real[2] .* Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotMul1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) .* ( 10 );
 x[2] = ( y[2] ) .* ( 20 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotMul1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { 10, 20 };
end ArrayDotMul1;


model ArrayDotMul2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul2",
         description="Scalarization of element-wise multiplication: Real[2,2] .* Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotMul2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) .* ( 10 );
 x[1,2] = ( y[1,2] ) .* ( 20 );
 x[2,1] = ( y[2,1] ) .* ( 30 );
 x[2,2] = ( y[2,2] ) .* ( 40 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotMul2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .* { { 10, 20 }, { 30, 40 } };
end ArrayDotMul2;


model ArrayDotMul3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul3",
         description="Scalarization of element-wise multiplication: Real[2,2,2] .* Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotMul3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = ( y[1,1,1] ) .* ( 10 );
 x[1,1,2] = ( y[1,1,2] ) .* ( 20 );
 x[1,2,1] = ( y[1,2,1] ) .* ( 30 );
 x[1,2,2] = ( y[1,2,2] ) .* ( 40 );
 x[2,1,1] = ( y[2,1,1] ) .* ( 50 );
 x[2,1,2] = ( y[2,1,2] ) .* ( 60 );
 x[2,2,1] = ( y[2,2,1] ) .* ( 70 );
 x[2,2,2] = ( y[2,2,2] ) .* ( 80 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotMul3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .* { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotMul3;


model ArrayDotMul4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul4",
         description="Scalarization of element-wise multiplication: Real[2] .* Integer",
         flatModel="
fclass ArrayTests.ArrayDotMul4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) .* ( 10 );
 x[2] = ( y[2] ) .* ( 10 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotMul4;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* 10;
end ArrayDotMul4;


model ArrayDotMul5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul5",
         description="Scalarization of element-wise multiplication: Real[2,2] .* Integer",
         flatModel="
fclass ArrayTests.ArrayDotMul5
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) .* ( 10 );
 x[1,2] = ( y[1,2] ) .* ( 10 );
 x[2,1] = ( y[2,1] ) .* ( 10 );
 x[2,2] = ( y[2,2] ) .* ( 10 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotMul5;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .* 10;
end ArrayDotMul5;


model ArrayDotMul6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul6",
         description="Scalarization of element-wise multiplication: Real[2,2,2] .* Integer",
         flatModel="
fclass ArrayTests.ArrayDotMul6
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = ( y[1,1,1] ) .* ( 10 );
 x[1,1,2] = ( y[1,1,2] ) .* ( 10 );
 x[1,2,1] = ( y[1,2,1] ) .* ( 10 );
 x[1,2,2] = ( y[1,2,2] ) .* ( 10 );
 x[2,1,1] = ( y[2,1,1] ) .* ( 10 );
 x[2,1,2] = ( y[2,1,2] ) .* ( 10 );
 x[2,2,1] = ( y[2,2,1] ) .* ( 10 );
 x[2,2,2] = ( y[2,2,2] ) .* ( 10 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotMul6;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .* 10;
end ArrayDotMul6;


model ArrayDotMul7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul7",
         description="Scalarization of element-wise multiplication: Real .* Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotMul7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = ( y ) .* ( 10 );
 x[2] = ( y ) .* ( 20 );
 y = 1;
end ArrayTests.ArrayDotMul7;
")})));

 Real x[2];
 Real y = 1;
equation
 x = y .* { 10, 20 };
end ArrayDotMul7;


model ArrayDotMul8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul8",
         description="Scalarization of element-wise multiplication: Real .* Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotMul8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y;
equation
 x[1,1] = ( y ) .* ( 10 );
 x[1,2] = ( y ) .* ( 20 );
 x[2,1] = ( y ) .* ( 30 );
 x[2,2] = ( y ) .* ( 40 );
 y = 1;
end ArrayTests.ArrayDotMul8;
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y .* { { 10, 20 }, { 30, 40 } };
end ArrayDotMul8;


model ArrayDotMul9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotMul9",
         description="Scalarization of element-wise multiplication: Real .* Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotMul9
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y;
equation
 x[1,1,1] = ( y ) .* ( 10 );
 x[1,1,2] = ( y ) .* ( 20 );
 x[1,2,1] = ( y ) .* ( 30 );
 x[1,2,2] = ( y ) .* ( 40 );
 x[2,1,1] = ( y ) .* ( 50 );
 x[2,1,2] = ( y ) .* ( 60 );
 x[2,2,1] = ( y ) .* ( 70 );
 x[2,2,2] = ( y ) .* ( 80 );
 y = 1;
end ArrayTests.ArrayDotMul9;
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y .* { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotMul9;


model ArrayDotMul10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotMul10",
         description="Scalarization of element-wise multiplication: Real[2] .* Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2638, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { 10, 20, 30 };
end ArrayDotMul10;


model ArrayDotMul11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotMul11",
         description="Scalarization of element-wise multiplication: Real[2] .* Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2657, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { { 10, 20 }, { 30, 40 } };
end ArrayDotMul11;


model ArrayDotMul12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotMul12",
         description="Scalarization of element-wise multiplication: Real[2] .* String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2676, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { "1", "2" };
end ArrayDotMul12;



model ArrayDotDiv1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv1",
         description="Scalarization of element-wise division: Real[2] ./ Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotDiv1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) ./ ( 10 );
 x[2] = ( y[2] ) ./ ( 20 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotDiv1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { 10, 20 };
end ArrayDotDiv1;


model ArrayDotDiv2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv2",
         description="Scalarization of element-wise division: Real[2,2] ./ Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotDiv2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) ./ ( 10 );
 x[1,2] = ( y[1,2] ) ./ ( 20 );
 x[2,1] = ( y[2,1] ) ./ ( 30 );
 x[2,2] = ( y[2,2] ) ./ ( 40 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotDiv2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };
end ArrayDotDiv2;


model ArrayDotDiv3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv3",
         description="Scalarization of element-wise division: Real[2,2,2] ./ Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotDiv3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = ( y[1,1,1] ) ./ ( 10 );
 x[1,1,2] = ( y[1,1,2] ) ./ ( 20 );
 x[1,2,1] = ( y[1,2,1] ) ./ ( 30 );
 x[1,2,2] = ( y[1,2,2] ) ./ ( 40 );
 x[2,1,1] = ( y[2,1,1] ) ./ ( 50 );
 x[2,1,2] = ( y[2,1,2] ) ./ ( 60 );
 x[2,2,1] = ( y[2,2,1] ) ./ ( 70 );
 x[2,2,2] = ( y[2,2,2] ) ./ ( 80 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotDiv3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y ./ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotDiv3;


model ArrayDotDiv4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv4",
         description="Scalarization of element-wise division: Real[2] ./ Integer",
         flatModel="
fclass ArrayTests.ArrayDotDiv4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) ./ ( 10 );
 x[2] = ( y[2] ) ./ ( 10 );
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotDiv4;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ 10;
end ArrayDotDiv4;


model ArrayDotDiv5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv5",
         description="Scalarization of element-wise division: Real[2,2] ./ Integer",
         flatModel="
fclass ArrayTests.ArrayDotDiv5
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) ./ ( 10 );
 x[1,2] = ( y[1,2] ) ./ ( 10 );
 x[2,1] = ( y[2,1] ) ./ ( 10 );
 x[2,2] = ( y[2,2] ) ./ ( 10 );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotDiv5;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y ./ 10;
end ArrayDotDiv5;


model ArrayDotDiv6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv6",
         description="Scalarization of element-wise division: Real[2,2,2] ./ Integer",
         flatModel="
fclass ArrayTests.ArrayDotDiv6
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = ( y[1,1,1] ) ./ ( 10 );
 x[1,1,2] = ( y[1,1,2] ) ./ ( 10 );
 x[1,2,1] = ( y[1,2,1] ) ./ ( 10 );
 x[1,2,2] = ( y[1,2,2] ) ./ ( 10 );
 x[2,1,1] = ( y[2,1,1] ) ./ ( 10 );
 x[2,1,2] = ( y[2,1,2] ) ./ ( 10 );
 x[2,2,1] = ( y[2,2,1] ) ./ ( 10 );
 x[2,2,2] = ( y[2,2,2] ) ./ ( 10 );
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotDiv6;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y ./ 10;
end ArrayDotDiv6;


model ArrayDotDiv7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv7",
         description="Scalarization of element-wise division: Real ./ Integer[2]",
         flatModel="
fclass ArrayTests.ArrayDotDiv7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = ( y ) ./ ( 10 );
 x[2] = ( y ) ./ ( 20 );
 y = 1;
end ArrayTests.ArrayDotDiv7;
")})));

 Real x[2];
 Real y = 1;
equation
 x = y ./ { 10, 20 };
end ArrayDotDiv7;


model ArrayDotDiv8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv8",
         description="Scalarization of element-wise division: Real ./ Integer[2,2]",
         flatModel="
fclass ArrayTests.ArrayDotDiv8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y;
equation
 x[1,1] = ( y ) ./ ( 10 );
 x[1,2] = ( y ) ./ ( 20 );
 x[2,1] = ( y ) ./ ( 30 );
 x[2,2] = ( y ) ./ ( 40 );
 y = 1;
end ArrayTests.ArrayDotDiv8;
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };
end ArrayDotDiv8;


model ArrayDotDiv9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotDiv9",
         description="Scalarization of element-wise division: Real ./ Integer[2,2,2]",
         flatModel="
fclass ArrayTests.ArrayDotDiv9
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y;
equation
 x[1,1,1] = ( y ) ./ ( 10 );
 x[1,1,2] = ( y ) ./ ( 20 );
 x[1,2,1] = ( y ) ./ ( 30 );
 x[1,2,2] = ( y ) ./ ( 40 );
 x[2,1,1] = ( y ) ./ ( 50 );
 x[2,1,2] = ( y ) ./ ( 60 );
 x[2,2,1] = ( y ) ./ ( 70 );
 x[2,2,2] = ( y ) ./ ( 80 );
 y = 1;
end ArrayTests.ArrayDotDiv9;
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y ./ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotDiv9;


model ArrayDotDiv10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotDiv10",
         description="Scalarization of element-wise division: Real[2] ./ Integer[3]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2638, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { 10, 20, 30 };
end ArrayDotDiv10;


model ArrayDotDiv11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotDiv11",
         description="Scalarization of element-wise division: Real[2] ./ Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2657, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };
end ArrayDotDiv11;


model ArrayDotDiv12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotDiv12",
         description="Scalarization of element-wise division: Real[2] ./ String[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2676, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { "1", "2" };
end ArrayDotDiv12;



model ArrayDotPow1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow1",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .^ 10;
 x[2] = y[2] .^ 20;
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotPow1;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { 10, 20 };
end ArrayDotPow1;


model ArrayDotPow2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow2",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] .^ 10;
 x[1,2] = y[1,2] .^ 20;
 x[2,1] = y[2,1] .^ 30;
 x[2,2] = y[2,2] .^ 40;
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotPow2;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };
end ArrayDotPow2;


model ArrayDotPow3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow3",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow3
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] .^ 10;
 x[1,1,2] = y[1,1,2] .^ 20;
 x[1,2,1] = y[1,2,1] .^ 30;
 x[1,2,2] = y[1,2,2] .^ 40;
 x[2,1,1] = y[2,1,1] .^ 50;
 x[2,1,2] = y[2,1,2] .^ 60;
 x[2,2,1] = y[2,2,1] .^ 70;
 x[2,2,2] = y[2,2,2] .^ 80;
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotPow3;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .^ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotPow3;


model ArrayDotPow4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow4",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .^ 10;
 x[2] = y[2] .^ 10;
 y[1] = 1;
 y[2] = 2;
end ArrayTests.ArrayDotPow4;
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ 10;
end ArrayDotPow4;


model ArrayDotPow5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow5",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow5
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = y[1,1] .^ 10;
 x[1,2] = y[1,2] .^ 10;
 x[2,1] = y[2,1] .^ 10;
 x[2,2] = y[2,2] .^ 10;
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayDotPow5;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .^ 10;
end ArrayDotPow5;


model ArrayDotPow6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow6",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow6
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
equation
 x[1,1,1] = y[1,1,1] .^ 10;
 x[1,1,2] = y[1,1,2] .^ 10;
 x[1,2,1] = y[1,2,1] .^ 10;
 x[1,2,2] = y[1,2,2] .^ 10;
 x[2,1,1] = y[2,1,1] .^ 10;
 x[2,1,2] = y[2,1,2] .^ 10;
 x[2,2,1] = y[2,2,1] .^ 10;
 x[2,2,2] = y[2,2,2] .^ 10;
 y[1,1,1] = 1;
 y[1,1,2] = 2;
 y[1,2,1] = 3;
 y[1,2,2] = 4;
 y[2,1,1] = 5;
 y[2,1,2] = 6;
 y[2,2,1] = 7;
 y[2,2,2] = 8;
end ArrayTests.ArrayDotPow6;
")})));

 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .^ 10;
end ArrayDotPow6;


model ArrayDotPow7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow7",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = y .^ 10;
 x[2] = y .^ 20;
 y = 1;
end ArrayTests.ArrayDotPow7;
")})));

 Real x[2];
 Real y = 1;
equation
 x = y .^ { 10, 20 };
end ArrayDotPow7;


model ArrayDotPow8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow8",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y;
equation
 x[1,1] = y .^ 10;
 x[1,2] = y .^ 20;
 x[2,1] = y .^ 30;
 x[2,2] = y .^ 40;
 y = 1;
end ArrayTests.ArrayDotPow8;
")})));

 Real x[2,2];
 Real y = 1;
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };
end ArrayDotPow8;


model ArrayDotPow9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayDotPow9",
         description="Scalarization of element-wise exponentiation:",
         flatModel="
fclass ArrayTests.ArrayDotPow9
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y;
equation
 x[1,1,1] = y .^ 10;
 x[1,1,2] = y .^ 20;
 x[1,2,1] = y .^ 30;
 x[1,2,2] = y .^ 40;
 x[2,1,1] = y .^ 50;
 x[2,1,2] = y .^ 60;
 x[2,2,1] = y .^ 70;
 x[2,2,2] = y .^ 80;
 y = 1;
end ArrayTests.ArrayDotPow9;
")})));

 Real x[2,2,2];
 Real y = 1;
equation
 x = y .^ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayDotPow9;


model ArrayDotPow10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotPow10",
         description="Scalarization of element-wise exponentiation:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 3972, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { 10, 20, 30 };
end ArrayDotPow10;


model ArrayDotPow11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotPow11",
         description="Scalarization of element-wise exponentiation:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 3991, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };
end ArrayDotPow11;


model ArrayDotPow12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayDotPow12",
         description="Scalarization of element-wise exponentiation:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4010, column 6:
  Type error in expression
")})));

 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { "1", "2" };
end ArrayDotPow12;



/* -- Standard test series for scalarisation of operators on arrays -- */
/* 
model ArrayAdd1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20 };
end ArrayAdd1;


model ArrayAdd2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + { { 10, 20 }, { 30, 40 } };
end ArrayAdd2;


model ArrayAdd3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayAdd3;


model ArrayAdd4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + 10;
end ArrayAdd4;


model ArrayAdd5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + 10;
end ArrayAdd5;


model ArrayAdd6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + 10;
end ArrayAdd6;


model ArrayAdd7
 Real x[2];
 Real y = 1;
equation
 x = y + { 10, 20 };
end ArrayAdd7;


model ArrayAdd8
 Real x[2,2];
 Real y = 1;
equation
 x = y + { { 10, 20 }, { 30, 40 } };
end ArrayAdd8;


model ArrayAdd9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };
end ArrayAdd9;


model ArrayAdd10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20, 30 };
end ArrayAdd10;


model ArrayAdd11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { { 10, 20 }, { 30, 40 } };
end ArrayAdd11;


model ArrayAdd12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { "1", "2" };
end ArrayAdd12;
*/

  annotation (uses(Modelica(version="3.0.1")));
end ArrayTests;
