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
 Real x[2];
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
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [3, 1]
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
  Array size mismatch for the attribute start, size of declaration is [3] and size of start expression is [2]
")})));

   Real x[3](start={1,2});
equation
   der(x) = ones(3);
end ArrayTest27_Err;


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

model ArrayTest31
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest31",
        description="Flattening of arrays.",
                                               flatModel=
"fclass ArrayTests.ArrayTest31
 Real x[1];
 Real x[2];
equation
 x[1] = sin(time);
 x[2] = cos(time);
end ArrayTests.ArrayTest31;
")})));

  Real x[2];
equation
 x = {sin(time),cos(time)};
end ArrayTest31;

model ArrayTest32
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayTest32",
         description="Scalarization of initial equation",
         flatModel="
fclass ArrayTests.ArrayTest32
 Real x[1];
 Real x[2];
initial equation 
 x[1] = 1;
 x[2] =  - ( 2 );
equation
 der(x[1]) =  - ( x[1] );
 der(x[2]) =  - ( x[2] );
end ArrayTests.ArrayTest32;
")})));

 Real x[2];
initial equation
 x = {1,-2};
equation
 der(x) = -x;
end ArrayTest32;


model ArrayTest33
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ArrayTest33",
         description="Equations in array components",
         flatModel="
fclass ArrayTests.ArrayTest33
 Real c[1].x;
 Real c[2].x;
 Real c[3].x;
equation
 c[1].x = 1;
 c[2].x = 1;
 c[3].x = 1;
end ArrayTests.ArrayTest33;
")})));

  model C
	Real x;
  equation
    x = 1;
  end C;
  
  C c[3];
end ArrayTest33;


model ArrayTest34
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ArrayTest34",
         description="Equations in array components",
         flatModel="
fclass ArrayTests.ArrayTest34
 Real a[1].b[1].x;
 Real a[1].b[1].c[1].x;
 Real a[1].b[1].c[2].x;
 Real a[1].b[2].x;
 Real a[1].b[2].c[1].x;
 Real a[1].b[2].c[2].x;
 Real a[2].b[1].x;
 Real a[2].b[1].c[1].x;
 Real a[2].b[1].c[2].x;
 Real a[2].b[2].x;
 Real a[2].b[2].c[1].x;
 Real a[2].b[2].c[2].x;
equation
 a[1].b[1].x = a[1].b[1].c[1].x;
 a[1].b[1].c[1].x = 1;
 a[1].b[1].c[2].x = 1;
 a[1].b[2].x = a[1].b[2].c[1].x;
 a[1].b[2].c[1].x = 1;
 a[1].b[2].c[2].x = 1;
 a[2].b[1].x = a[2].b[1].c[1].x;
 a[2].b[1].c[1].x = 1;
 a[2].b[1].c[2].x = 1;
 a[2].b[2].x = a[2].b[2].c[1].x;
 a[2].b[2].c[1].x = 1;
 a[2].b[2].c[2].x = 1;
end ArrayTests.ArrayTest34;
")})));

  model A
    B b[2];
  end A;
  
  model B
    Real x;
    C c[2];
  equation
    x = c[1].x;
  end B;
  
  model C
	Real x;
  equation
    x = 1;
  end C;
  
  A a[2];
end ArrayTest34;




model UnknownSize1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownSize1",
         description="Using unknown array sizes: deciding with binding exp",
         flatModel="
fclass ArrayTests.UnknownSize1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
end ArrayTests.UnknownSize1;
")})));

 Real x[:,:] = {{1,2},{3,4}};
end UnknownSize1;


model UnknownSize2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownSize2",
         description="Using unknown array sizes: binding exp through modification on array",
         flatModel="
fclass ArrayTests.UnknownSize2
 Real x[1].y[1].z[1];
 Real x[1].y[1].z[2];
 Real x[1].y[2].z[1];
 Real x[1].y[2].z[2];
 Real x[2].y[1].z[1];
 Real x[2].y[1].z[2];
 Real x[2].y[2].z[1];
 Real x[2].y[2].z[2];
equation
 x[1].y[1].z[1] = 1;
 x[1].y[1].z[2] = 2;
 x[1].y[2].z[1] = 3;
 x[1].y[2].z[2] = 4;
 x[2].y[1].z[1] = 1;
 x[2].y[1].z[2] = 2;
 x[2].y[2].z[1] = 3;
 x[2].y[2].z[2] = 4;
end ArrayTests.UnknownSize2;
")})));

 model A
  Real z[:];
 end A;
 
 model B
  A y[2](z={{1,2},{3,4}});
 end B;
 
 B x[2];
end UnknownSize2;


model UnknownSize3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownSize3",
         description="Using unknown array sizes: one dim known, one unknown",
         flatModel="
fclass ArrayTests.UnknownSize3
 Real x[1,1];
 Real x[1,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
end ArrayTests.UnknownSize3;
")})));

 Real x[1,:] = {{1,2}};
end UnknownSize3;


model UnknownSize4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownSize4",
         description="Using unknown array sizes: too few dims",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 789, column 7:
  Array size mismatch in declaration of x, size of declaration is [1, :] and size of binding expression is [2]
")})));

 Real x[1,:] = {1,2};
end UnknownSize4;


model UnknownSize5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownSize5",
         description="Using unknown array sizes: one dim specified and does not match",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 805, column 7:
  Array size mismatch in declaration of x, size of declaration is [1, 2] and size of binding expression is [2, 2]
")})));

 Real x[1,:] = {{1,2},{3,4}};
end UnknownSize5;


model UnknownSize6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownSize6",
         description="Using unknown array sizes:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 823, column 2:
  The right and left expression types of equation are not compatible
")})));

 Real x[:,:];
equation
 x = {{1,2},{3,4}};
end UnknownSize6;



model SizeExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExp1",
         description="Size operator: first dim",
         flatModel="
fclass ArrayTests.SizeExp1
 Real x;
equation
 x = 2;
end ArrayTests.SizeExp1;
")})));

 Real x = size(ones(2), 1);
end SizeExp1;


model SizeExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExp2",
         description="Size operator: second dim",
         flatModel="
fclass ArrayTests.SizeExp2
 Real x;
equation
 x = 3;
end ArrayTests.SizeExp2;
")})));

 Real x = size(ones(2, 3), 2);
end SizeExp2;


model SizeExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExp3",
         description="Size operator: without dim",
         flatModel="
fclass ArrayTests.SizeExp3
 Real x[1];
equation
 x[1] = 2;
end ArrayTests.SizeExp3;
")})));

 Real x[1] = size(ones(2));
end SizeExp3;


model SizeExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExp4",
         description="Size operator: without dim",
         flatModel="
fclass ArrayTests.SizeExp4
 Real x[1];
 Real x[2];
equation
 x[1] = 2;
 x[2] = 3;
end ArrayTests.SizeExp4;
")})));

 Real x[2] = size(ones(2, 3));
end SizeExp4;


model SizeExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExp5",
         description="Size operator: using parameter",
         flatModel="
fclass ArrayTests.SizeExp5
 parameter Integer p = 1 /* 1 */;
 Real x;
equation
 x = 2;
end ArrayTests.SizeExp5;
")})));

 parameter Integer p = 1;
 Real x = size(ones(2, 3), p);
end SizeExp5;


model SizeExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExp6",
         description="Size operator: too high variability of dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 793, column 11:
  Type error in expression
")})));

 Integer d = 1;
 Real x = size(ones(2, 3), d);
end SizeExp6;


model SizeExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExp7",
         description="Size operator: array as dim",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 809, column 11:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 809, column 28:
  Calling function size(): types of positional argument 2 and input d are not compatible
")})));

 Real x = size(ones(2, 3), {1, 2});
end SizeExp7;


model SizeExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExp8",
         description="Size operator: Real as dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 828, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 1.0);
end SizeExp8;


model SizeExp9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExp9",
         description="Size operator: too low dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 844, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 0);
end SizeExp9;


model SizeExp10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExp10",
         description="Size operator: too high dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 860, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 3);
end SizeExp10;



model FillExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="FillExp1",
         description="Fill operator: one dim",
         flatModel="
fclass ArrayTests.FillExp1
 Real x[1];
 Real x[2];
equation
 x[1] = 1 + 2;
 x[2] = 1 + 2;
end ArrayTests.FillExp1;
")})));

 Real x[2] = fill(1 + 2, 2);
end FillExp1;


model FillExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="FillExp2",
         description="Fill operator: three dims",
         flatModel="
fclass ArrayTests.FillExp2
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,1,3];
 Real x[1,1,4];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[1,2,3];
 Real x[1,2,4];
 Real x[1,3,1];
 Real x[1,3,2];
 Real x[1,3,3];
 Real x[1,3,4];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,1,3];
 Real x[2,1,4];
 Real x[2,2,1];
 Real x[2,2,2];
 Real x[2,2,3];
 Real x[2,2,4];
 Real x[2,3,1];
 Real x[2,3,2];
 Real x[2,3,3];
 Real x[2,3,4];
equation
 x[1,1,1] = 1 + 2;
 x[1,1,2] = 1 + 2;
 x[1,1,3] = 1 + 2;
 x[1,1,4] = 1 + 2;
 x[1,2,1] = 1 + 2;
 x[1,2,2] = 1 + 2;
 x[1,2,3] = 1 + 2;
 x[1,2,4] = 1 + 2;
 x[1,3,1] = 1 + 2;
 x[1,3,2] = 1 + 2;
 x[1,3,3] = 1 + 2;
 x[1,3,4] = 1 + 2;
 x[2,1,1] = 1 + 2;
 x[2,1,2] = 1 + 2;
 x[2,1,3] = 1 + 2;
 x[2,1,4] = 1 + 2;
 x[2,2,1] = 1 + 2;
 x[2,2,2] = 1 + 2;
 x[2,2,3] = 1 + 2;
 x[2,2,4] = 1 + 2;
 x[2,3,1] = 1 + 2;
 x[2,3,2] = 1 + 2;
 x[2,3,3] = 1 + 2;
 x[2,3,4] = 1 + 2;
end ArrayTests.FillExp2;
")})));

 Real x[2,3,4] = fill(1 + 2, 2, 3, 4);
end FillExp2;


model FillExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="FillExp3",
         description="Fill operator: no size args",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 892, column 11:
  Too few arguments to fill(), must have at least 2
")})));

 Real x = fill(1 + 2);
end FillExp3;


model FillExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="FillExp4",
         description="Fill operator:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 897, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [3]
")})));

 Real x[2] = fill(1 + 2, 3);
end FillExp4;


model FillExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="FillExp5",
         description="Fill operator: Real size arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 897, column 26:
  Argument of fill() is not compatible with Integer: 2.0
")})));

 Real x[2] = fill(1 + 2, 2.0);
end FillExp5;


model FillExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="FillExp6",
         description="Fill operator: too high variability of size arg",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1145, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [n]
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1145, column 26:
  Argument of fill() does not have constant or parameter variability: n
")})));

 Integer n = 2;
 Real x[2] = fill(1 + 2, n);
end FillExp6;


model FillExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="FillExp7",
         description="Fill operator: no arguments at all",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1029, column 14:
  Calling function fill(): missing argument for required input s
")})));

 Real x[2] = fill();
end FillExp7;


model FillExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="FillExp8",
         description="Fill operator: filling with array",
         flatModel="
fclass ArrayTests.FillExp8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 1;
 x[2,2] = 2;
 x[3,1] = 1;
 x[3,2] = 2;
end ArrayTests.FillExp8;
")})));

 Real x[3,2] = fill({1,2}, 3);
end FillExp8;
 


model MinExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinExp1",
         description="Min operator: 2 scalar args",
         flatModel="
fclass ArrayTests.MinExp1
 constant Real x = min(1 + 2, 3 + 4);
 Real y;
equation
 y = 3.0;
end ArrayTests.MinExp1;
")})));

 constant Real x = min(1+2, 3+4);
 Real y = x;
end MinExp1;


model MinExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinExp2",
         description="Min operator: 1 array arg",
         flatModel="
fclass ArrayTests.MinExp2
 constant Real x = min(min(min(1, 2), 3), 4);
 Real y;
equation
 y = 1.0;
end ArrayTests.MinExp2;
")})));

 constant Real x = min({{1,2},{3,4}});
 Real y = x;
end MinExp2;


model MinExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinExp3",
         description="Min operator: strings",
         flatModel="
fclass ArrayTests.MinExp3
 constant String x = min(\"foo\", \"bar\");
 String y;
equation
 y = \"bar\";
end ArrayTests.MinExp3;
")})));

 constant String x = min("foo", "bar");
 String y = x;
end MinExp3;


model MinExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinExp4",
         description="Min operator: booleans",
         flatModel="
fclass ArrayTests.MinExp4
 constant Boolean x = min(true, false);
 Boolean y;
equation
 y = false;
end ArrayTests.MinExp4;
")})));

 constant Boolean x = min(true, false);
 Boolean y = x;
end MinExp4;


model MinExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MinExp5",
         description="Min operator: mixed types",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 958, column 11:
  Type error in expression
")})));

 Real x = min(true, 0);
end MinExp5;


model MinExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MinExp6",
         description="Min operator: 2 array args",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 974, column 15:
  Calling function min(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 974, column 22:
  Calling function min(): types of positional argument 2 and input y are not compatible
")})));

 Real x = min({1,2}, {3,4});
end MinExp6;


model MinExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MinExp7",
         description="Min operator: 1 scalar arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 993, column 15:
  Calling function min(): types of positional argument 1 and input x are not compatible
")})));

 Real x = min(1);
end MinExp7;


model MinExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinExp8",
         description="Reduction-expression with min(): constant expression",
         flatModel="
fclass ArrayTests.MinExp8
 constant Real x = min(min(min(min(min(min(min(min(min(min(min(1.0, 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0);
 Real y;
equation
 y = 1.0;
end ArrayTests.MinExp8;
")})));

 constant Real x = min(1.0 for i in 1:4, j in {2,3,5});
 Real y = x;
end MinExp8;


model MinExp9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinExp9",
         description="Reduction-expression with min(): basic test",
         flatModel="
fclass ArrayTests.MinExp9
 Real x;
equation
 x = min(min(min(min(min(min(min(min(( 1 ) * ( 2 ), ( 1 ) * ( 3 )), ( 1 ) * ( 5 )), ( 2 ) * ( 2 )), ( 2 ) * ( 3 )), ( 2 ) * ( 5 )), ( 3 ) * ( 2 )), ( 3 ) * ( 3 )), ( 3 ) * ( 5 ));
end ArrayTests.MinExp9;
")})));

 Real x = min(i * j for i in 1:3, j in {2,3,5});
end MinExp9;


model MinExp10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MinExp10",
         description="Reduction-expression with min(): non-vector index expressions",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1183, column 25:
  The expression of for index i must be a vector expression: {{1,2},{3,4}} has 2 dimension(s)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1183, column 45:
  The expression of for index j must be a vector expression: 2 has 0 dimension(s)
")})));

 Real x = min(i * j for i in {{1,2},{3,4}}, j in 2);
end MinExp10;


model MinExp11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MinExp11",
         description="Reduction-expression with min(): non-scalar expression",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1188, column 11:
  The expression of a reduction-expression must be scalar, except for sum(): {( i ) * ( j ),2} has 1 dimension(s)
")})));

 Real x = min({i * j, 2} for i in 1:4, j in 2:5);
end MinExp11;


model MinExp12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MinExp12",
         description="Reduction-expression with min(): wrong type in expression",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1193, column 7:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Real x = min(false for i in 1:4, j in 2:5);
end MinExp12;



model MaxExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MaxExp1",
         description="Max operator: 2 scalar args",
         flatModel="
fclass ArrayTests.MaxExp1
 constant Real x = max(1 + 2, 3 + 4);
 Real y;
equation
 y = 7.0;
end ArrayTests.MaxExp1;
")})));

 constant Real x = max(1+2, 3+4);
 Real y = x;
end MaxExp1;


model MaxExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MaxExp2",
         description="Max operator: 1 array arg",
         flatModel="
fclass ArrayTests.MaxExp2
 constant Real x = max(max(max(1, 2), 3), 4);
 Real y;
equation
 y = 4.0;
end ArrayTests.MaxExp2;
")})));

 constant Real x = max({{1,2},{3,4}});
 Real y = x;
end MaxExp2;


model MaxExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MaxExp3",
         description="Max operator: strings",
         flatModel="
fclass ArrayTests.MaxExp3
 constant String x = max(\"foo\", \"bar\");
 String y;
equation
 y = \"foo\";
end ArrayTests.MaxExp3;
")})));

 constant String x = max("foo", "bar");
 String y = x;
end MaxExp3;


model MaxExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MaxExp4",
         description="Max operator: booleans",
         flatModel="
fclass ArrayTests.MaxExp4
 constant Boolean x = max(true, false);
 Boolean y;
equation
 y = true;
end ArrayTests.MaxExp4;
")})));

 constant Boolean x = max(true, false);
 Boolean y = x;
end MaxExp4;


model MaxExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MaxExp5",
         description="Max operator: mixed types",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 958, column 11:
  Type error in expression
")})));

 Real x = max(true, 0);
end MaxExp5;


model MaxExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MaxExp6",
         description="Max operator: 2 array args",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 974, column 15:
  Calling function max(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 974, column 22:
  Calling function max(): types of positional argument 2 and input y are not compatible
")})));

 Real x = max({1,2}, {3,4});
end MaxExp6;


model MaxExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MaxExp7",
         description="Max operator: 1 scalar arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 993, column 15:
  Calling function max(): types of positional argument 1 and input x are not compatible
")})));

 Real x = max(1);
end MaxExp7;


model MaxExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MaxExp8",
         description="Reduction-expression with max(): constant expression",
         flatModel="
fclass ArrayTests.MaxExp8
 Real x;
equation
 x = max(max(max(max(max(max(max(max(max(max(max(1.0, 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0);
end ArrayTests.MaxExp8;
")})));

 Real x = max(1.0 for i in 1:4, j in {2,3,5});
end MaxExp8;


model MaxExp9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MaxExp9",
         description="Reduction-expression with max(): basic test",
         flatModel="
fclass ArrayTests.MaxExp9
 constant Real x = max(max(max(max(max(max(max(max(max(max(max(( 1 ) * ( 2 ), ( 1 ) * ( 3 )), ( 1 ) * ( 5 )), ( 2 ) * ( 2 )), ( 2 ) * ( 3 )), ( 2 ) * ( 5 )), ( 3 ) * ( 2 )), ( 3 ) * ( 3 )), ( 3 ) * ( 5 )), ( 4 ) * ( 2 )), ( 4 ) * ( 3 )), ( 4 ) * ( 5 ));
 Real y;
equation
 y = 20.0;
end ArrayTests.MaxExp9;
")})));

 constant Real x = max(i * j for i in 1:4, j in {2,3,5});
 Real y = x;
end MaxExp9;


model MaxExp10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MaxExp10",
         description="Reduction-expression with max(): non-vector index expressions",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1424, column 25:
  The expression of for index i must be a vector expression: {{1,2},{3,4}} has 2 dimension(s)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1424, column 45:
  The expression of for index j must be a vector expression: 2 has 0 dimension(s)
")})));

 Real x = max(i * j for i in {{1,2},{3,4}}, j in 2);
end MaxExp10;


model MaxExp11
 Real x = max({i * j, 2} for i in 1:4, j in 2:5);
end MaxExp11;


model MaxExp12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="MaxExp12",
         description="Reduction-expression with max(): wrong type in expression",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1462, column 7:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Real x = max(false for i in 1:4, j in 2:5);
end MaxExp12;



model SumExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SumExp1",
         description="sum() expressions: basic test",
         flatModel="
fclass ArrayTests.SumExp1
 constant Real x = 1 + 2 + 3 + 4;
 Real y;
equation
 y = 10.0;
end ArrayTests.SumExp1;
")})));

 constant Real x = sum({1,2,3,4});
 Real y = x;
end SumExp1;


model SumExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SumExp2",
         description="sum() expressions: reduction-expression",
         flatModel="
fclass ArrayTests.SumExp2
 constant Real x = ( 1 ) * ( 1 ) + ( 1 ) * ( 2 ) + ( 1 ) * ( 3 ) + ( 2 ) * ( 1 ) + ( 2 ) * ( 2 ) + ( 2 ) * ( 3 ) + ( 3 ) * ( 1 ) + ( 3 ) * ( 2 ) + ( 3 ) * ( 3 );
 Real y;
equation
 y = 36.0;
end ArrayTests.SumExp2;
")})));

 constant Real x = sum(i * j for i in 1:3, j in 1:3);
 Real y = x;
end SumExp2;


model SumExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SumExp3",
         description="sum() expressions: reduction-expression over array",
         flatModel="
fclass ArrayTests.SumExp3
 constant Real x[1] = 1 + 1 + 1 + 2 + 2 + 2 + 3 + 3 + 3;
 constant Real x[2] = 2 + 3 + 4 + 2 + 3 + 4 + 2 + 3 + 4;
 Real y[1];
 Real y[2];
equation
 y[1] = 18.0;
 y[2] = 27.0;
end ArrayTests.SumExp3;
")})));

 constant Real x[2] = sum({i, j} for i in 1:3, j in 2:4);
 Real y[2] = x;
end SumExp3;


model SumExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SumExp4",
         description="sum() expressions: over array constructor with iterators",
         flatModel="
fclass ArrayTests.SumExp4
 constant Real x = 1 + 2 + 1 + 3 + 1 + 4 + 2 + 2 + 2 + 3 + 2 + 4 + 3 + 2 + 3 + 3 + 3 + 4;
 Real y;
equation
 y = 45.0;
end ArrayTests.SumExp4;
")})));

 constant Real x = sum( { {i, j} for i in 1:3, j in 2:4 } );
 Real y = x;
end SumExp4;


model SumExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SumExp5",
         description="sum() expressions: scalar input",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1489, column 15:
  Calling function sum(): types of positional argument 1 and input A are not compatible
")})));

 Real x = sum(1);
end SumExp5;



model ArrayIterTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayIterTest1",
         description="Array constructor with iterators: over scalar exp",
         flatModel="
fclass ArrayTests.ArrayIterTest1
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
equation
 x[1,1] = ( 1 ) * ( 2 );
 x[1,2] = ( 1 ) * ( 3 );
 x[1,3] = ( 1 ) * ( 5 );
 x[2,1] = ( 2 ) * ( 2 );
 x[2,2] = ( 2 ) * ( 3 );
 x[2,3] = ( 2 ) * ( 5 );
 x[3,1] = ( 3 ) * ( 2 );
 x[3,2] = ( 3 ) * ( 3 );
 x[3,3] = ( 3 ) * ( 5 );
end ArrayTests.ArrayIterTest1;
")})));

 Real x[3,3] = {i * j for i in 1:3, j in {2,3,5}};
end ArrayIterTest1;


model ArrayIterTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayIterTest2",
         description="Array constructor with iterators: over array exp",
         flatModel="
fclass ArrayTests.ArrayIterTest2
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
equation
 x[1,1,1] = ( 1 ) * ( 1 );
 x[1,1,2] = 2;
 x[1,2,1] = ( 1 ) * ( 1 );
 x[1,2,2] = 5;
 x[2,1,1] = ( 2 ) * ( 2 );
 x[2,1,2] = 2;
 x[2,2,1] = ( 2 ) * ( 2 );
 x[2,2,2] = 5;
end ArrayTests.ArrayIterTest2;
")})));

 Real x[2,2,2] = {{i * i, j} for i in 1:2, j in {2,5}};
end ArrayIterTest2;


model ArrayIterTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayIterTest3",
         description="Array constructor with iterators: without in",
         errorMessage="
2 errors found:
Semantic error at line 1529, column 28:
  For index without in expression isn't supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1529, column 31:
  For index without in expression isn't supported
")})));

 Real x[1,1] = { i * j for i, j };
end ArrayIterTest3;


model ArrayIterTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayIterTest4",
         description="Array constructor with iterators: nestled constructors, masking index",
         flatModel="
fclass ArrayTests.ArrayIterTest4
 Real i;
 Real x[1,1,1,1];
 Real x[1,1,1,2];
 Real x[1,1,2,1];
 Real x[1,1,2,2];
 Real x[1,2,1,1];
 Real x[1,2,1,2];
 Real x[1,2,2,1];
 Real x[1,2,2,2];
 Real x[2,1,1,1];
 Real x[2,1,1,2];
 Real x[2,1,2,1];
 Real x[2,1,2,2];
 Real x[2,2,1,1];
 Real x[2,2,1,2];
 Real x[2,2,2,1];
 Real x[2,2,2,2];
equation
 i = 1;
 x[1,1,1,1] = 3;
 x[1,1,1,2] = 1;
 x[1,1,2,1] = 3;
 x[1,1,2,2] = 2;
 x[1,2,1,1] = 4;
 x[1,2,1,2] = 1;
 x[1,2,2,1] = 4;
 x[1,2,2,2] = 2;
 x[2,1,1,1] = 3;
 x[2,1,1,2] = 1;
 x[2,1,2,1] = 3;
 x[2,1,2,2] = 2;
 x[2,2,1,1] = 4;
 x[2,2,1,2] = 1;
 x[2,2,2,1] = 4;
 x[2,2,2,2] = 2;
end ArrayTests.ArrayIterTest4;
")})));

 Real i = 1;
 Real x[2,2,2,2] = { { { {i, j} for j in 1:2 } for i in 3:4 } for i in 5:6 };
end ArrayIterTest4;


model ArrayIterTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayIterTest5",
         description="Array constructor with iterators: vectors of length 1",
         flatModel="
fclass ArrayTests.ArrayIterTest5
 Real x[1,1,1];
equation
 x[1,1,1] = 1;
end ArrayTests.ArrayIterTest5;
")})));

 Real x[1,1,1] = { {1} for i in {1}, j in {1} };
end ArrayIterTest5;



model SubscriptExpression1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SubscriptExpression1",
         description="Replacing expressions in array subscripts with literals: basic test",
         flatModel="
fclass ArrayTests.SubscriptExpression1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
equation
 x[1] = 1;
 x[2] = ( x[1] ) * ( 2 );
 x[3] = ( x[2] ) * ( 2 );
 x[4] = ( x[3] ) * ( 2 );
end ArrayTests.SubscriptExpression1;
")})));

 Real x[4];
equation
 x[1] = 1;
 for i in 2:4 loop
  x[i] = x[i-1] * 2;
 end for;
end SubscriptExpression1;


model SubscriptExpression2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SubscriptExpression2",
         description="Type checking array subscripts: literal < 1",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 737, column 4:
  Array index out of bounds: 0, index expression: 0
")})));

 Real x[4];
equation
 x[0] = 1;
end SubscriptExpression2;


model SubscriptExpression3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SubscriptExpression3",
         description="Type checking array subscripts: literal > end",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 754, column 4:
  Array index out of bounds: 5, index expression: 5
")})));

 Real x[4];
equation
 x[5] = 1;
end SubscriptExpression3;


model SubscriptExpression4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SubscriptExpression4",
         description="Type checking array subscripts: expression < 1",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 750, column 12:
  Array index out of bounds: 0, index expression: i - ( 1 )
")})));

 Real x[4];
equation
 for i in 1:4 loop
  x[i] = x[i-1] * 2;
 end for;
end SubscriptExpression4;


model SubscriptExpression5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SubscriptExpression5",
         description="Type checking array subscripts: expression > end",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 769, column 12:
  Array index out of bounds: 5, index expression: i + 1
")})));

 Real x[4];
equation
 for i in 1:4 loop
  x[i] = x[i+1] * 2;
 end for;
end SubscriptExpression5;


model SubscriptExpression6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SubscriptExpression6",
         description="Type checking array subscripts: simulating [4,4] with [16]",
         flatModel="
fclass ArrayTests.SubscriptExpression6
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real x[5];
 Real x[6];
 Real x[7];
 Real x[8];
 Real x[9];
 Real x[10];
 Real x[11];
 Real x[12];
 Real x[13];
 Real x[14];
 Real x[15];
 Real x[16];
equation
 x[1] = 1 + ( 1 ) * ( 2 );
 x[2] = 1 + ( 2 ) * ( 2 );
 x[3] = 1 + ( 3 ) * ( 2 );
 x[4] = 1 + ( 4 ) * ( 2 );
 x[5] = 2 + ( 1 ) * ( 2 );
 x[6] = 2 + ( 2 ) * ( 2 );
 x[7] = 2 + ( 3 ) * ( 2 );
 x[8] = 2 + ( 4 ) * ( 2 );
 x[9] = 3 + ( 1 ) * ( 2 );
 x[10] = 3 + ( 2 ) * ( 2 );
 x[11] = 3 + ( 3 ) * ( 2 );
 x[12] = 3 + ( 4 ) * ( 2 );
 x[13] = 4 + ( 1 ) * ( 2 );
 x[14] = 4 + ( 2 ) * ( 2 );
 x[15] = 4 + ( 3 ) * ( 2 );
 x[16] = 4 + ( 4 ) * ( 2 );
end ArrayTests.SubscriptExpression6;
")})));

 Real x[16];
equation
 for i in 1:4, j in 1:4 loop
  x[4*(i-1) + j] = i + j * 2;
 end for;
end SubscriptExpression6;


model SubscriptExpression7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SubscriptExpression7",
         description="Type checking array subscripts: using min in subscripts",
         flatModel="
fclass ArrayTests.SubscriptExpression7
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
equation
 x[1,1] = 1 + ( 1 ) * ( 2 );
 x[1,2] = 1 + ( 2 ) * ( 2 );
 x[1,3] = 1 + ( 3 ) * ( 2 );
 x[1,4] = 1 + ( 4 ) * ( 2 );
 x[2,2] = 2 + ( 1 ) * ( 2 );
 x[2,2] = 2 + ( 2 ) * ( 2 );
 x[2,3] = 2 + ( 3 ) * ( 2 );
 x[2,4] = 2 + ( 4 ) * ( 2 );
 x[3,3] = 3 + ( 1 ) * ( 2 );
 x[3,3] = 3 + ( 2 ) * ( 2 );
 x[3,3] = 3 + ( 3 ) * ( 2 );
 x[3,4] = 3 + ( 4 ) * ( 2 );
 x[4,4] = 4 + ( 1 ) * ( 2 );
 x[4,4] = 4 + ( 2 ) * ( 2 );
 x[4,4] = 4 + ( 3 ) * ( 2 );
 x[4,4] = 4 + ( 4 ) * ( 2 );
end ArrayTests.SubscriptExpression7;
")})));

 Real x[4,4];
equation
 for i in 1:4, j in 1:4 loop
  x[i, j + i - min(i, j)] = i + j * 2;
 end for;
end SubscriptExpression7;


model SubscriptExpression8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SubscriptExpression8",
         description="Type checking array subscripts: complex expression, several bad indices",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1499, column 5:
  Array index out of bounds: 5, index expression: i + ( j ) * ( max(( i ) * ( 1:4 )) )
")})));

 Real x[4];
equation
 for i in 1:4, j in 1:4 loop
  x[i + j * max(i*(1:4))] = i + j * 2;
 end for;
end SubscriptExpression8;



model NumSubscripts1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="NumSubscripts1",
         description="Check number of array subscripts:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1928, column 12:
  Too many array subscripts for access: 1 subscripts given, component has 0 dimensions
")})));

 Real x = 1;
 Real y = x[1];
end NumSubscripts1;


model NumSubscripts2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="NumSubscripts2",
         description="Check number of array subscripts:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1945, column 12:
  Too many array subscripts for access: 3 subscripts given, component has 2 dimensions
")})));

 Real x[1,1] = {{1}};
 Real y = x[1,1,1];
end NumSubscripts2;



/* ========== Array algebra ========== */

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


model ArrayMulOK13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayMulOK13",
         description="Scalarization of multiplication: check that type() of Real[3] * Real[3] is correct",
         flatModel="
fclass ArrayTests.ArrayMulOK13
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
 y[1] = ( ( x[1] ) * ( x[1] ) + ( x[2] ) * ( x[2] ) + ( x[3] ) * ( x[3] ) ) * ( x[1] );
 y[2] = ( ( x[1] ) * ( x[1] ) + ( x[2] ) * ( x[2] ) + ( x[3] ) * ( x[3] ) ) * ( x[2] );
 y[3] = ( ( x[1] ) * ( x[1] ) + ( x[2] ) * ( x[2] ) + ( x[3] ) * ( x[3] ) ) * ( x[3] );
end ArrayTests.ArrayMulOK13;
")})));

 Real x[3] = { 1, 2, 3 };
 Real y[3] = x * x * x;
end ArrayMulOK13;


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



model ArrayPow1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow1",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 0",
         flatModel="
fclass ArrayTests.ArrayPow1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 0;
 x[2,1] = 0;
 x[2,2] = 1;
end ArrayTests.ArrayPow1;
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 0;
end ArrayPow1;


model ArrayPow2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow2",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 1",
         flatModel="
fclass ArrayTests.ArrayPow2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
end ArrayTests.ArrayPow2;
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 1;
end ArrayPow2;


model ArrayPow3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow3",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 2",
         flatModel="
fclass ArrayTests.ArrayPow3
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = ( 1 ) * ( 1 ) + ( 2 ) * ( 3 );
 x[1,2] = ( 1 ) * ( 2 ) + ( 2 ) * ( 4 );
 x[2,1] = ( 3 ) * ( 1 ) + ( 4 ) * ( 3 );
 x[2,2] = ( 3 ) * ( 2 ) + ( 4 ) * ( 4 );
end ArrayTests.ArrayPow3;
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 2;
end ArrayPow3;


model ArrayPow4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow4",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 3",
         flatModel="
fclass ArrayTests.ArrayPow4
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = ( ( 1 ) * ( 1 ) + ( 2 ) * ( 3 ) ) * ( 1 ) + ( ( 1 ) * ( 2 ) + ( 2 ) * ( 4 ) ) * ( 3 );
 x[1,2] = ( ( 1 ) * ( 1 ) + ( 2 ) * ( 3 ) ) * ( 2 ) + ( ( 1 ) * ( 2 ) + ( 2 ) * ( 4 ) ) * ( 4 );
 x[2,1] = ( ( 3 ) * ( 1 ) + ( 4 ) * ( 3 ) ) * ( 1 ) + ( ( 3 ) * ( 2 ) + ( 4 ) * ( 4 ) ) * ( 3 );
 x[2,2] = ( ( 3 ) * ( 1 ) + ( 4 ) * ( 3 ) ) * ( 2 ) + ( ( 3 ) * ( 2 ) + ( 4 ) * ( 4 ) ) * ( 4 );
end ArrayTests.ArrayPow4;
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 3;
end ArrayPow4;


model ArrayPow5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow5",
         description="Scalarization of element-wise exponentiation: Integer[3,3] ^ 2",
         flatModel="
fclass ArrayTests.ArrayPow5
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
equation
 x[1,1] = ( 1 ) * ( 1 ) + ( 2 ) * ( 4 ) + ( 3 ) * ( 7 );
 x[1,2] = ( 1 ) * ( 2 ) + ( 2 ) * ( 5 ) + ( 3 ) * ( 8 );
 x[1,3] = ( 1 ) * ( 3 ) + ( 2 ) * ( 6 ) + ( 3 ) * ( 9 );
 x[2,1] = ( 4 ) * ( 1 ) + ( 5 ) * ( 4 ) + ( 6 ) * ( 7 );
 x[2,2] = ( 4 ) * ( 2 ) + ( 5 ) * ( 5 ) + ( 6 ) * ( 8 );
 x[2,3] = ( 4 ) * ( 3 ) + ( 5 ) * ( 6 ) + ( 6 ) * ( 9 );
 x[3,1] = ( 7 ) * ( 1 ) + ( 8 ) * ( 4 ) + ( 9 ) * ( 7 );
 x[3,2] = ( 7 ) * ( 2 ) + ( 8 ) * ( 5 ) + ( 9 ) * ( 8 );
 x[3,3] = ( 7 ) * ( 3 ) + ( 8 ) * ( 6 ) + ( 9 ) * ( 9 );
end ArrayTests.ArrayPow5;
")})));

 Real x[3,3] = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } } ^ 2;
end ArrayPow5;


model ArrayPow6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow6",
         description="Scalarization of element-wise exponentiation: component Real[2,2] ^ 2",
         flatModel="
fclass ArrayTests.ArrayPow6
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1,1] = ( y[1,1] ) * ( y[1,1] ) + ( y[1,2] ) * ( y[2,1] );
 x[1,2] = ( y[1,1] ) * ( y[1,2] ) + ( y[1,2] ) * ( y[2,2] );
 x[2,1] = ( y[2,1] ) * ( y[1,1] ) + ( y[2,2] ) * ( y[2,1] );
 x[2,2] = ( y[2,1] ) * ( y[1,2] ) + ( y[2,2] ) * ( y[2,2] );
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayPow6;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation 
 x = y ^ 2;
end ArrayPow6;


model ArrayPow7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow7",
         description="Scalarization of element-wise exponentiation:component Real[2,2] ^ 0",
         flatModel="
fclass ArrayTests.ArrayPow7
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
 x[1,2] = 0;
 x[2,1] = 0;
 x[2,2] = 1;
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
end ArrayTests.ArrayPow7;
")})));

 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation 
 x = y ^ 0;
end ArrayPow7;


model ArrayPow8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow8",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ (negative Integer)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4068, column 16:
  Type error in expression
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ (-1);
end ArrayPow8;


model ArrayPow9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow9",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ Real",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4084, column 16:
  Type error in expression
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 1.0;
end ArrayPow9;


model ArrayPow10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow10",
         description="Scalarization of element-wise exponentiation: Integer[2,2] ^ Integer[2,2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4100, column 16:
  Type error in expression
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ { { 1, 2 }, { 3, 4 } };
end ArrayPow10;


model ArrayPow11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow11",
         description="Scalarization of element-wise exponentiation: Integer[2,3] ^ 2",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4116, column 16:
  Type error in expression
")})));

 Real x[2,3] = { { 1, 2 }, { 3, 4 }, { 5, 6 } } ^ 2;
end ArrayPow11;


model ArrayPow12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow12",
         description="Scalarization of element-wise exponentiation: Real[2,2] ^ Integer component",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4286, column 16:
  Type error in expression
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 Integer y = 2;
end ArrayPow12;


model ArrayPow13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow13",
         description="Scalarization of element-wise exponentiation: Real[2,2] ^ constant Integer component",
         flatModel="
fclass ArrayTests.ArrayPow13
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 constant Integer y = 2;
equation
 x[1,1] = ( 1 ) * ( 1 ) + ( 2 ) * ( 3 );
 x[1,2] = ( 1 ) * ( 2 ) + ( 2 ) * ( 4 );
 x[2,1] = ( 3 ) * ( 1 ) + ( 4 ) * ( 3 );
 x[2,2] = ( 3 ) * ( 2 ) + ( 4 ) * ( 4 );
end ArrayTests.ArrayPow13;
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 constant Integer y = 2;
end ArrayPow13;


model ArrayPow14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow14",
         description="Scalarization of element-wise exponentiation: Real[2,2] ^ parameter Integer component",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4326, column 16:
  Type error in expression
")})));

 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 parameter Integer y = 2;
end ArrayPow14;


model ArrayPow15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow15",
         description="Scalarization of element-wise exponentiation: Integer[1,1] ^ 2",
         flatModel="
fclass ArrayTests.ArrayPow15
 Real x[1,1];
equation
 x[1,1] = ( 1 ) * ( 1 );
end ArrayTests.ArrayPow15;
")})));

 Real x[1,1] = { { 1 } } ^ 2;
end ArrayPow15;


model ArrayPow16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayPow16",
         description="Scalarization of element-wise exponentiation: Integer[1] ^ 2",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4177, column 16:
  Type error in expression
")})));

 Real x[1] = { 1 } ^ 2;
end ArrayPow16;


model ArrayPow17
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayPow17",
         description="Scalarization of element-wise exponentiation: Integer ^ 2",
         flatModel="
fclass ArrayTests.ArrayPow17
 Real x;
equation
 x = 1 ^ 2;
end ArrayTests.ArrayPow17;
")})));

 Real x = 1 ^ 2;
end ArrayPow17;



model ArrayAnd1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayAnd1",
         description="Scalarization of logical and: arrays of Booleans (literal)",
         flatModel="
fclass ArrayTests.ArrayAnd1
 Boolean x[1];
 Boolean x[2];
equation
 x[1] = true and true;
 x[2] = true and false;
end ArrayTests.ArrayAnd1;
")})));

 Boolean x[2] = { true, true } and { true, false };
end ArrayAnd1;


model ArrayAnd2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayAnd2",
         description="Scalarization of logical and: arrays of Booleans (component)",
         flatModel="
fclass ArrayTests.ArrayAnd2
 Boolean y[1];
 Boolean y[2];
 Boolean x[1];
 Boolean x[2];
equation
 y[1] = true;
 y[2] = false;
 x[1] = true and y[1];
 x[2] = true and y[2];
end ArrayTests.ArrayAnd2;
")})));

 Boolean y[2] = { true, false };
 Boolean x[2] = { true, true } and y;
end ArrayAnd2;


model ArrayAnd3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAnd3",
         description="Scalarization of logical and: different array sizes (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5569, column 17:
  Type error in expression
")})));

 Boolean x[2] = { true, true } and { true, false, true };
end ArrayAnd3;


model ArrayAnd4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAnd4",
         description="Scalarization of logical and: different array sizes (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5586, column 17:
  Type error in expression
")})));

 Boolean y[3] = { true, false, true };
 Boolean x[2] = { true, true } and y;
end ArrayAnd4;


model ArrayAnd5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAnd5",
         description="Scalarization of logical and: array and scalar (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5602, column 17:
  Type error in expression
")})));

 Boolean x[2] = { true, true } and true;
end ArrayAnd5;


model ArrayAnd6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAnd6",
         description="Scalarization of logical and: array and scalar (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5619, column 17:
  Type error in expression
")})));

 Boolean y = true;
 Boolean x[2] = { true, true } and y;
end ArrayAnd6;


model ArrayAnd7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAnd7",
         description="Scalarization of logical and: Integer[2] and Integer[2] (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5635, column 17:
  Type error in expression
")})));

 Integer x[2] = { 1, 1 } and { 1, 0 };
end ArrayAnd7;


model ArrayAnd8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayAnd8",
         description="Scalarization of logical and: Integer[2] and Integer[2] (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5652, column 17:
  Type error in expression
")})));

 Integer y[2] = { 1, 0 };
 Integer x[2] = { 1, 1 } and y;
end ArrayAnd8;


model ArrayAnd9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayAnd9",
         description="Scalarization of logical and: constant evaluation",
         flatModel="
fclass ArrayTests.ArrayAnd9
 constant Boolean y[1] = true and true;
 constant Boolean y[2] = false and true;
 constant Boolean y[3] = false and false;
 Boolean x[1];
 Boolean x[2];
 Boolean x[3];
equation
 x[1] = true;
 x[2] = false;
 x[3] = false;
end ArrayTests.ArrayAnd9;
")})));

 constant Boolean y[3] = { true, false, false } and { true, true, false };
 Boolean x[3] = y;
end ArrayAnd9;



model ArrayOr1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOr1",
         description="Scalarization of logical or: arrays of Booleans (literal)",
         flatModel="
fclass ArrayTests.ArrayOr1
 Boolean x[1];
 Boolean x[2];
equation
 x[1] = true or true;
 x[2] = true or false;
end ArrayTests.ArrayOr1;
")})));

 Boolean x[2] = { true, true } or { true, false };
end ArrayOr1;


model ArrayOr2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOr2",
         description="Scalarization of logical or: arrays of Booleans (component)",
         flatModel="
fclass ArrayTests.ArrayOr2
 Boolean y[1];
 Boolean y[2];
 Boolean x[1];
 Boolean x[2];
equation
 y[1] = true;
 y[2] = false;
 x[1] = true or y[1];
 x[2] = true or y[2];
end ArrayTests.ArrayOr2;
")})));

 Boolean y[2] = { true, false };
 Boolean x[2] = { true, true } or y;
end ArrayOr2;


model ArrayOr3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayOr3",
         description="Scalarization of logical or: different array sizes (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5723, column 17:
  Type error in expression
")})));

 Boolean x[2] = { true, true } or { true, false, true };
end ArrayOr3;


model ArrayOr4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayOr4",
         description="Scalarization of logical or: different array sizes (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5740, column 17:
  Type error in expression
")})));

 Boolean y[3] = { true, false, true };
 Boolean x[2] = { true, true } or y;
end ArrayOr4;


model ArrayOr5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayOr5",
         description="Scalarization of logical or: array and scalar (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5759, column 17:
  Type error in expression
")})));

 Boolean x[2] = { true, true } or true;
end ArrayOr5;


model ArrayOr6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayOr6",
         description="Scalarization of logical or: array and scalar (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5776, column 17:
  Type error in expression
")})));

 Boolean y = true;
 Boolean x[2] = { true, true } or y;
end ArrayOr6;


model ArrayOr7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayOr7",
         description="Scalarization of logical or: Integer[2] or Integer[2] (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5803, column 17:
  Type error in expression
")})));

 Integer x[2] = { 1, 1 } or { 1, 0 };
end ArrayOr7;


model ArrayOr8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayOr8",
         description="Scalarization of logical or: Integer[2] or Integer[2] (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5820, column 17:
  Type error in expression
")})));

 Integer y[2] = { 1, 0 };
 Integer x[2] = { 1, 1 } or y;
end ArrayOr8;


model ArrayOr9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOr9",
         description="Scalarization of logical or: constant evaluation",
         flatModel="
fclass ArrayTests.ArrayOr9
 constant Boolean y[1] = true or true;
 constant Boolean y[2] = true or false;
 constant Boolean y[3] = false or false;
 Boolean x[1];
 Boolean x[2];
 Boolean x[3];
equation
 x[1] = true;
 x[2] = true;
 x[3] = false;
end ArrayTests.ArrayOr9;
")})));

 constant Boolean y[3] = { true, true, false } or { true, false, false };
 Boolean x[3] = y;
end ArrayOr9;



model ArrayNot1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayNot1",
         description="Scalarization of logical not: array of Boolean (literal)",
         flatModel="
fclass ArrayTests.ArrayNot1
 Boolean x[1];
 Boolean x[2];
equation
 x[1] = not true;
 x[2] = not false;
end ArrayTests.ArrayNot1;
")})));

 Boolean x[2] = not { true, false };
end ArrayNot1;


model ArrayNot2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayNot2",
         description="Scalarization of logical not: array of Boolean (component)",
         flatModel="
fclass ArrayTests.ArrayNot2
 Boolean x[1];
 Boolean x[2];
 Boolean y[1];
 Boolean y[2];
equation
 x[1] = not y[1];
 x[2] = not y[2];
 y[1] = true;
 y[2] = false;
end ArrayTests.ArrayNot2;
")})));

 Boolean x[2] = not y;
 Boolean y[2] = { true, false };
end ArrayNot2;


model ArrayNot3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayNot3",
         description="Scalarization of logical not: constant evaluation",
         flatModel="
fclass ArrayTests.ArrayNot3
 Boolean x[1];
 Boolean x[2];
 constant Boolean y[1] = not true;
 constant Boolean y[2] = not false;
equation
 x[1] = false;
 x[2] = true;
end ArrayTests.ArrayNot3;
")})));

 Boolean x[2] = y;
 constant Boolean y[2] = not { true, false };
end ArrayNot3;


model ArrayNot4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayNot4",
         description="Scalarization of logical not: not Integer[2] (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5879, column 17:
  Type error in expression
")})));

 Integer x[2] = not { 1, 0 };
end ArrayNot4;


model ArrayNot5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayNot5",
         description="Scalarization of logical or: not Integer[2] (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5895, column 17:
  Type error in expression
")})));

 Integer x[2] = not y;
 Integer y[2] = { 1, 0 };
end ArrayNot5;



model ArrayNeg1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayNeg1",
         description="Scalarization of negation: array of Integer (literal)",
         flatModel="
fclass ArrayTests.ArrayNeg1
 Integer x[1];
 Integer x[2];
 Integer x[3];
equation
 x[1] =  - ( 1 );
 x[2] =  - ( 0 );
 x[3] =  - (  - ( 1 ) );
end ArrayTests.ArrayNeg1;
")})));

 Integer x[3] = -{ 1, 0, -1 };
end ArrayNeg1;


// TODO: When tests can set options, do this without alias removal
model ArrayNeg2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayNeg2",
         description="",
         flatModel="
fclass ArrayTests.ArrayNeg2
 Integer x[1];
 Integer x[2];
 Integer x[3];
equation
  - ( x[1] ) = 1;
  - ( x[2] ) = 0;
  - ( x[3] ) =  - ( 1 );
end ArrayTests.ArrayNeg2;
")})));

 Integer x[3] = -y;
 Integer y[3] = { 1, 0, -1 };
end ArrayNeg2;


model ArrayNeg3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayNeg3",
         description="Scalarization of negation: constant evaluation",
         flatModel="
fclass ArrayTests.ArrayNeg3
 Integer x[1];
 Integer x[2];
 Integer x[3];
 constant Integer y[1] =  - ( 1 );
 constant Integer y[2] =  - ( 0 );
 constant Integer y[3] =  - (  - ( 1 ) );
equation
 x[1] = -1;
 x[2] = 0;
 x[3] = 1;
end ArrayTests.ArrayNeg3;
")})));

 Integer x[3] = y;
 constant Integer y[3] = -{ 1, 0, -1 };
end ArrayNeg3;


model ArrayNeg4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayNeg4",
         description="Scalarization of negation: -Boolean[2] (literal)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6029, column 17:
  Type error in expression
")})));

 Boolean x[2] = -{ true, false };
end ArrayNeg4;


model ArrayNeg5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayNeg5",
         description="Scalarization of negation: -Boolean[2] (component)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6045, column 17:
  Type error in expression
")})));

 Boolean x[2] = -y;
 Boolean y[2] = { true, false };
end ArrayNeg5;



model Transpose1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Transpose1",
         description="Scalarization of transpose operator: Integer[2,2]",
         flatModel="
fclass ArrayTests.Transpose1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 3;
 x[2,1] = 2;
 x[2,2] = 4;
end ArrayTests.Transpose1;
")})));

 Real x[2,2] = transpose({{1,2},{3,4}});
end Transpose1;


model Transpose2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Transpose2",
         description="Scalarization of transpose operator: Integer[3,2]",
         flatModel="
fclass ArrayTests.Transpose2
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
equation
 x[1,1] = 1;
 x[1,2] = 3;
 x[1,3] = 5;
 x[2,1] = 2;
 x[2,2] = 4;
 x[2,3] = 6;
end ArrayTests.Transpose2;
")})));

 Real x[2,3] = transpose({{1,2},{3,4},{5,6}});
end Transpose2;


model Transpose3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Transpose3",
         description="Scalarization of transpose operator: Integer[1,2]",
         flatModel="
fclass ArrayTests.Transpose3
 Real x[1,1];
 Real x[2,1];
equation
 x[1,1] = 1;
 x[2,1] = 2;
end ArrayTests.Transpose3;
")})));

 Real x[2,1] = transpose({{1,2}});
end Transpose3;


model Transpose4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Transpose4",
         description="Scalarization of transpose operator: Integer[2,2,2]",
         flatModel="
fclass ArrayTests.Transpose4
 Integer x[1,1,1];
 Integer x[1,1,2];
 Integer x[1,2,1];
 Integer x[1,2,2];
 Integer x[2,1,1];
 Integer x[2,1,2];
 Integer x[2,2,1];
 Integer x[2,2,2];
equation
 x[1,1,1] = 1;
 x[1,1,2] = 2;
 x[1,2,1] = 5;
 x[1,2,2] = 6;
 x[2,1,1] = 3;
 x[2,1,2] = 4;
 x[2,2,1] = 7;
 x[2,2,2] = 8;
end ArrayTests.Transpose4;
")})));

 Integer x[2,2,2] = transpose({{{1,2},{3,4}},{{5,6},{7,8}}});
end Transpose4;


model Transpose5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Transpose5",
         description="Scalarization of transpose operator: too few dimensions of arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6377, column 15:
  Calling function transpose(): types of positional argument 1 and input A are not compatible
")})));

  Real x[2] = {1,2};
  Real y[2];
equation
  y=transpose(x)*x;
end Transpose5;


model Transpose6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Transpose6",
         description="Scalarization of transpose operator: Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4876, column 24:
  Calling function transpose(): types of positional argument 1 and input A are not compatible
")})));

 Real x[2] = transpose(1);
end Transpose6;


model Transpose7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Transpose7",
         description="Scalarization of transpose operator: Real[1,2] -> Integer[2,1]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4892, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[2,1] = transpose({{1.0,2}});
end Transpose7;



model Cross1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Cross1",
         description="cross() operator: Real result",
         flatModel="
fclass ArrayTests.Cross1
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = ( 2 ) * ( 6 ) - ( ( 3 ) * ( 5 ) );
 x[2] = ( 3 ) * ( 4 ) - ( ( 1.0 ) * ( 6 ) );
 x[3] = ( 1.0 ) * ( 5 ) - ( ( 2 ) * ( 4 ) );
end ArrayTests.Cross1;
")})));

 Real x[3] = cross({1.0,2,3}, {4,5,6});
end Cross1; 


model Cross2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="Cross2",
         description="cross() operator: Integer result",
         flatModel="
fclass ArrayTests.Cross2
 Integer x[3] = cross({1,2,3}, {4,5,6});
end ArrayTests.Cross2;
")})));

 Integer x[3] = cross({1,2,3}, {4,5,6});
end Cross2; 


model Cross3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Cross3",
         description="cross() operator: Real arg, assigning Integer component",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6359, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[3] = cross({1.0,2,3}, {4,5,6});
end Cross3; 


model Cross4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Cross4",
         description="cross() operator: scalar arguments",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6401, column 20:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6401, column 23:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 Integer x = cross(1, 2);
end Cross4; 


model Cross5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Cross5",
         description="cross() operator: Integer[4] arguments",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6437, column 23:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6437, column 34:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 Integer x[4] = cross({1,2,3,4}, {4,5,6,7});
end Cross5; 


model Cross6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Cross6",
         description="cross() operator: String[3] arguments",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6456, column 22:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6456, column 37:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 String x[3] = cross({"1","2","3"}, {"4","5","6"});
end Cross6; 


model Cross7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Cross7",
         description="cross() operator: too many dims",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6475, column 25:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6475, column 52:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 Integer x[3,3] = cross({{1,2,3},{1,2,3},{1,2,3}}, {{4,5,6},{4,5,6},{4,5,6}});
end Cross7; 



model LongArrayForm1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="LongArrayForm1",
         description="Long form of array constructor",
         flatModel="
fclass ArrayTests.LongArrayForm1
 Real x[3] = array(1,2,3);
end ArrayTests.LongArrayForm1;
")})));

 Real x[3] = array(1, 2, 3);
end LongArrayForm1;


model LongArrayForm2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="LongArrayForm2",
         description="Long form of array constructor",
         flatModel="
fclass ArrayTests.LongArrayForm2
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
end ArrayTests.LongArrayForm2;
")})));

 Real x[3] = array(1, 2, 3);
end LongArrayForm2;


model LongArrayForm3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="LongArrayForm3",
         description="Long form of array constructor, array component parts",
         flatModel="
fclass ArrayTests.LongArrayForm3
 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1[1:3],x2[1:3],{7,8,9});
end ArrayTests.LongArrayForm3;
")})));

 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1,x2,{7,8,9});
end LongArrayForm3;


model LongArrayForm4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="LongArrayForm4",
         description="Long form of array constructor, array component parts",
         flatModel="
fclass ArrayTests.LongArrayForm4
 Real x3[1,1];
 Real x3[1,2];
 Real x3[1,3];
 Real x3[2,1];
 Real x3[2,2];
 Real x3[2,3];
 Real x3[3,1];
 Real x3[3,2];
 Real x3[3,3];
equation
 x3[1,1] = 1;
 x3[1,2] = 2;
 x3[1,3] = 3;
 x3[2,1] = 4;
 x3[2,2] = 5;
 x3[2,3] = 6;
 x3[3,1] = 7;
 x3[3,2] = 8;
 x3[3,3] = 9;
end ArrayTests.LongArrayForm4;
")})));

 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1,x2,{7,8,9});
end LongArrayForm4;



model ArrayCat1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayCat1",
         description="cat() operator: basic test",
         flatModel="
fclass ArrayTests.ArrayCat1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
 Real x[4,1];
 Real x[4,2];
 Real x[5,1];
 Real x[5,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
 x[3,1] = 5;
 x[3,2] = 6;
 x[4,1] = 7;
 x[4,2] = 8;
 x[5,1] = 9;
 x[5,2] = 0;
end ArrayTests.ArrayCat1;
")})));

 Real x[5,2] = cat(1, {{1,2},{3,4}}, {{5,6}}, {{7,8},{9,0}});
end ArrayCat1;


model ArrayCat2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayCat2",
         description="cat() operator: basic test",
         flatModel="
fclass ArrayTests.ArrayCat2
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[1,4];
 Real x[1,5];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[2,4];
 Real x[2,5];
equation
 x[1,1] = 1.0;
 x[1,2] = 2.0;
 x[1,3] = 3;
 x[1,4] = 4;
 x[1,5] = 5;
 x[2,1] = 6;
 x[2,2] = 7;
 x[2,3] = 8;
 x[2,4] = 9;
 x[2,5] = 0;
end ArrayTests.ArrayCat2;
")})));

 Real x[2,5] = cat(2, {{1.0,2.0},{6,7}}, {{3},{8}}, {{4,5},{9,0}});
end ArrayCat2;


model ArrayCat3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ArrayCat3",
         description="cat() operator: using strings",
         flatModel="
fclass ArrayTests.ArrayCat3
 String x[2,5] = cat(2, {{\"1\",\"2\"},{\"6\",\"7\"}}, {{\"3\"},{\"8\"}}, {{\"4\",\"5\"},{\"9\",\"0\"}});
end ArrayTests.ArrayCat3;
")})));

 String x[2,5] = cat(2, {{"1","2"},{"6","7"}}, {{"3"},{"8"}}, {{"4","5"},{"9","0"}});
end ArrayCat3;


model ArrayCat4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat4",
         description="cat() operator: size mismatch",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6656, column 19:
  Types do not match in array concatenation
")})));

 Integer x[5,2] = cat(2, {{1,2},{3,4}}, {{5,6,0}}, {{7,8},{9,0}});
end ArrayCat4;


model ArrayCat5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat5",
         description="cat() operator: size mismatch",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6672, column 19:
  Types do not match in array concatenation
")})));

 Integer x[2,5] = cat(2, {{1,2},{6,7}}, {{3},{8},{0}}, {{4,5},{9,0}});
end ArrayCat5;


model ArrayCat6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat6",
         description="cat() operator: type mismatch",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6688, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[2,5] = cat(2, {{1.0,2},{6,7}}, {{3},{8}}, {{4,5},{9,0}});
end ArrayCat6;


model ArrayCat6b
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat6b",
         description="cat() operator: type mismatch",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6704, column 19:
  Types do not match in array concatenation
")})));

 Integer x[2,5] = cat(2, {{"1","2"},{"6","7"}}, {{3},{8}}, {{4,5},{9,0}});
end ArrayCat6b;


model ArrayCat7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat7",
         description="cat() operator: to high variability of dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6721, column 17:
  Dimension argument of cat() does not have constant or parameter variability: d
")})));

 Integer d = 1;
 Integer x[4] = cat(d, {1,2}, {4,5});
end ArrayCat7;


model ArrayCat8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ArrayCat8",
         description="cat() operator: parameter dim",
         flatModel="
fclass ArrayTests.ArrayCat8
 parameter Integer d = 1 /* 1 */;
 Integer x[4] = cat(d, {1,2}, {4,5});
end ArrayTests.ArrayCat8;
")})));

 parameter Integer d = 1;
 Integer x[4] = cat(d, {1,2}, {4,5});
end ArrayCat8;


model ArrayCat9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat9",
         description="cat() operator: non-Integer dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6743, column 17:
  Dimension argument of cat() is not compatible with Integer: 1.0
")})));

 Integer x[4] = cat(1.0, {1,2}, {4,5});
end ArrayCat9;


model ArrayCat10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayCat10",
         description="Records:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6797, column 15:
  Types do not match in array concatenation
")})));

  Real x[2] = cat(1, {1}, 2);
end ArrayCat10;



model ArrayShortCat1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayShortCat1",
         description="Shorthand array concatenation operator: basic test",
         flatModel="
fclass ArrayTests.ArrayShortCat1
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[1,3] = 3;
 x[2,1] = 4;
 x[2,2] = 5;
 x[2,3] = 6;
end ArrayTests.ArrayShortCat1;
")})));

 Real x[2,3] = [1,2,3; 4,5,6];
end ArrayShortCat1;

model ArrayShortCat2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayShortCat2",
         description="Shorthand array concatenation operator: different sizes",
         flatModel="
fclass ArrayTests.ArrayShortCat2
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[1,3] = 3;
 x[2,1] = 4;
 x[3,1] = 7;
 x[2,2] = 5;
 x[2,3] = 6;
 x[3,2] = 8;
 x[3,3] = 9;
end ArrayTests.ArrayShortCat2;
")})));

 Real x[3,3] = [a, b; c, d];
 Real a = 1;
 Real b[1,2] = {{2,3}};
 Real c[2] = {4,7};
 Real d[2,2] = {{5,6},{8,9}};
end ArrayShortCat2;


model ArrayShortCat3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayShortCat3",
         description="Shorthand array concatenation operator: more than 2 dimensions",
         flatModel="
fclass ArrayTests.ArrayShortCat3
 Real x[1,1,1,1];
 Real x[1,1,2,1];
 Real x[1,2,1,1];
 Real x[1,2,2,1];
 Real x[2,1,1,1];
 Real x[2,1,2,1];
 Real x[2,2,1,1];
 Real x[2,2,2,1];
equation
 x[1,1,1,1] = 1;
 x[1,1,2,1] = 2;
 x[1,2,1,1] = 3;
 x[1,2,2,1] = 4;
 x[2,1,1,1] = 5;
 x[2,1,2,1] = 6;
 x[2,2,1,1] = 7;
 x[2,2,2,1] = 8;
end ArrayTests.ArrayShortCat3;
")})));

 Real x[2,2,2,1] = [{{{{1},{2}}}}, {{{3,4}}}; {{{5,6}}}, {{{7,8}}}];
end ArrayShortCat3;


model ArrayShortCat4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayShortCat4",
         description="Shorthand array concatenation operator:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6862, column 16:
  Types do not match in array concatenation
")})));

 Real x[2,3] = [{{1,2,3}}; {{4,5}}];
end ArrayShortCat4;


model ArrayShortCat5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayShortCat5",
         description="Shorthand array concatenation operator:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6878, column 17:
  Types do not match in array concatenation
")})));

 Real x[3,2] = [{1,2,3}, {4,5}];
end ArrayShortCat5;



model ArrayEnd1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayEnd1",
         description="end operator: basic test",
         flatModel="
fclass ArrayTests.ArrayEnd1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real y[1];
 Real y[2];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
 x[4] = 4;
 y[1] = ( x[2] ) * ( 2 );
 y[2] = ( x[3] ) * ( 2 );
end ArrayTests.ArrayEnd1;
")})));

 Real x[4] = {1,2,3,4};
 Real y[2] = x[2:end-1] * 2;
end ArrayEnd1;


model ArrayEnd2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ArrayEnd2",
         description="End operator: using in wrong place",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6924, column 15:
  The end operator may only be used in array subscripts
")})));

 Real x[4] = {1,2,3,4};
 Real y = 2 - end;
end ArrayEnd2;


model ArrayEnd3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayEnd3",
         description="End operator: nestled array subscripts",
         flatModel="
fclass ArrayTests.ArrayEnd3
 constant Integer x1[1] = 1;
 constant Integer x1[2] = 2;
 constant Integer x1[3] = 3;
 constant Integer x1[4] = 4;
 Real x2[1];
 Real x2[4];
 Real x2[5];
 Real y[1];
 Real y[2];
equation
 x2[1] = 5;
 y[2] = 6;
 y[1] = 7;
 x2[4] = 8;
 x2[5] = 9;
end ArrayTests.ArrayEnd3;
")})));

 constant Integer x1[4] = {1,2,3,4};
 Real x2[5] = {5,6,7,8,9};
 Real y[2] = x2[end.-x1[2:end-1]];
end ArrayEnd3;



model Linspace1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Linspace1",
         description="Linspace operator: basic test",
         flatModel="
fclass ArrayTests.Linspace1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
equation
 x[1] = 1 + ( 0 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
 x[2] = 1 + ( 1 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
 x[3] = 1 + ( 2 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
 x[4] = 1 + ( 3 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
end ArrayTests.Linspace1;
")})));

 Real x[4] = linspace(1, 3, 4);
end Linspace1;


model Linspace2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Linspace2",
         description="Linspace operator: using parameter component as n",
         flatModel="
fclass ArrayTests.Linspace2
 Real a;
 Real b;
 parameter Integer c = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 a = 1;
 b = 2;
 x[1] = a + ( 0 ) * ( ( b - ( a ) ) / ( 2 ) );
 x[2] = a + ( 1 ) * ( ( b - ( a ) ) / ( 2 ) );
 x[3] = a + ( 2 ) * ( ( b - ( a ) ) / ( 2 ) );
end ArrayTests.Linspace2;
")})));

 Real a = 1;
 Real b = 2;
 parameter Integer c = 3;
 Real x[3] = linspace(a, b, c);
end Linspace2;


model Linspace3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Linspace3",
         description="Linspace operator: wrong type of n",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7033, column 29:
  Calling function linspace(): types of positional argument 3 and input n are not compatible
")})));

 Real a = 1;
 Real b = 2;
 parameter Real c = 3;
 Real x[3] = linspace(a, b, c);
end Linspace3;


model Linspace4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Linspace4",
         description="Linspace operator: wrong variability of n",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7052, column 14:
  Type error in expression
")})));

 Real a = 1;
 Real b = 2;
 Integer c = 3;
 Real x[3] = linspace(a, b, c);
end Linspace4;


model Linspace5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Linspace5",
         description="Linspace operator: using result as Integer",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7057, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[4] = linspace(1, 3, 3);
end Linspace5;



model NdimsExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="NdimsExp1",
         description="Ndims operator: basic test",
         flatModel="
fclass ArrayTests.NdimsExp1
 constant Integer n = 2;
 Integer x;
equation
 x = ( 2 ) * ( 2 );
end ArrayTests.NdimsExp1;
")})));

 constant Integer n = ndims({{1,2},{3,4}});
 Integer x = n * 2;
end NdimsExp1;



model ArrayIfExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayIfExp1",
         description="Array if expressions",
         flatModel="
fclass ArrayTests.ArrayIfExp1
 parameter Integer N = 3 /* 3 */;
 parameter Real A[1,1] = 1 /* 1.0 */;
 parameter Real A[1,2] = 0 /* 0.0 */;
 parameter Real A[1,3] = 0 /* 0.0 */;
 parameter Real A[2,1] = 0 /* 0.0 */;
 parameter Real A[2,2] = 1 /* 1.0 */;
 parameter Real A[2,3] = 0 /* 0.0 */;
 parameter Real A[3,1] = 0 /* 0.0 */;
 parameter Real A[3,2] = 0 /* 0.0 */;
 parameter Real A[3,3] = 1 /* 1.0 */;
 Real x[1](start = 1);
 Real x[2](start = 1);
 Real x[3](start = 1);
equation
 der(x[1]) = (if time >= 3 then ( ( A[1,1] ) * ( x[1] ) + ( A[1,2] ) * ( x[2] ) + ( A[1,3] ) * ( x[3] ) ) / ( N ) else ( (  - ( A[1,1] ) ) * ( x[1] ) + (  - ( A[1,2] ) ) * ( x[2] ) + (  - ( A[1,3] ) ) * ( x[3] ) ) / ( N ));
 der(x[2]) = (if time >= 3 then ( ( A[2,1] ) * ( x[1] ) + ( A[2,2] ) * ( x[2] ) + ( A[2,3] ) * ( x[3] ) ) / ( N ) else ( (  - ( A[2,1] ) ) * ( x[1] ) + (  - ( A[2,2] ) ) * ( x[2] ) + (  - ( A[2,3] ) ) * ( x[3] ) ) / ( N ));
 der(x[3]) = (if time >= 3 then ( ( A[3,1] ) * ( x[1] ) + ( A[3,2] ) * ( x[2] ) + ( A[3,3] ) * ( x[3] ) ) / ( N ) else ( (  - ( A[3,1] ) ) * ( x[1] ) + (  - ( A[3,2] ) ) * ( x[2] ) + (  - ( A[3,3] ) ) * ( x[3] ) ) / ( N ));
end ArrayTests.ArrayIfExp1;
")})));

  parameter Integer N = 3;
  parameter Real A[N,N] = identity(N);
  Real x[N](each start = 1);
equation
  der(x) = if time>=3 then A*x/N else -A*x/N;
end ArrayIfExp1;


model ArrayIfExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayIfExp2",
         description="Constant evaluation of if expression",
         flatModel="
fclass ArrayTests.ArrayIfExp2
 constant Real a = (if 1 > 2 then 5 elseif 1 < 2 then 6 else 7);
 Real b;
equation
 b = 6.0;
end ArrayTests.ArrayIfExp2;
")})));

  constant Real a = if 1 > 2 then 5 elseif 1 < 2 then 6 else 7;
  Real b = a;
end ArrayIfExp2;



model Identity1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="Identity1",
         description="identity() operator: basic test",
         flatModel="
fclass ArrayTests.Identity1
 parameter Real A[1,1] = 1 /* 1.0 */;
 parameter Real A[1,2] = 0 /* 0.0 */;
 parameter Real A[1,3] = 0 /* 0.0 */;
 parameter Real A[2,1] = 0 /* 0.0 */;
 parameter Real A[2,2] = 1 /* 1.0 */;
 parameter Real A[2,3] = 0 /* 0.0 */;
 parameter Real A[3,1] = 0 /* 0.0 */;
 parameter Real A[3,2] = 0 /* 0.0 */;
 parameter Real A[3,3] = 1 /* 1.0 */;
end ArrayTests.Identity1;
")})));

  parameter Real A[3,3] = identity(3);
end Identity1;


model Identity2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Identity2",
         description="identity() operator:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7207, column 18:
  Array size mismatch in declaration of A, size of declaration is [] and size of binding expression is [3, 3]
")})));

  parameter Real A = identity(3);
end Identity2;


model Identity3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Identity3",
         description="identity() operator:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7224, column 27:
  Type error in expression
")})));

  Integer n = 3;
  parameter Real A[3,3] = identity(n);
end Identity3;


model Identity4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="Identity4",
         description="identity() operator:",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7240, column 36:
  Calling function identity(): types of positional argument 1 and input n are not compatible
")})));

  parameter Real A[3,3] = identity(3.0);
end Identity4;



model ScalarSize1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ScalarSize1",
         description="Size of zero-length vector",
         flatModel="
fclass ArrayTests.ScalarSize1
 Real x[1] = cat(1, {1}, size(3.141592653589793));
end ArrayTests.ScalarSize1;
")})));

  Real x[1] = cat(1, {1}, size(Modelica.Constants.pi));
end ScalarSize1;


model ScalarSize2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ScalarSize2",
         description="Size of scalar dotted access",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 7272, column 15:
  Type error in expression
")})));

  Real x[1] = {1} + Modelica.Constants.pi;
end ScalarSize2;



model ForEquation1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ForEquation1",
         description="Flattening of for equations: for equ in a component",
         flatModel="
fclass ArrayTests.ForEquation1
 Real y.x[3];
equation
 for i in 1:3 loop
  y.x[i] = ( i ) * ( i );
 end for;
end ArrayTests.ForEquation1;
")})));

 model A
  Real x[3];
 equation
  for i in 1:3 loop
   x[i] = i*i;
  end for;
 end A;
 
 A y;
end ForEquation1;



model SliceTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="SliceTest1",
         description="Slice operations: basic test",
         flatModel="
fclass ArrayTests.SliceTest1
 Real x[1].a[2] = {1,2};
 Real x[2].a[2] = {3,4};
 Real y[2,2] = x[1:2].a[1:2] .+ 1;
end ArrayTests.SliceTest1;
")})));

 model A
  Real a[2];
 end A;
 
 A x[2](a={{1,2},{3,4}});
 Real y[2,2] = x.a .+ 1;
end SliceTest1;


model SliceTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SliceTest2",
         description="Slice operations: basic test",
         flatModel="
fclass ArrayTests.SliceTest2
 Real x[1].a[1];
 Real x[1].a[2];
 Real x[2].a[1];
 Real x[2].a[2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1].a[1] = 1;
 x[1].a[2] = 2;
 x[2].a[1] = 3;
 x[2].a[2] = 4;
 y[1,1] = x[1].a[1] .+ 1;
 y[1,2] = x[1].a[2] .+ 1;
 y[2,1] = x[2].a[1] .+ 1;
 y[2,2] = x[2].a[2] .+ 1;
end ArrayTests.SliceTest2;
")})));

 model A
  Real a[2];
 end A;
 
 A x[2](a={{1,2},{3,4}});
 Real y[2,2] = x.a .+ 1;
end SliceTest2;


model SliceTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SliceTest3",
         description="Slice operations: test with vector indices",
         flatModel="
fclass ArrayTests.SliceTest3
 Real x[1].a[1];
 Real x[1].a[2];
 Real x[1].a[3];
 Real x[1].a[4];
 Real x[2].a[1];
 Real x[2].a[2];
 Real x[2].a[3];
 Real x[2].a[4];
 Real x[3].a[1];
 Real x[3].a[2];
 Real x[3].a[3];
 Real x[3].a[4];
 Real x[4].a[1];
 Real x[4].a[2];
 Real x[4].a[3];
 Real x[4].a[4];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 x[1].a[1] = 1;
 x[1].a[2] = 2;
 x[1].a[3] = 3;
 x[1].a[4] = 4;
 x[2].a[1] = 1;
 x[2].a[2] = 2;
 x[2].a[3] = 3;
 x[2].a[4] = 4;
 x[3].a[1] = 1;
 x[3].a[2] = 2;
 x[3].a[3] = 3;
 x[3].a[4] = 4;
 x[4].a[1] = 1;
 x[4].a[2] = 2;
 x[4].a[3] = 3;
 x[4].a[4] = 4;
 y[1,1] = x[2].a[2] .+ 1;
 y[1,2] = x[2].a[4] .+ 1;
 y[2,1] = x[3].a[2] .+ 1;
 y[2,2] = x[3].a[4] .+ 1;
end ArrayTests.SliceTest3;
")})));

 model A
  Real a[4];
 end A;
 
 A x[4](a={{1,2,3,4},{1,2,3,4},{1,2,3,4},{1,2,3,4}});
 Real y[2,2] = x[2:3].a[{2,4}] .+ 1;
end SliceTest3;



model MixedIndices1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MixedIndices1",
         description="Mixing for index subscripts with colon subscripts",
         flatModel="
fclass ArrayTests.MixedIndices1
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
 Real z[1,1,1];
 Real z[1,1,2];
 Real z[1,2,1];
 Real z[1,2,2];
 Real z[2,1,1];
 Real z[2,1,2];
 Real z[2,2,1];
 Real z[2,2,2];
equation
 der(y[1,1,1]) = z[1,1,1];
 der(y[1,1,2]) = z[1,1,2];
 der(y[1,2,1]) = z[1,2,1];
 der(y[1,2,2]) = z[1,2,2];
 der(y[2,1,1]) = z[2,1,1];
 der(y[2,1,2]) = z[2,1,2];
 der(y[2,2,1]) = z[2,2,1];
 der(y[2,2,2]) = z[2,2,2];
 z[1,1,1] = 1;
 z[1,1,2] = 0;
 z[1,2,1] = 0;
 z[1,2,2] = 1;
 z[2,1,1] = 1;
 z[2,1,2] = 0;
 z[2,2,1] = 0;
 z[2,2,2] = 1;
end ArrayTests.MixedIndices1;
")})));

 model M
   Real x[2,2] = identity(2);
 end M;
 
 M m[2];
 Real y[2,2,2];
 Real z[2,2,2];
equation
 for i in 1:2 loop
  der(y[i,:,:]) = m[i].x;
  z[i,:,:] = m[i].x;
 end for;
end MixedIndices1;


model MixedIndices2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MixedIndices2",
         description="Mixing expression subscripts containing for indices with colon subscripts",
         flatModel="
fclass ArrayTests.MixedIndices2
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
 Real y[3,1];
 Real y[3,2];
 Real y[4,1];
 Real y[4,2];
 Real z[1,1];
 Real z[1,2];
 Real z[2,1];
 Real z[2,2];
equation
 y[1,1] = ( z[1,1] ) * ( 2 );
 y[1,2] = ( z[1,2] ) * ( 2 );
 y[2,1] = ( z[2,1] ) * ( 2 );
 y[2,2] = ( z[2,2] ) * ( 2 );
 y[3,1] = ( z[1,1] ) * ( 2 );
 y[3,2] = ( z[1,2] ) * ( 2 );
 y[4,1] = ( z[2,1] ) * ( 2 );
 y[4,2] = ( z[2,2] ) * ( 2 );
 z[1,1] = 1;
 z[1,2] = 0;
 z[2,1] = 0;
 z[2,2] = 1;
end ArrayTests.MixedIndices2;
")})));

 Real y[4,2];
 Real z[2,2] = identity(2);
equation
 for i in 0:2:2 loop
   y[(1:2).+i,:] = z[:,:] * 2;
 end for;
end MixedIndices2;



  annotation (uses(Modelica(version="3.0.1")));
end ArrayTests;
