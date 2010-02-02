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



model SizeExpression1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExpression1",
         description="Size operator: first dim",
         flatModel="
fclass ArrayTests.SizeExpression1
 Real x;
equation
 x = 2;
end ArrayTests.SizeExpression1;
")})));

 Real x = size(ones(2), 1);
end SizeExpression1;


model SizeExpression2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExpression2",
         description="Size operator: second dim",
         flatModel="
fclass ArrayTests.SizeExpression2
 Real x;
equation
 x = 3;
end ArrayTests.SizeExpression2;
")})));

 Real x = size(ones(2, 3), 2);
end SizeExpression2;


model SizeExpression3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExpression3",
         description="Size operator: without dim",
         flatModel="
fclass ArrayTests.SizeExpression3
 Real x[1];
equation
 x[1] = 2;
end ArrayTests.SizeExpression3;
")})));

 Real x[1] = size(ones(2));
end SizeExpression3;


model SizeExpression4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExpression4",
         description="Size operator: without dim",
         flatModel="
fclass ArrayTests.SizeExpression4
 Real x[1];
 Real x[2];
equation
 x[1] = 2;
 x[2] = 3;
end ArrayTests.SizeExpression4;
")})));

 Real x[2] = size(ones(2, 3));
end SizeExpression4;


model SizeExpression5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="SizeExpression5",
         description="Size operator: using parameter",
         flatModel="
fclass ArrayTests.SizeExpression5
 parameter Integer p = 1 /* 1 */;
 Real x;
equation
 x = 2;
end ArrayTests.SizeExpression5;
")})));

 parameter Integer p = 1;
 Real x = size(ones(2, 3), p);
end SizeExpression5;


model SizeExpression6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExpression6",
         description="Size operator: too high variability of dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 793, column 11:
  Type error in expression
")})));

 Integer d = 1;
 Real x = size(ones(2, 3), d);
end SizeExpression6;


model SizeExpression7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExpression7",
         description="Size operator: array as dim",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 809, column 11:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 809, column 28:
  Types of positional argument 2 and input d are not compatible
")})));

 Real x = size(ones(2, 3), {1, 2});
end SizeExpression7;


model SizeExpression8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExpression8",
         description="Size operator: Real as dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 828, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 1.0);
end SizeExpression8;


model SizeExpression9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExpression9",
         description="Size operator: too low dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 844, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 0);
end SizeExpression9;


model SizeExpression10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="SizeExpression10",
         description="Size operator: too high dim",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 860, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 3);
end SizeExpression10;



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


model ArrayNeg2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ArrayNeg2",
         description="Scalarization of negation: array of Integer (component)",
         flatModel="
fclass ArrayTests.ArrayNeg2
 Integer x[3] =  - ( y );
 Integer y[3] = {1,0, - ( 1 )};
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
         description="Scalarization of transpose operator: Integer[2]",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4886, column 24:
  Types of positional argument 1 and input A are not compatible
")})));

 Real x[2] = transpose({1,2});
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
  Types of positional argument 1 and input A are not compatible
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



  annotation (uses(Modelica(version="3.0.1")));
end ArrayTests;
