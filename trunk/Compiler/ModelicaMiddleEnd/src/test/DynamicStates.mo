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
    a2 := 1 / DSS(0, a1)
    -------------------------------
  --- States: a2 ---
    --- Solved equation ---
    a1 := 1 / DSS(0, a2)
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
  DSS(0, a1) * der(a2) + der(a1) * DSS(0, a2) = 0
    Iteration variables: der(a2)

Jacobian:
  |-1.0, 0.0, 1.0|
  |-1.0, 1.0, 0.0|
  |0.0, DSS(0, a2), DSS(0, a1)|
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
    DSS(0, a1) ^ 2 + DSS(0, a2) ^ 2 = 1
      Computed variables: a1
    -------------------------------
  --- States: a1 ---
    --- Unsolved equation (Block 1(a1).0) ---
    DSS(0, a1) ^ 2 + DSS(0, a2) ^ 2 = 1
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
  2 * DSS(0, a1) * der(a1) + 2 * DSS(0, a2) * der(a2) = 0
    Iteration variables: der(a1)

Jacobian:
  |-1.0, 0.0, 1.0|
  |-1.0, 1.0, 0.0|
  |0.0, 2 * DSS(0, a2), 2 * DSS(0, a1)|
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
    a3 := 1 / (DSS(0, a1) * DSS(0, a2))
    -------------------------------
  --- States: a3, a1 ---
    --- Solved equation ---
    a2 := 1 / (DSS(0, a1) * DSS(0, a3))
    -------------------------------
  --- States: a3, a2 ---
    --- Solved equation ---
    a1 := 1 / (DSS(0, a2) * DSS(0, a3))
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
  DSS(0, a1) * DSS(0, a2) * der(a3) + (DSS(0, a1) * der(a2) + der(a1) * DSS(0, a2)) * DSS(0, a3) = 0
    Iteration variables: der(a3)

Jacobian:
  |-1.0, 0.0, 0.0, 1.0|
  |-1.0, 1.0, 0.0, 0.0|
  |-1.0, 0.0, 1.0, 0.0|
  |0.0, DSS(0, a1) * DSS(0, a3), DSS(0, a2) * DSS(0, a3), DSS(0, a1) * DSS(0, a2)|
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
    a2 := 1 / DSS(0, a1)

    --- Solved equation ---
    a3 := 1 / DSS(0, a2)
    -------------------------------
  --- States: a2 ---
    --- Solved equation ---
    a3 := 1 / DSS(0, a2)

    --- Solved equation ---
    a1 := 1 / DSS(0, a2)
    -------------------------------
  --- States: a3 ---
    --- Solved equation ---
    a2 := 1 / DSS(0, a3)

    --- Solved equation ---
    a1 := 1 / DSS(0, a2)
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
  b := - (- der(a2) + (- der(a3)))
  der(a1) := b

Residual equations:
  DSS(0, a2) * der(a3) + der(a2) * DSS(0, a3) = 0
    Iteration variables: der(a2)
  DSS(0, a1) * der(a2) + der(a1) * DSS(0, a2) = 0
    Iteration variables: der(a3)

Jacobian:
  |-1.0, 0.0, 1.0, 1.0|
  |-1.0, 1.0, 0.0, 0.0|
  |0.0, 0.0, DSS(0, a3), DSS(0, a2)|
  |0.0, DSS(0, a2), DSS(0, a1), 0.0|
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
    a3 := 1 / (DSS(0, a1) * DSS(0, a2))

    --- Solved equation ---
    a4 := 1 / (DSS(0, a2) * DSS(0, a3))
    -------------------------------
  --- States: a3, a1 ---
    --- Solved equation ---
    a2 := 1 / (DSS(0, a1) * DSS(0, a3))

    --- Solved equation ---
    a4 := 1 / (DSS(0, a2) * DSS(0, a3))
    -------------------------------
  --- States: a3, a2 ---
    --- Solved equation ---
    a4 := 1 / (DSS(0, a2) * DSS(0, a3))

    --- Solved equation ---
    a1 := 1 / (DSS(0, a2) * DSS(0, a3))
    -------------------------------
  --- States: a4, a1 ---
    --- Unsolved system (Block 1(a4, a1).0) of 2 variables ---
    Unknown variables:
      a2 ()
      a3 ()

    Equations:
      DSS(0, a1) * DSS(0, a2) * DSS(0, a3) = 1
        Iteration variables: a2
      DSS(0, a2) * DSS(0, a3) * DSS(0, a4) = 1
        Iteration variables: a3
    -------------------------------
  --- States: a4, a2 ---
    --- Solved equation ---
    a3 := 1 / (DSS(0, a2) * DSS(0, a4))

    --- Solved equation ---
    a1 := 1 / (DSS(0, a2) * DSS(0, a3))
    -------------------------------
  --- States: a4, a3 ---
    --- Solved equation ---
    a2 := 1 / (DSS(0, a3) * DSS(0, a4))

    --- Solved equation ---
    a1 := 1 / (DSS(0, a2) * DSS(0, a3))
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
  b := - (- der(a3) + (- der(a4)))
  der(a2) := b
  der(a1) := b

Residual equations:
  DSS(0, a2) * DSS(0, a3) * der(a4) + (DSS(0, a2) * der(a3) + der(a2) * DSS(0, a3)) * DSS(0, a4) = 0
    Iteration variables: der(a3)
  DSS(0, a1) * DSS(0, a2) * der(a3) + (DSS(0, a1) * der(a2) + der(a1) * DSS(0, a2)) * DSS(0, a3) = 0
    Iteration variables: der(a4)

Jacobian:
  |-1.0, 0.0, 0.0, 1.0, 1.0|
  |-1.0, 1.0, 0.0, 0.0, 0.0|
  |-1.0, 0.0, 1.0, 0.0, 0.0|
  |0.0, DSS(0, a3) * DSS(0, a4), 0.0, DSS(0, a2) * DSS(0, a4), DSS(0, a2) * DSS(0, a3)|
  |0.0, DSS(0, a1) * DSS(0, a3), DSS(0, a2) * DSS(0, a3), DSS(0, a1) * DSS(0, a2), 0.0|
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
    a4 := 1 / DSS(0, a3)

    --- Solved equation ---
    a2 := - DSS(0, a3) + 1

    --- Solved equation ---
    a1 := 1 / DSS(0, a2)
    -------------------------------
  --- States: a1 ---
    --- Solved equation ---
    a2 := 1 / DSS(0, a1)

    --- Solved equation ---
    a3 := - DSS(0, a2) + 1

    --- Solved equation ---
    a4 := 1 / DSS(0, a3)
    -------------------------------
  --- States: a2 ---
    --- Solved equation ---
    a3 := - DSS(0, a2) + 1

    --- Solved equation ---
    a4 := 1 / DSS(0, a3)

    --- Solved equation ---
    a1 := 1 / DSS(0, a2)
    -------------------------------
  --- States: a4 ---
    --- Solved equation ---
    a3 := 1 / DSS(0, a4)

    --- Solved equation ---
    a2 := - DSS(0, a3) + 1

    --- Solved equation ---
    a1 := 1 / DSS(0, a2)
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
  b := - (- der(a2) + (- der(a3)))
  der(a1) := - der(a4) + b

Residual equations:
  DSS(0, a1) * der(a2) + der(a1) * DSS(0, a2) = 0
    Iteration variables: der(a2)
  DSS(0, a3) * der(a4) + der(a3) * DSS(0, a4) = 0
    Iteration variables: der(a4)

Jacobian:
  |1.0, 0.0, 0.0, 1.0, 0.0|
  |1.0, -1.0, 0.0, 1.0, 0.0|
  |0.0, -1.0, 1.0, 0.0, 1.0|
  |0.0, 0.0, DSS(0, a2), DSS(0, a1), 0.0|
  |DSS(0, a4), 0.0, 0.0, 0.0, DSS(0, a3)|
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
    a5 := 1 / DSS(0, a4)
    -------------------------------
  --- States: a5 ---
    --- Solved equation ---
    a4 := 1 / DSS(0, a5)
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
  DSS(0, a4) * der(a5) + der(a4) * DSS(0, a5) = 0
    Iteration variables: _der_a1

Jacobian:
  |1.0, 0.0, 1.0|
  |1.0, 1.0, 1.0|
  |DSS(0, a5), DSS(0, a4), 0.0|

--- Solved equation ---
a1 := - DSS(0, a4) + 1

--- Dynamic state block ---
  --- States: a2 ---
    --- Solved equation ---
    a3 := (- a1) / (- DSS(1, a2))
    -------------------------------
  --- States: a3 ---
    --- Solved equation ---
    a2 := (- a1) / (- DSS(1, a3))
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
  _der_a1 = DSS(1, a2) * der(a3) + der(a2) * DSS(1, a3)
    Iteration variables: der(a3)

Jacobian:
  |1.0, 1.0|
  |- DSS(1, a3), - DSS(1, a2)|
-------------------------------
")})));
        end TwoDSSetForced;

    end Basic;
end DynamicStates;
