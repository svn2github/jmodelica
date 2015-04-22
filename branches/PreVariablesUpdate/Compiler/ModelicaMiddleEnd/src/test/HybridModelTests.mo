/*
    Copyright (C) 2009-2015 Modelon AB

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


package HybridModelTests
    model PreTest1
        Integer i;
        Real x, y;
        Boolean b;
    equation
        der(x) = if pre(i) == 0 then 0 else 1;
        der(y) = if i == 0 then 2 else 3;
        b = sin(time) >= 0;
        i = if b then 1 else 0;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest1",
            description="Testing of hybrid models with pre variable that don't need to be iterated in block",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
b := sin(time) >= 0

--- Unsolved mixed linear system (Block 1) of 2 variables ---
Coefficient variability: constant
Unknown continuous variables:
  der(x)

Solved discrete variables:
  i

Continuous residual equations:
  der(x) = if pre(i) == 0 then 0 else 1
    Iteration variables: der(x)

Discrete equations:
  i := if b then 1 else 0

Jacobian:
  |1.0|

--- Solved equation ---
der(y) := if i == 0 then 2 else 3
-------------------------------
")})));
    end PreTest1;

    model PreTest2
        Real x, y;
        Integer i;
    equation
        x + pre(i) = y;
        i = if x >= 0 then 1 else 2;
        y = 3 * sin(time);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest2",
            description="Testing of hybrid models with pre variable that need to be iterated in block",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
y := 3 * sin(time)

--- Unsolved mixed linear system (Block 1) of 2 variables ---
Coefficient variability: constant
Unknown continuous variables:
  x

Solved discrete variables:
  i

Continuous residual equations:
  x + pre(i) = y
    Iteration variables: x

Discrete equations:
  i := if x >= 0 then 1 else 2

Jacobian:
  |1.0|
-------------------------------
")})));
    end PreTest2;

    model PreTest3
        Real x, y, z;
        Integer i, j;
    equation
        y = 3 * sin(time);
        x + pre(i) = y;
        i = if x >= 0 then 1 else 2;
        z + pre(i) + pre(j) = y;
        j = if x >= 0 and z>=0 then 1 else 2;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest3",
            description="Testing of hybrid models with pre variables that need to be iterated in two separate blocks",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
y := 3 * sin(time)

--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  x

Iteration variables:
  z

Solved discrete variables:
  j
  i

Torn equations:
  x := - pre(i) + y

Continuous residual equations:
  z + pre(i) + pre(j) = y
    Iteration variables: z

Discrete equations:
  j := if x >= 0 and z >= 0 then 1 else 2
  i := if x >= 0 then 1 else 2

Jacobian:
  |1.0, 0.0|
  |0.0, 1.0|
-------------------------------
")})));
    end PreTest3;

    model PreTest4
        discrete Real x_d;
        Real x_c;
    initial equation
        x_c = 1;
    equation
        der(x_c) = (-x_c) + x_d;
        when sample(0, 1) then
            x_d = x_c + 1;
        end when;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest4",
            description="Test interaction between continuous and discrete equations",
            methodName="printDAEBLT",
            methodResult="
--- Unsolved mixed linear system (Block 1) of 2 variables ---
Coefficient variability: constant
Unknown continuous variables:
  x_d

Solved discrete variables:
  temp_1

Continuous residual equations:
  x_d = if temp_1 and not pre(temp_1) then x_c + 1 else pre(x_d)
    Iteration variables: x_d

Discrete equations:
  temp_1 := sample(0, 1)

Jacobian:
  |1.0|

--- Solved equation ---
der(x_c) := - x_c + x_d
-------------------------------
")})));
    end PreTest4;

    model PreTest5
        discrete Real x_d;
        Real x_c;
    initial equation
        x_c = 1;
    equation
        0 = (-x_c) + x_d;
        when sample(0, 1) then
            x_d = x_c + 1;
        end when;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest5",
            description="TODO: this model should give an error",
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: discrete-time
Torn variables:
  x_d

Iteration variables:
  x_c

Solved discrete variables:
  temp_1

Torn equations:
  x_d := if temp_1 and not pre(temp_1) then x_c + 1 else pre(x_d)

Continuous residual equations:
  0 = - x_c + x_d
    Iteration variables: x_c

Discrete equations:
  temp_1 := sample(0, 1)

Jacobian:
  |1.0, - (if temp_1 and not pre(temp_1) then 1.0 else 0.0)|
  |-1.0, 1.0|
-------------------------------
")})));
    end PreTest5;

    model PreTest6
        discrete Real x_d;
        Real x_c;
    initial equation
        x_c = 1;
    equation
        0 = (-x_c) + pre(x_d);
        when sample(0, 1) then
            x_d = x_c + 1;
        end when;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest6",
            description="A case which gives bigger block with local pre handling, but avoid global iteration",
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  x_d

Iteration variables:
  x_c

Solved discrete variables:
  temp_1

Torn equations:
  x_d := if temp_1 and not pre(temp_1) then x_c + 1 else pre(x_d)

Continuous residual equations:
  0 = - x_c + pre(x_d)
    Iteration variables: x_c

Discrete equations:
  temp_1 := sample(0, 1)

Jacobian:
  |1.0, 0.0|
  |0.0, 1.0|
-------------------------------
")})));
    end PreTest6;

    model PreTest7
        discrete Real x_d;
        Real x_c;
    initial equation
        x_c = 1;
    equation
        0 = (-x_c) + x_d;
        when sample(0, 1) then
            x_d = pre(x_c) + 1;
        end when;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest7",
            description="A case which gives bigger block with local pre handling, but avoid global iteration",
            methodName="printDAEBLT",
            methodResult="
--- Unsolved mixed linear system (Block 1) of 2 variables ---
Coefficient variability: constant
Unknown continuous variables:
  x_d

Solved discrete variables:
  temp_1

Continuous residual equations:
  x_d = if temp_1 and not pre(temp_1) then pre(x_c) + 1 else pre(x_d)
    Iteration variables: x_d

Discrete equations:
  temp_1 := sample(0, 1)

Jacobian:
  |1.0|

--- Solved equation ---
x_c := x_d
-------------------------------
")})));
    end PreTest7;

    model PreTest8
        Real x;
        discrete Real y;
        Integer i;
    equation
        i = if time >= 3 then 1 else 0;
        when sample(0, 1) then
            y = pre(y) + 1;
        end when;
        der(x) = (if pre(y) >= 3 then 1 else 2) + (if pre(i) == 4 then 5 else 6);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest8",
            description="A case which gives bigger block with local pre handling, but avoid global iteration",
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  der(x)

Iteration variables:
  y

Solved discrete variables:
  temp_1
  i

Torn equations:
  der(x) := (if pre(y) >= 3 then 1 else 2) + (if pre(i) == 4 then 5 else 6)

Continuous residual equations:
  y = if temp_1 and not pre(temp_1) then pre(y) + 1 else pre(y)
    Iteration variables: y

Discrete equations:
  temp_1 := sample(0, 1)
  i := if time >= 3 then 1 else 0

Jacobian:
  |1.0, 0.0|
  |0.0, 1.0|
-------------------------------
")})));
    end PreTest8;

    model PreTest9
        parameter Real tau0_max = 0.15, tau0 = 0.10;
        Real sa;
        Boolean locked(start=true), startForward(start=false);
    equation
        sa = if locked then tau0_max+1e-4 else tau0+1e-4;
        startForward = sa > tau0_max or pre(startForward) and sa > tau0;
        locked = not startForward;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.PreTest9",
            description="A test that simulates the common friction problems",
            methodName="printDAEBLT",
            methodResult="
--- Unsolved mixed linear system (Block 1) of 3 variables ---
Coefficient variability: constant
Unknown continuous variables:
  sa

Solved discrete variables:
  startForward
  locked

Continuous residual equations:
  sa = if locked then tau0_max + 1.0E-4 else tau0 + 1.0E-4
    Iteration variables: sa

Discrete equations:
  startForward := sa > tau0_max or pre(startForward) and sa > tau0
  locked := not startForward

Jacobian:
  |1.0|
-------------------------------
")})));
    end PreTest9;
    
    model WhenAndPreTest1
        Real xx(start=2);
        discrete Real x; 
        discrete Real y; 
        discrete Boolean w(start=true); 
        discrete Boolean v(start=true); 
        discrete Boolean z(start=true); 
    equation
        when sample(0,1) then 
            x = pre(x) + 1.1; 
            y = pre(y) + 1.1; 
        end when; 
    
        der(xx) = -x; 
    
        when y > 2 and pre(z) then 
            w = false; 
        end when; 
    
        when x > 2 then 
            z = false; 
        end when; 
    
        when y > 2 and z then 
            v = false; 
        end when; 
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="HybridModelTests.WhenAndPreTest1",
            description="Test complicated when and pre variable case",
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  x

Iteration variables:
  y

Solved discrete variables:
  temp_1

Torn equations:
  x := if temp_1 and not pre(temp_1) then pre(x) + 1.1 else pre(x)

Continuous residual equations:
  y = if temp_1 and not pre(temp_1) then pre(y) + 1.1 else pre(y)
    Iteration variables: y

Discrete equations:
  temp_1 := sample(0, 1)

Jacobian:
  |1.0, 0.0|
  |0.0, 1.0|

--- Solved equation ---
der(xx) := - x

--- Unsolved mixed linear system (Block 2) of 4 variables ---
Coefficient variability: constant
Unknown continuous variables:

Solved discrete variables:
  temp_2
  w
  temp_3
  z

Continuous residual equations:

Discrete equations:
  temp_2 := y > 2 and pre(z)
  w := if temp_2 and not pre(temp_2) then false else pre(w)
  temp_3 := x > 2
  z := if temp_3 and not pre(temp_3) then false else pre(z)

Jacobian:

--- Unsolved mixed linear system (Block 3) of 2 variables ---
Coefficient variability: constant
Unknown continuous variables:

Solved discrete variables:
  temp_4
  v

Continuous residual equations:

Discrete equations:
  temp_4 := y > 2 and z
  v := if temp_4 and not pre(temp_4) then false else pre(v)

Jacobian:
-------------------------------
")})));
    end WhenAndPreTest1;

end HybridModelTests;