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

within ;
package ArrayTests

package General
		
  model ArrayTest1
    Real x[2];
  equation
    x[1] = 3;
    x[2] = 4;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayTest1",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest1
 Real x[2];
equation 
 x[1] = 3;
 x[2] = 4;

end ArrayTests.General.ArrayTest1;
")})));
  end ArrayTest1;

  model ArrayTest1b
  
    parameter Integer n = 2;
    Real x[n];
  equation
    x[1] = 3;
    x[2] = 4;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayTest1b",
			description="Flattening of arrays.",
			flatModel=" 
fclass ArrayTests.General.ArrayTest1b
 parameter Integer n = 2 /* 2 */;
 Real x[2];
equation 
 x[1] = 3;
 x[2] = 4; 

end ArrayTests.General.ArrayTest1b;
")})));
  end ArrayTest1b;


  model ArrayTest1c

    Real x[2];
  equation
    der(x[1]) = 3;
    der(x[2]) = 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest1c",
			description="Test scalarization of variables",
			automatic_add_initial_equations=false,
			flatModel="
fclass ArrayTests.General.ArrayTest1c
 Real x[1];
 Real x[2];
equation 
 der(x[1]) = 3;
 der(x[2]) = 4;

end ArrayTests.General.ArrayTest1c;
")})));
  end ArrayTest1c;


  model ArrayTest2

    Real x[2,2];
  equation
    x[1,1] = 1;
    x[1,2] = 2;
    x[2,1] = 3;
    x[2,2] = 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest2",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation 
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;

end ArrayTests.General.ArrayTest2;
")})));
  end ArrayTest2;

  model ArrayTest3

    Real x[:] = {2,3};
    Real y[2];
  equation
    y[1] = x[1];
    y[2] = x[2];
  end ArrayTest3;

  model ArrayTest4



    model M
      Real x[2];
    end M;
    M m[2];
  equation
    m[1].x[1] = 1;
    m[1].x[2] = 2;
    m[2].x[1] = 3;
    m[2].x[2] = 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest4",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest4
 Real m[1].x[1];
 Real m[1].x[2];
 Real m[2].x[1];
 Real m[2].x[2];
equation 
 m[1].x[1] = 1;
 m[1].x[2] = 2;
 m[2].x[1] = 3;
 m[2].x[2] = 4;
end ArrayTests.General.ArrayTest4;
")})));
  end ArrayTest4;

  model ArrayTest5
    model M
      Real x[3] = {-1,-2,-3};
    end M;
    M m[2](x={{1,2,3},{4,5,6}});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest5",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest5
 Real m[1].x[1];
 Real m[1].x[2];
 Real m[1].x[3];
 Real m[2].x[1];
 Real m[2].x[2];
 Real m[2].x[3];
equation
 m[1].x[1] = 1;
 m[1].x[2] = 2;
 m[1].x[3] = 3;
 m[2].x[1] = 4;
 m[2].x[2] = 5;
 m[2].x[3] = 6;

end ArrayTests.General.ArrayTest5;
")})));
  end ArrayTest5;

  model ArrayTest6
    model M
      Real x[3];
    end M;
    M m[2];
  equation
    m.x = {{1,2,3},{4,5,6}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest6",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest6
 Real m[1].x[1];
 Real m[1].x[2];
 Real m[1].x[3];
 Real m[2].x[1];
 Real m[2].x[2];
 Real m[2].x[3];
equation
 m[1].x[1] = 1;
 m[1].x[2] = 2;
 m[1].x[3] = 3;
 m[2].x[1] = 4;
 m[2].x[2] = 5;
 m[2].x[3] = 6;

end ArrayTests.General.ArrayTest6;
")})));
  end ArrayTest6;

  model ArrayTest7
    Real x[3];
  equation
    x[1:2] = {1,2};
    x[3] = 3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest7",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest7
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;

end ArrayTests.General.ArrayTest7;
")})));
  end ArrayTest7;

  model ArrayTest8
    model M
      parameter Integer n = 3;
      Real x[n] = ones(n);
    end M;
      M m[2](n={1,2});

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayTest8",
			description="Test flattening of variables with sizes given in modifications",
			flatModel="
fclass ArrayTests.General.ArrayTest8
 parameter Integer m[1].n = 1 /* 1 */;
 Real m[1].x[1] = ones(m[1].n);
 parameter Integer m[2].n = 2 /* 2 */;
 Real m[2].x[2] = ones(m[2].n);

end ArrayTests.General.ArrayTest8;
")})));
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest9",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest9
 parameter Integer nn.n2 = 2 /* 2 */;
 parameter Integer nn.m[1,1].n1 = 2 /* 2 */;
 Real nn.m[1,1].x[1];
 Real nn.m[1,1].x[2];
 parameter Integer nn.m[1,2].n1 = 2 /* 2 */;
 Real nn.m[1,2].x[1];
 Real nn.m[1,2].x[2];
 parameter Integer nn.m[1,3].n1 = 2 /* 2 */;
 Real nn.m[1,3].x[1];
 Real nn.m[1,3].x[2];
 parameter Integer nn.m[2,1].n1 = 2 /* 2 */;
 Real nn.m[2,1].x[1];
 Real nn.m[2,1].x[2];
 parameter Integer nn.m[2,2].n1 = 2 /* 2 */;
 Real nn.m[2,2].x[1];
 Real nn.m[2,2].x[2];
 parameter Integer nn.m[2,3].n1 = 2 /* 2 */;
 Real nn.m[2,3].x[1];
 Real nn.m[2,3].x[2];
equation
 nn.m[1,1].x[1] = 1;
 nn.m[1,1].x[2] = 1;
 nn.m[1,2].x[1] = 1;
 nn.m[1,2].x[2] = 1;
 nn.m[1,3].x[1] = 1;
 nn.m[1,3].x[2] = 1;
 nn.m[2,1].x[1] = 1;
 nn.m[2,1].x[2] = 1;
 nn.m[2,2].x[1] = 1;
 nn.m[2,2].x[2] = 1;
 nn.m[2,3].x[1] = 1;
 nn.m[2,3].x[2] = 1;

end ArrayTests.General.ArrayTest9;
")})));
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
        N n[2](m(n1={3,4}));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest95",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest95
 parameter Integer n[1].n2 = 2 /* 2 */;
 parameter Integer n[1].m.n1 = 3 /* 3 */;
 parameter Integer n[2].n2 = 2 /* 2 */;
 parameter Integer n[2].m.n1 = 4 /* 4 */;

end ArrayTests.General.ArrayTest95;
")})));
      end ArrayTest95;


   model ArrayTest10
    parameter Integer n;
    Real x[n];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest10",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest10
 parameter Integer n;

end ArrayTests.General.ArrayTest10;
")})));
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest11",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest11
 Real m1[1].x[1];
 Real m1[1].x[2];
 Real m1[2].x[1];
 Real m1[2].x[2];
 Real m2[1].x[1];
 Real m2[1].x[2];
 Real m2[2].x[1];
 Real m2[2].x[2];
 Real m2[3].x[1];
 Real m2[3].x[2];
equation
 m1[1].x[1] = 1;
 m1[1].x[2] = 2;
 m1[2].x[1] = 3;
 m1[2].x[2] = 4;
 m2[1].x[1] = 1;
 m2[1].x[2] = 2;
 m2[2].x[1] = 3;
 m2[2].x[2] = 4;
 m2[3].x[1] = 1;
 m2[3].x[2] = 2;

end ArrayTests.General.ArrayTest11;
")})));
   end ArrayTest11;

      model ArrayTest12
        model M
              Real x[2];
        end M;

        model N
              M m[3];
        end N;
        N n[1];
      equation
        n.m.x={{{1,2},{3,4},{5,6}}};


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest12",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest12
 Real n[1].m[1].x[1];
 Real n[1].m[1].x[2];
 Real n[1].m[2].x[1];
 Real n[1].m[2].x[2];
 Real n[1].m[3].x[1];
 Real n[1].m[3].x[2];
equation
 n[1].m[1].x[1] = 1;
 n[1].m[1].x[2] = 2;
 n[1].m[2].x[1] = 3;
 n[1].m[2].x[2] = 4;
 n[1].m[3].x[1] = 5;
 n[1].m[3].x[2] = 6;

end ArrayTests.General.ArrayTest12;
")})));
      end ArrayTest12;

  model ArrayTest13
    model C
      parameter Integer n = 2;
    end C;
    C c;
    C cv[c.n];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest13",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest13
 parameter Integer c.n = 2 /* 2 */;
 parameter Integer cv[1].n = 2 /* 2 */;
 parameter Integer cv[2].n = 2 /* 2 */;

end ArrayTests.General.ArrayTest13;
")})));
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


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest14",
			description="Test scalarization of variables",
			flatModel="
fclass ArrayTests.General.ArrayTest14
 Real n.m[1,1].x[1];
 Real n.m[1,2].x[1];
 Real n.m[2,1].x[1];
 Real n.m[2,2].x[1];
 Real n.m[3,1].x[1];
 Real n.m[3,2].x[1];
equation
 n.m[1,1].x[1] = 1;
 n.m[1,2].x[1] = 1;
 n.m[2,1].x[1] = 1;
 n.m[2,2].x[1] = 1;
 n.m[3,1].x[1] = 1;
 n.m[3,2].x[1] = 1;

end ArrayTests.General.ArrayTest14;
")})));
      end ArrayTest14;

model ArrayTest15_Err
   Real x[3] = {{2},{2},{3}};

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayTest15_Err",
			description="Test type checking of arrays",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 251, column 9:
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [3, 1]
")})));
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
	equation
	  x[2] = 1;
    end M;
    M m[2,1];
  end N;
  N n[2];
  equation
//  n.m.x=1;
  n.m.x[1]={{{1},{2}},{{3},{4}}};


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest17",
			description="Test scalarization of variables",
			automatic_add_initial_equations=false,
			flatModel="
fclass ArrayTests.General.ArrayTest17
 Real n[1].m[1,1].x[1];
 Real n[1].m[1,1].x[2];
 Real n[1].m[2,1].x[1];
 Real n[1].m[2,1].x[2];
 Real n[2].m[1,1].x[1];
 Real n[2].m[1,1].x[2];
 Real n[2].m[2,1].x[1];
 Real n[2].m[2,1].x[2];
equation
 n[1].m[1,1].x[1] = 1;
 n[1].m[2,1].x[1] = 2;
 n[2].m[1,1].x[1] = 3;
 n[2].m[2,1].x[1] = 4;
 n[1].m[1,1].x[2] = 1;
 n[1].m[2,1].x[2] = 1;
 n[2].m[1,1].x[2] = 1;
 n[2].m[2,1].x[2] = 1;

end ArrayTests.General.ArrayTest17;
")})));
end ArrayTest17;

model ArrayTest21
  Real x[2];
  Real y[2];
equation
  x=y;
  x=zeros(2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest21",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest21
 Real x[1];
 Real x[2];
equation 
 x[1] = 0;
 x[2] = 0;

end ArrayTests.General.ArrayTest21;

")})));
end ArrayTest21;

model ArrayTest22
  Real x[2];
  Real y[2];
equation
  x=y;
  x=ones(2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest22",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest22
 Real x[1];
 Real x[2];
equation 
 x[1] = 1;
 x[2] = 1;

end ArrayTests.General.ArrayTest22;

")})));
end ArrayTest22;

model ArrayTest23
  Real x[2,2];
  Real y[2,2];
equation
  x=y;
  x=ones(2,2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest23",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest23
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation 
 x[1,1] = 1;
 x[1,2] = 1;
 x[2,1] = 1;
 x[2,2] = 1;

end ArrayTests.General.ArrayTest23;
")})));
end ArrayTest23;

model ArrayTest24

  Real x[2,2];
  Real y[2,2];
equation
  for i in 1:2, j in 1:2 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
  end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest24",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest24
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

end ArrayTests.General.ArrayTest24;
")})));
end ArrayTest24;

model ArrayTest25

  Real x[2,3];
  Real y[2,3];
equation
  for i in 1:2 loop
   for j in 1:3 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
   end for;
  end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest25",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest25
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

end ArrayTests.General.ArrayTest25;
")})));
end ArrayTest25;


model ArrayTest26

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


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest26",
			description="Flattening of arrays.",
			automatic_add_initial_equations=false,
			enable_structural_diagnosis=false,
			flatModel="fclass ArrayTests.General.ArrayTest26
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
end ArrayTests.General.ArrayTest26;
")})));
end ArrayTest26;


model ArrayTest27_Err
   Real x[3](start={1,2});
equation
   der(x) = ones(3);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayTest27_Err",
			description="Test type checking of arrays",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 592, column 13:
  Array size mismatch for the attribute start, size of declaration is [3] and size of start expression is [2]
")})));
end ArrayTest27_Err;


model ArrayTest29
   Real x[3](start={1,2,3});
equation
   der(x) = ones(3);


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest29",
			description="Flattening of arrays.",
			automatic_add_initial_equations=false,
			flatModel="
fclass ArrayTests.General.ArrayTest29
 Real x[1](start = 1);
 Real x[2](start = 2);
 Real x[3](start = 3);
equation
 der(x[1]) = 1;
 der(x[2]) = 1;
 der(x[3]) = 1;
end ArrayTests.General.ArrayTest29;
")})));
end ArrayTest29;

model ArrayTest30

   Real x[3,2](start={{1,2},{3,4},{5,6}});
equation
   der(x) = {{-1,-2},{-3,-4},{-5,-6}};


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest30",
			description="Flattening of arrays.",
			automatic_add_initial_equations=false,
			flatModel="
fclass ArrayTests.General.ArrayTest30
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

end ArrayTests.General.ArrayTest30;
")})));
end ArrayTest30;

model ArrayTest31
  Real x[2];
equation
 x = {sin(time),cos(time)};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest31",
			description="Flattening of arrays.",
			flatModel="
fclass ArrayTests.General.ArrayTest31
 Real x[1];
 Real x[2];
equation
 x[1] = sin(time);
 x[2] = cos(time);
end ArrayTests.General.ArrayTest31;
")})));
end ArrayTest31;

model ArrayTest32
 Real x[2];
initial equation
 x = {1,-2};
equation
 der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest32",
			description="Scalarization of initial equation",
			flatModel="
fclass ArrayTests.General.ArrayTest32
 Real x[1];
 Real x[2];
initial equation 
 x[1] = 1;
 x[2] =  - ( 2 );
equation
 der(x[1]) =  - ( x[1] );
 der(x[2]) =  - ( x[2] );

end ArrayTests.General.ArrayTest32;
")})));
end ArrayTest32;


model ArrayTest33
  model C
	Real x;
  equation
    x = 1;
  end C;
  
  C c[3];

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayTest33",
			description="Equations in array components",
			flatModel="
fclass ArrayTests.General.ArrayTest33
 Real c[1].x;
 Real c[2].x;
 Real c[3].x;
equation
 c[1].x = 1;
 c[2].x = 1;
 c[3].x = 1;

end ArrayTests.General.ArrayTest33;
")})));
end ArrayTest33;


model ArrayTest34
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

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayTest34",
			description="Equations in array components",
			flatModel="
fclass ArrayTests.General.ArrayTest34
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

end ArrayTests.General.ArrayTest34;
")})));
end ArrayTest34;


// TODO: the result is wrong, but tests a fixed crash bug - change when cat + unknown array sizes are supported
model ArrayTest35
	function f
		input Real[:] x;
		output Real[2 * size(x, 1) + 1] y = cat(1, x, zeros(size(x, 1) + 1));
	algorithm
	end f;
	
	Real[5] z = f({1,2});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest35",
			description="Test adding array sizes that are present as expressions in tree",
			flatModel="
fclass ArrayTests.General.ArrayTest35
 Real z[1];
 Real z[2];
 Real z[3];
 Real z[4];
 Real z[5];
equation
 ({z[1],z[2],z[3],z[4],z[5]}) = ArrayTests.General.ArrayTest35.f({1,2});

public
 function ArrayTests.General.ArrayTest35.f
  input Real[:] x;
  output Real[( 2 ) * ( size(x, 1) ) + 1] y;
 algorithm
  for i1 in 1:size(y, 1) loop
   y[i1] := cat(1, x, zeros(size(x, 1) + 1));
  end for;
  return;
 end ArrayTests.General.ArrayTest35.f;

end ArrayTests.General.ArrayTest35;
")})));
end ArrayTest35;

end General;


package UnknownSize

model UnknownSize1
 Real x[:,:] = {{1,2},{3,4}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="UnknownSize1",
			description="Using unknown array sizes: deciding with binding exp",
			flatModel="
fclass ArrayTests.UnknownSize.UnknownSize1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;

end ArrayTests.UnknownSize.UnknownSize1;
")})));
end UnknownSize1;


model UnknownSize2
 model A
  Real z[:] = {1};
 end A;
 
 model B
  A y[2](z={{1,2},{3,4}});
 end B;
 
 B x[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="UnknownSize2",
			description="Using unknown array sizes: binding exp through modification on array",
			flatModel="
fclass ArrayTests.UnknownSize.UnknownSize2
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

end ArrayTests.UnknownSize.UnknownSize2;
")})));
end UnknownSize2;


model UnknownSize3
 Real x[1,:] = {{1,2}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="UnknownSize3",
			description="Using unknown array sizes: one dim known, one unknown",
			flatModel="
fclass ArrayTests.UnknownSize.UnknownSize3
 Real x[1,1];
 Real x[1,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;

end ArrayTests.UnknownSize.UnknownSize3;
")})));
end UnknownSize3;


model UnknownSize4
 Real x[1,:] = {1,2};

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnknownSize4",
			description="Using unknown array sizes: too few dims",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 789, column 7:
  Can not infer array size of the variable x
Semantic error at line 789, column 7:
  Array size mismatch in declaration of x, size of declaration is [1, :] and size of binding expression is [2]
")})));
end UnknownSize4;


model UnknownSize5
 Real x[1,:] = {{1,2},{3,4}};

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnknownSize5",
			description="Using unknown array sizes: one dim specified and does not match",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 805, column 7:
  Array size mismatch in declaration of x, size of declaration is [1, 2] and size of binding expression is [2, 2]
")})));
end UnknownSize5;


model UnknownSize6
 Real x[:,:];
equation
 x = {{1,2},{3,4}};

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnknownSize6",
			description="Using unknown array sizes:",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 821, column 7:
  Can not infer array size of the variable x
Semantic error at line 823, column 2:
  The right and left expression types of equation are not compatible
")})));
end UnknownSize6;

end UnknownSize;


package Subscripts
	
model SubscriptExpression1
 Real x[4];
equation
 x[1] = 1;
 for i in 2:4 loop
  x[i] = x[i-1] * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SubscriptExpression1",
			description="Replacing expressions in array subscripts with literals: basic test",
			flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
equation
 x[1] = 1;
 x[2] = ( x[1] ) * ( 2 );
 x[3] = ( x[2] ) * ( 2 );
 x[4] = ( x[3] ) * ( 2 );

end ArrayTests.Subscripts.SubscriptExpression1;
")})));
end SubscriptExpression1;


model SubscriptExpression2
 Real x[4];
equation
 x[0] = 1;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="SubscriptExpression2",
			description="Type checking array subscripts: literal < 1",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 737, column 4:
  Array index out of bounds: 0, index expression: 0
")})));
end SubscriptExpression2;


model SubscriptExpression3
 Real x[4];
equation
 x[5] = 1;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="SubscriptExpression3",
			description="Type checking array subscripts: literal > end",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 754, column 4:
  Array index out of bounds: 5, index expression: 5
")})));
end SubscriptExpression3;


model SubscriptExpression4
 Real x[4];
equation
 for i in 1:4 loop
  x[i] = x[i-1] * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="SubscriptExpression4",
			description="Type checking array subscripts: expression < 1",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 750, column 12:
  Array index out of bounds: 0, index expression: i - ( 1 )
")})));
end SubscriptExpression4;


model SubscriptExpression5
 Real x[4];
equation
 for i in 1:4 loop
  x[i] = x[i+1] * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="SubscriptExpression5",
			description="Type checking array subscripts: expression > end",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 769, column 12:
  Array index out of bounds: 5, index expression: i + 1
")})));
end SubscriptExpression5;


model SubscriptExpression6
 Real x[16];
equation
 for i in 1:4, j in 1:4 loop
  x[4*(i-1) + j] = i + j * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SubscriptExpression6",
			description="Type checking array subscripts: simulating [4,4] with [16]",
			flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression6
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

end ArrayTests.Subscripts.SubscriptExpression6;
")})));
end SubscriptExpression6;


model SubscriptExpression7
 Real x[4,4];
equation
 for i in 1:4, j in 1:4 loop
  x[i, j + i - min(i, j)] = i + j * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SubscriptExpression7",
			description="Type checking array subscripts: using min in subscripts",
			automatic_add_initial_equations=false,
			enable_structural_diagnosis=false,
			flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression7
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

end ArrayTests.Subscripts.SubscriptExpression7;
")})));
end SubscriptExpression7;


model SubscriptExpression8
 Real x[4];
equation
 for i in 1:4, j in 1:4 loop
  x[i + j * max(i*(1:4))] = i + j * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="SubscriptExpression8",
			description="Type checking array subscripts: complex expression, several bad indices",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1499, column 5:
  Array index out of bounds: 5, index expression: i + ( j ) * ( max(( i ) * ( 1:4 )) )
")})));
end SubscriptExpression8;



model NumSubscripts1
 Real x = 1;
 Real y = x[1];

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NumSubscripts1",
			description="Check number of array subscripts:",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1928, column 12:
  Too many array subscripts for access: 1 subscripts given, component has 0 dimensions
")})));
end NumSubscripts1;


model NumSubscripts2
 Real x[1,1] = {{1}};
 Real y = x[1,1,1];

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="NumSubscripts2",
			description="Check number of array subscripts:",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1945, column 12:
  Too many array subscripts for access: 3 subscripts given, component has 2 dimensions
")})));
end NumSubscripts2;

end Subscripts;



/* ========== Array algebra ========== */
package Algebra

package Add
	
model ArrayAdd1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayAdd1",
			description="Scalarization of addition: Real[2] + Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayAdd1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] + 10;
 x[2] = y[2] + 20;
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Add.ArrayAdd1;
")})));
end ArrayAdd1;


model ArrayAdd2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayAdd2",
			description="Scalarization of addition: Real[2,2] + Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayAdd2
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

end ArrayTests.Algebra.Add.ArrayAdd2;
")})));
end ArrayAdd2;


model ArrayAdd3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayAdd3",
			description="Scalarization of addition: Real[2,2,2] + Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayAdd3
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

end ArrayTests.Algebra.Add.ArrayAdd3;
")})));
end ArrayAdd3;


model ArrayAdd4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + 10;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd4",
			description="Scalarization of addition: Real[2] + Integer",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 796, column 6:
  Type error in expression: y + 10
")})));
end ArrayAdd4;


model ArrayAdd5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + 10;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd5",
			description="Scalarization of addition: Real[2,2] + Integer",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 815, column 6:
  Type error in expression: y + 10
")})));
end ArrayAdd5;


model ArrayAdd6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + 10;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd6",
			description="Scalarization of addition: Real[2,2,2] + Integer",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 834, column 6:
  Type error in expression: y + 10
")})));
end ArrayAdd6;


model ArrayAdd7
 Real x[2];
 Real y = 1;
equation
 x = y + { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd7",
			description="Scalarization of addition: Real + Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 853, column 6:
  Type error in expression: y + {10, 20}
")})));
end ArrayAdd7;


model ArrayAdd8
 Real x[2,2];
 Real y = 1;
equation
 x = y + { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd8",
			description="Scalarization of addition: Real + Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 861, column 6:
  Type error in expression: y + {{10, 20}, {30, 40}}
")})));
end ArrayAdd8;


model ArrayAdd9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd9",
			description="Scalarization of addition: Real + Integer[2,2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 869, column 6:
  Type error in expression: y + {{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}
")})));
end ArrayAdd9;


model ArrayAdd10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd10",
			description="Scalarization of addition: Real[2] + Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 910, column 6:
  Type error in expression: y + {10, 20, 30}
")})));
end ArrayAdd10;


model ArrayAdd11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd11",
			description="Scalarization of addition: Real[2] + Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 929, column 6:
  Type error in expression: y + {{10, 20}, {30, 40}}
")})));
end ArrayAdd11;


model ArrayAdd12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAdd12",
			description="Scalarization of addition: Real[2] + String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 948, column 6:
  Type error in expression: y + {\"1\", \"2\"}
")})));
end ArrayAdd12;



model ArrayDotAdd1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd1",
			description="Scalarization of element-wise addition: Real[2] .+ Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .+ 10;
 x[2] = y[2] .+ 20;
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Add.ArrayDotAdd1;
")})));
end ArrayDotAdd1;


model ArrayDotAdd2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd2",
			description="Scalarization of element-wise addition: Real[2,2] .+ Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd2
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

end ArrayTests.Algebra.Add.ArrayDotAdd2;
")})));
end ArrayDotAdd2;


model ArrayDotAdd3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .+ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd3",
			description="Scalarization of element-wise addition: Real[2,2,2] .+ Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd3
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

end ArrayTests.Algebra.Add.ArrayDotAdd3;
")})));
end ArrayDotAdd3;


model ArrayDotAdd4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd4",
			description="Scalarization of element-wise addition: Real[2] .+ Integer",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .+ 10;
 x[2] = y[2] .+ 10;
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Add.ArrayDotAdd4;
")})));
end ArrayDotAdd4;


model ArrayDotAdd5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .+ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd5",
			description="Scalarization of element-wise addition: Real[2,2] .+ Integer",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd5
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

end ArrayTests.Algebra.Add.ArrayDotAdd5;
")})));
end ArrayDotAdd5;


model ArrayDotAdd6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .+ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd6",
			description="Scalarization of element-wise addition: Real[2,2,2] .+ Integer",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd6
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

end ArrayTests.Algebra.Add.ArrayDotAdd6;
")})));
end ArrayDotAdd6;


model ArrayDotAdd7
 Real x[2];
 Real y = 1;
equation
 x = y .+ { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd7",
			description="Scalarization of element-wise addition: Real .+ Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = y .+ 10;
 x[2] = y .+ 20;
 y = 1;

end ArrayTests.Algebra.Add.ArrayDotAdd7;
")})));
end ArrayDotAdd7;


model ArrayDotAdd8
 Real x[2,2];
 Real y = 1;
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd8",
			description="Scalarization of element-wise addition: Real .+ Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd8
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

end ArrayTests.Algebra.Add.ArrayDotAdd8;
")})));
end ArrayDotAdd8;


model ArrayDotAdd9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .+ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotAdd9",
			description="Scalarization of element-wise addition: Real .+ Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd9
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

end ArrayTests.Algebra.Add.ArrayDotAdd9;
")})));
end ArrayDotAdd9;


model ArrayDotAdd10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotAdd10",
			description="Scalarization of element-wise addition: Real[2] .+ Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2508, column 6:
  Type error in expression: y .+ {10, 20, 30}
")})));
end ArrayDotAdd10;


model ArrayDotAdd11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotAdd11",
			description="Scalarization of element-wise addition: Real[2] .+ Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2527, column 6:
  Type error in expression: y .+ {{10, 20}, {30, 40}}
")})));
end ArrayDotAdd11;


model ArrayDotAdd12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotAdd12",
			description="Scalarization of element-wise addition: Real[2] .+ String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2546, column 6:
  Type error in expression: y .+ {\"1\", \"2\"}
")})));
end ArrayDotAdd12;

end Add;


package Sub
	
model ArraySub1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArraySub1",
			description="Scalarization of subtraction: Real[2] - Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArraySub1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] - ( 10 );
 x[2] = y[2] - ( 20 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Sub.ArraySub1;
")})));
end ArraySub1;


model ArraySub2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y - { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArraySub2",
			description="Scalarization of subtraction: Real[2,2] - Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArraySub2
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

end ArrayTests.Algebra.Sub.ArraySub2;
")})));
end ArraySub2;


model ArraySub3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y - { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArraySub3",
			description="Scalarization of subtraction: Real[2,2,2] - Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArraySub3
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

end ArrayTests.Algebra.Sub.ArraySub3;
")})));
end ArraySub3;


model ArraySub4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - 10;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub4",
			description="Scalarization of subtraction: Real[2] - Integer",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1078, column 6:
  Type error in expression: y - ( 10 )
")})));
end ArraySub4;


model ArraySub5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y - 10;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub5",
			description="Scalarization of subtraction: Real[2,2] - Integer",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1097, column 6:
  Type error in expression: y - ( 10 )
")})));
end ArraySub5;


model ArraySub6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y - 10;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub6",
			description="Scalarization of subtraction: Real[2,2,2] - Integer",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1116, column 6:
  Type error in expression: y - ( 10 )
")})));
end ArraySub6;


model ArraySub7
 Real x[2];
 Real y = 1;
equation
 x = y - { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub7",
			description="Scalarization of subtraction: Real - Integer[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1135, column 6:
  Type error in expression: y - ( {10, 20} )
")})));
end ArraySub7;


model ArraySub8
 Real x[2,2];
 Real y = 1;
equation
 x = y - { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub8",
			description="Scalarization of subtraction: Real - Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1154, column 6:
  Type error in expression: y - ( {{10, 20}, {30, 40}} )
")})));
end ArraySub8;


model ArraySub9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y - { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub9",
			description="Scalarization of subtraction: Real - Integer[2,2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1173, column 6:
  Type error in expression: y - ( {{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}} )
")})));
end ArraySub9;


model ArraySub10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub10",
			description="Scalarization of subtraction: Real[2] - Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1192, column 6:
  Type error in expression: y - ( {10, 20, 30} )
")})));
end ArraySub10;


model ArraySub11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub11",
			description="Scalarization of subtraction: Real[2] - Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1211, column 6:
  Type error in expression: y - ( {{10, 20}, {30, 40}} )
")})));
end ArraySub11;


model ArraySub12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySub12",
			description="Scalarization of subtraction: Real[2] - String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1230, column 6:
  Type error in expression: y - ( {\"1\", \"2\"} )
")})));
end ArraySub12;



model ArrayDotSub1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub1",
			description="Scalarization of element-wise subtraction: Real[2] .- Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .- ( 10 );
 x[2] = y[2] .- ( 20 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Sub.ArrayDotSub1;
")})));
end ArrayDotSub1;


model ArrayDotSub2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .- { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub2",
			description="Scalarization of element-wise subtraction: Real[2,2] .- Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub2
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

end ArrayTests.Algebra.Sub.ArrayDotSub2;
")})));
end ArrayDotSub2;


model ArrayDotSub3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .- { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub3",
			description="Scalarization of element-wise subtraction: Real[2,2,2] .- Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub3
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

end ArrayTests.Algebra.Sub.ArrayDotSub3;
")})));
end ArrayDotSub3;


model ArrayDotSub4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub4",
			description="Scalarization of element-wise subtraction: Real[2] .- Integer",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .- ( 10 );
 x[2] = y[2] .- ( 10 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Sub.ArrayDotSub4;
")})));
end ArrayDotSub4;


model ArrayDotSub5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .- 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub5",
			description="Scalarization of element-wise subtraction: Real[2,2] .- Integer",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub5
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

end ArrayTests.Algebra.Sub.ArrayDotSub5;
")})));
end ArrayDotSub5;


model ArrayDotSub6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .- 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub6",
			description="Scalarization of element-wise subtraction: Real[2,2,2] .- Integer",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub6
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

end ArrayTests.Algebra.Sub.ArrayDotSub6;
")})));
end ArrayDotSub6;


model ArrayDotSub7
 Real x[2];
 Real y = 1;
equation
 x = y .- { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub7",
			description="Scalarization of element-wise subtraction: Real .- Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = y .- ( 10 );
 x[2] = y .- ( 20 );
 y = 1;

end ArrayTests.Algebra.Sub.ArrayDotSub7;
")})));
end ArrayDotSub7;


model ArrayDotSub8
 Real x[2,2];
 Real y = 1;
equation
 x = y .- { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub8",
			description="Scalarization of element-wise subtraction: Real .- Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub8
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

end ArrayTests.Algebra.Sub.ArrayDotSub8;
")})));
end ArrayDotSub8;


model ArrayDotSub9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .- { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotSub9",
			description="Scalarization of element-wise subtraction: Real .- Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub9
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

end ArrayTests.Algebra.Sub.ArrayDotSub9;
")})));
end ArrayDotSub9;


model ArrayDotSub10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotSub10",
			description="Scalarization of element-wise subtraction: Real[2] .- Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2638, column 6:
  Type error in expression: y .- ( {10, 20, 30} )
")})));
end ArrayDotSub10;


model ArrayDotSub11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotSub11",
			description="Scalarization of element-wise subtraction: Real[2] .- Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2657, column 6:
  Type error in expression: y .- ( {{10, 20}, {30, 40}} )
")})));
end ArrayDotSub11;


model ArrayDotSub12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotSub12",
			description="Scalarization of element-wise subtraction: Real[2] .- String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2676, column 6:
  Type error in expression: y .- ( {\"1\", \"2\"} )
")})));
end ArrayDotSub12;

end Sub;


package Mul
	
model ArrayMulOK1
 Real x;
 Real y[3] = { 1, 2, 3 };
equation
 x = y * { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK1",
			description="Scalarization of multiplication: Real[3] * Integer[3]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK1
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = ( y[1] ) * ( 10 ) + ( y[2] ) * ( 20 ) + ( y[3] ) * ( 30 );
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;

end ArrayTests.Algebra.Mul.ArrayMulOK1;
")})));
end ArrayMulOK1;


model ArrayMulOK2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK2",
			description="Scalarization of multiplication: Real[2,2] * Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK2
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

end ArrayTests.Algebra.Mul.ArrayMulOK2;
")})));
end ArrayMulOK2;


model ArrayMulOK3
 Real x[3,4];
 Real y[2,4] = { { 1, 2, 3, 4 }, { 5, 6, 7, 8 } };
equation
 x = { { 10, 20 }, { 30, 40 }, { 50, 60 } } * y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK3",
			description="Scalarization of multiplication: Integer[3,2] * Real[2,4]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK3
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

end ArrayTests.Algebra.Mul.ArrayMulOK3;
")})));
end ArrayMulOK3;


model ArrayMulOK4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK4",
			description="Scalarization of multiplication: Real[2] * Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) * ( 10 ) + ( y[2] ) * ( 30 );
 x[2] = ( y[1] ) * ( 20 ) + ( y[2] ) * ( 40 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Mul.ArrayMulOK4;
")})));
end ArrayMulOK4;


model ArrayMulOK5
 Real x[2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK5",
			description="Scalarization of multiplication: Real[2,2] * Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK5
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

end ArrayTests.Algebra.Mul.ArrayMulOK5;
")})));
end ArrayMulOK5;


model ArrayMulOK6
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK6",
			description="Scalarization of multiplication: Real[2] * Integer",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK6
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) * ( 10 );
 x[2] = ( y[2] ) * ( 10 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Mul.ArrayMulOK6;
")})));
end ArrayMulOK6;


model ArrayMulOK7
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK7",
			description="Scalarization of multiplication: Real[2,2] * Integer",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK7
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

end ArrayTests.Algebra.Mul.ArrayMulOK7;
")})));
end ArrayMulOK7;


model ArrayMulOK8
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y * 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK8",
			description="Scalarization of multiplication: Real[2,2,2] * Integer",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK8
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

end ArrayTests.Algebra.Mul.ArrayMulOK8;
")})));
end ArrayMulOK8;


model ArrayMulOK9
 Real x[2];
 Real y = 1;
equation
 x = y * { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK9",
			description="Scalarization of multiplication: Real * Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK9
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = ( y ) * ( 10 );
 x[2] = ( y ) * ( 20 );
 y = 1;

end ArrayTests.Algebra.Mul.ArrayMulOK9;
")})));
end ArrayMulOK9;


model ArrayMulOK10
 Real x[2,2];
 Real y = 1;
equation
 x = y * { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK10",
			description="Scalarization of multiplication: Real * Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK10
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

end ArrayTests.Algebra.Mul.ArrayMulOK10;
")})));
end ArrayMulOK10;


model ArrayMulOK11
 Real x[2,2,2];
 Real y = 1;
equation
 x = y * { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK11",
			description="Scalarization of multiplication: Real * Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK11
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

end ArrayTests.Algebra.Mul.ArrayMulOK11;
")})));
end ArrayMulOK11;


model ArrayMulOK12
 Real x[2,1];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10 }, { 20 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK12",
			description="Scalarization of multiplication: Real[2,2] * Integer[2,1]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK12
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

end ArrayTests.Algebra.Mul.ArrayMulOK12;
")})));
end ArrayMulOK12;


model ArrayMulOK13
 Real x[3] = { 1, 2, 3 };
 Real y[3] = x * x * x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayMulOK13",
			description="Scalarization of multiplication: check that type() of Real[3] * Real[3] is correct",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK13
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

end ArrayTests.Algebra.Mul.ArrayMulOK13;
")})));
end ArrayMulOK13;


model ArrayMulErr1
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y * { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr1",
			description="Scalarization of multiplication: Real[2,2,2] * Integer[2,2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1602, column 6:
  Type error in expression: ( y ) * ( {{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}} )
")})));
end ArrayMulErr1;


model ArrayMulErr2
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr2",
			description="Scalarization of multiplication: Real[2] * Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1621, column 6:
  Type error in expression: ( y ) * ( {10, 20, 30} )
")})));
end ArrayMulErr2;


model ArrayMulErr3
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr3",
			description="Scalarization of multiplication: Real[2] * String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1640, column 6:
  Type error in expression: ( y ) * ( {\"1\", \"2\"} )
")})));
end ArrayMulErr3;


model ArrayMulErr4
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 }, { 30, 40 }, { 50, 60 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr4",
			description="Scalarization of multiplication: Real[2,2] * Integer[3,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1659, column 6:
  Type error in expression: ( y ) * ( {{10, 20}, {30, 40}, {50, 60}} )
")})));
end ArrayMulErr4;


model ArrayMulErr5
 Real x[2,2];
 Real y[2,3] = { { 1, 2, 3 }, { 4, 5, 6 } };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr5",
			description="Scalarization of multiplication: Real[2,3] * Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1678, column 6:
  Type error in expression: ( y ) * ( {{10, 20}, {30, 40}} )
")})));
end ArrayMulErr5;


model ArrayMulErr6
 Real x[2,2];
 Real y[2,3] = { { 1, 2, 3 }, { 4, 5, 6 } };
equation
 x = y * { { 10, 20, 30 }, { 40, 50, 60 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr6",
			description="Scalarization of multiplication: Real[2,3] * Integer[2,3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1697, column 6:
  Type error in expression: ( y ) * ( {{10, 20, 30}, {40, 50, 60}} )
")})));
end ArrayMulErr6;


model ArrayMulErr7
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr7",
			description="Scalarization of multiplication: Real[2,2] * Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1716, column 6:
  Type error in expression: ( y ) * ( {10, 20, 30} )
")})));
end ArrayMulErr7;


model ArrayMulErr8
 Real x[2,2];
 Real y[3] = { 1, 2, 3 };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr8",
			description="Scalarization of multiplication: Real[3] * Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1735, column 6:
  Type error in expression: ( y ) * ( {{10, 20}, {30, 40}} )
")})));
end ArrayMulErr8;


model ArrayMulErr9
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayMulErr9",
			description="Scalarization of multiplication: Real[2,2] * Integer[1,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1754, column 6:
  Type error in expression: ( y ) * ( {{10, 20}} )
")})));
end ArrayMulErr9;



model ArrayDotMul1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul1",
			description="Scalarization of element-wise multiplication: Real[2] .* Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) .* ( 10 );
 x[2] = ( y[2] ) .* ( 20 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Mul.ArrayDotMul1;
")})));
end ArrayDotMul1;


model ArrayDotMul2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .* { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul2",
			description="Scalarization of element-wise multiplication: Real[2,2] .* Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul2
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

end ArrayTests.Algebra.Mul.ArrayDotMul2;
")})));
end ArrayDotMul2;


model ArrayDotMul3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .* { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul3",
			description="Scalarization of element-wise multiplication: Real[2,2,2] .* Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul3
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

end ArrayTests.Algebra.Mul.ArrayDotMul3;
")})));
end ArrayDotMul3;


model ArrayDotMul4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul4",
			description="Scalarization of element-wise multiplication: Real[2] .* Integer",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) .* ( 10 );
 x[2] = ( y[2] ) .* ( 10 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Mul.ArrayDotMul4;
")})));
end ArrayDotMul4;


model ArrayDotMul5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .* 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul5",
			description="Scalarization of element-wise multiplication: Real[2,2] .* Integer",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul5
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

end ArrayTests.Algebra.Mul.ArrayDotMul5;
")})));
end ArrayDotMul5;


model ArrayDotMul6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .* 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul6",
			description="Scalarization of element-wise multiplication: Real[2,2,2] .* Integer",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul6
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

end ArrayTests.Algebra.Mul.ArrayDotMul6;
")})));
end ArrayDotMul6;


model ArrayDotMul7
 Real x[2];
 Real y = 1;
equation
 x = y .* { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul7",
			description="Scalarization of element-wise multiplication: Real .* Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = ( y ) .* ( 10 );
 x[2] = ( y ) .* ( 20 );
 y = 1;

end ArrayTests.Algebra.Mul.ArrayDotMul7;
")})));
end ArrayDotMul7;


model ArrayDotMul8
 Real x[2,2];
 Real y = 1;
equation
 x = y .* { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul8",
			description="Scalarization of element-wise multiplication: Real .* Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul8
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

end ArrayTests.Algebra.Mul.ArrayDotMul8;
")})));
end ArrayDotMul8;


model ArrayDotMul9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .* { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotMul9",
			description="Scalarization of element-wise multiplication: Real .* Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul9
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

end ArrayTests.Algebra.Mul.ArrayDotMul9;
")})));
end ArrayDotMul9;


model ArrayDotMul10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotMul10",
			description="Scalarization of element-wise multiplication: Real[2] .* Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2638, column 6:
  Type error in expression: ( y ) .* ( {10, 20, 30} )
")})));
end ArrayDotMul10;


model ArrayDotMul11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotMul11",
			description="Scalarization of element-wise multiplication: Real[2] .* Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2657, column 6:
  Type error in expression: ( y ) .* ( {{10, 20}, {30, 40}} )
")})));
end ArrayDotMul11;


model ArrayDotMul12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotMul12",
			description="Scalarization of element-wise multiplication: Real[2] .* String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2676, column 6:
  Type error in expression: ( y ) .* ( {\"1\", \"2\"} )
")})));
end ArrayDotMul12;

end Mul;


package Div
	
model ArrayDiv1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDiv1",
			description="Scalarization of division: Real[2] / Integer[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1994, column 6:
  Type error in expression: ( y ) / ( {10, 20} )
")})));
end ArrayDiv1;


model ArrayDiv2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y / { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDiv2",
			description="Scalarization of division: Real[2,2] / Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2013, column 6:
  Type error in expression: ( y ) / ( {{10, 20}, {30, 40}} )
")})));
end ArrayDiv2;


model ArrayDiv3
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDiv3",
			description="Scalarization of division: Real[2] / Integer",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDiv3
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) / ( 10 );
 x[2] = ( y[2] ) / ( 10 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Div.ArrayDiv3;
")})));
end ArrayDiv3;


model ArrayDiv4
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y / 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDiv4",
			description="Scalarization of division: Real[2,2] / Integer",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDiv4
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

end ArrayTests.Algebra.Div.ArrayDiv4;
")})));
end ArrayDiv4;


model ArrayDiv5
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y / 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDiv5",
			description="Scalarization of division: Real[2,2,2] / Integer",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDiv5
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

end ArrayTests.Algebra.Div.ArrayDiv5;
")})));
end ArrayDiv5;


model ArrayDiv6
 Real x[2];
 Real y = 1;
equation
 x = y / { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDiv6",
			description="Scalarization of division: Real / Integer[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2056, column 6:
  Type error in expression: ( y ) / ( {10, 20} )
")})));
end ArrayDiv6;


model ArrayDiv7
 Real x[2,2];
 Real y = 1;
equation
 x = y / { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDiv7",
			description="Scalarization of division: Real / Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2075, column 6:
  Type error in expression: ( y ) / ( {{10, 20}, {30, 40}} )
")})));
end ArrayDiv7;


model ArrayDiv8
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDiv8",
			description="Scalarization of division: Real[2] / String",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2094, column 6:
  Type error in expression: ( y ) / ( {\"1\", \"2\"} )
")})));
end ArrayDiv8;



model ArrayDotDiv1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv1",
			description="Scalarization of element-wise division: Real[2] ./ Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) ./ ( 10 );
 x[2] = ( y[2] ) ./ ( 20 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Div.ArrayDotDiv1;
")})));
end ArrayDotDiv1;


model ArrayDotDiv2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv2",
			description="Scalarization of element-wise division: Real[2,2] ./ Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv2
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

end ArrayTests.Algebra.Div.ArrayDotDiv2;
")})));
end ArrayDotDiv2;


model ArrayDotDiv3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y ./ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv3",
			description="Scalarization of element-wise division: Real[2,2,2] ./ Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv3
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

end ArrayTests.Algebra.Div.ArrayDotDiv3;
")})));
end ArrayDotDiv3;


model ArrayDotDiv4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv4",
			description="Scalarization of element-wise division: Real[2] ./ Integer",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = ( y[1] ) ./ ( 10 );
 x[2] = ( y[2] ) ./ ( 10 );
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Div.ArrayDotDiv4;
")})));
end ArrayDotDiv4;


model ArrayDotDiv5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y ./ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv5",
			description="Scalarization of element-wise division: Real[2,2] ./ Integer",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv5
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

end ArrayTests.Algebra.Div.ArrayDotDiv5;
")})));
end ArrayDotDiv5;


model ArrayDotDiv6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y ./ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv6",
			description="Scalarization of element-wise division: Real[2,2,2] ./ Integer",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv6
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

end ArrayTests.Algebra.Div.ArrayDotDiv6;
")})));
end ArrayDotDiv6;


model ArrayDotDiv7
 Real x[2];
 Real y = 1;
equation
 x = y ./ { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv7",
			description="Scalarization of element-wise division: Real ./ Integer[2]",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = ( y ) ./ ( 10 );
 x[2] = ( y ) ./ ( 20 );
 y = 1;

end ArrayTests.Algebra.Div.ArrayDotDiv7;
")})));
end ArrayDotDiv7;


model ArrayDotDiv8
 Real x[2,2];
 Real y = 1;
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv8",
			description="Scalarization of element-wise division: Real ./ Integer[2,2]",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv8
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

end ArrayTests.Algebra.Div.ArrayDotDiv8;
")})));
end ArrayDotDiv8;


model ArrayDotDiv9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y ./ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotDiv9",
			description="Scalarization of element-wise division: Real ./ Integer[2,2,2]",
			flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv9
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

end ArrayTests.Algebra.Div.ArrayDotDiv9;
")})));
end ArrayDotDiv9;


model ArrayDotDiv10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotDiv10",
			description="Scalarization of element-wise division: Real[2] ./ Integer[3]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2638, column 6:
  Type error in expression: ( y ) ./ ( {10, 20, 30} )
")})));
end ArrayDotDiv10;


model ArrayDotDiv11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotDiv11",
			description="Scalarization of element-wise division: Real[2] ./ Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2657, column 6:
  Type error in expression: ( y ) ./ ( {{10, 20}, {30, 40}} )
")})));
end ArrayDotDiv11;


model ArrayDotDiv12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotDiv12",
			description="Scalarization of element-wise division: Real[2] ./ String[2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 2676, column 6:
  Type error in expression: ( y ) ./ ( {\"1\", \"2\"} )
")})));
end ArrayDotDiv12;

end Div;


package Pow
	
model ArrayDotPow1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow1",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .^ 10;
 x[2] = y[2] .^ 20;
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Pow.ArrayDotPow1;
")})));
end ArrayDotPow1;


model ArrayDotPow2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow2",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow2
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

end ArrayTests.Algebra.Pow.ArrayDotPow2;
")})));
end ArrayDotPow2;


model ArrayDotPow3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .^ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow3",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow3
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

end ArrayTests.Algebra.Pow.ArrayDotPow3;
")})));
end ArrayDotPow3;


model ArrayDotPow4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow4",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 x[1] = y[1] .^ 10;
 x[2] = y[2] .^ 10;
 y[1] = 1;
 y[2] = 2;

end ArrayTests.Algebra.Pow.ArrayDotPow4;
")})));
end ArrayDotPow4;


model ArrayDotPow5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .^ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow5",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow5
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

end ArrayTests.Algebra.Pow.ArrayDotPow5;
")})));
end ArrayDotPow5;


model ArrayDotPow6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .^ 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow6",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow6
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

end ArrayTests.Algebra.Pow.ArrayDotPow6;
")})));
end ArrayDotPow6;


model ArrayDotPow7
 Real x[2];
 Real y = 1;
equation
 x = y .^ { 10, 20 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow7",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow7
 Real x[1];
 Real x[2];
 Real y;
equation
 x[1] = y .^ 10;
 x[2] = y .^ 20;
 y = 1;

end ArrayTests.Algebra.Pow.ArrayDotPow7;
")})));
end ArrayDotPow7;


model ArrayDotPow8
 Real x[2,2];
 Real y = 1;
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow8",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow8
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

end ArrayTests.Algebra.Pow.ArrayDotPow8;
")})));
end ArrayDotPow8;


model ArrayDotPow9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .^ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayDotPow9",
			description="Scalarization of element-wise exponentiation:",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow9
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

end ArrayTests.Algebra.Pow.ArrayDotPow9;
")})));
end ArrayDotPow9;


model ArrayDotPow10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { 10, 20, 30 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotPow10",
			description="Scalarization of element-wise exponentiation:",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 3972, column 6:
  Type error in expression: ( y ) .^ ( {10, 20, 30} )
")})));
end ArrayDotPow10;


model ArrayDotPow11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotPow11",
			description="Scalarization of element-wise exponentiation:",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 3991, column 6:
  Type error in expression: ( y ) .^ ( {{10, 20}, {30, 40}} )
")})));
end ArrayDotPow11;


model ArrayDotPow12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { "1", "2" };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayDotPow12",
			description="Scalarization of element-wise exponentiation:",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4010, column 6:
  Type error in expression: ( y ) .^ ( {\"1\", \"2\"} )
")})));
end ArrayDotPow12;



model ArrayPow1
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow1",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 0",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 0;
 x[2,1] = 0;
 x[2,2] = 1;

end ArrayTests.Algebra.Pow.ArrayPow1;
")})));
end ArrayPow1;


model ArrayPow2
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow2",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 1",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow2
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;

end ArrayTests.Algebra.Pow.ArrayPow2;
")})));
end ArrayPow2;


model ArrayPow3
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow3",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 2",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow3
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = ( 1 ) * ( 1 ) + ( 2 ) * ( 3 );
 x[1,2] = ( 1 ) * ( 2 ) + ( 2 ) * ( 4 );
 x[2,1] = ( 3 ) * ( 1 ) + ( 4 ) * ( 3 );
 x[2,2] = ( 3 ) * ( 2 ) + ( 4 ) * ( 4 );

end ArrayTests.Algebra.Pow.ArrayPow3;
")})));
end ArrayPow3;


model ArrayPow4
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow4",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 3",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow4
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = ( ( 1 ) * ( 1 ) + ( 2 ) * ( 3 ) ) * ( 1 ) + ( ( 1 ) * ( 2 ) + ( 2 ) * ( 4 ) ) * ( 3 );
 x[1,2] = ( ( 1 ) * ( 1 ) + ( 2 ) * ( 3 ) ) * ( 2 ) + ( ( 1 ) * ( 2 ) + ( 2 ) * ( 4 ) ) * ( 4 );
 x[2,1] = ( ( 3 ) * ( 1 ) + ( 4 ) * ( 3 ) ) * ( 1 ) + ( ( 3 ) * ( 2 ) + ( 4 ) * ( 4 ) ) * ( 3 );
 x[2,2] = ( ( 3 ) * ( 1 ) + ( 4 ) * ( 3 ) ) * ( 2 ) + ( ( 3 ) * ( 2 ) + ( 4 ) * ( 4 ) ) * ( 4 );

end ArrayTests.Algebra.Pow.ArrayPow4;
")})));
end ArrayPow4;


model ArrayPow5
 Real x[3,3] = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } } ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow5",
			description="Scalarization of element-wise exponentiation: Integer[3,3] ^ 2",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow5
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

end ArrayTests.Algebra.Pow.ArrayPow5;
")})));
end ArrayPow5;


model ArrayPow6
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation 
 x = y ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow6",
			description="Scalarization of element-wise exponentiation: component Real[2,2] ^ 2",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow6
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

end ArrayTests.Algebra.Pow.ArrayPow6;
")})));
end ArrayPow6;


model ArrayPow7
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation 
 x = y ^ 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow7",
			description="Scalarization of element-wise exponentiation:component Real[2,2] ^ 0",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow7
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

end ArrayTests.Algebra.Pow.ArrayPow7;
")})));
end ArrayPow7;


model ArrayPow8
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ (-1);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow8",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ (negative Integer)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4068, column 16:
  Type error in expression: ( {{1, 2}, {3, 4}} ) ^ (  - ( 1 ) )
")})));
end ArrayPow8;


model ArrayPow9
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 1.0;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow9",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ Real",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4084, column 16:
  Type error in expression: ( {{1, 2}, {3, 4}} ) ^ 1.0
")})));
end ArrayPow9;


model ArrayPow10
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ { { 1, 2 }, { 3, 4 } };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow10",
			description="Scalarization of element-wise exponentiation: Integer[2,2] ^ Integer[2,2]",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4100, column 16:
  Type error in expression: ( {{1, 2}, {3, 4}} ) ^ ( {{1, 2}, {3, 4}} )
")})));
end ArrayPow10;


model ArrayPow11
 Real x[2,3] = { { 1, 2 }, { 3, 4 }, { 5, 6 } } ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow11",
			description="Scalarization of element-wise exponentiation: Integer[2,3] ^ 2",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4116, column 16:
  Type error in expression: ( {{1, 2}, {3, 4}, {5, 6}} ) ^ 2
")})));
end ArrayPow11;


model ArrayPow12
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 Integer y = 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow12",
			description="Scalarization of element-wise exponentiation: Real[2,2] ^ Integer component",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4286, column 16:
  Type error in expression: ( {{1, 2}, {3, 4}} ) ^ ( y )
")})));
end ArrayPow12;


model ArrayPow13
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 constant Integer y = 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow13",
			description="Scalarization of element-wise exponentiation: Real[2,2] ^ constant Integer component",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow13
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

end ArrayTests.Algebra.Pow.ArrayPow13;
")})));
end ArrayPow13;


model ArrayPow14
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 parameter Integer y = 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow14",
			description="Scalarization of element-wise exponentiation: Real[2,2] ^ parameter Integer component",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4326, column 16:
  Type error in expression: ( {{1, 2}, {3, 4}} ) ^ ( y )
")})));
end ArrayPow14;


model ArrayPow15
 Real x[1,1] = { { 1 } } ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow15",
			description="Scalarization of element-wise exponentiation: Integer[1,1] ^ 2",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow15
 Real x[1,1];
equation
 x[1,1] = ( 1 ) * ( 1 );

end ArrayTests.Algebra.Pow.ArrayPow15;
")})));
end ArrayPow15;


model ArrayPow16
 Real x[1] = { 1 } ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayPow16",
			description="Scalarization of element-wise exponentiation: Integer[1] ^ 2",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 4177, column 16:
  Type error in expression: ( {1} ) ^ 2
")})));
end ArrayPow16;


model ArrayPow17
 Real x = 1 ^ 2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayPow17",
			description="Scalarization of element-wise exponentiation: Integer ^ 2",
			flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow17
 Real x;
equation
 x = 1 ^ 2;

end ArrayTests.Algebra.Pow.ArrayPow17;
")})));
end ArrayPow17;

end Pow;


package Neg
    
model ArrayNeg1
 Integer x[3] = -{ 1, 0, -1 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayNeg1",
			description="Scalarization of negation: array of Integer (literal)",
			flatModel="
fclass ArrayTests.Algebra.Neg.ArrayNeg1
 discrete Integer x[1];
 discrete Integer x[2];
 discrete Integer x[3];
initial equation 
 pre(x[1]) = 0;
 pre(x[2]) = 0;
 pre(x[3]) = 0;
equation
 x[1] =  - ( 1 );
 x[2] =  - ( 0 );
 x[3] =  - (  - ( 1 ) );

end ArrayTests.Algebra.Neg.ArrayNeg1;
")})));
end ArrayNeg1;


model ArrayNeg2
 Integer x[3] = -y;
 Integer y[3] = { 1, 0, -1 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayNeg2",
			description="Scalarization of negation: array of Integer (variable)",
			eliminate_alias_variables=false,
			flatModel="
fclass ArrayTests.Algebra.Neg.ArrayNeg2
 discrete Integer x[1];
 discrete Integer x[2];
 discrete Integer x[3];
 discrete Integer y[1];
 discrete Integer y[2];
 discrete Integer y[3];
initial equation  
 pre(x[1]) = 0;
 pre(x[2]) = 0;
 pre(x[3]) = 0;
 pre(y[1]) = 0;
 pre(y[2]) = 0;
 pre(y[3]) = 0;
equation
 x[1] =  - ( y[1] );
 x[2] =  - ( y[2] );
 x[3] =  - ( y[3] );
 y[1] = 1;
 y[2] = 0;
 y[3] =  - ( 1 );

end ArrayTests.Algebra.Neg.ArrayNeg2;
")})));
end ArrayNeg2;


model ArrayNeg3
 Integer x[3] = y;
 constant Integer y[3] = -{ 1, 0, -1 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayNeg3",
			description="Scalarization of negation: constant evaluation",
			flatModel="
fclass ArrayTests.Algebra.Neg.ArrayNeg3
 discrete Integer x[1];
 discrete Integer x[2];
 discrete Integer x[3];
 constant Integer y[1] =  - ( 1 );
 constant Integer y[2] =  - ( 0 );
 constant Integer y[3] =  - (  - ( 1 ) );
initial equation 
 pre(x[1]) = 0;
 pre(x[2]) = 0;
 pre(x[3]) = 0;
equation
 x[1] = -1;
 x[2] = 0;
 x[3] = 1;

end ArrayTests.Algebra.Neg.ArrayNeg3;
")})));
end ArrayNeg3;


model ArrayNeg4
 Boolean x[2] = -{ true, false };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayNeg4",
			description="Scalarization of negation: -Boolean[2] (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6029, column 17:
  Type error in expression:  - ( {true, false} )
")})));
end ArrayNeg4;


model ArrayNeg5
 Boolean x[2] = -y;
 Boolean y[2] = { true, false };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayNeg5",
			description="Scalarization of negation: -Boolean[2] (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6045, column 17:
  Type error in expression:  - ( y )
")})));
end ArrayNeg5;

end Neg;

end Algebra;



package Logical
	
package And

model ArrayAnd1
 Boolean x[2] = { true, true } and { true, false };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayAnd1",
			description="Scalarization of logical and: arrays of Booleans (literal)",
			flatModel="
fclass ArrayTests.Logical.And.ArrayAnd1
 discrete Boolean x[1];
 discrete Boolean x[2];
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
equation
 x[1] = true and true;
 x[2] = true and false;

end ArrayTests.Logical.And.ArrayAnd1;
")})));
end ArrayAnd1;

model ArrayAnd2
 Boolean y[2] = { true, false };
 Boolean x[2] = { true, true } and y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayAnd2",
			description="Scalarization of logical and: arrays of Booleans (component)",
			flatModel="
fclass ArrayTests.Logical.And.ArrayAnd2
 discrete Boolean y[1];
 discrete Boolean y[2];
 discrete Boolean x[1];
 discrete Boolean x[2];
initial equation 
 pre(y[1]) = false;
 pre(y[2]) = false;
 pre(x[1]) = false;
 pre(x[2]) = false;
equation
 y[1] = true;
 y[2] = false;
 x[1] = true and y[1];
 x[2] = true and y[2];

end ArrayTests.Logical.And.ArrayAnd2;
")})));
end ArrayAnd2;


model ArrayAnd3
 Boolean x[2] = { true, true } and { true, false, true };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAnd3",
			description="Scalarization of logical and: different array sizes (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5569, column 17:
  Type error in expression: {true, true} and {true, false, true}
")})));
end ArrayAnd3;


model ArrayAnd4
 Boolean y[3] = { true, false, true };
 Boolean x[2] = { true, true } and y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAnd4",
			description="Scalarization of logical and: different array sizes (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5586, column 17:
  Type error in expression: {true, true} and y
")})));
end ArrayAnd4;


model ArrayAnd5
 Boolean x[2] = { true, true } and true;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAnd5",
			description="Scalarization of logical and: array and scalar (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5602, column 17:
  Type error in expression: {true, true} and true
")})));
end ArrayAnd5;


model ArrayAnd6
 Boolean y = true;
 Boolean x[2] = { true, true } and y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAnd6",
			description="Scalarization of logical and: array and scalar (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5619, column 17:
  Type error in expression: {true, true} and y
")})));
end ArrayAnd6;


model ArrayAnd7
 Integer x[2] = { 1, 1 } and { 1, 0 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAnd7",
			description="Scalarization of logical and: Integer[2] and Integer[2] (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5635, column 17:
  Type error in expression: {1, 1} and {1, 0}
")})));
end ArrayAnd7;


model ArrayAnd8
 Integer y[2] = { 1, 0 };
 Integer x[2] = { 1, 1 } and y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayAnd8",
			description="Scalarization of logical and: Integer[2] and Integer[2] (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5652, column 17:
  Type error in expression: {1, 1} and y
")})));
end ArrayAnd8;


model ArrayAnd9
 constant Boolean y[3] = { true, false, false } and { true, true, false };
 Boolean x[3] = y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayAnd9",
			description="Scalarization of logical and: constant evaluation",
			flatModel="
fclass ArrayTests.Logical.And.ArrayAnd9
 constant Boolean y[1] = true and true;
 constant Boolean y[2] = false and true;
 constant Boolean y[3] = false and false;
 discrete Boolean x[1];
 discrete Boolean x[2];
 discrete Boolean x[3];
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
 pre(x[3]) = false;
equation
 x[1] = true;
 x[2] = false;
 x[3] = false;

end ArrayTests.Logical.And.ArrayAnd9;
")})));
end ArrayAnd9;

end And;


package Or
	
model ArrayOr1
 Boolean x[2] = { true, true } or { true, false };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayOr1",
			description="Scalarization of logical or: arrays of Booleans (literal)",
			flatModel="
fclass ArrayTests.Logical.Or.ArrayOr1
 discrete Boolean x[1];
 discrete Boolean x[2];
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
equation
 x[1] = true or true;
 x[2] = true or false;

end ArrayTests.Logical.Or.ArrayOr1;
")})));
end ArrayOr1;


model ArrayOr2
 Boolean y[2] = { true, false };
 Boolean x[2] = { true, true } or y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayOr2",
			description="Scalarization of logical or: arrays of Booleans (component)",
			flatModel="
fclass ArrayTests.Logical.Or.ArrayOr2
 discrete Boolean y[1];
 discrete Boolean y[2];
 discrete Boolean x[1];
 discrete Boolean x[2];
initial equation 
 pre(y[1]) = false;
 pre(y[2]) = false;
 pre(x[1]) = false;
 pre(x[2]) = false;
equation
 y[1] = true;
 y[2] = false;
 x[1] = true or y[1];
 x[2] = true or y[2];

end ArrayTests.Logical.Or.ArrayOr2;
")})));
end ArrayOr2;


model ArrayOr3
 Boolean x[2] = { true, true } or { true, false, true };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayOr3",
			description="Scalarization of logical or: different array sizes (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5723, column 17:
  Type error in expression: {true, true} or {true, false, true}
")})));
end ArrayOr3;


model ArrayOr4
 Boolean y[3] = { true, false, true };
 Boolean x[2] = { true, true } or y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayOr4",
			description="Scalarization of logical or: different array sizes (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5740, column 17:
  Type error in expression: {true, true} or y
")})));
end ArrayOr4;


model ArrayOr5
 Boolean x[2] = { true, true } or true;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayOr5",
			description="Scalarization of logical or: array and scalar (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5759, column 17:
  Type error in expression: {true, true} or true
")})));
end ArrayOr5;


model ArrayOr6
 Boolean y = true;
 Boolean x[2] = { true, true } or y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayOr6",
			description="Scalarization of logical or: array and scalar (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5776, column 17:
  Type error in expression: {true, true} or y
")})));
end ArrayOr6;


model ArrayOr7
 Integer x[2] = { 1, 1 } or { 1, 0 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayOr7",
			description="Scalarization of logical or: Integer[2] or Integer[2] (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5803, column 17:
  Type error in expression: {1, 1} or {1, 0}
")})));
end ArrayOr7;


model ArrayOr8
 Integer y[2] = { 1, 0 };
 Integer x[2] = { 1, 1 } or y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayOr8",
			description="Scalarization of logical or: Integer[2] or Integer[2] (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5820, column 17:
  Type error in expression: {1, 1} or y
")})));
end ArrayOr8;


model ArrayOr9
 constant Boolean y[3] = { true, true, false } or { true, false, false };
 Boolean x[3] = y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayOr9",
			description="Scalarization of logical or: constant evaluation",
			flatModel="
fclass ArrayTests.Logical.Or.ArrayOr9
 constant Boolean y[1] = true or true;
 constant Boolean y[2] = true or false;
 constant Boolean y[3] = false or false;
 discrete Boolean x[1];
 discrete Boolean x[2];
 discrete Boolean x[3];
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
 pre(x[3]) = false;
equation
 x[1] = true;
 x[2] = true;
 x[3] = false;

end ArrayTests.Logical.Or.ArrayOr9;
")})));
end ArrayOr9;

end Or;



package Not
	
model ArrayNot1
 Boolean x[2] = not { true, false };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayNot1",
			description="Scalarization of logical not: array of Boolean (literal)",
			flatModel="
fclass ArrayTests.Logical.Not.ArrayNot1
 discrete Boolean x[1];
 discrete Boolean x[2];
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
equation
 x[1] = not true;
 x[2] = not false;

end ArrayTests.Logical.Not.ArrayNot1;
")})));
end ArrayNot1;


model ArrayNot2
 Boolean x[2] = not y;
 Boolean y[2] = { true, false };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayNot2",
			description="Scalarization of logical not: array of Boolean (component)",
			flatModel="
fclass ArrayTests.Logical.Not.ArrayNot2
 discrete Boolean x[1];
 discrete Boolean x[2];
 discrete Boolean y[1];
 discrete Boolean y[2];
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
 pre(y[1]) = false;
 pre(y[2]) = false;
equation
 x[1] = not y[1];
 x[2] = not y[2];
 y[1] = true;
 y[2] = false;

end ArrayTests.Logical.Not.ArrayNot2;
")})));
end ArrayNot2;


model ArrayNot3
 Boolean x[2] = y;
 constant Boolean y[2] = not { true, false };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayNot3",
			description="Scalarization of logical not: constant evaluation",
			flatModel="
fclass ArrayTests.Logical.Not.ArrayNot3
 discrete Boolean x[1];
 discrete Boolean x[2];
 constant Boolean y[1] = not true;
 constant Boolean y[2] = not false;
initial equation 
 pre(x[1]) = false;
 pre(x[2]) = false;
equation
 x[1] = false;
 x[2] = true;

end ArrayTests.Logical.Not.ArrayNot3;
")})));
end ArrayNot3;


model ArrayNot4
 Integer x[2] = not { 1, 0 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayNot4",
			description="Scalarization of logical not: not Integer[2] (literal)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5879, column 17:
  Type error in expression: not {1, 0}
")})));
end ArrayNot4;


model ArrayNot5
 Integer x[2] = not y;
 Integer y[2] = { 1, 0 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayNot5",
			description="Scalarization of logical or: not Integer[2] (component)",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5895, column 17:
  Type error in expression: not y
")})));
end ArrayNot5;

end Not;

end Logical;



package Constructors

package LongForm
	
model LongArrayForm1
 Real x[3] = array(1, 2, 3);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="LongArrayForm1",
			description="Long form of array constructor",
			flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm1
 Real x[3] = array(1,2,3);

end ArrayTests.Constructors.LongForm.LongArrayForm1;
")})));
end LongArrayForm1;


model LongArrayForm2
 Real x[3] = array(1, 2, 3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="LongArrayForm2",
			description="Long form of array constructor",
			flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm2
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;

end ArrayTests.Constructors.LongForm.LongArrayForm2;
")})));
end LongArrayForm2;


model LongArrayForm3
 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1,x2,{7,8,9});

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="LongArrayForm3",
			description="Long form of array constructor, array component parts",
			flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm3
 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1[1:3],x2[1:3],{7,8,9});

end ArrayTests.Constructors.LongForm.LongArrayForm3;
")})));
end LongArrayForm3;


model LongArrayForm4
 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1,x2,{7,8,9});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="LongArrayForm4",
			description="Long form of array constructor, array component parts",
			flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm4
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

end ArrayTests.Constructors.LongForm.LongArrayForm4;
")})));
end LongArrayForm4;

end LongForm;


package EmptyArray
	
model EmptyArray1
    Real x[3,0] = zeros(3,0);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="EmptyArray1",
			description="Empty arrays, basic test",
			flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray1

end ArrayTests.Constructors.EmptyArray.EmptyArray1;
")})));
end EmptyArray1;


model EmptyArray2
    Real x[3,0] = zeros(3,0);
    Real y[3,0] = zeros(3,0);
    Real z[3,0] = x + y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="EmptyArray2",
			description="Empty arrays, addition",
			flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray2

end ArrayTests.Constructors.EmptyArray.EmptyArray2;
")})));
end EmptyArray2;


model EmptyArray3
    Real x[2,2] = {{1,2},{3,4}};
    Real y[2,0] = ones(2,0);
    Real z[0,2] = ones(0,2);
    Real w[0,0] = ones(0,0);
    Real xx[2,2] = [x, y; z, w];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="EmptyArray3",
			description="Empty arrays, concatenation",
			flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray3
 Real xx[1,1];
 Real xx[1,2];
 Real xx[2,1];
 Real xx[2,2];
equation
 xx[1,1] = 1;
 xx[1,2] = 2;
 xx[2,1] = 3;
 xx[2,2] = 4;

end ArrayTests.Constructors.EmptyArray.EmptyArray3;
")})));
end EmptyArray3;


model EmptyArray4
    Real x[2,0] = {{1,2},{3,4}} * ones(2,0);
    Real y[2,2] = ones(2,0) * ones(0,2);
    Real z[0,0] = ones(0,2) * ones(2,0);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="EmptyArray4",
			description="Empty arrays, multiplication",
			flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray4
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 y[1,1] = 0;
 y[1,2] = 0;
 y[2,1] = 0;
 y[2,2] = 0;

end ArrayTests.Constructors.EmptyArray.EmptyArray4;
")})));
end EmptyArray4;


model EmptyArray5
    parameter Integer n = 0;
    parameter Integer p = 2;
    parameter Integer q = 2;
    input Real u[p];
    Real x[n];
    Real y[q];
    parameter Real A[n,n] = ones(n,n);
    parameter Real B[n,p] = ones(n,p);
    parameter Real C[q,n] = ones(q,n);
    parameter Real D[q,p] = { i*j for i in 1:q, j in 1:p };
equation
    der(x) = A*x + B*u;
        y  = C*x + D*u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="EmptyArray5",
			description="Empty arrays, simple equation system",
			flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray5
 parameter Integer n = 0 /* 0 */;
 parameter Integer p = 2 /* 2 */;
 parameter Integer q = 2 /* 2 */;
 input Real u[1];
 input Real u[2];
 Real y[1];
 Real y[2];
 parameter Real D[1,1] = ( 1 ) * ( 1 ) /* 1 */;
 parameter Real D[1,2] = ( 2 ) * ( 1 ) /* 2 */;
 parameter Real D[2,1] = ( 1 ) * ( 2 ) /* 2 */;
 parameter Real D[2,2] = ( 2 ) * ( 2 ) /* 4 */;
equation
 y[1] = 0.0 + ( D[1,1] ) * ( u[1] ) + ( D[1,2] ) * ( u[2] );
 y[2] = 0.0 + ( D[2,1] ) * ( u[1] ) + ( D[2,2] ) * ( u[2] );

end ArrayTests.Constructors.EmptyArray.EmptyArray5;
")})));
end EmptyArray5;

end EmptyArray;


package Iterators

model ArrayIterTest1
 Real x[3,3] = {i * j for i in 1:3, j in {2,3,5}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayIterTest1",
			description="Array constructor with iterators: over scalar exp",
			flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest1
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
 x[1,2] = ( 2 ) * ( 2 );
 x[1,3] = ( 3 ) * ( 2 );
 x[2,1] = ( 1 ) * ( 3 );
 x[2,2] = ( 2 ) * ( 3 );
 x[2,3] = ( 3 ) * ( 3 );
 x[3,1] = ( 1 ) * ( 5 );
 x[3,2] = ( 2 ) * ( 5 );
 x[3,3] = ( 3 ) * ( 5 );

end ArrayTests.Constructors.Iterators.ArrayIterTest1;
")})));
end ArrayIterTest1;


model ArrayIterTest2
 Real x[2,2,2] = {{i * i, j} for i in 1:2, j in {2,5}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayIterTest2",
			description="Array constructor with iterators: over array exp",
			flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest2
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
 x[1,2,1] = ( 2 ) * ( 2 );
 x[1,2,2] = 2;
 x[2,1,1] = ( 1 ) * ( 1 );
 x[2,1,2] = 5;
 x[2,2,1] = ( 2 ) * ( 2 );
 x[2,2,2] = 5;

end ArrayTests.Constructors.Iterators.ArrayIterTest2;
")})));
end ArrayIterTest2;


model ArrayIterTest3
 Real x[1,1] = { i * j for i, j };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayIterTest3",
			description="Array constructor with iterators: without in",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5981, column 7:
  Array size mismatch in declaration of x, size of declaration is [1, 1] and size of binding expression is [:, :]
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5981, column 28:
  For index without in expression isn't supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 5981, column 31:
  For index without in expression isn't supported
")})));
end ArrayIterTest3;


model ArrayIterTest4
 Real i = 1;
 Real x[2,2,2,2] = { { { {i, j} for j in 1:2 } for i in 3:4 } for i in 5:6 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayIterTest4",
			description="Array constructor with iterators: nestled constructors, masking index",
			flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest4
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

end ArrayTests.Constructors.Iterators.ArrayIterTest4;
")})));
end ArrayIterTest4;


model ArrayIterTest5
 Real x[1,1,1] = { {1} for i in {1}, j in {1} };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayIterTest5",
			description="Array constructor with iterators: vectors of length 1",
			flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest5
 Real x[1,1,1];
equation
 x[1,1,1] = 1;

end ArrayTests.Constructors.Iterators.ArrayIterTest5;
")})));
end ArrayIterTest5;
                       
                       
model ArrayIterTest6
    function f
    algorithm
    end f;
    
    Real x[3] = { f() for i in 1:3 };

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArrayIterTest6",
			description="Iterated expression with bad size",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1960, column 16:
  Function f() has no outputs, but is used in expression
")})));
end ArrayIterTest6;

end Iterators;

end Constructors;



package For
	
model ForEquation1
 model A
  Real x[3];
 equation
  for i in 1:3 loop
   x[i] = i*i;
  end for;
 end A;
 
 A y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ForEquation1",
			description="Flattening of for equations: for equ in a component",
			flatModel="
fclass ArrayTests.For.ForEquation1
 Real y.x[3];
equation
 for i in 1:3 loop
  y.x[i] = ( i ) * ( i );
 end for;

end ArrayTests.For.ForEquation1;
")})));
end ForEquation1;


model ForEquation2
    model A
        parameter Integer N;
        parameter Integer[N] rev = N:-1:1;
        Real[N] x;
        Real[N] y;
    equation
        for i in 1:N loop
            x[i] = y[rev[i]];
        end for;
    end A;
    
    A a(N=3, x={1,2,3});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForEquation2",
			description="",
			flatModel="
fclass ArrayTests.For.ForEquation2
 parameter Integer a.N = 3 /* 3 */;
 parameter Integer a.rev[1] = 3 /* 3 */;
 parameter Integer a.rev[2] = 2 /* 2 */;
 parameter Integer a.rev[3] = 1 /* 1 */;
 Real a.x[1];
 Real a.x[2];
 Real a.x[3];
equation
 a.x[1] = 1;
 a.x[2] = 2;
 a.x[3] = 3;

end ArrayTests.For.ForEquation2;
")})));
end ForEquation2;


model ForEquation3
	function f
		input Real x;
		output Real y = x + 1;
	algorithm
	end f;
	
	parameter Integer n = 3;
	Real x[n];
equation
	for i in 1:n loop
		x[i] = f(sum(1:i));
	end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForEquation3",
			description="Array expressions depending on for loop index",
			flatModel="
fclass ArrayTests.For.ForEquation3
 parameter Integer n = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = ArrayTests.For.ForEquation3.f(1);
 x[2] = ArrayTests.For.ForEquation3.f(1 + 2);
 x[3] = ArrayTests.For.ForEquation3.f(1 + 2 + 3);

public
 function ArrayTests.For.ForEquation3.f
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 end ArrayTests.For.ForEquation3.f;

end ArrayTests.For.ForEquation3;
")})));
end ForEquation3;



model ForInitial1
  parameter Integer N = 3;
  Real x[N];
initial equation
  for i in 1:N loop
    der(x[i]) = 0;
  end for;
equation
  der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForInitial1",
			description="For equation in initial equation block",
			flatModel="
fclass ArrayTests.For.ForInitial1
 parameter Integer N = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
initial equation 
 der(x[1]) = 0;
 der(x[2]) = 0;
 der(x[3]) = 0;
equation
 der(x[1]) =  - ( x[1] );
 der(x[2]) =  - ( x[2] );
 der(x[3]) =  - ( x[3] );

end ArrayTests.For.ForInitial1;
")})));
end ForInitial1;

end For;



package Slices
	
model SliceTest1
 model A
  Real a[2];
 end A;
 
 A x[2](a={{1,2},{3,4}});
 Real y[2,2] = x.a .+ 1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="SliceTest1",
			description="Slice operations: basic test",
			flatModel="
fclass ArrayTests.Slices.SliceTest1
 Real x[1].a[2] = {1,2};
 Real x[2].a[2] = {3,4};
 Real y[2,2] = x[1:2].a[1:2] .+ 1;

end ArrayTests.Slices.SliceTest1;
")})));
end SliceTest1;


model SliceTest2
 model A
  Real a[2];
 end A;
 
 A x[2](a={{1,2},{3,4}});
 Real y[2,2] = x.a .+ 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SliceTest2",
			description="Slice operations: basic test",
			flatModel="
fclass ArrayTests.Slices.SliceTest2
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

end ArrayTests.Slices.SliceTest2;
")})));
end SliceTest2;


model SliceTest3
 model A
  Real a[4];
 end A;
 
 A x[4](a={{1,2,3,4},{1,2,3,4},{1,2,3,4},{1,2,3,4}});
 Real y[2,2] = x[2:3].a[{2,4}] .+ 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SliceTest3",
			description="Slice operations: test with vector indices",
			flatModel="
fclass ArrayTests.Slices.SliceTest3
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

end ArrayTests.Slices.SliceTest3;
")})));
end SliceTest3;



model MixedIndices1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MixedIndices1",
			description="Mixing for index subscripts with colon subscripts",
			automatic_add_initial_equations=false,
			flatModel="
fclass ArrayTests.Slices.MixedIndices1
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

end ArrayTests.Slices.MixedIndices1;
")})));
end MixedIndices1;


model MixedIndices2
 Real y[4,2];
 Real z[2,2] = identity(2);
equation
 for i in 0:2:2 loop
   y[(1:2).+i,:] = z[:,:] * 2;
 end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MixedIndices2",
			description="Mixing expression subscripts containing for indices with colon subscripts",
			flatModel="
fclass ArrayTests.Slices.MixedIndices2
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

end ArrayTests.Slices.MixedIndices2;
")})));
end MixedIndices2;

end Slices;



package Other
	
model CircularFunctionArg1
	function f 
		input Real[:] a;
		output Real[:] b = a;
	algorithm
	end f;
	
	Real[:] c = f(d);
	Real[:] d = f(c);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="CircularFunctionArg1",
			description="Circular dependency when calculating size of function output",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1528, column 14:
  Could not evaluate array size of output b
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 1529, column 14:
  Could not evaluate array size of output b
")})));
end CircularFunctionArg1;



constant Real testConst[2] = { 1, 2 };


model ArrayConst1
	Real x[2] = { 1 / testConst[i] for i in 1:2 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayConst1",
			description="Array constants used with parameter index",
			flatModel="
fclass ArrayTests.Other.ArrayConst1
 Real x[1];
 Real x[2];
equation
 x[1] = ( 1 ) / ( 1.0 );
 x[2] = ( 1 ) / ( 2.0 );

end ArrayTests.Other.ArrayConst1;
")})));
end ArrayConst1;
								   
   
model ArrayConst2
	Real x[2];
equation
	for i in 1:2 loop
		x[i] = testConst[i];
	end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayConst2",
			description="Array constants used with parameter index",
			flatModel="
fclass ArrayTests.Other.ArrayConst2
 Real x[1];
 Real x[2];
equation
 x[1] = 1.0;
 x[2] = 2.0;

end ArrayTests.Other.ArrayConst2;
")})));
end ArrayConst2;


model ArrayConst3
	function f
		input Real i;
		output Real o;
	algorithm
		o := testConst[integer(i)];
	end f;
	
	Real x = f(1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayConst3",
			description="Array constants used with index of discrete variability",
			flatModel="
fclass ArrayTests.Other.ArrayConst3
 Real x;
equation
 x = ArrayTests.Other.ArrayConst3.f(1);

public
 function ArrayTests.Other.ArrayConst3.f
  Real[2] testConst;
  input Real i;
  output Real o;
 algorithm
  testConst[1] := 1;
  testConst[2] := 2;
  o := testConst[integer(i)];
  return;
 end ArrayTests.Other.ArrayConst3.f;

end ArrayTests.Other.ArrayConst3;
")})));
end ArrayConst3;


model ArrayConst4
	parameter Integer i = 1;
	Real x = testConst[i];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayConst4",
			description="Array constants used with parameter index",
			flatModel="
fclass ArrayTests.Other.ArrayConst4
 parameter Integer i = 1 /* 1 */;
 Real x;
equation
 x = 1.0;

end ArrayTests.Other.ArrayConst4;
")})));
end ArrayConst4;


model ArraySize2
	parameter Real x[:, size(x,1)];

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ArraySize2",
			description="Size of variable: one dimension refering to another",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6365, column 17:
  Can not infer array size of the variable x
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayTests.mo':
Semantic error at line 6365, column 22:
  Could not evaluate array size expression: size(x, 1)
")})));
end ArraySize2;


model ArraySize3
	model A
		Real x[2] = {1,2};
	end A;
	
	parameter Integer n = 2;
	A[n] b;
	Real[n] c;
equation
	for i in 1:n loop
		c[i] = b[i].x[1] + b[i].x[end];
	end for;

	annotation(__JModelica(UnitTesting(tests={ 
		TransformCanonicalTestCase(
			name="Other_ArraySize3",
			description="Handle end in for loop",
			flatModel="
fclass ArrayTests.Other.ArraySize3
 parameter Integer n = 2 /* 2 */;
 Real b[1].x[1];
 Real b[1].x[2];
 Real b[2].x[1];
 Real b[2].x[2];
 Real c[1];
 Real c[2];
equation
 c[1] = b[1].x[1] + b[1].x[2];
 c[2] = b[2].x[1] + b[2].x[2];
 b[1].x[1] = 1;
 b[1].x[2] = 2;
 b[2].x[1] = 1;
 b[2].x[2] = 2;
end ArrayTests.Other.ArraySize3;
")})));
end ArraySize3;


model M_OLineExample
	extends Modelica.Electrical.Analog.Lines.M_OLine;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="Other_M_OLineExample",
			description="Test example that caused infinite loop",
			errorMessage="
16 errors found:
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Basic.mo':
Semantic error at line 610, column 43:
  Could not evaluate array size expression: dimL
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 161, column 22:
  Could not evaluate array size expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 163, column 26:
  Array size mismatch in declaration of l, size of declaration is [dim_vector_lgc] and size of binding expression is [10]
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 166, column 22:
  Could not evaluate array size expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 168, column 26:
  Array size mismatch in declaration of g, size of declaration is [dim_vector_lgc] and size of binding expression is [10]
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 171, column 22:
  Could not evaluate array size expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 173, column 26:
  Array size mismatch in declaration of c, size of declaration is [dim_vector_lgc] and size of binding expression is [10]
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 203, column 25:
  Could not evaluate array size expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 206, column 25:
  Could not evaluate array size expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 208, column 25:
  Could not evaluate array size expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 272, column 38:
  Could not evaluate array index expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 273, column 17:
  Could not evaluate array index expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 274, column 38:
  Could not evaluate array index expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 275, column 17:
  Could not evaluate array index expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 288, column 29:
  Could not evaluate array index expression: dim_vector_lgc
Error: in file 'C:\\Users\\jesper_026\\workspace\\JModelica\\ThirdParty\\MSL\\Modelica\\Electrical\\Analog\\Lines.mo':
Semantic error at line 310, column 25:
  Could not evaluate array size expression: dim_vector_lgc
")})));
end M_OLineExample;

end Other;


  annotation(uses(Modelica(version="3.0.1")));
end ArrayTests;
