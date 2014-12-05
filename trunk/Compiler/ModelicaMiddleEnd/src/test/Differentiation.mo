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


package Differentiation
    package Expressions
        model Cos
            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + cos(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Cos",
                description="Test differentiation of cos",
                flatModel="
fclass Differentiation.Expressions.Cos
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + cos(x2) = 0;
 _der_x1 + (- sin(x2) * der(x2)) = 0;
end Differentiation.Expressions.Cos;
")})));
        end Cos;

        model Sin
            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + sin(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Sin",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Sin
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sin(x2) = 0;
 _der_x1 + cos(x2) * der(x2) = 0;
end Differentiation.Expressions.Sin;
")})));
        end Sin;

        model Neg
            Real x1,x2(stateSelect=StateSelect.prefer);
        equation
            der(x1) + der(x2) = 1;
-           x1 + 2*x2 = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Neg",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Neg
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 - x1 + 2 * x2 = 0;
 - _der_x1 + 2 * der(x2) = 0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end Differentiation.Expressions.Neg;
")})));
        end Neg;

        model Exp
            Real x1,x2(stateSelect=StateSelect.prefer);
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + exp(x2*p*time) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Exp",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Exp
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + exp(x2 * p * time) = 0;
 _der_x1 + exp(x2 * p * time) * (x2 * p + der(x2) * p * time) = 0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end Differentiation.Expressions.Exp;
")})));
        end Exp;

        model Tan
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + tan(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Tan",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Tan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + tan(x2) = 0;
 _der_x1 + der(x2) / cos(x2) ^ 2 = 0;
end Differentiation.Expressions.Tan;
")})));
        end Tan;

        model Asin
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + asin(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Asin",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Asin
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + asin(x2) = 0;
 _der_x1 + der(x2) / sqrt(1 - x2 ^ 2) = 0;
end Differentiation.Expressions.Asin;
")})));
        end Asin;

        model Acos
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + acos(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Acos",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Acos
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + acos(x2) = 0;
 _der_x1 + (- der(x2)) / sqrt(1 - x2 ^ 2) = 0;
end Differentiation.Expressions.Acos;
")})));
        end Acos;

        model Atan
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + atan(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Atan",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Atan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + atan(x2) = 0;
 _der_x1 + der(x2) / (1 + x2 ^ 2) = 0;
end Differentiation.Expressions.Atan;
")})));
        end Atan;

        model Atan2
            Real x1,x2,x3;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            der(x3) = time;
            x1 + atan2(x2,x3) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Atan2",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Atan2
 Real x1;
 Real x2;
 Real x3;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
 x3 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 der(x3) = time;
 x1 + atan2(x2, x3) = 0;
 _der_x1 + (der(x2) * x3 - x2 * der(x3)) / (x2 * x2 + x3 * x3) = 0;
end Differentiation.Expressions.Atan2;
")})));
        end Atan2;

        model Sinh
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + sinh(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Sinh",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Sinh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sinh(x2) = 0;
 _der_x1 + cosh(x2) * der(x2) = 0;
end Differentiation.Expressions.Sinh;
")})));
        end Sinh;

        model Cosh
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + cosh(x2) = 0;

            annotation(__JModelica(UnitTesting(tests={
                TransformCanonicalTestCase(
                    name="Expressions_Cosh",
                    description="Test of index reduction",
                    flatModel="
fclass Differentiation.Expressions.Cosh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + cosh(x2) = 0;
 _der_x1 + sinh(x2) * der(x2) = 0;
end Differentiation.Expressions.Cosh;
")})));
        end Cosh;

        model Tanh
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + tanh(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Tanh",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Tanh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + tanh(x2) = 0;
 _der_x1 + der(x2) / cosh(x2) ^ 2 = 0;
end Differentiation.Expressions.Tanh;
")})));
        end Tanh;

        model Log
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + log(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Log",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Log
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + log(x2) = 0;
 _der_x1 + der(x2) / x2 = 0;
end Differentiation.Expressions.Log;
")})));
        end Log;

        model Log10
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + log10(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Log10",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Log10
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + log10(x2) = 0;
 _der_x1 + der(x2) / (x2 * log(10)) = 0;
end Differentiation.Expressions.Log10;
")})));
        end Log10;

        model Sqrt
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + sqrt(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Sqrt",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Sqrt
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sqrt(x2) = 0;
 _der_x1 + der(x2) / (2 * sqrt(x2)) = 0;
end Differentiation.Expressions.Sqrt;
")})));
        end Sqrt;

        model If
            Real x1,x2(stateSelect=StateSelect.prefer);
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + (if p>3 then 3*x2 else if p<=3 then sin(x2) else 2*x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_If",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.If
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + (if p > 3 then 3 * x2 elseif p <= 3 then sin(x2) else 2 * x2) = 0;
 _der_x1 + (if p > 3 then 3 * der(x2) elseif p <= 3 then cos(x2) * der(x2) else 2 * der(x2)) = 0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end Differentiation.Expressions.If;
")})));
        end If;

        model Pow
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + x2^p + x2^1.4 = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Pow",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Pow
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + x2 ^ p + x2 ^ 1.4 = 0;
 _der_x1 + p * x2 ^ (p - 1) * der(x2) + 1.4 * x2 ^ 0.3999999999999999 * der(x2) = 0;
end Differentiation.Expressions.Pow;
")})));
        end Pow;

        model Div1
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            (x1 + x2)/(x1 + p) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Div1",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Div1
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 (x1 + x2) / (x1 + p) = 0;
 ((_der_x1 + der(x2)) * (x1 + p) - (x1 + x2) * _der_x1) / (x1 + p) ^ 2 = 0;
end Differentiation.Expressions.Div1;
")})));
        end Div1;

        model Div2
            Real x1,x2;
            parameter Real p1 = 2;
            parameter Real p2 = 5;
        equation
            der(x1) + der(x2) = 1;
            (x1 + x2)/(p1*p2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Div2",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.Div2
 Real x1;
 Real x2;
 parameter Real p1 = 2 /* 2 */;
 parameter Real p2 = 5 /* 5 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 (x1 + x2) / (p1 * p2) = 0;
 (_der_x1 + der(x2)) / (p1 * p2) = 0;
end Differentiation.Expressions.Div2;
")})));
        end Div2;

        model NoEvent
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            noEvent(x1 + sin(x2)) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_NoEvent",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.NoEvent
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;
 noEvent(_der_x1 + cos(x2) * der(x2)) = 0;
end Differentiation.Expressions.NoEvent;
")})));
        end NoEvent;

        model MinExp
            Real x1,x2,x3;
        equation
            der(x1) + der(x2) + der(x3) = 1;
            min({x1,x2}) = 0;
            min(x1,x3) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="IMinExp",
                description="Test of index reduction. Min expression.",
                flatModel="
fclass Differentiation.Expressions.MinExp
 Real x1;
 Real x2;
 Real x3;
 Real _der_x2;
 Real _der_x3;
initial equation 
 x1 = 0.0;
equation
 der(x1) + _der_x2 + _der_x3 = 1;
 min(x1, x2) = 0;
 min(x1, x3) = 0;
 noEvent(if x1 < x2 then der(x1) else _der_x2) = 0;
 noEvent(if x1 < x3 then der(x1) else _der_x3) = 0;
end Differentiation.Expressions.MinExp;
")})));
        end MinExp;

        model MaxExp
            Real x1,x2,x3;
        equation
            der(x1) + der(x2) + der(x3) = 1;
            max({x1,x2}) = 0;
            max(x1,x3) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_MaxExp",
                description="Test of index reduction. Max expression.",
                flatModel="
fclass Differentiation.Expressions.MaxExp
 Real x1;
 Real x2;
 Real x3;
 Real _der_x2;
 Real _der_x3;
initial equation 
 x1 = 0.0;
equation
 der(x1) + _der_x2 + _der_x3 = 1;
 max(x1, x2) = 0;
 max(x1, x3) = 0;
 noEvent(if x1 > x2 then der(x1) else _der_x2) = 0;
 noEvent(if x1 > x3 then der(x1) else _der_x3) = 0;
end Differentiation.Expressions.MaxExp;
")})));
        end MaxExp;

        model Homotopy
            //TODO: this test should be updated when the homotopy operator is fully implemented.
            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            homotopy(x1,x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_Homotopy",
                description="Test of index reduction. Homotopy expression.",
                flatModel="
fclass Differentiation.Expressions.Homotopy
 constant Real x1 = 0;
 Real x2;
initial equation 
 x2 = 0.0;
equation
 der(x2) = 1;
end Differentiation.Expressions.Homotopy;
            
")})));
        end Homotopy;

        model DotAdd
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .+ x2 = {0,0};

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DotAdd",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.DotAdd
 Real x1[1];
 Real x1[2];
initial equation 
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ (- der(x1[1])) = 1;
 der(x1[2]) .+ (- der(x1[2])) = 1;
end Differentiation.Expressions.DotAdd;
")})));
        end DotAdd;

        model DotSub
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .- x2 = {0,0};

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DotSub",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.DotSub
 Real x1[1];
 Real x1[2];
initial equation 
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ der(x1[1]) = 1;
 der(x1[2]) .+ der(x1[2]) = 1;
end Differentiation.Expressions.DotSub;
")})));
        end DotSub;

        model DotMul
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .* x2 = {0,0};

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DotMul",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.DotMul
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] .* x2[1] = 0;
 x1[2] .* x2[2] = 0;
 x1[1] .* der(x2[1]) .+ _der_x1[1] .* x2[1] = 0;
 x1[2] .* der(x2[2]) .+ _der_x1[2] .* x2[2] = 0;
end Differentiation.Expressions.DotMul;
")})));
        end DotMul;

        model DotDiv
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 ./ x2 = {0,0};

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DotDiv",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.DotDiv
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] ./ x2[1] = 0;
 x1[2] ./ x2[2] = 0;
 (_der_x1[1] .* x2[1] .- x1[1] .* der(x2[1])) ./ x2[1] .^ 2 = 0;
 (_der_x1[2] .* x2[2] .- x1[2] .* der(x2[2])) ./ x2[2] .^ 2 = 0;
end Differentiation.Expressions.DotDiv;
")})));
        end DotDiv;

        model DotPow
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .^ x2 = {0,0};

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DotPow",
                description="Test of index reduction",
                flatModel="
fclass Differentiation.Expressions.DotPow
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] .^ x2[1] = 0;
 x1[2] .^ x2[2] = 0;
 x2[1] .* x1[1] .^ (x2[1] .- 1) .* _der_x1[1] = 0;
 x2[2] .* x1[2] .^ (x2[2] .- 1) .* _der_x1[2] = 0;
end Differentiation.Expressions.DotPow;
")})));
        end DotPow;

        model DivFunc
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + div(x2, 3.14) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DivFunc",
                description="Test differentiation of div() operator. This model probably makes no sence in the real world!",
                flatModel="
fclass Differentiation.Expressions.DivFunc
 Real x1;
 Real x2;
 discrete Real temp_1;
 Real _der_x1;
initial equation 
 pre(temp_1) = 0.0;
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + temp_1 = 1;
 temp_1 = if div(x2, 3.14) < pre(temp_1) or div(x2, 3.14) >= pre(temp_1) + 1 or initial() then div(x2, 3.14) else pre(temp_1);
 _der_x1 = 0;
end Differentiation.Expressions.DivFunc;
")})));
        end DivFunc;

        model FunctionCall1
            function f
                input Real x;
                output Real y;
                input Integer n;
            algorithm
                y := x*n;
            annotation(smoothOrder=2, Inline=false);
            end f;
            Real x,y;
        equation
            x = f(time, 2);
            y = der(x);
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_FunctionCall1",
                description="Test differentiation of function calls where the function have mixed order among inputs and outputs (also mixed type).",
                flatModel="
fclass Differentiation.Expressions.FunctionCall1
 Real x;
 Real y;
 Real _der_x;
equation
 x = Differentiation.Expressions.FunctionCall1.f(time, 2);
 y = _der_x;
 _der_x = Differentiation.Expressions.FunctionCall1._der_f(time, 2, 1.0);

public
 function Differentiation.Expressions.FunctionCall1.f
  input Real x;
  output Real y;
  input Integer n;
 algorithm
  y := x * n;
  return;
 annotation(Inline = false,smoothOrder = 2,derivative(order = 1) = Differentiation.Expressions.FunctionCall1._der_f);
 end Differentiation.Expressions.FunctionCall1.f;

 function Differentiation.Expressions.FunctionCall1._der_f
  input Real x;
  input Integer n;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := _der_x * n;
  y := x * n;
  return;
 annotation(smoothOrder = 1);
 end Differentiation.Expressions.FunctionCall1._der_f;

end Differentiation.Expressions.FunctionCall1;
")})));
        end FunctionCall1;
    end Expressions;

    model ComponentArray
        model M
            parameter Real L = 1 "Pendulum length";
            parameter Real g =9.81 "Acceleration due to gravity";
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
        end M;

        M m[1];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ComponentArray",
            description="Name for der variables from FQNameString",
            flatModel="
fclass Differentiation.ComponentArray
 parameter Real m[1].L = 1 \"Pendulum length\" /* 1 */;
 parameter Real m[1].g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real m[1].x \"Cartesian x coordinate\";
 Real m[1].y \"Cartesian x coordinate\";
 Real m[1].vx \"Velocity in x coordinate\";
 Real m[1].vy \"Velocity in y coordinate\";
 Real m[1].lambda \"Lagrange multiplier\";
 Real m[1]._der_x;
 Real m[1]._der_vx;
 Real m[1]._der_der_x;
 Real m[1]._der_der_y;
initial equation 
 m[1].y = 0.0;
 m[1].vy = 0.0;
equation
 m[1]._der_x = m[1].vx;
 der(m[1].y) = m[1].vy;
 m[1]._der_vx = m[1].lambda * m[1].x;
 der(m[1].vy) = m[1].lambda * m[1].y - m[1].g;
 m[1].x ^ 2 + m[1].y ^ 2 = m[1].L;
 2 * m[1].x * m[1]._der_x + 2 * m[1].y * der(m[1].y) = 0.0;
 m[1]._der_der_x = m[1]._der_vx;
 m[1]._der_der_y = der(m[1].vy);
 2 * m[1].x * m[1]._der_der_x + 2 * m[1]._der_x * m[1]._der_x + (2 * m[1].y * m[1]._der_der_y + 2 * der(m[1].y) * der(m[1].y)) = 0.0;
end Differentiation.ComponentArray;

")})));
    end ComponentArray;

    model BooleanVariable
        Real x,y;
        Boolean b = false;
    equation
        x = if b then 1 else 2 + y;
        der(x) + der(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="BooleanVariable",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.BooleanVariable
 Real x;
 Real y;
 constant Boolean b = false;
 Real _der_x;
initial equation 
 y = 0.0;
equation
 x = 2 + y;
 _der_x + der(y) = 0;
 _der_x = der(y);
end Differentiation.BooleanVariable;
")})));
    end BooleanVariable;

    model IntegerVariable
        Real x,y;
        Integer b = 2;
    equation
        x = if b==2 then 1 else 2 + y;
        der(x) + der(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IntegerVariable",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.IntegerVariable
 Real x;
 Real y;
 constant Integer b = 2;
 Real _der_x;
initial equation 
 y = 0.0;
equation
 x = 1;
 _der_x + der(y) = 0;
 _der_x = 0;
end Differentiation.IntegerVariable;
")})));
end IntegerVariable;

model ErrorMessage1
  Real x1;
  Real x2;
algorithm
  x1 := x2;
equation
  der(x1) + der(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ErrorMessage1",
            description="Test error messages for algorithms.",
            inline_functions="none",
            errorMessage="
Error: in file '...':
Semantic error at line 0, column 0:
  Cannot differentate the equation:
   algorithm
 x1 := x2;
")})));
    end ErrorMessage1;
    
    package DerivativeAnnotation
        model Test1
            function f
                input Real x;
                output Real y;
            algorithm
                y := x^2;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x;
                input Real der_x;
                output Real der_y;
            algorithm
                der_y := 2*x*der_x;
            end f_der;

            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + f(x2) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_Test1",
                description="Test of index reduction",
                inline_functions="none",
                flatModel="
fclass Differentiation.DerivativeAnnotation.Test1
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.DerivativeAnnotation.Test1.f(x2) = 0;
 _der_x1 + Differentiation.DerivativeAnnotation.Test1.f_der(x2, der(x2)) = 0;

public
 function Differentiation.DerivativeAnnotation.Test1.f
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Test1.f_der);
 end Differentiation.DerivativeAnnotation.Test1.f;

 function Differentiation.DerivativeAnnotation.Test1.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x * der_x;
  return;
 end Differentiation.DerivativeAnnotation.Test1.f_der;

end Differentiation.DerivativeAnnotation.Test1;
")})));
        end Test1;

        model Test2
            function f
                input Real x[2];
                input Real A[2,2];
                output Real y;
            algorithm
                y := x*A*x;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x[2];
                input Real A[2,2];
                input Real der_x[2];
                input Real der_A[2,2];
                output Real der_y;
            algorithm
                der_y := 2*x*A*der_x + x*der_A*x;
            end f_der;

            parameter Real A[2,2] = {{1,2},{3,4}};
            Real x1[2],x2[2];
        equation
            der(x1) + der(x2) = {1,2};
            x1[1] + f(x2,A) = 0;
            x1[2] = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_Test2",
                description="Test of index reduction",
                inline_functions="none",
                flatModel="
fclass Differentiation.DerivativeAnnotation.Test2
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 constant Real x1[2] = 0;
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + Differentiation.DerivativeAnnotation.Test2.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}) = 0;
 _der_x1[1] + Differentiation.DerivativeAnnotation.Test2.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}}) = 0;

public
 function Differentiation.DerivativeAnnotation.Test2.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real y;
 algorithm
  y := (x[1] * A[1,1] + x[2] * A[2,1]) * x[1] + (x[1] * A[1,2] + x[2] * A[2,2]) * x[2];
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Test2.f_der);
 end Differentiation.DerivativeAnnotation.Test2.f;

 function Differentiation.DerivativeAnnotation.Test2.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output Real der_y;
 algorithm
  der_y := (2 * x[1] * A[1,1] + 2 * x[2] * A[2,1]) * der_x[1] + (2 * x[1] * A[1,2] + 2 * x[2] * A[2,2]) * der_x[2] + ((x[1] * der_A[1,1] + x[2] * der_A[2,1]) * x[1] + (x[1] * der_A[1,2] + x[2] * der_A[2,2]) * x[2]);
  return;
 end Differentiation.DerivativeAnnotation.Test2.f_der;

end Differentiation.DerivativeAnnotation.Test2;
")})));
        end Test2;

        model Test3
            function f
                input Real x[2];
                output Real y;
            algorithm
                y := x[1]^2 + x[2]^3;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x[2];
                input Real der_x[2];
                output Real der_y;
            algorithm
                der_y := 2*x[1]*der_x[1] + 3*x[2]^2*der_x[2];
            end f_der;

            Real x1[2],x2[2];
        equation
            der(x1) + der(x2) = {1,2};
            x1[1] + f(x2) = 0;
            x1[2] = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_Test3",
                description="Test of index reduction",
                inline_functions="none",
                flatModel="
fclass Differentiation.DerivativeAnnotation.Test3
 Real x1[1];
 constant Real x1[2] = 0;
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + Differentiation.DerivativeAnnotation.Test3.f({x2[1], x2[2]}) = 0;
 _der_x1[1] + Differentiation.DerivativeAnnotation.Test3.f_der({x2[1], x2[2]}, {der(x2[1]), der(x2[2])}) = 0;

public
 function Differentiation.DerivativeAnnotation.Test3.f
  input Real[2] x;
  output Real y;
 algorithm
  y := x[1] ^ 2 + x[2] ^ 3;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Test3.f_der);
 end Differentiation.DerivativeAnnotation.Test3.f;

 function Differentiation.DerivativeAnnotation.Test3.f_der
  input Real[2] x;
  input Real[2] der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x[1] * der_x[1] + 3 * x[2] ^ 2 * der_x[2];
  return;
 end Differentiation.DerivativeAnnotation.Test3.f_der;

end Differentiation.DerivativeAnnotation.Test3;
")})));
        end Test3;

        model NoDerivative1
            function der_F
                import SI = Modelica.SIunits;
                input SI.Pressure p;
                input SI.SpecificEnthalpy h;
                input Integer phase=0;
                input Real z;
                input Real der_p;
                input Real der_h;
                output Real der_rho;
            algorithm
                der_rho := der_p + der_h;
            end der_F;

            function F 
                import SI = Modelica.SIunits;
                input SI.Pressure p;
                input SI.SpecificEnthalpy h;
                input Integer phase=0;
                input Real z;
                output SI.Density rho;
            algorithm
                rho := p + h;
            annotation(derivative(noDerivative=z)=der_F);
            end F;

            Real x,y;
        equation
            der(x) + der(y) = 0;
            x + F(y,x,0,x) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_NoDerivative1",
                description="Index reduction: function with record input & output",
                inline_functions="none",
                flatModel="
fclass Differentiation.DerivativeAnnotation.NoDerivative1
 Real x;
 Real y;
 Real _der_x;
initial equation 
 y = 0.0;
equation
 _der_x + der(y) = 0;
 x + Differentiation.DerivativeAnnotation.NoDerivative1.F(y, x, 0, x) = 0;
 _der_x + Differentiation.DerivativeAnnotation.NoDerivative1.der_F(y, x, 0, x, der(y), _der_x) = 0;

public
 function Differentiation.DerivativeAnnotation.NoDerivative1.F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  output Real rho;
 algorithm
  rho := p + h;
  return;
 annotation(derivative(noDerivative = z) = Differentiation.DerivativeAnnotation.NoDerivative1.der_F);
 end Differentiation.DerivativeAnnotation.NoDerivative1.F;

 function Differentiation.DerivativeAnnotation.NoDerivative1.der_F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  input Real der_p;
  input Real der_h;
  output Real der_rho;
 algorithm
  der_rho := der_p + der_h;
  return;
 end Differentiation.DerivativeAnnotation.NoDerivative1.der_F;

end Differentiation.DerivativeAnnotation.NoDerivative1;
")})));
        end NoDerivative1;

        model Order1
            function f
                input Real x;
                output Real y;
            algorithm
                y := x * x;
                y := y * x + 2 * y + 3 * x;
                annotation(derivative=df);
            end f;

            function df
                input Real x;
                input Real dx;
                output Real dy;
            algorithm
                dy := x * x;
                dy := dy + 2 * x + 3;
                annotation(derivative(order=2)=ddf);
            end df;

            function ddf
                input Real x;
                input Real dx;
                input Real ddx;
                output Real ddy;
            algorithm
                ddy := x;
                ddy := ddy + 2;
            end ddf;
    
            Real x;
            Real dx;
            Real y;
            Real dy;
        equation
            der(x) = dx;
            der(y) = dy;
            der(dx) + der(dy) = 0;
            x + f(y) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_Order1",
                description="Test use of order argument to derivative annotation",
                flatModel="
fclass Differentiation.DerivativeAnnotation.Order1
 Real x;
 Real dx;
 Real y;
 Real dy;
 Real _der_x;
 Real _der_dx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 dy = 0.0;
equation
 _der_x = dx;
 der(y) = dy;
 _der_dx + der(dy) = 0;
 x + Differentiation.DerivativeAnnotation.Order1.f(y) = 0;
 _der_x + Differentiation.DerivativeAnnotation.Order1.df(y, der(y)) = 0;
 _der_der_x = _der_dx;
 _der_der_y = der(dy);
 _der_der_x + Differentiation.DerivativeAnnotation.Order1.ddf(y, der(y), _der_der_y) = 0;

public
 function Differentiation.DerivativeAnnotation.Order1.f
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  y := y * x + 2 * y + 3 * x;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Order1.df);
 end Differentiation.DerivativeAnnotation.Order1.f;

 function Differentiation.DerivativeAnnotation.Order1.df
  input Real x;
  input Real dx;
  output Real dy;
 algorithm
  dy := x * x;
  dy := dy + 2 * x + 3;
  return;
 annotation(derivative(order = 2) = Differentiation.DerivativeAnnotation.Order1.ddf);
 end Differentiation.DerivativeAnnotation.Order1.df;

 function Differentiation.DerivativeAnnotation.Order1.ddf
  input Real x;
  input Real dx;
  input Real ddx;
  output Real ddy;
 algorithm
  ddy := x;
  ddy := ddy + 2;
  return;
 end Differentiation.DerivativeAnnotation.Order1.ddf;

end Differentiation.DerivativeAnnotation.Order1;
")})));
        end Order1;


        model Order2
            function f
                input Real x1;
                input Real x2;
                output Real y;
            algorithm
                y := x1 * x1;
                y := y * x2;
                annotation(derivative=df);
            end f;

            function df
                input Real x1;
                input Real x2;
                input Real dx1;
                input Real dx2;
                output Real dy;
            algorithm
                dy := x1 * x1;
                dy := dy * x2;
                annotation(derivative(order=2)=ddf);
            end df;

            function ddf
                input Real x1;
                input Real x2;
                input Real dx1;
                input Real dx2;
                input Real ddx1;
                input Real ddx2;
                output Real ddy;
            algorithm
                ddy := x1 * x1;
                ddy := ddy * x2;
            end ddf;

            Real x;
            Real dx;
            Real y;
            Real dy;
        equation
            der(x) = dx;
            der(y) = dy;
            der(dx) + der(dy) = 0;
            x + f(y, time) = 0;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_Order2",
                description="Test use of order argument to derivative annotation for function with two arguments",
                flatModel="
fclass Differentiation.DerivativeAnnotation.Order2
 Real x;
 Real dx;
 Real y;
 Real dy;
 Real _der_x;
 Real _der_dx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 dy = 0.0;
equation
 _der_x = dx;
 der(y) = dy;
 _der_dx + der(dy) = 0;
 x + Differentiation.DerivativeAnnotation.Order2.f(y, time) = 0;
 _der_x + Differentiation.DerivativeAnnotation.Order2.df(y, time, der(y), 1.0) = 0;
 _der_der_x = _der_dx;
 _der_der_y = der(dy);
 _der_der_x + Differentiation.DerivativeAnnotation.Order2.ddf(y, time, der(y), 1.0, _der_der_y, 0.0) = 0;

public
 function Differentiation.DerivativeAnnotation.Order2.f
  input Real x1;
  input Real x2;
  output Real y;
 algorithm
  y := x1 * x1;
  y := y * x2;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Order2.df);
 end Differentiation.DerivativeAnnotation.Order2.f;

 function Differentiation.DerivativeAnnotation.Order2.df
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  output Real dy;
 algorithm
  dy := x1 * x1;
  dy := dy * x2;
  return;
 annotation(derivative(order = 2) = Differentiation.DerivativeAnnotation.Order2.ddf);
 end Differentiation.DerivativeAnnotation.Order2.df;

 function Differentiation.DerivativeAnnotation.Order2.ddf
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  input Real ddx1;
  input Real ddx2;
  output Real ddy;
 algorithm
  ddy := x1 * x1;
  ddy := ddy * x2;
  return;
 end Differentiation.DerivativeAnnotation.Order2.ddf;

end Differentiation.DerivativeAnnotation.Order2;

")})));
        end Order2;

        model Functional1
            partial function partFunc
                output Real y;
            end partFunc;

            function fullFunc
                extends partFunc;
                input Real x1;
            algorithm
                y := x1;
            end fullFunc;

            function usePartFunc
                input partFunc pf;
                output Real y;
            algorithm
                y := pf();
                annotation(smoothOrder=1);
            end usePartFunc;

            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + usePartFunc(function fullFunc(x1=x2)) = 1;

        annotation(__JModelica(UnitTesting(tests={
            ErrorTestCase(
                name="DerivativeAnnotation_Functional1",
                description="Test failing differentiation of functional input arguments",
                errorMessage="
1 errors found:
Error: in file '...':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative or smooth order annotation 'pf()' in equation:
   x1 + Differentiation.DerivativeAnnotation.Functional1.usePartFunc(function Differentiation.DerivativeAnnotation.Functional1.fullFunc(x2)) = 1
")})));
        end Functional1;

    end DerivativeAnnotation;

    package AlgorithmDifferentiation

        model Simple
            function F
                input Real x;
                output Real y;
            algorithm
                y := sin(x);
                annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_Simple",
                description="Test differentiation of simple function",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.Simple
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.Simple.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.Simple._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.Simple.F
  input Real x;
  output Real y;
 algorithm
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.Simple._der_F);
 end Differentiation.AlgorithmDifferentiation.Simple.F;

 function Differentiation.AlgorithmDifferentiation.Simple._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.Simple._der_F;

end Differentiation.AlgorithmDifferentiation.Simple;
")})));
        end Simple;

        model RecordInput
            function F
                input R x;
                output Real y;
            algorithm
                y := sin(x.x[1]);
            annotation(Inline=false, smoothOrder=1);
            end F;
            record R
                Real x[1];
            end R;

            Real x1;
            R x2;
        equation
            der(x1) + der(x2.x[1]) = 1;
            x1 + F(x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_RecordInput",
                description="Test differentiation of function with record input",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.RecordInput
 Real x1;
 Real x2.x[1];
 Real _der_x1;
initial equation 
 x2.x[1] = 0.0;
equation
 _der_x1 + der(x2.x[1]) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.RecordInput.F(Differentiation.AlgorithmDifferentiation.RecordInput.R({x2.x[1]})) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.RecordInput._der_F(Differentiation.AlgorithmDifferentiation.RecordInput.R({x2.x[1]}), Differentiation.AlgorithmDifferentiation.RecordInput.R({der(x2.x[1])})) = 0;

public
 function Differentiation.AlgorithmDifferentiation.RecordInput.F
  input Differentiation.AlgorithmDifferentiation.RecordInput.R x;
  output Real y;
 algorithm
  y := sin(x.x[1]);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.RecordInput._der_F);
 end Differentiation.AlgorithmDifferentiation.RecordInput.F;

 function Differentiation.AlgorithmDifferentiation.RecordInput._der_F
  input Differentiation.AlgorithmDifferentiation.RecordInput.R x;
  input Differentiation.AlgorithmDifferentiation.RecordInput.R _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := cos(x.x[1]) * _der_x.x[1];
  y := sin(x.x[1]);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.RecordInput._der_F;

 record Differentiation.AlgorithmDifferentiation.RecordInput.R
  Real x[1];
 end Differentiation.AlgorithmDifferentiation.RecordInput.R;

end Differentiation.AlgorithmDifferentiation.RecordInput;
")})));
        end RecordInput;

        model RecordOutput
            function F
                input Real x;
                output R y;
            algorithm
                y.x[1] := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;
            record R
                Real x[1];
            end R;
            Real x1;
            Real x2;
            R r;
        equation
            der(x1) + der(x2) = 1;
            r = F(x2);
            x1 + r.x[1] = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_RecordOutput",
                description="Test differentiation of function with record output",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.RecordOutput
 Real x1;
 Real x2;
 Real r.x[1];
 Real _der_x1;
 Real _der_x2;
initial equation 
 r.x[1] = 0.0;
equation
 _der_x1 + _der_x2 = 1;
 (Differentiation.AlgorithmDifferentiation.RecordOutput.R({r.x[1]})) = Differentiation.AlgorithmDifferentiation.RecordOutput.F(x2);
 x1 + r.x[1] = 1;
 (Differentiation.AlgorithmDifferentiation.RecordOutput.R({der(r.x[1])})) = Differentiation.AlgorithmDifferentiation.RecordOutput._der_F(x2, _der_x2);
 _der_x1 + der(r.x[1]) = 0;

public
 function Differentiation.AlgorithmDifferentiation.RecordOutput.F
  input Real x;
  output Differentiation.AlgorithmDifferentiation.RecordOutput.R y;
 algorithm
  y.x[1] := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.RecordOutput._der_F);
 end Differentiation.AlgorithmDifferentiation.RecordOutput.F;

 function Differentiation.AlgorithmDifferentiation.RecordOutput._der_F
  input Real x;
  input Real _der_x;
  output Differentiation.AlgorithmDifferentiation.RecordOutput.R _der_y;
  Differentiation.AlgorithmDifferentiation.RecordOutput.R y;
 algorithm
  _der_y.x[1] := cos(x) * _der_x;
  y.x[1] := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.RecordOutput._der_F;

 record Differentiation.AlgorithmDifferentiation.RecordOutput.R
  Real x[1];
 end Differentiation.AlgorithmDifferentiation.RecordOutput.R;

end Differentiation.AlgorithmDifferentiation.RecordOutput;
")})));
        end RecordOutput;

        model For
            function F
                input Real x;
                output Real y;
                output Real c = 0;
            algorithm
                for i in 1:10 loop
                    if i > x then
                    break;
                end if;
                    c := c + 0.5;
                end for;
                y := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_For",
                description="Test differentiation of function with for statement",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.For
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.For.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.For._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.For.F
  input Real x;
  output Real y;
  output Real c;
 algorithm
  c := 0;
  for i in 1:10 loop
   if i > x then
    break;
   end if;
   c := c + 0.5;
  end for;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.For._der_F);
 end Differentiation.AlgorithmDifferentiation.For.F;

 function Differentiation.AlgorithmDifferentiation.For._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0;
  c := 0;
  for i in 1:10 loop
   if i > x then
    break;
   end if;
   _der_c := _der_c;
   c := c + 0.5;
  end for;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.For._der_F;

end Differentiation.AlgorithmDifferentiation.For;
")})));
        end For;

        model FunctionCall
            function F1
                input Real x1;
                input Real x2;
                output Real y;
                Real a;
                Real b;
            algorithm
                (a, b) := F2(x1, x2);
                y := a + b;
            annotation(Inline=false, smoothOrder=1);
            end F1;

            function F2
                input Real x1;
                input Real x2;
                output Real a = x1;
                output Real b = sin(x2);
            algorithm
            end F2;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            F1(x1, x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_FunctionCall",
                description="Test differentiation of function with function call statement",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.FunctionCall
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 Differentiation.AlgorithmDifferentiation.FunctionCall.F1(x1, x2) = 1;
 Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1(x1, x2, _der_x1, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.FunctionCall.F1
  input Real x1;
  input Real x2;
  output Real y;
  Real a;
  Real b;
 algorithm
  (a, b) := Differentiation.AlgorithmDifferentiation.FunctionCall.F2(x1, x2);
  y := a + b;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1);
 end Differentiation.AlgorithmDifferentiation.FunctionCall.F1;

 function Differentiation.AlgorithmDifferentiation.FunctionCall.F2
  input Real x1;
  input Real x2;
  output Real a;
  output Real b;
 algorithm
  a := x1;
  b := sin(x2);
  return;
 annotation(derivative(order = 1) = Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2);
 end Differentiation.AlgorithmDifferentiation.FunctionCall.F2;

 function Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_y;
  Real y;
  Real a;
  Real _der_a;
  Real b;
  Real _der_b;
 algorithm
  (_der_a, _der_b) := Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2(x1, x2, _der_x1, _der_x2);
  (a, b) := Differentiation.AlgorithmDifferentiation.FunctionCall.F2(x1, x2);
  _der_y := _der_a + _der_b;
  y := a + b;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1;

 function Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_a;
  output Real _der_b;
  Real a;
  Real b;
 algorithm
  _der_a := _der_x1;
  a := x1;
  _der_b := cos(x2) * _der_x2;
  b := sin(x2);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2;

end Differentiation.AlgorithmDifferentiation.FunctionCall;
")})));
        end FunctionCall;

        model If
            function F
                input Real x;
                output Real y;
                output Real b;
            algorithm
                if 10 > x then
                    b := 1;
                else
                    b := 2;
                end if;
                y := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_If",
                description="Test differentiation of function with if statement",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.If
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.If.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.If._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.If.F
  input Real x;
  output Real y;
  output Real b;
 algorithm
  if 10 > x then
   b := 1;
  else
   b := 2;
  end if;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.If._der_F);
 end Differentiation.AlgorithmDifferentiation.If.F;

 function Differentiation.AlgorithmDifferentiation.If._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_b;
  Real y;
  Real b;
 algorithm
  if 10 > x then
   _der_b := 0;
   b := 1;
  else
   _der_b := 0;
   b := 2;
  end if;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.If._der_F;

end Differentiation.AlgorithmDifferentiation.If;
")})));
        end If;

        model InitArray
            function F
                    input Real[:] x;
                    output Real y;
                    Real[:] a = x .^ 2;
                algorithm
                    y := a[1];
                annotation(Inline=false, smoothOrder=3);
            end F;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F({x2}) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_InitArray",
                description="Test differentiation of function with initial array statement",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.InitArray
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.InitArray.F({x2}) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.InitArray._der_F({x2}, {der(x2)}) = 0;

public
 function Differentiation.AlgorithmDifferentiation.InitArray.F
  input Real[:] x;
  output Real y;
  Real[:] a;
 algorithm
  size(a) := {size(x, 1)};
  for i1 in 1:size(x, 1) loop
   a[i1] := x[i1] .^ 2;
  end for;
  y := a[1];
  return;
 annotation(Inline = false,smoothOrder = 3,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.InitArray._der_F);
 end Differentiation.AlgorithmDifferentiation.InitArray.F;

 function Differentiation.AlgorithmDifferentiation.InitArray._der_F
  input Real[:] x;
  input Real[:] _der_x;
  output Real _der_y;
  Real y;
  Real[:] a;
  Real[:] _der_a;
 algorithm
  size(a) := {size(x, 1)};
  size(_der_a) := {size(x, 1)};
  for i1 in 1:size(x, 1) loop
   _der_a[i1] := 2 .* x[i1] .* _der_x[i1];
   a[i1] := x[i1] .^ 2;
  end for;
  _der_y := _der_a[1];
  y := a[1];
  return;
 annotation(smoothOrder = 2,derivative(order = 2) = Differentiation.AlgorithmDifferentiation.InitArray._der_der_F);
 end Differentiation.AlgorithmDifferentiation.InitArray._der_F;

end Differentiation.AlgorithmDifferentiation.InitArray;
")})));
        end InitArray;

        model RecordArray
            record R
                Real x;
            end R;

            function F
                input R[1] x;
                output R[1] y;
            algorithm
                y := x;
            annotation(Inline=false, smoothOrder=3);
            end F;
    
            function e
                input R[:] r;
                output Real y = r[1].x;
                algorithm
            end e;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + e(F({R(x2)})) = 1;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="AlgorithmDifferentiation_RecordArray",
                description="Test code gen of differentiated function with array of records #3611",
                template="$C_functions$",
                generatedCode="
void func_Differentiation_AlgorithmDifferentiation_RecordArray_F_def0(R_0_ra* x_a, R_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, R_0_r, R_0_ra, y_an, 1, 1)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, y_an, 1, 1, 1)
        y_a = y_an;
    }
    jmi_array_rec_1(y_a, 1)->x = jmi_array_rec_1(x_a, 1)->x;
    JMI_DYNAMIC_FREE()
    return;
}

void func_Differentiation_AlgorithmDifferentiation_RecordArray__der_F_def1(R_0_ra* x_a, R_0_ra* _der_x_a, R_0_ra* _der_y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, R_0_r, R_0_ra, _der_y_an, 1, 1)
    JMI_ARR(STAT, R_0_r, R_0_ra, y_a, 1, 1)
    if (_der_y_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, _der_y_an, 1, 1, 1)
        _der_y_a = _der_y_an;
    }
    JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, y_a, 1, 1, 1)
    jmi_array_rec_1(_der_y_a, 1)->x = jmi_array_rec_1(_der_x_a, 1)->x;
    jmi_array_rec_1(y_a, 1)->x = jmi_array_rec_1(x_a, 1)->x;
    JMI_DYNAMIC_FREE()
    return;
}
")})));
        end RecordArray;

        model While
            function F
                input Real x;
                output Real y;
                output Real c = 0;
            algorithm
                while c < x loop
                    c := c + 0.5;
                end while;
                y := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_While",
                description="Test differentiation of function with while statement",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.While
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.While.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.While._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.While.F
  input Real x;
  output Real y;
  output Real c;
 algorithm
  c := 0;
  while c < x loop
   c := c + 0.5;
  end while;
  y := sin(x);
  return;
 annotation(Inline = false, smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.While._der_F);
 end Differentiation.AlgorithmDifferentiation.While.F;

 function Differentiation.AlgorithmDifferentiation.While._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0;
  c := 0;
  while c < x loop
   _der_c := _der_c;
   c := c + 0.5;
  end while;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.While._der_F;

end Differentiation.AlgorithmDifferentiation.While;
")})));
        end While;

        model Recursive
            function F1
                input Real x1;
                input Real x2;
                output Real y;
                Real a;
                Real b;
            algorithm
                (a, b) := F2(x1, x2, 0);
                y := a + b;
            annotation(Inline=false, smoothOrder=1);
            end F1;

            function F2
                input Real x1;
                input Real x2;
                input Integer c;
                output Real a;
                output Real b;
            algorithm
                if c < 10 then
                    (a, b) := F2(x1, x2, c + 1);
                else
                    a := x1;
                    b := sin(x2);
                end if;
            end F2;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            F1(x1, x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_Recursive",
                description="Test differentiation of Recursive function",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.Recursive
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 Differentiation.AlgorithmDifferentiation.Recursive.F1(x1, x2) = 1;
 Differentiation.AlgorithmDifferentiation.Recursive._der_F1(x1, x2, _der_x1, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.Recursive.F1
  input Real x1;
  input Real x2;
  output Real y;
  Real a;
  Real b;
 algorithm
  (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, 0);
  y := a + b;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.Recursive._der_F1);
 end Differentiation.AlgorithmDifferentiation.Recursive.F1;

 function Differentiation.AlgorithmDifferentiation.Recursive.F2
  input Real x1;
  input Real x2;
  input Integer c;
  output Real a;
  output Real b;
 algorithm
  if c < 10 then
   (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, c + 1);
  else
   a := x1;
   b := sin(x2);
  end if;
  return;
 annotation(derivative(order = 1) = Differentiation.AlgorithmDifferentiation.Recursive._der_F2);
 end Differentiation.AlgorithmDifferentiation.Recursive.F2;

 function Differentiation.AlgorithmDifferentiation.Recursive._der_F1
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_y;
  Real y;
  Real a;
  Real _der_a;
  Real b;
  Real _der_b;
 algorithm
  (_der_a, _der_b) := Differentiation.AlgorithmDifferentiation.Recursive._der_F2(x1, x2, 0, _der_x1, _der_x2);
  (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, 0);
  _der_y := _der_a + _der_b;
  y := a + b;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.Recursive._der_F1;

 function Differentiation.AlgorithmDifferentiation.Recursive._der_F2
  input Real x1;
  input Real x2;
  input Integer c;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_a;
  output Real _der_b;
  Real a;
  Real b;
 algorithm
  if c < 10 then
   (_der_a, _der_b) := Differentiation.AlgorithmDifferentiation.Recursive._der_F2(x1, x2, c + 1, _der_x1, _der_x2);
   (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, c + 1);
  else
   _der_a := _der_x1;
   a := x1;
   _der_b := cos(x2) * _der_x2;
   b := sin(x2);
  end if;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.Recursive._der_F2;

end Differentiation.AlgorithmDifferentiation.Recursive;
")})));
        end Recursive;

        model DiscreteComponents
            function F
                input Real x;
                output Real y;
                output Integer c = 0;
            algorithm
                c := if x > 23 then 2 else -2;
                c := c + 23;
                y := sin(x);
                annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_DiscreteComponents",
                description="Test differentiation of function with discrete components",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.DiscreteComponents
 Real x1;
 Real x2;
 Real _der_x1;
initial equation 
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.DiscreteComponents.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.DiscreteComponents.F
  input Real x;
  output Real y;
  output Integer c;
 algorithm
  c := 0;
  c := if x > 23 then 2 else - 2;
  c := c + 23;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F);
 end Differentiation.AlgorithmDifferentiation.DiscreteComponents.F;

 function Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
  Integer c;
 algorithm
  c := 0;
  c := if x > 23 then 2 else - 2;
  c := c + 23;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F;

end Differentiation.AlgorithmDifferentiation.DiscreteComponents;
")})));
        end DiscreteComponents;

        model PlanarPendulum
            function square
                input Real x;
                output Real y;
            algorithm
                y := x ^ 2;
                annotation(Inline=false, smoothOrder=2);
            end square;
  
            parameter Real L = 1 "Pendulum length";
            parameter Real g =9.81 "Acceleration due to gravity";
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
            square(x) + square(y) = L;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_PlanarPendulum",
                description="Test differentiation of simple function twice",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 Differentiation.AlgorithmDifferentiation.PlanarPendulum.square(x) + Differentiation.AlgorithmDifferentiation.PlanarPendulum.square(y) = L;
 Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square(x, _der_x) + Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square(y, der(y)) = 0.0;
 _der_der_x = _der_vx;
 _der_der_y = der(vy);
 Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square(x, _der_x, _der_der_x) + Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square(y, der(y), _der_der_y) = 0.0;

public
 function Differentiation.AlgorithmDifferentiation.PlanarPendulum.square
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 annotation(Inline = false,smoothOrder = 2,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square);
 end Differentiation.AlgorithmDifferentiation.PlanarPendulum.square;

 function Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := 2 * x * _der_x;
  y := x ^ 2;
  return;
 annotation(smoothOrder = 1,derivative(order = 2) = Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square);
 end Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square;

 function Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square
  input Real x;
  input Real _der_x;
  input Real _der_der_x;
  output Real _der_der_y;
  Real _der_y;
  Real y;
 algorithm
  _der_der_y := 2 * x * _der_der_x + 2 * _der_x * _der_x;
  _der_y := 2 * x * _der_x;
  y := x ^ 2;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square;

end Differentiation.AlgorithmDifferentiation.PlanarPendulum;
")})));
        end PlanarPendulum;

        model SelfReference_AssignStmt
            function F
                input Real x;
                output Real y;
            algorithm
                y := x * x;
                y := y * x;
            annotation(smoothOrder=1);
            end F;
            Real a = F(time * 2);
            Real b = der(a);

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_SelfReference_AssignStmt",
                description="Test differentiation of statements with lsh variable in rhs",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt
 Real a;
 Real b;
 Real _der_a;
equation
 a = Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt.F(time * 2);
 b = _der_a;
 _der_a = Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F(time * 2, 2);

public
 function Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt.F
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  y := y * x;
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F);
 end Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt.F;

 function Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := x * _der_x + _der_x * x;
  y := x * x;
  _der_y := y * _der_x + _der_y * x;
  y := y * x;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F;

end Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt;
")})));
        end SelfReference_AssignStmt;

        model SelfReference_FunctionCall
            function F1
                input Real x;
                output Real y;
            algorithm
                (,y) := F2(x);
                (,y) := F2(y);
            annotation(smoothOrder=1);
            end F1;
            function F2
                input Real x;
                output Real y;
                output Real z;
            algorithm
                y := 42;
                z := x * x;
                z := z * x;
            annotation(smoothOrder=1);
            end F2;
            Real a = F1(time * 2);
            Real b = der(a);

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_SelfReference_FunctionCall",
                description="Test differentiation of statements with lsh variable in rhs",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall
 Real a;
 Real b;
 Real _der_a;
equation
 a = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F1(time * 2);
 b = _der_a;
 _der_a = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1(time * 2, 2);

public
 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F1
  input Real x;
  output Real y;
 algorithm
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(x);
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(y);
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F1;

 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := 42;
  z := x * x;
  z := z * x;
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2;

 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  (, _der_y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2(x, _der_x);
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(x);
  (, _der_y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2(y, _der_y);
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(y);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1;

 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := 0;
  y := 42;
  _der_z := x * _der_x + _der_x * x;
  z := x * x;
  _der_z := z * _der_x + _der_z * x;
  z := z * x;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2;

end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall;
")})));
        end SelfReference_FunctionCall;

    end AlgorithmDifferentiation;

end Differentiation;
