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


package DynamicStates
    package Basic
        model TwoDSOneEq
            // a1 a2
            // +  +
            Real a1;
            Real a2;
            Real b;
        equation
            der(a1) = b;
            der(a2) = b;
            a1 * a2 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_TwoDSOneEq",
                description="Two dynamic states in one equation",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a1 ---
    --- Solved equation ---
    a2 := 1 / ds(0, a1)
    -------------------------------
  --- States: a2 ---
    --- Solved equation ---
    a1 := 1 / ds(0, a2)
    -------------------------------

--- Torn linear system (Block 2) of 1 iteration variables and 2 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  b
  der(a1)

Iteration variables:
  der(a2)

Torn equations:
  b := der(a2)
  der(a1) := b

Residual equations:
  ds(0, a1) * der(a2) + der(a1) * ds(0, a2) = 0
    Iteration variables: der(a2)

Jacobian:
  |-1.0, 0.0, 1.0|
  |-1.0, 1.0, 0.0|
  |0.0, ds(0, a2), ds(0, a1)|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)
-------------------------------
")})));
        end TwoDSOneEq;

        model TwoDSOneEqUnsolved
            // a1 a2
            // +  +
            Real a1;
            Real a2;
            Real b;
        equation
            der(a1) = b;
            der(a2) = b;
            a1^2 + a2^2 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_TwoDSOneEqUnsolved",
                description="Two dynamic states in one equation with unsolved incidences",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a2 ---
    --- Unsolved equation (Block 1(a2).0) ---
    ds(0, a1) ^ 2 + ds(0, a2) ^ 2 = 1
      Computed variables: a1
    -------------------------------
  --- States: a1 ---
    --- Unsolved equation (Block 1(a1).0) ---
    ds(0, a1) ^ 2 + ds(0, a2) ^ 2 = 1
      Computed variables: a2
    -------------------------------

--- Torn linear system (Block 2) of 1 iteration variables and 2 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  b
  der(a2)

Iteration variables:
  der(a1)

Torn equations:
  b := der(a1)
  der(a2) := b

Residual equations:
  2 * ds(0, a1) * der(a1) + 2 * ds(0, a2) * der(a2) = 0
    Iteration variables: der(a1)

Jacobian:
  |-1.0, 0.0, 1.0|
  |-1.0, 1.0, 0.0|
  |0.0, 2 * ds(0, a2), 2 * ds(0, a1)|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)
-------------------------------
")})));
        end TwoDSOneEqUnsolved;

        model ThreeDSOneEq
            // a1 a2 a3
            // +  +  +
            Real a1;
            Real a2;
            Real a3;
            Real b;
        equation
            der(a1) = b;
            der(a2) = b;
            der(a3) = b;
            a1 * a2 * a3 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_ThreeDSOneEq",
                description="Three dynamic states in one equation",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a2, a1 ---
    --- Solved equation ---
    a3 := 1 / (ds(0, a1) * ds(0, a2))
    -------------------------------
  --- States: a3, a1 ---
    --- Solved equation ---
    a2 := 1 / (ds(0, a1) * ds(0, a3))
    -------------------------------
  --- States: a3, a2 ---
    --- Solved equation ---
    a1 := 1 / (ds(0, a2) * ds(0, a3))
    -------------------------------

--- Torn linear system (Block 2) of 1 iteration variables and 3 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  b
  der(a2)
  der(a1)

Iteration variables:
  der(a3)

Torn equations:
  b := der(a3)
  der(a2) := b
  der(a1) := b

Residual equations:
  ds(0, a1) * ds(0, a2) * der(a3) + (ds(0, a1) * der(a2) + der(a1) * ds(0, a2)) * ds(0, a3) = 0
    Iteration variables: der(a3)

Jacobian:
  |-1.0, 0.0, 0.0, 1.0|
  |-1.0, 1.0, 0.0, 0.0|
  |-1.0, 0.0, 1.0, 0.0|
  |0.0, ds(0, a1) * ds(0, a3), ds(0, a2) * ds(0, a3), ds(0, a1) * ds(0, a2)|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)

--- Solved equation ---
der(_ds.0.s1) := dsDer(0, 1)
-------------------------------
")})));
        end ThreeDSOneEq;

        model ThreeDSTwoEq
            // a1 a2 a3
            // +  +    
            //    +  + 
            Real a1;
            Real a2;
            Real a3;
            Real b;
        equation
            der(a1) = b;
            der(a2) + der(a3) = b;
            a1 * a2 = 1;
            a2 * a3 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_ThreeDSTwoEq",
                description="Three dynamic states in two equation",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a1 ---
    --- Solved equation ---
    a2 := 1 / ds(0, a1)

    --- Solved equation ---
    a3 := 1 / ds(0, a2)
    -------------------------------
  --- States: a2 ---
    --- Solved equation ---
    a3 := 1 / ds(0, a2)

    --- Solved equation ---
    a1 := 1 / ds(0, a2)
    -------------------------------
  --- States: a3 ---
    --- Solved equation ---
    a2 := 1 / ds(0, a3)

    --- Solved equation ---
    a1 := 1 / ds(0, a2)
    -------------------------------

--- Torn linear system (Block 2) of 2 iteration variables and 2 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  b
  der(a1)

Iteration variables:
  der(a2)
  der(a3)

Torn equations:
  b := der(a2) + der(a3)
  der(a1) := b

Residual equations:
  ds(0, a2) * der(a3) + der(a2) * ds(0, a3) = 0
    Iteration variables: der(a2)
  ds(0, a1) * der(a2) + der(a1) * ds(0, a2) = 0
    Iteration variables: der(a3)

Jacobian:
  |-1.0, 0.0, 1.0, 1.0|
  |-1.0, 1.0, 0.0, 0.0|
  |0.0, 0.0, ds(0, a3), ds(0, a2)|
  |0.0, ds(0, a2), ds(0, a1), 0.0|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)
-------------------------------
")})));
        end ThreeDSTwoEq;

        model FourDSTwoEq
            // a1 a2 a3 a4
            // +  +  +    
            //    +  +  + 
            Real a1;
            Real a2;
            Real a3;
            Real a4;
            Real b;
        equation
            der(a1) = b;
            der(a2) = b;
            der(a3) + der(a4) = b;
            a1 * a2 * a3 = 1;
            a2 * a3 * a4 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_FourDSTwoEq",
                description="Four dynamic states in two equation",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a2, a1 ---
    --- Solved equation ---
    a3 := 1 / (ds(0, a1) * ds(0, a2))

    --- Solved equation ---
    a4 := 1 / (ds(0, a2) * ds(0, a3))
    -------------------------------
  --- States: a3, a1 ---
    --- Solved equation ---
    a2 := 1 / (ds(0, a1) * ds(0, a3))

    --- Solved equation ---
    a4 := 1 / (ds(0, a2) * ds(0, a3))
    -------------------------------
  --- States: a3, a2 ---
    --- Solved equation ---
    a4 := 1 / (ds(0, a2) * ds(0, a3))

    --- Solved equation ---
    a1 := 1 / (ds(0, a2) * ds(0, a3))
    -------------------------------
  --- States: a4, a1 ---
    --- Unsolved system (Block 1(a4, a1).0) of 2 variables ---
    Unknown variables:
      a2 ()
      a3 ()

    Equations:
      ds(0, a1) * ds(0, a2) * ds(0, a3) = 1
        Iteration variables: a2
      ds(0, a2) * ds(0, a3) * ds(0, a4) = 1
        Iteration variables: a3
    -------------------------------
  --- States: a4, a2 ---
    --- Solved equation ---
    a3 := 1 / (ds(0, a2) * ds(0, a4))

    --- Solved equation ---
    a1 := 1 / (ds(0, a2) * ds(0, a3))
    -------------------------------
  --- States: a4, a3 ---
    --- Solved equation ---
    a2 := 1 / (ds(0, a3) * ds(0, a4))

    --- Solved equation ---
    a1 := 1 / (ds(0, a2) * ds(0, a3))
    -------------------------------

--- Torn linear system (Block 2) of 2 iteration variables and 3 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  b
  der(a2)
  der(a1)

Iteration variables:
  der(a3)
  der(a4)

Torn equations:
  b := der(a3) + der(a4)
  der(a2) := b
  der(a1) := b

Residual equations:
  ds(0, a2) * ds(0, a3) * der(a4) + (ds(0, a2) * der(a3) + der(a2) * ds(0, a3)) * ds(0, a4) = 0
    Iteration variables: der(a3)
  ds(0, a1) * ds(0, a2) * der(a3) + (ds(0, a1) * der(a2) + der(a1) * ds(0, a2)) * ds(0, a3) = 0
    Iteration variables: der(a4)

Jacobian:
  |-1.0, 0.0, 0.0, 1.0, 1.0|
  |-1.0, 1.0, 0.0, 0.0, 0.0|
  |-1.0, 0.0, 1.0, 0.0, 0.0|
  |0.0, ds(0, a3) * ds(0, a4), 0.0, ds(0, a2) * ds(0, a4), ds(0, a2) * ds(0, a3)|
  |0.0, ds(0, a1) * ds(0, a3), ds(0, a2) * ds(0, a3), ds(0, a1) * ds(0, a2), 0.0|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)

--- Solved equation ---
der(_ds.0.s1) := dsDer(0, 1)
-------------------------------
")})));
        end FourDSTwoEq;

        model FiveDSTwoEq
            // a1 a2 a3 a4 a5
            // +  +  +      
            //       +  +  +
            Real a1;
            Real a2;
            Real a3;
            Real a4;
            Real a5;
            Real b;
        equation
            der(a1) = b;
            der(a2) = b;
            der(a3) = b;
            der(a4) + der(a5) = b;
            a1 * a2 * a3 = 1;
            a3 * a4 * a5 = 1;

        annotation(__JModelica(disabled_UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_FiveDSTwoEq",
                description="Five dynamic states in two equation",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
")})));
        end FiveDSTwoEq;

        model TwoDSSetMerge
            // a1 a2 a3 a4
            // +  +       
            //    *  *    
            //       +  + 
            Real a1;
            Real a2;
            Real a3;
            Real a4;
            Real b;
        equation
            der(a1) + der(a4) = b;
            der(a2) + der(a3) = b;
            a1 * a2 = 1;
            a2 + a3 = 1;
            a3 * a4 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_TwoDSSetMerge",
                description="Two dynamic state sets that need to be merged",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a3 ---
    --- Solved equation ---
    a4 := 1 / ds(0, a3)

    --- Solved equation ---
    a2 := - ds(0, a3) + 1

    --- Solved equation ---
    a1 := 1 / ds(0, a2)
    -------------------------------
  --- States: a1 ---
    --- Solved equation ---
    a2 := 1 / ds(0, a1)

    --- Solved equation ---
    a3 := - ds(0, a2) + 1

    --- Solved equation ---
    a4 := 1 / ds(0, a3)
    -------------------------------
  --- States: a2 ---
    --- Solved equation ---
    a3 := - ds(0, a2) + 1

    --- Solved equation ---
    a4 := 1 / ds(0, a3)

    --- Solved equation ---
    a1 := 1 / ds(0, a2)
    -------------------------------
  --- States: a4 ---
    --- Solved equation ---
    a3 := 1 / ds(0, a4)

    --- Solved equation ---
    a2 := - ds(0, a3) + 1

    --- Solved equation ---
    a1 := 1 / ds(0, a2)
    -------------------------------

--- Torn linear system (Block 2) of 2 iteration variables and 3 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  der(a3)
  b
  der(a1)

Iteration variables:
  der(a2)
  der(a4)

Torn equations:
  der(a3) := - der(a2)
  b := der(a2) + der(a3)
  der(a1) := - der(a4) + b

Residual equations:
  ds(0, a1) * der(a2) + der(a1) * ds(0, a2) = 0
    Iteration variables: der(a2)
  ds(0, a3) * der(a4) + der(a3) * ds(0, a4) = 0
    Iteration variables: der(a4)

Jacobian:
  |1.0, 0.0, 0.0, 1.0, 0.0|
  |1.0, -1.0, 0.0, 1.0, 0.0|
  |0.0, -1.0, 1.0, 0.0, 1.0|
  |0.0, 0.0, ds(0, a2), ds(0, a1), 0.0|
  |ds(0, a4), 0.0, 0.0, 0.0, ds(0, a3)|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)
-------------------------------
")})));
        end TwoDSSetMerge;

        model TwoDSSetForced
            // a1 a2 a3 a4 a5
            // *  +  +       
            // *        *    
            //          +  + 
            Real a1;
            Real a2;
            Real a3;
            Real a4;
            Real a5;
        equation
            der(a1) + der(a4) + der(a5) = 0;
            der(a2) + der(a3) = 0;
            a1 = a2 * a3;
            a1 + a4 = 1;
            a4 * a5 = 1;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Basic_TwoDSSetForced",
                description="Two dynamic states sets where one is forced by the other",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: a4 ---
    --- Solved equation ---
    a5 := 1 / ds(0, a4)
    -------------------------------
  --- States: a5 ---
    --- Solved equation ---
    a4 := 1 / ds(0, a5)
    -------------------------------

--- Torn linear system (Block 2) of 1 iteration variables and 2 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  der(a4)
  der(a5)

Iteration variables:
  _der_a1

Torn equations:
  der(a4) := - _der_a1
  der(a5) := - _der_a1 + (- der(a4))

Residual equations:
  ds(0, a4) * der(a5) + der(a4) * ds(0, a5) = 0
    Iteration variables: _der_a1

Jacobian:
  |1.0, 0.0, 1.0|
  |1.0, 1.0, 1.0|
  |ds(0, a5), ds(0, a4), 0.0|

--- Solved equation ---
a1 := - ds(0, a4) + 1

--- Dynamic state block ---
  --- States: a2 ---
    --- Solved equation ---
    a3 := (- a1) / (- ds(1, a2))
    -------------------------------
  --- States: a3 ---
    --- Solved equation ---
    a2 := (- a1) / (- ds(1, a3))
    -------------------------------

--- Torn linear system (Block 4) of 1 iteration variables and 1 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  der(a2)

Iteration variables:
  der(a3)

Torn equations:
  der(a2) := - der(a3)

Residual equations:
  _der_a1 = ds(1, a2) * der(a3) + der(a2) * ds(1, a3)
    Iteration variables: der(a3)

Jacobian:
  |1.0, 1.0|
  |- ds(1, a3), - ds(1, a2)|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)

--- Solved equation ---
der(_ds.1.s0) := dsDer(1, 0)
-------------------------------
")})));
        end TwoDSSetForced;

    end Basic;
    
    package Examples
        model Pendulum
            parameter Real L = 1 "Pendulum length";
            parameter Real g = 9.81 "Acceleration due to gravity";
            Real x "Cartesian x coordinate";
            Real y "Cartesian x coordinate";
            Real vx "Velocity in x coordinate";
            Real vy "Velocity in y coordinate";
            Real lambda "Lagrange multiplier";
        equation
            der(x) = vx;
            der(y) = vy;
            der(vx) = lambda*x;
            der(vy) = lambda*y - g;
            x^2 + y^2 = L;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="DynamicStates_Examples_Pendulum_BLT",
                description="Check the BLT of the pendulum model",
                dynamic_states=true,
                methodName="printDAEBLT",
                methodResult="
--- Dynamic state block ---
  --- States: y ---
    --- Unsolved equation (Block 1(y).0) ---
    ds(1, x) ^ 2 + ds(1, y) ^ 2 = L
      Computed variables: x
    -------------------------------
  --- States: x ---
    --- Unsolved equation (Block 1(x).0) ---
    ds(1, x) ^ 2 + ds(1, y) ^ 2 = L
      Computed variables: y
    -------------------------------

--- Dynamic state block ---
  --- States: _der_y ---
    --- Solved equation ---
    der(y) := ds(0, _der_y)

    --- Solved equation ---
    der(x) := (- 2 * ds(1, y) * der(y)) / (2 * ds(1, x))

    --- Solved equation ---
    _der_x := der(x)
    -------------------------------
  --- States: _der_x ---
    --- Solved equation ---
    der(x) := ds(0, _der_x)

    --- Solved equation ---
    der(y) := (- 2 * ds(1, x) * der(x)) / (2 * ds(1, y))

    --- Solved equation ---
    _der_y := der(y)
    -------------------------------

--- Solved equation ---
vx := der(x)

--- Solved equation ---
vy := der(y)

--- Torn linear system (Block 3) of 1 iteration variables and 4 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  _der_vy
  der(_der_y)
  _der_vx
  der(_der_x)

Iteration variables:
  lambda

Torn equations:
  _der_vy := lambda * ds(1, y) + (- g)
  der(_der_y) := _der_vy
  _der_vx := lambda * ds(1, x)
  der(_der_x) := _der_vx

Residual equations:
  2 * ds(1, x) * der(_der_x) + 2 * der(x) * der(x) + (2 * ds(1, y) * der(_der_y) + 2 * der(y) * der(y)) = 0.0
    Iteration variables: lambda

Jacobian:
  |1.0, 0.0, 0.0, 0.0, - ds(1, y)|
  |-1.0, 1.0, 0.0, 0.0, 0.0|
  |0.0, 0.0, 1.0, 0.0, (- ds(1, x))|
  |0.0, 0.0, -1.0, 1.0, 0.0|
  |0.0, 2 * ds(1, y), 0.0, 2 * ds(1, x), 0.0|

--- Solved equation ---
der(_ds.0.s0) := dsDer(0, 0)

--- Solved equation ---
der(_ds.1.s0) := dsDer(1, 0)
-------------------------------
"),TransformCanonicalTestCase(
                name="DynamicStates_Examples_Pendulum_Model",
                description="Check the model of the pendulum model",
                dynamic_states=true,
                flatModel="
fclass DynamicStates.Examples.Pendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_vx;
 Real _der_vy;
 Real _der_x;
 Real _der_y;
 Real _ds.0.a0;
 Real _ds.0.s0;
 Real _ds.1.a0;
 Real _ds.1.s0;
initial equation 
 _ds.0.s0 = 0.0;
 _ds.1.s0 = 0.0;
 x = 0.0;
 y = 0.0;
 _der_x = 0.0;
 _der_y = 0.0;
equation
 der(x) = vx;
 der(y) = vy;
 _der_vx = lambda * ds(1, x);
 _der_vy = lambda * ds(1, y) - g;
 ds(1, x) ^ 2 + ds(1, y) ^ 2 = L;
 2 * ds(1, x) * der(x) + 2 * ds(1, y) * der(y) = 0.0;
 der(_der_x) = _der_vx;
 der(_der_y) = _der_vy;
 2 * ds(1, x) * der(_der_x) + 2 * der(x) * der(x) + (2 * ds(1, y) * der(_der_y) + 2 * der(y) * der(y)) = 0.0;
 ds(0, _der_x) = der(x);
 ds(0, _der_y) = der(y);
 der(_ds.0.s0) = dsDer(0, 0);
 der(_ds.1.s0) = dsDer(1, 0);
end DynamicStates.Examples.Pendulum;
")})));
        end Pendulum;
    end Examples;
end DynamicStates;
