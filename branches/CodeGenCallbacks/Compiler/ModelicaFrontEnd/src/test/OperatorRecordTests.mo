/*
    Copyright (C) 2014 Modelon AB

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

package OperatorRecordTests


    operator record Cplx
        Real re;
        Real im;

        operator function 'constructor'
            input Real re;
            input Real im = 0;
            output Cplx c;
        algorithm
            c.re := re;
            c.im := im;
        end 'constructor';

        operator function '0'
            output Cplx c;
        algorithm
            c := Cplx(0);
        end '0';

        operator function '+'
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re + b.re, a.im + b.im);
        end '+';

        operator '-'
            function sub
                input Cplx a;
                input Cplx b;
                output Cplx c;
            algorithm
                c := Cplx(a.re - b.re, a.im - b.im);
            end sub;

            function neg
                input Cplx a;
                output Cplx c;
            algorithm
                c := Cplx(-a.re, -a.im);
            end neg;
        end '-';

        operator '*'
            function mul
                input Cplx a;
                input Cplx b;
                output Cplx c;
            algorithm
                c := Cplx(a.re*b.re - a.im*b.im, a.re*b.im + a.im*b.re);
            end mul;

            function prod
                input Cplx[:] a;
                input Cplx[size(a,1)] b;
                output Cplx c;
            algorithm
                c := Complex(0);
                for i in 1:size(a, 1) loop
                    c :=c + a[i] * b[i];
                end for;
            end prod;
        end '*';

        operator function 'String'
            input Cplx a;
            output String b;
        algorithm
            if a.im == 0 then
                b := String(a.re);
            elseif a.re == 0 then
                b := String(a.im) + "j";
            else
                b := String(a.re) + " + " + String(a.im) + "j";
            end if;
        end 'String';

        operator function '/' // Dummy implementation for simplicity
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re / b.re, a.im / b.im);
        end '/';

        operator function '^' // Dummy implementation for simplicity
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re ^ b.re, a.im ^ b.im);
        end '^';

        operator function '=='
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re == b.re and a.im == b.im;
        end '==';

        operator function '<>'
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re <> b.re or a.im <> b.im;
        end '<>';

        operator function '>'
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 > b.re ^ 2 + b.im ^ 2;
        end '>';

        operator function '<'
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 < b.re ^ 2 + b.im ^ 2;
        end '<';

        operator function '>='
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 >= b.re ^ 2 + b.im ^ 2;
        end '>=';

        operator function '<='
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 <= b.re ^ 2 + b.im ^ 2;
        end '<=';

        operator function 'and' // Dummy implementation for testing
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re + b.re, a.im + b.im);
        end 'and';

        operator function 'or' // Dummy implementation for testing
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re - b.re, a.im - b.im);
        end 'or';

        operator function 'not' // Dummy implementation for testing (conjugate)
            input Cplx a;
            output Cplx c;
        algorithm
            c := Cplx(a.re, -a.im);
        end 'not';
    end Cplx;


    model OperatorOverload1
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload1",
            description="Basic test of overloaded operators: addition",
            flatModel="
fclass OperatorRecordTests.OperatorOverload1
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload1;
")})));
    end OperatorOverload1;


    model OperatorOverload2
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 - c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload2",
            description="Basic test of overloaded operators: subtraction",
            flatModel="
fclass OperatorRecordTests.OperatorOverload2
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'-'.sub(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.sub
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'-'.sub;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload2;
")})));
    end OperatorOverload2;


    model OperatorOverload3
        Cplx c1 = Cplx(1, 2);
        Cplx c3 = -c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload3",
            description="Basic test of overloaded operators: negation",
            flatModel="
fclass OperatorRecordTests.OperatorOverload3
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'-'.neg(c1);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.neg
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(- a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'-'.neg;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload3;
")})));
    end OperatorOverload3;


    model OperatorOverload4
        Cplx c1 = Cplx(1, 2);
        Boolean b = false;
        Cplx c3 = c1 - b;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorOverload4",
            description="Basic type error test for operator records",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/OperatorRecordTests.mo':
Semantic error at line 130, column 19:
  Type error in expression: c1 - b
")})));
    end OperatorOverload4;


    model OperatorOverload5
        Cplx c1 = Cplx(1, 2);
        Real r = 3;
        Cplx c3 = c1 + r;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload5",
            description="Automatic type conversion for overloaded operators: right",
            flatModel="
fclass OperatorRecordTests.OperatorOverload5
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 Real r = 3;
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, OperatorRecordTests.Cplx.'constructor'(r, 0));

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload5;
")})));
    end OperatorOverload5;


    model OperatorOverload6
        Cplx c1 = Cplx(1, 2);
        Real r = 3;
        Cplx c3 = r * 4 + c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload6",
            description="Automatic type conversion for overloaded operators: left",
            flatModel="
fclass OperatorRecordTests.OperatorOverload6
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 Real r = 3;
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'constructor'(r * 4, 0), c1);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload6;
")})));
    end OperatorOverload6;


    model OperatorOverload7
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Cplx[2] c2 = { Cplx(5, 6), Cplx(7, 8) };
        Cplx[2] c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload7",
            description="Array addition with operator records",
            flatModel="
fclass OperatorRecordTests.OperatorOverload7
 OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 OperatorRecordTests.Cplx c2[2] = {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)};
 OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'+'(c1[1], c2[1]), OperatorRecordTests.Cplx.'+'(c1[2], c2[2])};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload7;
")})));
    end OperatorOverload7;


    model OperatorOverload8
        Cplx c1 = Cplx(1, 2);
        Real[2] r = { 3, 4 };
        Cplx[2] c3 = c1 .+ r;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload8",
            description="Scalar-array addition with operator records and automatic type conversion",
            flatModel="
fclass OperatorRecordTests.OperatorOverload8
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 Real r[2] = {3, 4};
 OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'+'(c1, OperatorRecordTests.Cplx.'constructor'(r[1], 0)), OperatorRecordTests.Cplx.'+'(c1, OperatorRecordTests.Cplx.'constructor'(r[2], 0))};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload8;
")})));
    end OperatorOverload8;


    model OperatorOverload9
		operator record Op
			Real x;
			Real y;
			
			operator function '*'
				input Op a;
				input Op b;
				output Op c;
			algorithm
				c := Op(a.x * b.x, a.y * b.y);
			end '*';
		end Op;
		
        Op[2] c1 = { Op(1, 2), Op(3, 4) };
        Op[2] c2 = { Op(5, 6), Op(7, 8) };
        Op c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorOverload9",
            description="Error for array multiplication cases not allowed for operator records: vector*vector",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/OperatorRecordTests.mo':
Semantic error at line 407, column 19:
  Type error in expression: c1 * c2
")})));
    end OperatorOverload9;


    model OperatorOverload10
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Cplx[2,2] c2 = { { Cplx(5, 6), Cplx(7, 8) }, { Cplx(9, 10), Cplx(11, 12) } };
        Cplx[2] c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorOverload10",
            description="Error for array multiplication cases not allowed for operator records: vector*matrix",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/OperatorRecordTests.mo':
Semantic error at line 425, column 22:
  Type error in expression: c1 * c2
")})));
    end OperatorOverload10;


    model OperatorOverload11
        Cplx[2,2] c1 = { { Cplx(1, 2), Cplx(3, 4) }, { Cplx(5, 6), Cplx(7, 8) } };
        Cplx[2,2] c2 = { { Cplx(11, 12), Cplx(13, 14) }, { Cplx(15, 16), Cplx(17, 18) } };
        Cplx[2,2] c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload11",
            description="Matrix multiplication with operator records",
            flatModel="
fclass OperatorRecordTests.OperatorOverload11
 OperatorRecordTests.Cplx c1[2,2] = {{OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)}, {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)}};
 OperatorRecordTests.Cplx c2[2,2] = {{OperatorRecordTests.Cplx.'constructor'(11, 12), OperatorRecordTests.Cplx.'constructor'(13, 14)}, {OperatorRecordTests.Cplx.'constructor'(15, 16), OperatorRecordTests.Cplx.'constructor'(17, 18)}};
 OperatorRecordTests.Cplx c3[2,2] = {{OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[1,1], c2[1,1]), OperatorRecordTests.Cplx.'*'.mul(c1[1,2], c2[2,1])), OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[1,1], c2[1,2]), OperatorRecordTests.Cplx.'*'.mul(c1[1,2], c2[2,2]))}, {OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[2,1], c2[1,1]), OperatorRecordTests.Cplx.'*'.mul(c1[2,2], c2[2,1])), OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[2,1], c2[1,2]), OperatorRecordTests.Cplx.'*'.mul(c1[2,2], c2[2,2]))}};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload11;
")})));
    end OperatorOverload11;


// Note: this test gives wrong result due to the bug in #2779
    model OperatorOverload12
        constant Cplx c1 = Cplx(1, 2);
        constant Cplx c2 = Cplx(3, 4);
        constant Cplx c3 = c1 + c2;
        constant Cplx c4 = c3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload12",
            description="Constant eval of overloaded operator expression: scalars",
            flatModel="
fclass OperatorRecordTests.OperatorOverload12
 constant OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 constant OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 constant OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx(2, 1), OperatorRecordTests.Cplx(4, 3));
 constant OperatorRecordTests.Cplx c4 = OperatorRecordTests.Cplx(6.0, 4.0);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload12;
")})));
    end OperatorOverload12;


// Note: this test gives wrong result due to the bug in #2779
    model OperatorOverload13
        constant Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        constant Cplx[2] c2 = { Cplx(5, 6), Cplx(7, 8) };
        constant Cplx[2] c3 = c1 + c2;
        constant Cplx[2] c4 = c3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload13",
            description="Constant eval of overloaded operator expression: arrays",
            flatModel="
fclass OperatorRecordTests.OperatorOverload13
 constant OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 constant OperatorRecordTests.Cplx c2[2] = {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)};
 constant OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx(2, 1), OperatorRecordTests.Cplx(6, 5)), OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx(4, 3), OperatorRecordTests.Cplx(8, 7))};
 constant OperatorRecordTests.Cplx c4[2] = {OperatorRecordTests.Cplx(8.0, 6.0), OperatorRecordTests.Cplx(12.0, 10.0)};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload13;
")})));
    end OperatorOverload13;


    model OperatorOverload14
		operator record Cplx2 = Cplx;
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload14",
            description="Short class decls of operator records",
            flatModel="
fclass OperatorRecordTests.OperatorOverload14
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.OperatorOverload14.Cplx2 c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

 record OperatorRecordTests.OperatorOverload14.Cplx2
  Real re;
  Real im;
 end OperatorRecordTests.OperatorOverload14.Cplx2;

end OperatorRecordTests.OperatorOverload14;
")})));
    end OperatorOverload14;


    model OperatorOverload15
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Cplx[2] c2 = { Cplx(5, 6), Cplx(7, 8) };
        Cplx c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload15",
            description="Using overloaded operator taking array args",
            flatModel="
fclass OperatorRecordTests.OperatorOverload15
 OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 OperatorRecordTests.Cplx c2[2] = {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)};
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'*'.prod(c1[1:2], c2[1:2]);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.prod
  input OperatorRecordTests.Cplx[:] a;
  input OperatorRecordTests.Cplx[size(a, 1)] b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := Complex.'constructor'.fromReal(0, 0);
  for i in 1:size(a, 1) loop
   c := OperatorRecordTests.Cplx.'+'(c, OperatorRecordTests.Cplx.'*'.mul(a[i], b[i]));
  end for;
  return;
 end OperatorRecordTests.Cplx.'*'.prod;

 function Complex.'constructor'.fromReal
  input Real re;
  input Real im := 0;
  output Complex result;
 algorithm
  return;
 end Complex.'constructor'.fromReal;

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

 record Complex
  Real re \"Real part of complex number\";
  Real im \"Imaginary part of complex number\";
 end Complex;

end OperatorRecordTests.OperatorOverload15;
")})));
    end OperatorOverload15;


// Note: this test gives wrong result due to the bug in #2779
    model OperatorOverload16
        constant Cplx c1 = Cplx(1, 2);
        constant String s1 = String(c1);
        constant String s2 = s1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload16",
            description="Overloading of String()",
            flatModel="
fclass OperatorRecordTests.OperatorOverload16
 constant OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 constant String s1 = OperatorRecordTests.Cplx.'String'(OperatorRecordTests.Cplx(2, 1));
 constant String s2 = \"1.00000 + 2.00000j\";

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'String'
  input OperatorRecordTests.Cplx a;
  output String b;
 algorithm
  if a.im == 0 then
   b := String(a.re);
  elseif a.re == 0 then
   b := String(a.im) + \"j\";
  else
   b := String(a.re) + \" + \" + String(a.im) + \"j\";
  end if;
  return;
 end OperatorRecordTests.Cplx.'String';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload16;
")})));
    end OperatorOverload16;


    model OperatorOverload17
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 / c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload17",
            description="Basic test of overloaded operators: division",
            flatModel="
fclass OperatorRecordTests.OperatorOverload17
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'/'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'/'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re / b.re, a.im / b.im);
  return;
 end OperatorRecordTests.Cplx.'/';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload17;
")})));
    end OperatorOverload17;


    model OperatorOverload18
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 ^ c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload18",
            description="Basic test of overloaded operators: power",
            flatModel="
fclass OperatorRecordTests.OperatorOverload18
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'^'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'^'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re ^ b.re, a.im ^ b.im);
  return;
 end OperatorRecordTests.Cplx.'^';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload18;
")})));
    end OperatorOverload18;


    model OperatorOverload19
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 == c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload19",
            description="Basic test of overloaded operators: equals",
            flatModel="
fclass OperatorRecordTests.OperatorOverload19
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'=='(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'=='
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re == b.re and a.im == b.im;
  return;
 end OperatorRecordTests.Cplx.'==';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload19;
")})));
    end OperatorOverload19;


    model OperatorOverload20
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 <> c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload20",
            description="Basic test of overloaded operators: not equals",
            flatModel="
fclass OperatorRecordTests.OperatorOverload20
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'<>'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'<>'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re <> b.re or a.im <> b.im;
  return;
 end OperatorRecordTests.Cplx.'<>';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload20;
")})));
    end OperatorOverload20;


    model OperatorOverload21
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 < c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload21",
            description="Basic test of overloaded operators: less",
            flatModel="
fclass OperatorRecordTests.OperatorOverload21
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'<'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'<'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 < b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'<';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload21;
")})));
    end OperatorOverload21;


    model OperatorOverload22
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 > c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload22",
            description="Basic test of overloaded operators: greater",
            flatModel="
fclass OperatorRecordTests.OperatorOverload22
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'>'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'>'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 > b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'>';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload22;
")})));
    end OperatorOverload22;


    model OperatorOverload23
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 <= c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload23",
            description="Basic test of overloaded operators: less or equal",
            flatModel="
fclass OperatorRecordTests.OperatorOverload23
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'<='(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'<='
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 <= b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'<=';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload23;
")})));
    end OperatorOverload23;


    model OperatorOverload24
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 >= c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload24",
            description="Basic test of overloaded operators: greater or equal",
            flatModel="
fclass OperatorRecordTests.OperatorOverload24
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'>='(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'>='
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 >= b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'>=';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload24;
")})));
    end OperatorOverload24;


    model OperatorOverload25
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 and c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload25",
            description="Basic test of overloaded operators: and",
            flatModel="
fclass OperatorRecordTests.OperatorOverload25
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'and'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'and'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'and';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload25;
")})));
    end OperatorOverload25;


    model OperatorOverload26
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 or c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload26",
            description="Basic test of overloaded operators: or",
            flatModel="
fclass OperatorRecordTests.OperatorOverload26
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'or'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'or'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'or';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload26;
")})));
    end OperatorOverload26;


    model OperatorOverload27
        Cplx c1 = Cplx(1, 2);
        Cplx c3 = not c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload27",
            description="Basic test of overloaded operators: not",
            flatModel="
fclass OperatorRecordTests.OperatorOverload27
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'not'(c1);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'not'
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'not';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload27;
")})));
    end OperatorOverload27;


    model OperatorOverload28
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = if time < 2 then c1 else c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload28",
            description="If expression with operator record",
            flatModel="
fclass OperatorRecordTests.OperatorOverload28
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = if time < 2 then c1 else c2;

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload28;
")})));
    end OperatorOverload28;


    model OperatorOverload29
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Real r1 = 1;
        Cplx[2] c3 = c1 * r1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload29",
            description="Checks that automatic conversions are only applied for scalar inputs",
            flatModel="
fclass OperatorRecordTests.OperatorOverload29
 OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 Real r1 = 1;
 OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'*'.mul(c1[1], OperatorRecordTests.Cplx.'constructor'(r1, 0)), OperatorRecordTests.Cplx.'*'.mul(c1[2], OperatorRecordTests.Cplx.'constructor'(r1, 0))};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload29;
")})));
    end OperatorOverload29;


    model OperatorRecordConnect1
        connector C
            Cplx x;
            flow Cplx y;
        end C;

        C c1, c2, c3;
    equation
        connect(c1, c2);
        connect(c1, c3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect1",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect1
 OperatorRecordTests.Cplx c1.x;
 OperatorRecordTests.Cplx c1.y;
 OperatorRecordTests.Cplx c2.x;
 OperatorRecordTests.Cplx c2.y;
 OperatorRecordTests.Cplx c3.x;
 OperatorRecordTests.Cplx c3.y;
equation
 c1.x = c2.x;
 c2.x = c3.x;
 OperatorRecordTests.Cplx.'-'.sub(OperatorRecordTests.Cplx.'-'.sub(OperatorRecordTests.Cplx.'-'.neg(c1.y), c2.y), c3.y) = OperatorRecordTests.Cplx.'0'();
 c1.y = OperatorRecordTests.Cplx.'0'();
 c2.y = OperatorRecordTests.Cplx.'0'();
 c3.y = OperatorRecordTests.Cplx.'0'();

public
 function OperatorRecordTests.Cplx.'0'
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(0, 0);
  return;
 end OperatorRecordTests.Cplx.'0';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.neg
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(- a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'-'.neg;

 function OperatorRecordTests.Cplx.'-'.sub
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'-'.sub;

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect1;
")})));
    end OperatorRecordConnect1;


    model OperatorRecordConnect2
        connector C
            Cplx x;
            flow Cplx y;
        end C;

        model A
            C c;
        end A;

        A a1, a2, a3, a4;
    equation
        connect(a1.c, a2.c);
        connect(a1.c, a3.c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect2",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect2
 OperatorRecordTests.Cplx a1.c.x;
 OperatorRecordTests.Cplx a1.c.y;
 OperatorRecordTests.Cplx a2.c.x;
 OperatorRecordTests.Cplx a2.c.y;
 OperatorRecordTests.Cplx a3.c.x;
 OperatorRecordTests.Cplx a3.c.y;
 OperatorRecordTests.Cplx a4.c.x;
 OperatorRecordTests.Cplx a4.c.y;
equation
 a1.c.x = a2.c.x;
 a2.c.x = a3.c.x;
 OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'+'(a1.c.y, a2.c.y), a3.c.y) = OperatorRecordTests.Cplx.'0'();
 a4.c.y = OperatorRecordTests.Cplx.'0'();

public
 function OperatorRecordTests.Cplx.'0'
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(0, 0);
  return;
 end OperatorRecordTests.Cplx.'0';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.neg
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(- a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'-'.neg;

 function OperatorRecordTests.Cplx.'-'.sub
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'-'.sub;

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect2;
")})));
    end OperatorRecordConnect2;


    model OperatorRecordConnect3
        connector C = Cplx;

        C c1, c2, c3;
    equation
        connect(c1, c2);
		c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect3",
            description="Connectors that are operator records",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect3
 OperatorRecordTests.OperatorRecordConnect3.C c1;
 OperatorRecordTests.OperatorRecordConnect3.C c2;
 OperatorRecordTests.OperatorRecordConnect3.C c3;
equation
 c3 = OperatorRecordTests.Cplx.'+'(c1, c2);
 c1 = c2;

public
 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.OperatorRecordConnect3.C
  Real re;
  Real im;
 end OperatorRecordTests.OperatorRecordConnect3.C;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect3;
")})));
    end OperatorRecordConnect3;


    model OperatorRecordConnect4
        connector C
            Cplx x;
            flow Cplx y;
        end C;

        C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect4",
            description="Connector with flow operator record without connection",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect4
 OperatorRecordTests.Cplx c.x;
 OperatorRecordTests.Cplx c.y;
equation
 c.y = OperatorRecordTests.Cplx.'0'();

public
 function OperatorRecordTests.Cplx.'0'
  output OperatorRecordTests.Cplx c;
 algorithm
  c := OperatorRecordTests.Cplx.'constructor'(0, 0);
  return;
 end OperatorRecordTests.Cplx.'0';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im := 0;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect4;
")})));
    end OperatorRecordConnect4;


end OperatorRecordTests;
