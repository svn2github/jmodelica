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
 Real x[2,1];
 Real x[1,2];
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
      JModelica.UnitTesting.ErrorTestCase(name="ArrayTest15_Err",
        description="Test type checking of arrays",
                                               errorMessage=
"
JError: 1 problems found:
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 213, column 9:
  Type dimension mismatch in declaration x: dimension of declaration is 1, dimension of binding expression is 2
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
 Real x[2,1];
 Real x[1,2];
 Real x[2,2];
equation 
 x[1,1] = 1;
 x[2,1] = 1;
 x[1,2] = 1;
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
 Real x[2,1];
 Real x[1,2];
 Real x[2,2];
 Real y[1,1];
 Real y[2,1];
 Real y[1,2];
 Real y[2,2];
equation
 x[1,1] = 1;
 y[1,1] = x[1,1] + 1;
 x[2,1] = 2;
 y[2,1] = x[2,1] + 1;
 x[1,2] = 1;
 y[1,2] = x[1,2] + 2;
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
 Real x[2,1];
 Real x[1,2];
 Real x[2,2];
 Real x[1,3];
 Real x[2,3];
 Real y[1,1];
 Real y[2,1];
 Real y[1,2];
 Real y[2,2];
 Real y[1,3];
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
 Real x[2,1];
 Real x[3,1];
 Real x[4,1];
 Real x[1,2];
 Real x[2,2];
 Real x[3,2];
 Real x[4,2];
 Real x[1,3];
 Real x[2,3];
 Real x[3,3];
 Real x[4,3];
 Real x[1,4];
 Real x[2,4];
 Real x[3,4];
 Real x[4,4];
 Real y[1,1];
 Real y[2,1];
 Real y[3,1];
 Real y[4,1];
 Real y[1,2];
 Real y[2,2];
 Real y[3,2];
 Real y[4,2];
 Real y[1,3];
 Real y[2,3];
 Real y[3,3];
 Real y[4,3];
 Real y[1,4];
 Real y[2,4];
 Real y[3,4];
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

  annotation (uses(Modelica(version="3.0.1")));
end ArrayTests;
