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


// TODO: This test has incorrect flattening - update when flattening of overloaded operators is fixed
    model OperatorOverload1
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload1",
            description="Basic test of type calculation for overloaded operators: addition",
            flatModel="
fclass OperatorRecordTests.OperatorOverload1
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx(3, 4);
 OperatorRecordTests.Cplx c3 = c1 + c2;

public
 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload1;
")})));
    end OperatorOverload1;


// TODO: This test has incorrect flattening - update when flattening of overloaded operators is fixed
    model OperatorOverload2
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 - c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload2",
            description="Basic test of type calculation for overloaded operators: subtraction",
            flatModel="
fclass OperatorRecordTests.OperatorOverload2
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx(3, 4);
 OperatorRecordTests.Cplx c3 = c1 - c2;

public
 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload2;
")})));
    end OperatorOverload2;


// TODO: This test has incorrect flattening - update when flattening of overloaded operators is fixed
    model OperatorOverload3
        Cplx c1 = Cplx(1, 2);
        Cplx c3 = -c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload3",
            description="Basic test of type calculation for overloaded operators: negation",
            flatModel="
fclass OperatorRecordTests.OperatorOverload3
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx(1, 2);
 OperatorRecordTests.Cplx c3 = - c1;

public
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
