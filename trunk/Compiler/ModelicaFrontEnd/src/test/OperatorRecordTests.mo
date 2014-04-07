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


    model OperatorOverloadCompliance
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="OperatorOverloadCompliance",
            description="Compliance check for operator records",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/OperatorRecordTests.mo':
Compliance error at line 20, column 5:
  Operator records are not supported
")})));
    end OperatorOverloadCompliance;


end OperatorRecordTests;
