/*
    Copyright (C) 2013 Modelon AB

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


package ExpandableConnectors

    model Expandable1
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        EC ec2;
        EC ec3;
        C c1;
        C c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c2);
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable1",
            description="Basic test of expandable connectors",
			expandable_connectors=true,
            flatModel="
fclass ExpandableConnectors.Expandable1
 Real ec1.a;
 Real ec2.a;
 Real ec3.a;
 Real c1;
 Real c2;
equation
 c1 = time;
 c1 = c2;
 c2 = ec1.a;
 ec1.a = ec2.a;
 ec2.a = ec3.a;
end ExpandableConnectors.Expandable1;
")})));
    end Expandable1;


	model Expandable2
        expandable connector EC
        end EC;
		
		connector C
			Real a;
			flow Real b;
		end C;

        EC ec1, ec2, ec3;
        C c1, c2, c3, c4, c5;
	equation
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(c1, ec1.x);     
        connect(c2, ec1.y);     
        connect(ec3.x, c3);
        connect(ec3.y, c4);
        connect(ec2.x, c5);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable2",
			description="Expandable connectors: adding composite connectors",
			expandable_connectors=true,
			flatModel="
fclass ExpandableConnectors.Expandable2
 Real ec1.x.a;
 Real ec1.x.b;
 Real ec1.y.a;
 Real ec1.y.b;
 Real ec2.x.a;
 Real ec2.x.b;
 Real ec2.y.a;
 Real ec2.y.b;
 Real ec3.x.a;
 Real ec3.x.b;
 Real ec3.y.a;
 Real ec3.y.b;
 Real c1.a;
 Real c1.b;
 Real c2.a;
 Real c2.b;
 Real c3.a;
 Real c3.b;
 Real c4.a;
 Real c4.b;
 Real c5.a;
 Real c5.b;
equation
 c1.b = 0;
 c2.b = 0;
 c3.b = 0;
 c4.b = 0;
 c5.b = 0;
 c1.a = c3.a;
 c3.a = c5.a;
 c5.a = ec1.x.a;
 ec1.x.a = ec2.x.a;
 ec2.x.a = ec3.x.a;
 - c1.b - c3.b - c5.b - ec1.x.b - ec2.x.b - ec3.x.b = 0;
 c2.a = c4.a;
 c4.a = ec1.y.a;
 ec1.y.a = ec2.y.a;
 ec2.y.a = ec3.y.a;
 - c2.b - c4.b - ec1.y.b - ec2.y.b - ec3.y.b = 0;
end ExpandableConnectors.Expandable2;
")})));
	end Expandable2;


    model Expandable3
        expandable connector EC
        end EC;
        
        connector C = Real[3];
        
		model M
	        EC ec1;
	        EC ec2;
	        EC ec3;
	        C c1;
	        C c2;
	    equation
	        connect(c1, ec1.a);
	        connect(ec1, ec2);
	        connect(ec2, ec3);
	        connect(ec3.a, c2);
		end M;
		
		M m[2];

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable3",
			description="Expandable connectors: adding entire array without subscripts, within array component",
			expandable_connectors=true,
			flatModel="
fclass ExpandableConnectors.Expandable3
 ExpandableConnectors.Expandable3.C m[1].ec1.a;
 ExpandableConnectors.Expandable3.C m[1].ec2.a;
 ExpandableConnectors.Expandable3.C m[1].ec3.a;
 ExpandableConnectors.Expandable3.C m[1].c1[3];
 ExpandableConnectors.Expandable3.C m[1].c2[3];
 ExpandableConnectors.Expandable3.C m[2].ec1.a;
 ExpandableConnectors.Expandable3.C m[2].ec2.a;
 ExpandableConnectors.Expandable3.C m[2].ec3.a;
 ExpandableConnectors.Expandable3.C m[2].c1[3];
 ExpandableConnectors.Expandable3.C m[2].c2[3];
equation
 m[1].c1[1] = m[1].ec1.a[1];
 m[1].c1[2] = m[1].ec1.a[2];
 m[1].c1[3] = m[1].ec1.a[3];
 m[1].ec1.a[1:3] = m[1].ec2.a[1:3];
 m[1].ec2.a[1:3] = m[1].ec3.a[1:3];
 m[1].c2[1] = m[1].ec3.a[1];
 m[1].c2[2] = m[1].ec3.a[2];
 m[1].c2[3] = m[1].ec3.a[3];
 m[2].c1[1] = m[2].ec1.a[1];
 m[2].c1[2] = m[2].ec1.a[2];
 m[2].c1[3] = m[2].ec1.a[3];
 m[2].ec1.a[1:3] = m[2].ec2.a[1:3];
 m[2].ec2.a[1:3] = m[2].ec3.a[1:3];
 m[2].c2[1] = m[2].ec3.a[1];
 m[2].c2[2] = m[2].ec3.a[2];
 m[2].c2[3] = m[2].ec3.a[3];

public
 type ExpandableConnectors.Expandable3.C = Real;
end ExpandableConnectors.Expandable3;
")})));
    end Expandable3;


    model Expandable4
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec[3];
        C c1;
        C c2;
    equation
        connect(c1, ec[1].a);
        connect(ec[1], ec[2]);
        connect(ec[2], ec[3]);
        connect(ec[3].a, c2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable4",
			description="Array of expandable connectors",
			expandable_connectors=true,
			flatModel="
fclass ExpandableConnectors.Expandable4
 Real ec[1].a;
 Real ec[2].a;
 Real ec[3].a;
 Real c1;
 Real c2;
equation
 c1 = c2;
 c2 = ec[1].a;
 ec[1].a = ec[2].a;
 ec[2].a = ec[3].a;
end ExpandableConnectors.Expandable4;
")})));
    end Expandable4;
	
	
    model Expandable5
        expandable connector EC
        end EC;
        
        connector C = Real;
		
		model M
			C c;
		end M;
        
        parameter Integer n = 4;
        
        EC ec[n];
        M m[n];
    equation
        for i in 1:(n-2) loop
            connect(ec[i], ec[i+2]);
            connect(ec[i].a, m[i].c);
        end for;
        connect(ec[end-1].a, m[end-1].c);
        connect(ec[end].a, m[end].c);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable5",
			description="Connecting to expandable connector in for loop",
			expandable_connectors=true,
			flatModel="
fclass ExpandableConnectors.Expandable5
 parameter Integer n = 4 /* 4 */;
 Real ec[1].a;
 Real ec[2].a;
 Real ec[3].a;
 Real ec[4].a;
 Real m[1].c;
 Real m[2].c;
 Real m[3].c;
 Real m[4].c;
equation
 ec[1].a = ec[3].a;
 ec[3].a = m[1].c;
 m[1].c = m[3].c;
 ec[2].a = ec[4].a;
 ec[4].a = m[2].c;
 m[2].c = m[4].c;
end ExpandableConnectors.Expandable5;
")})));
	end Expandable5;
	
	
	model ExpandableCompliance
        expandable connector EC
        end EC;
	
        EC ec;		

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ExpandableCompliance",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 284, column 15:
  Expandable connectors are not supported
")})));
	end ExpandableCompliance;
    

end ExpandableConnectors;
