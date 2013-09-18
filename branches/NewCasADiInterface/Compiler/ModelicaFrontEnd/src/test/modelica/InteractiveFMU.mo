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
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_1
Solution:
  iter_1 + (- iter_0) + (- time)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  iter_0 + (- iter_1) + 2
-------------------------------
")})));
	end ScalarEquation1;
	
	model ScalarEquation2
		Real x;
		Real y;
	equation
		x = y + time;
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
  x
Solution:
  iter_0 + time
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  iter_0 + (- x) + 2
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
Solved block of 2 variables:
Unknown variables:
  temp_2
  temp_3
Equations:
  (InteractiveFMU.FunctionCallEquation1.R(temp_2, temp_3)) = InteractiveFMU.FunctionCallEquation1.F(iter_1, y)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  temp_2 + (- iter_0)
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
Solved block of 2 variables:
Unknown variables:
  r.x
  temp_2
Equations:
  (InteractiveFMU.FunctionCallEquation2.R(r.x, temp_2)) = InteractiveFMU.FunctionCallEquation2.F(iter_0, y)
-------------------------------
Solved block of 1 variables:
Computed variable:
  res_0
Solution:
  temp_2 + (- r.y)
-------------------------------
")})));
	end FunctionCallEquation2;
	
	
end InteractiveFMU;