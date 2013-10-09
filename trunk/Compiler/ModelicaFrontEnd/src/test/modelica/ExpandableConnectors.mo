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
        
        EC ec1, ec2, ec3;
        C c1, c2;
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
	        EC ec1, ec2, ec3;
	        C c1, c2;
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
			flatModel="
fclass ExpandableConnectors.Expandable3
 ExpandableConnectors.Expandable3.C m[1].ec1.a[3];
 ExpandableConnectors.Expandable3.C m[1].ec2.a[3];
 ExpandableConnectors.Expandable3.C m[1].ec3.a[3];
 ExpandableConnectors.Expandable3.C m[1].c1[3];
 ExpandableConnectors.Expandable3.C m[1].c2[3];
 ExpandableConnectors.Expandable3.C m[2].ec1.a[3];
 ExpandableConnectors.Expandable3.C m[2].ec2.a[3];
 ExpandableConnectors.Expandable3.C m[2].ec3.a[3];
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
        C c1, c2;
    equation
        connect(c1, ec[1].a);
        connect(ec[1], ec[2]);
        connect(ec[2], ec[3]);
        connect(ec[3].a, c2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable4",
			description="Array of expandable connectors",
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
	
	
	model Expandable7
        expandable connector EC
        end EC;
        
		model A
			replaceable EC ec;
		end A;
        
        connector C = Real;
		
		A a1(redeclare EC ec);
        A a2(redeclare EC ec);
        A a3(redeclare EC ec);
        C c1, c2;
    equation
        connect(c1, a1.ec.b);
        connect(a1.ec, a2.ec);
        connect(a2.ec, a3.ec);
        connect(a3.ec.b, c2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable7",
			description="Added support for redeclaring expandable connectors",
			flatModel="
fclass ExpandableConnectors.Expandable7
 Real a1.ec.b;
 Real a2.ec.b;
 Real a3.ec.b;
 Real c1;
 Real c2;
equation
 a1.ec.b = a2.ec.b;
 a2.ec.b = a3.ec.b;
 a3.ec.b = c1;
 c1 = c2;
end ExpandableConnectors.Expandable7;
")})));
	end Expandable7;


    model Expandable8
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c1 = 1;
        C c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable8",
			description="Adding to expandable connectors from var with bining exp",
			flatModel="
fclass ExpandableConnectors.Expandable8
 Real ec1.a;
 Real ec2.a;
 Real ec3.a;
 Real c1 = 1;
 Real c2;
equation
 c1 = c2;
 c2 = ec1.a;
 ec1.a = ec2.a;
 ec2.a = ec3.a;
end ExpandableConnectors.Expandable8;
")})));
	end Expandable8;
	
	
    model Expandable9
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c[2];
    equation
        connect(c[1], ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[2]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable9",
			description="Expandable connectors: connect to single element in array",
			flatModel="
fclass ExpandableConnectors.Expandable9
 Real ec1.a;
 Real ec2.a;
 Real ec3.a;
 Real c[2];
equation
 c[1] = c[2];
 c[2] = ec1.a;
 ec1.a = ec2.a;
 ec2.a = ec3.a;
end ExpandableConnectors.Expandable9;
")})));
	end Expandable9;
    
    
    model Expandable10
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c[4];
    equation
        connect(c[1:2], ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[3:4]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable10",
			description="Expandable connectors: connect to slice",
			flatModel="
fclass ExpandableConnectors.Expandable10
 Real ec1.a[2];
 Real ec2.a[2];
 Real ec3.a[2];
 Real c[4];
equation
 c[1] = ec1.a[1];
 c[2] = ec1.a[2];
 ec1.a[1:2] = ec2.a[1:2];
 ec2.a[1:2] = ec3.a[1:2];
 c[3] = ec3.a[1];
 c[4] = ec3.a[2];
end ExpandableConnectors.Expandable10;
")})));
    end Expandable10;


    model Expandable11
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c1, c2, c3, c4;
    equation
        connect(c1, ec1.a[1]);
        connect(c2, ec1.a[2]);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a[1], c3);
        connect(ec3.a[2], c4);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable11",
			description="Connecting to cell of array in expandable connector",
			expandable_connectors=true,
			flatModel="
fclass ExpandableConnectors.Expandable11
 Real ec1.a[2];
 Real ec2.a[2];
 Real ec3.a[2];
 Real c1;
 Real c2;
 Real c3;
 Real c4;
equation
 c1 = ec1.a[1];
 c2 = ec1.a[2];
 ec1.a[1:2] = ec2.a[1:2];
 ec2.a[1:2] = ec3.a[1:2];
 c3 = ec3.a[1];
 c4 = ec3.a[2];
end ExpandableConnectors.Expandable11;
")})));
	end Expandable11;


    model Expandable12
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c1[5], c2[5];
    equation
        connect(c1[1:2], ec1.a[1:2:3]);
        connect(c1[3:4], ec1.a[2:2:4]);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a[1:2:3], c2[1:2]);
        connect(ec3.a[2:2:4], c2[3:4]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable12",
			description="Connecting to slice of array in expandable connector",
			flatModel="
fclass ExpandableConnectors.Expandable12
 Real ec1.a[4];
 Real ec2.a[4];
 Real ec3.a[4];
 Real c1[5];
 Real c2[5];
equation
 c1[1] = ec1.a[1];
 c1[2] = ec1.a[3];
 c1[3] = ec1.a[2];
 c1[4] = ec1.a[4];
 ec1.a[1:4] = ec2.a[1:4];
 ec2.a[1:4] = ec3.a[1:4];
 c2[1] = ec3.a[1];
 c2[2] = ec3.a[3];
 c2[3] = ec3.a[2];
 c2[4] = ec3.a[4];
end ExpandableConnectors.Expandable12;
")})));
	end Expandable12;


    model Expandable13
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2;
		C c1[2], c2[2,2];
	equation
        connect(ec1, ec2);
        connect(ec1.a[1,:], c1);
        connect(ec1.b[:,1:2], c2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable13",
			description="Connecting to slice with colon of array in expandable connector",
			flatModel="
fclass ExpandableConnectors.Expandable13
 Real ec1.a[1,2];
 Real ec1.b[2,2];
 Real ec2.a[1,2];
 Real ec2.b[2,2];
 Real c1[2];
 Real c2[2,2];
equation
 ec1.a[1:1,1:2] = ec2.a[1:1,1:2];
 ec1.b[1:2,1:2] = ec2.b[1:2,1:2];
 c1[1] = ec1.a[1,1];
 c1[2] = ec1.a[1,2];
 c2[1,1] = ec1.b[1,1];
 c2[1,2] = ec1.b[1,2];
 c2[2,1] = ec1.b[2,1];
 c2[2,2] = ec1.b[2,2];
end ExpandableConnectors.Expandable13;
")})));
    end Expandable13;
    
    
    model Expandable14
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c1[3], c2;
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a[3]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable14",
			description="Connecting to entire array and to single element",
			flatModel="
fclass ExpandableConnectors.Expandable14
 Real ec1.a[3];
 Real c1[3];
 Real c2;
equation
 c1[1] = ec1.a[1];
 c1[2] = ec1.a[2];
 c1[3] = c2;
 c2 = ec1.a[3];
end ExpandableConnectors.Expandable14;
")})));
    end Expandable14;
	
    
    
    model ExpandableErr1
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c[3];
    equation
        connect(c, ec1.a[1:2]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr1",
            description="Exandable connectors: local size error in connection, length differs",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 551, column 9:
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr1;
    
    
    model ExpandableErr2
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c[3];
    equation
        connect(c, ec1.a[:,1:2]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr2",
            description="Exandable connectors: local size error in connection, number of dimensions differ",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 575, column 9:
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr2;
    
    
    model ExpandableErr3
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c[3,3];
    equation
        connect(c, ec1.a[:]);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr3",
			description="Exandable connectors: local size error in connection, number of dimensions differ",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 614, column 6:
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr3;
    
    
    model ExpandableErr3b
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c[3,3];
    equation
        connect(c, ec1.a[:,1]);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr3b",
			description="Exandable connectors: local size error in connection, number of dimensions differ",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 637, column 9:
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr3b;
    
    
    model ExpandableErr4
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c1[3], c2;
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a[4]);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr4",
			description="Exandable connectors: size mismatch between connections, access to specific element > fixed size",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 639, column 9:
  Size introduced for external connector member does not match other connections to same name in connection set
")})));
    end ExpandableErr4;
    
    
    model ExpandableErr5
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c1[3], c2;
    equation
        connect(c2, ec1.a[4]);
        connect(c1, ec1.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr5",
			description="Exandable connectors: size mismatch between connections, access to specific element > fixed size",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 664, column 9:
  Size introduced for external connector member does not match other connections to same name in connection set
")})));
    end ExpandableErr5;
    
    
    model ExpandableErr6
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c1[3], c2;
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a[3,1]);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr6",
			description="Exandable connectors: size mismatch between connections, number of dimensions differ",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 689, column 9:
  Size introduced for external connector member does not match other connections to same name in connection set
")})));
    end ExpandableErr6;
    
    
    model ExpandableErr7
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c1[3], c2;
    equation
        connect(c2, ec1.a[3,1]);
        connect(c1, ec1.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr7",
			description="Exandable connectors: size mismatch between connections, number of dimensions differ",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 714, column 9:
  Size introduced for external connector member does not match other connections to same name in connection set
")})));
    end ExpandableErr7;
    
    
    model ExpandableErr8
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        C c1[3], c2[4];
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr8",
			description="Exandable connectors: size mismatch between connections, different fixed sizes",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 762, column 9:
  Size introduced for external connector member does not match other connections to same name in connection set
")})));
    end ExpandableErr8;
	
	
	model ExpandableErr9
        expandable connector EC
        end EC;
        
        connector C1
            Real x;
        end C1;
        
        connector C2
            Real y;
        end C2;
		
        EC ec;
        C1 c1;
		C2 c2;
	equation
        connect(c1, ec.a);
        connect(c2, ec.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr9",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 811, column 9:
  Type of component introduced to external connector does not match other connections to same name in connection set
")})));
	end ExpandableErr9;
    
    
    model ExpandableErr10
        expandable connector EC
        end EC;
        
        connector C1 = Real;
        
        connector C2 = Boolean;
        
        EC ec;
        C1 c1;
        C2 c2;
    equation
        connect(c1, ec.a[1]);
        connect(c2, ec.a[2]);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr10",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 839, column 9:
  Type of component introduced to external connector does not match other connections to same name in connection set
")})));
    end ExpandableErr10;



	model ExpandableCompliance
        expandable connector EC
        end EC;
	
        EC ec;		

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ExpandableCompliance",
			description="Check that expandable connectors gives compliance error without correct option",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 284, column 15:
  Expandable connectors are not supported
")})));
	end ExpandableCompliance;


end ExpandableConnectors;
