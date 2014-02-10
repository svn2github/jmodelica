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

package InteractiveFMU

    model ScalarEquation1
        Real x;
        Real y;
    equation
        x = y + time;
        y = x - 2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ScalarEquation1",
            description="Test of interactive FMU of scalar equations",
            equation_sorting=true,
            interactive_fmu=true,
            automatic_tearing=false,
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  (- iter_1) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_1
Solution:
  x + (- y) + (- time)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  y + (- x) + 2
-------------------------------
")})));
    end ScalarEquation1;
    
    model ScalarEquation2
        Real x;
        Real y;
    equation
        x = abs(y) + time;
        y = x - 2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ScalarEquation2",
            description="Test of interactive FMU of torn scalar equations",
            equation_sorting=true,
            interactive_fmu=true,
            automatic_tearing=true,
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  abs(y) + time
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  y + (- x) + 2
-------------------------------
")})));
    end ScalarEquation2;
    
    model FunctionCallEquation1
        record R
            Real x;
            Real y;
        end R;
        function F
            input Real a;
            input Real b;
            output R r;
        algorithm
            r := R(a + b, a - b);
        end F;
        Real x, y;
        R r;
    equation
        y = sin(time);
        r.y = 2;
        r = F(x,y);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="FunctionCallEquation1",
            description="Test of interactive FMU of function call equations",
            equation_sorting=true,
            automatic_tearing=false,
            interactive_fmu=true,
            inline_functions="none",
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  sin(time)
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  (- iter_1) / (- 1.0)
-------------------------------
Solved block of 2 variables:
Unknown variables:
  temp_2
  temp_3
Equations:
  (InteractiveFMU.FunctionCallEquation1.R(temp_2, temp_3)) = InteractiveFMU.FunctionCallEquation1.F(x, y)
-------------------------------
Solved block of 1 variables:
Computed variable:
  r.x
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  temp_2 + (- r.x)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_1
Solution:
  temp_3 + (- r.y)
-------------------------------
")})));
    end FunctionCallEquation1;
    
    model FunctionCallEquation2
        record R
            Real x;
            Real y;
        end R;
        function F
            input Real a;
            input Real b;
            output R r;
        algorithm
            r := R(a + b, a - b);
        end F;
        Real x, y;
        R r;
    equation
        y = sin(time);
        r.y = 2;
        r = F(x,y);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="FunctionCallEquation2",
            description="Test of interactive FMU of torn function call equations",
            equation_sorting=true,
            interactive_fmu=true,
            inline_functions="none",
            automatic_tearing=true,
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  sin(time)
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Solved block of 2 variables:
Unknown variables:
  r.x
  temp_2
Equations:
  (InteractiveFMU.FunctionCallEquation2.R(r.x, temp_2)) = InteractiveFMU.FunctionCallEquation2.F(x, y)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  temp_2 + (- r.y)
-------------------------------
")})));
    end FunctionCallEquation2;
    
    model LocalIteration1
        Real a, b, c;
    equation
        20 = c * a;
        23 = c * b;
        c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LocalIteration1",
            description="Test of interactive FMU and local iterations",
            equation_sorting=true,
            interactive_fmu=true,
            local_iteration_in_tearing=true,
            inline_functions="none",
            automatic_tearing=true,
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  c
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  b
Solution:
  (- 23) / (- c)
-------------------------------
Solved block of 1 variables:
Computed variable:
  a
Solution:
  (- c + b) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  20 + (- c * a)
-------------------------------
")})));
    end LocalIteration1;
    
    model LocalIteration2
        Real a, b, c;
    equation
        20 = c * a;
        23 = sin(c * b);
        c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LocalIteration2",
            description="Test of interactive FMU and local iterations",
            equation_sorting=true,
            interactive_fmu=true,
            local_iteration_in_tearing=true,
            inline_functions="none",
            automatic_tearing=true,
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  c
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Non-solved block of 1 variables:
Unknown variables:
  b()
Equations:
  23 = sin(c * b)
-------------------------------
Solved block of 1 variables:
Computed variable:
  a
Solution:
  (- c + b) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  20 + (- c * a)
-------------------------------
            
")})));
    end LocalIteration2;
    
    model EquationName1
        Real x;
        Real y;
    equation
        x = abs(y) + time;
        y = x - 2 annotation(__Modelon(name=eq_1));

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="EquationName1_1",
            description="Test of interactive FMU and equation name",
            equation_sorting=true,
            interactive_fmu=true,
            automatic_tearing=true,
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (- iter_0) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  abs(y) + time
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  y + (- x) + 2
-------------------------------
Solved block of 1 variables:
Computed variable:
  eq_1
Solution:
  (- res_0) / (- 1.0)
-------------------------------
"),FClassMethodTestCase(
            name="EquationName1_2",
            description="Test of interactive FMU and equation name",
            equation_sorting=true,
            interactive_fmu=true,
            automatic_tearing=true,
            methodName="aliasDiagnostics",
            methodResult="
Alias sets:
0 variables can be eliminated
")})));
    end EquationName1;
    
    model Alias1
        class A
            Real a annotation(__Modelon(IterationVariable));
        end A;
        A a;
        Real b = a.a;
        Real c;
    equation
        time = c * b annotation(__Modelon(ResidualEquation));
        c + b = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Alias1",
            description="Test of interactive FMU and alias elimination",
            equation_sorting=true,
            interactive_fmu=true,
            hand_guided_tearing=true,
            flatModel="
fclass InteractiveFMU.Alias1
 Real a.a annotation(__Modelon(IterationVariable(enabled=true)));
 Real c;
 input Real iter_0 \"a.a\" annotation(__Modelon(IterationVariable(enabled=true)));
 output Real res_0 annotation(__Modelon(IterationVariable(enabled=true)));
equation
 res_0 = time - c * a.a;
 c + a.a = 1;
 iter_0 = a.a;
end InteractiveFMU.Alias1;
")})));
    end Alias1;
    
end InteractiveFMU;