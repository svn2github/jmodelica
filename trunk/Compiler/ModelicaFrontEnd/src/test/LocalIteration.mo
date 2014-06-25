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

package LocalIteration

    model Simple1
        Real a, b, c;
    equation
        20 = c * a;
        23 = c * b;
        c = a + b;
        annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            local_iteration_in_tearing="all",
            name="Simple1",
            description="Simple test of local iteration",
            methodName="printDAEBLT",
            methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables:
Solved variables:
  b()
  a
Iteration variables:
  c()
Solved equations:
 Iteration variables: b
  23 = c * b
  c = a + b
Residual equations:
 Iteration variables: c
  20 = c * a
-------------------------------
")})));
    end Simple1;

    package Annotation
        
        model Simple1
            Real a, b, c;
        equation
            20 = c * a;
            23 = c * b annotation(__Modelon(LocalIteration));
            c = a + b;
            annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                local_iteration_in_tearing="annotation",
                name="Annotation_Simple1",
                description="Simple test of local iteration annotation",
                methodName="printDAEBLT",
                methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables:
Solved variables:
  b()
  a
Iteration variables:
  c()
Solved equations:
 Iteration variables: b
  23 = c * b annotation(__Modelon(LocalIteration))
  c = a + b
Residual equations:
 Iteration variables: c
  20 = c * a
-------------------------------
")})));
        end Simple1;
        
        model NoAnnotation
            Real a, b, c;
        equation
            20 = c * a;
            23 = c * b;
            c = a + b;
            annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                local_iteration_in_tearing="annotation",
                name="Annotation_NoAnnotation",
                description="Test with no annotation (no local iteration)",
                methodName="printDAEBLT",
                methodResult="
-------------------------------
Torn block of 2 iteration variables and 1 solved variables:
Solved variables:
  a
Iteration variables:
  c()
  b()
Solved equations:
  c = a + b
Residual equations:
 Iteration variables: c
  23 = c * b
 Iteration variables: b
  20 = c * a
-------------------------------
")})));
        end NoAnnotation;
        
        package Enabled
        
            model True
                Real a, b, c;
            equation
                20 = c * a;
                23 = c * b annotation(__Modelon(LocalIteration(enabled=true)));
                c = a + b;
                
                annotation(__JModelica(UnitTesting(tests={
                FClassMethodTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_True",
                    description="Test of enabled annotation set to true expression",
                    methodName="printDAEBLT",
                    methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables:
Solved variables:
  b()
  a
Iteration variables:
  c()
Solved equations:
 Iteration variables: b
  23 = c * b annotation(__Modelon(LocalIteration(enabled = true)))
  c = a + b
Residual equations:
 Iteration variables: c
  20 = c * a
-------------------------------
")})));
            end True;
            
            model False
                Real a, b, c;
            equation
                20 = c * a;
                23 = c * b annotation(__Modelon(LocalIteration(enabled=false)));
                c = a + b;
                
                annotation(__JModelica(UnitTesting(tests={
                FClassMethodTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_False",
                    description="Test of enabled annotation set to false expression (no local iteration)",
                    methodName="printDAEBLT",
                    methodResult="
-------------------------------
Torn block of 2 iteration variables and 1 solved variables:
Solved variables:
  a
Iteration variables:
  c()
  b()
Solved equations:
  c = a + b
Residual equations:
 Iteration variables: c
  23 = c * b annotation(__Modelon(LocalIteration(enabled = false)))
 Iteration variables: b
  20 = c * a
-------------------------------
")})));
            end False;
            
            model Exp
                Real a, b, c;
                parameter Boolean e = true;
            equation
                20 = c * a;
                23 = c * b annotation(__Modelon(LocalIteration(enabled=e)));
                c = a + b;
                
                annotation(__JModelica(UnitTesting(tests={
                FClassMethodTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_Exp",
                    description="Test of enabled annotation set to a parameter expression",
                    methodName="printDAEBLT",
                    methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables:
Solved variables:
  b()
  a
Iteration variables:
  c()
Solved equations:
 Iteration variables: b
  23 = c * b annotation(__Modelon(LocalIteration(enabled = e)))
  c = a + b
Residual equations:
 Iteration variables: c
  20 = c * a
-------------------------------
")})));
            end Exp;
            
            model Vectorized
                Real a[2], b[2], c[2];
            equation
                {20, 1} = c .* a;
                {23, 42} = c .* b annotation(__Modelon(LocalIteration(enabled={true, false})));
                c = a .+ b;
                
                annotation(__JModelica(UnitTesting(tests={
                FClassMethodTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_Vectorized",
                    description="Test of enabled annotation set to a vectorized expression",
                    methodName="printDAEBLT",
                    methodResult="
-------------------------------
Torn linear block of 1 iteration variables and 2 solved variables:
Coefficient variability: continuous-time
Solved variables:
  b[1]()
  a[1]
Iteration variables:
  c[1]
Solved equations:
 Iteration variables: b[1]
  23 = c[1] .* b[1] annotation(__Modelon(LocalIteration(enabled = true)))
  c[1] = a[1] .+ b[1]
Residual equations:
 Iteration variables: c[1]
  20 = c[1] .* a[1]
Jacobian:
  |(- c[1]), 0.0, (- b[1])|
  |- 1.0, - 1.0, 1.0|
  |0.0, (- c[1]), (- a[1])|
-------------------------------
Torn linear block of 2 iteration variables and 1 solved variables:
Coefficient variability: continuous-time
Solved variables:
  a[2]
Iteration variables:
  c[2]
  b[2]
Solved equations:
  c[2] = a[2] .+ b[2]
Residual equations:
 Iteration variables: c[2]
  42 = c[2] .* b[2] annotation(__Modelon(LocalIteration(enabled = false)))
 Iteration variables: b[2]
  1 = c[2] .* a[2]
Jacobian:
  |- 1.0, 1.0, - 1.0|
  |0.0, (- b[2]), (- c[2])|
  |(- c[2]), (- a[2]), 0.0|
-------------------------------
")})));
            end Vectorized;
        
            model Error1
                Real a, b, c;
            equation
                20 = c * a;
                23 = c * b annotation(__Modelon(LocalIteration(enabled=1)));
                c = a + b;
                
            annotation(__JModelica(UnitTesting(tests={
                ErrorTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_Error1",
                    description="Test of enabled annotation with expression of wrong type",
                    errorMessage="
1 errors found:

Error: in file '...':
Semantic error at line 0, column 0:
  The type of the enabled expression is not boolean
")})));
            end Error1;
        
            model Error2
                Real a, b, c;
            equation
                20 = c * a;
                23 = c * b annotation(__Modelon(LocalIteration(enabled=unknownParameter3)));
                c = a + b;
                
            annotation(__JModelica(UnitTesting(tests={
                ErrorTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_Error2",
                    description="Test of enabled annotation with unknown parameter expression",
                    errorMessage="
2 errors found:

Error: in file '...':
Semantic error at line 0, column 0:
  Cannot find class or component declaration for unknownParameter3
")})));
            end Error2;
        
            model Error3
                Real a, b, c;
            equation
                20 = c * a;
                23 = c * b annotation(__Modelon(LocalIteration(enabled={true, false})));
                c = a + b;
                
            annotation(__JModelica(UnitTesting(tests={
                ErrorTestCase(
                    local_iteration_in_tearing="annotation",
                    name="Annotation_Enabled_Error3",
                    description="Test of enabled annotation with missmatched size",
                    errorMessage="
1 errors found:

Error: in file '...':
Semantic error at line 0, column 0:
  Array size mismatch for the enabled attribute, size of component declaration is scalar and size of expression is [2]
")})));
            end Error3;
            
        end Enabled;
        
    end Annotation;



end LocalIteration;
