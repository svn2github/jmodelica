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
        
        connector C = Real[2];
        
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
 ExpandableConnectors.Expandable3.C m[1].ec1.a[2];
 ExpandableConnectors.Expandable3.C m[1].ec2.a[2];
 ExpandableConnectors.Expandable3.C m[1].ec3.a[2];
 ExpandableConnectors.Expandable3.C m[1].c1[2];
 ExpandableConnectors.Expandable3.C m[1].c2[2];
 ExpandableConnectors.Expandable3.C m[2].ec1.a[2];
 ExpandableConnectors.Expandable3.C m[2].ec2.a[2];
 ExpandableConnectors.Expandable3.C m[2].ec3.a[2];
 ExpandableConnectors.Expandable3.C m[2].c1[2];
 ExpandableConnectors.Expandable3.C m[2].c2[2];
equation
 m[1].c1[1] = m[1].c2[1];
 m[1].c2[1] = m[1].ec1.a[1];
 m[1].ec1.a[1] = m[1].ec2.a[1];
 m[1].ec2.a[1] = m[1].ec3.a[1];
 m[1].c1[2] = m[1].c2[2];
 m[1].c2[2] = m[1].ec1.a[2];
 m[1].ec1.a[2] = m[1].ec2.a[2];
 m[1].ec2.a[2] = m[1].ec3.a[2];
 m[2].c1[1] = m[2].c2[1];
 m[2].c2[1] = m[2].ec1.a[1];
 m[2].ec1.a[1] = m[2].ec2.a[1];
 m[2].ec2.a[1] = m[2].ec3.a[1];
 m[2].c1[2] = m[2].c2[2];
 m[2].c2[2] = m[2].ec1.a[2];
 m[2].ec1.a[2] = m[2].ec2.a[2];
 m[2].ec2.a[2] = m[2].ec3.a[2];

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
			description="Adding to expandable connectors from var with binding exp",
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


    model Expandable8b
        expandable connector EC
        end EC;
        
        connector C
			Real x;
			Real y;
		end C;
        
        EC ec1, ec2, ec3;
        C c1(x = 1, y = 2);
        C c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c2);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable8b",
			description="Adding to expandable connectors from composite with binding exps",
			flatModel="
fclass ExpandableConnectors.Expandable8b
 Real ec1.a.x;
 Real ec1.a.y;
 Real ec2.a.x;
 Real ec2.a.y;
 Real ec3.a.x;
 Real ec3.a.y;
 Real c1.x = 1;
 Real c1.y = 2;
 Real c2.x;
 Real c2.y;
equation
 c1.x = c2.x;
 c2.x = ec1.a.x;
 ec1.a.x = ec2.a.x;
 ec2.a.x = ec3.a.x;
 c1.y = c2.y;
 c2.y = ec1.a.y;
 ec1.a.y = ec2.a.y;
 ec2.a.y = ec3.a.y;
end ExpandableConnectors.Expandable8b;
")})));
    end Expandable8b;
	
	
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
 c[1] = c[3];
 c[3] = ec1.a[1];
 ec1.a[1] = ec2.a[1];
 ec2.a[1] = ec3.a[1];
 c[2] = c[4];
 c[4] = ec1.a[2];
 ec1.a[2] = ec2.a[2];
 ec2.a[2] = ec3.a[2];
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
 c1 = c3;
 c3 = ec1.a[1];
 ec1.a[1] = ec2.a[1];
 ec2.a[1] = ec3.a[1];
 c2 = c4;
 c4 = ec1.a[2];
 ec1.a[2] = ec2.a[2];
 ec2.a[2] = ec3.a[2];
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
 c1[1] = c2[1];
 c2[1] = ec1.a[1];
 ec1.a[1] = ec2.a[1];
 ec2.a[1] = ec3.a[1];
 c1[2] = c2[2];
 c2[2] = ec1.a[3];
 ec1.a[3] = ec2.a[3];
 ec2.a[3] = ec3.a[3];
 c1[3] = c2[3];
 c2[3] = ec1.a[2];
 ec1.a[2] = ec2.a[2];
 ec2.a[2] = ec3.a[2];
 c1[4] = c2[4];
 c2[4] = ec1.a[4];
 ec1.a[4] = ec2.a[4];
 ec2.a[4] = ec3.a[4];
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
 c1[1] = ec1.a[1,1];
 ec1.a[1,1] = ec2.a[1,1];
 c1[2] = ec1.a[1,2];
 ec1.a[1,2] = ec2.a[1,2];
 c2[1,1] = ec1.b[1,1];
 ec1.b[1,1] = ec2.b[1,1];
 c2[1,2] = ec1.b[1,2];
 ec1.b[1,2] = ec2.b[1,2];
 c2[2,1] = ec1.b[2,1];
 ec1.b[2,1] = ec2.b[2,1];
 c2[2,2] = ec1.b[2,2];
 ec1.b[2,2] = ec2.b[2,2];
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
    
    
    model Expandable15
        expandable connector EC
			Real x;
			Real y;
        end EC;
        
        connector C = Real;
		
		EC ec;
		C c;
	equation
		connect(c, ec.x);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable15",
			description="Expandable connector with members",
			flatModel="
fclass ExpandableConnectors.Expandable15
 Real ec.x;
 Real c;
equation
 c = ec.x;
end ExpandableConnectors.Expandable15;
")})));
    end Expandable15;
    
    
    model Expandable16
        expandable connector EC
            Real a[3];
        end EC;
        
        connector C = Real;
        
        EC ec;
        C c[3];
    equation
        connect(c, ec.a);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable16",
			description="Expandable connector with members: array",
			flatModel="
fclass ExpandableConnectors.Expandable16
 Real ec.a[3];
 Real c[3];
equation
 c[1] = ec.a[1];
 c[2] = ec.a[2];
 c[3] = ec.a[3];
end ExpandableConnectors.Expandable16;
")})));
    end Expandable16;
    
    
    model Expandable17
        expandable connector EC
            C a;
        end EC;
        
        connector C
            Real x;
            Real y;
        end C;
        
        EC ec;
        C c;
    equation
        connect(c, ec.a);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable17",
			description="Expandable connector with members: composite",
			flatModel="
fclass ExpandableConnectors.Expandable17
 Real ec.a.x;
 Real ec.a.y;
 Real c.x;
 Real c.y;
equation
 c.x = ec.a.x;
 c.y = ec.a.y;
end ExpandableConnectors.Expandable17;
")})));
    end Expandable17;
    
    
    model Expandable18
        expandable connector EC
            Real x;
        end EC;
		
		connector C = Real;
        
		C c;
        EC ec;
        Real y;
    equation
		connect(c, ec.x);
        y = ec.x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable18",
			description="Using member of expandable connector that is connected to",
			flatModel="
fclass ExpandableConnectors.Expandable18
 Real c;
 Real ec.x;
 Real y;
equation
 y = ec.x;
 c = ec.x;
end ExpandableConnectors.Expandable18;
")})));
    end Expandable18;
    
    
    model Expandable19
        expandable connector EC
            Real x;
        end EC;
        
        connector C = Real;
        
        C c;
        EC ec;
        Real y = ec.x;
    equation
        connect(c, ec.x);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable19",
			description="Using member of expandable connector that is connected to",
			flatModel="
fclass ExpandableConnectors.Expandable19
 Real c;
 Real ec.x;
 Real y = ec.x;
equation
 c = ec.x;
end ExpandableConnectors.Expandable19;
")})));
    end Expandable19;
    
    
    model Expandable20
        expandable connector EC
            Real x;
        end EC;
        
        model A
            Real y;
        end A;
        
        connector C = Real;
        
        C c;
        EC ec;
        A a(y = ec.x);
    equation
        connect(c, ec.x);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable20",
			description="Using member of expandable connector that is connected to",
			flatModel="
fclass ExpandableConnectors.Expandable20
 Real c;
 Real ec.x;
 Real a.y = ec.x;
equation
 c = ec.x;
end ExpandableConnectors.Expandable20;
")})));
    end Expandable20;
    
    
    model Expandable21
        expandable connector EC1
            Real x;
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        connector C = Real;
        
        C c;
        EC1 ec1a, ec1b;
        EC2 ec2;
        Real y;
    equation
        connect(ec1a, ec1b);
        connect(ec1b, ec2);
        connect(c, ec2.x);
        y = ec1b.x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable21",
			description="Using member of expandable connector that is connected to",
			flatModel="
fclass ExpandableConnectors.Expandable21
 Real c;
 Real ec1a.x;
 Real ec1b.x;
 Real ec2.x;
 Real y;
equation
 y = ec1b.x;
 c = ec1a.x;
 ec1a.x = ec1b.x;
 ec1b.x = ec2.x;
end ExpandableConnectors.Expandable21;
")})));
    end Expandable21;
    
    
    model Expandable22
        expandable connector EC1
            Real x;
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        connector C = Real;
        
        C c;
        EC1 ec1a, ec1b;
        EC2 ec2;
        Real y = ec1b.x;
    equation
        connect(ec1a, ec1b);
        connect(ec1b, ec2);
        connect(c, ec2.x);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable22",
			description="Using member of expandable connector that is connected to",
			flatModel="
fclass ExpandableConnectors.Expandable22
 Real c;
 Real ec1a.x;
 Real ec1b.x;
 Real ec2.x;
 Real y = ec1b.x;
equation
 c = ec1a.x;
 ec1a.x = ec1b.x;
 ec1b.x = ec2.x;
end ExpandableConnectors.Expandable22;
")})));
    end Expandable22;
    
    
    model Expandable23
        expandable connector EC1
            Real x;
        end EC1;
		
        expandable connector EC2
        end EC2;
        
        model A
            Real y;
        end A;
        
        connector C = Real;
        
        C c;
        EC1 ec1a, ec1b;
        EC2 ec2;
        A a(y = ec1b.x);
    equation
        connect(ec1a, ec1b);
        connect(ec1b, ec2);
        connect(c, ec2.x);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable23",
			description="Using member of expandable connector that is connected to",
			flatModel="
fclass ExpandableConnectors.Expandable23
 Real c;
 Real ec1a.x;
 Real ec1b.x;
 Real ec2.x;
 Real a.y = ec1b.x;
equation
 c = ec1a.x;
 ec1a.x = ec1b.x;
 ec1b.x = ec2.x;
end ExpandableConnectors.Expandable23;
")})));
    end Expandable23;
    
    
    model Expandable24
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable24",
			description="Connecting to only some elements of array",
			flatModel="
fclass ExpandableConnectors.Expandable24
 Real ec.x[2];
 Real c;
equation
 c = ec.x[2];
 ec.x[1] = 0;
end ExpandableConnectors.Expandable24;
")})));
    end Expandable24;
	
	
	model Expandable25
        expandable connector EC
            Real x[3];
        end EC;
		
		connector C = Real;
		
		EC ec;
		C c;
	equation
		connect(c, ec.x[2]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable25",
			description="Connecting to only some elements of array",
			flatModel="
fclass ExpandableConnectors.Expandable25
 Real ec.x[3];
 Real c;
equation
 c = ec.x[2];
 ec.x[1] = 0;
 ec.x[3] = 0;
end ExpandableConnectors.Expandable25;
")})));
	end Expandable25;
    
    
    model Expandable26
        expandable connector EC
        end EC;
        
        connector C
            Real x;
            Real y;
        end C;
	        
        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable26",
			description="Connecting to only some elements of array",
			flatModel="
fclass ExpandableConnectors.Expandable26
 Real ec.x.x;
 Real ec.x.y;
 Real c.x;
 Real c.y;
equation
 c.x = ec.x[2].x;
 c.y = ec.x[2].y;
 ec.x[1].x = 0;
 ec.x[1].y = 0;
end ExpandableConnectors.Expandable26;
")})));
    end Expandable26;
    
    
    model Expandable27
        expandable connector EC
            C x[3];
        end EC;
        
        connector C
			Real x;
			Real y;
		end C;
        
        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Expandable27",
			description="Connecting to only some elements of array",
			flatModel="
fclass ExpandableConnectors.Expandable27
 Real ec.x[1].x;
 Real ec.x[1].y;
 Real ec.x[2].x;
 Real ec.x[2].y;
 Real ec.x[3].x;
 Real ec.x[3].y;
 Real c.x;
 Real c.y;
equation
 c.x = ec.x[2].x;
 c.y = ec.x[2].y;
 ec.x[1].x = 0;
 ec.x[1].y = 0;
 ec.x[3].x = 0;
 ec.x[3].y = 0;
end ExpandableConnectors.Expandable27;
")})));
    end Expandable27;
    
    
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
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
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
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
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
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
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
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
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
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
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
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
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
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr10;
    
    
    model ExpandableErr11
        expandable connector EC
            Real a;
        end EC;
        
        connector C = Boolean;
        
        EC ec;
        C c;
    equation
        connect(c, ec.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr11",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 953, column 9:
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr11;
    
    
    model ExpandableErr12
        expandable connector EC
            Real a[3];
        end EC;
        
        connector C = Real;
        
        EC ec;
        C c[3];
    equation
        connect(c[1:2], ec.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr12",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 978, column 9:
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr12;
    
    
    model ExpandableErr13
        expandable connector EC1
            Real a;
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        connector C = Boolean;
        
        EC1 ec1;
        EC2 ec2;
        C c;
    equation
        connect(ec1, ec2);
        connect(c, ec2.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr13",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1008, column 9:
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr13;
    
    
    model ExpandableErr14
        expandable connector EC1
            Real a;
        end EC1;
        
        expandable connector EC2
            Boolean a;
        end EC2;
        
        EC1 ec1;
        EC2 ec2;
    equation
        connect(ec1, ec2);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr14",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1035, column 9:
  Types of connected components do not match
")})));
    end ExpandableErr14;
    
    
    model ExpandableErr15
        expandable connector EC1
            Real a[3];
        end EC1;
        
        expandable connector EC2
            Real a[4];
        end EC2;
        
        EC1 ec1;
        EC2 ec2;
    equation
        connect(ec1, ec2);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr15",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1062, column 9:
  Types of connected components do not match
")})));
    end ExpandableErr15;
    
    
    model ExpandableErr16
        expandable connector EC1
            Real a;
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        expandable connector EC3
            Boolean a;
        end EC3;
        
        connector C = Real;
        
        EC1 ec1;
        EC2 ec2;
        EC3 ec3;
		C c;
    equation
        connect(ec1, ec2);
        connect(ec2, ec3);
		connect(c, ec1.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr16",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1085, column 32:
  Type of declared member of expandable connector does not match declarations in other expandable connectors in same connection set
")})));
    end ExpandableErr16;
    
    
    model ExpandableErr17
        expandable connector EC1
            Real a[3];
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        expandable connector EC3
            Real a[4];
        end EC3;
        
        connector C = Real;
        
        EC1 ec1;
        EC2 ec2;
        EC3 ec3;
        C c[3];
    equation
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(c, ec1.a);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr17",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1124, column 32:
  Size of declared member of expandable connector does not match declarations in other expandable connectors in same connection set
")})));
    end ExpandableErr17;
	
	
	model ExpandableErr18
		expandable connector EC
			Real x;
		end EC;
		
		connector C
			Real x;
		end C;
		
		EC ec;
		C c;
	equation
		connect(ec, c);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr18",
			description="",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1209, column 3:
  Connecting an expandable connector to a non-expandable connector is not allowed
")})));
	end ExpandableErr18;
    
    
    model ExpandableErr19
        expandable connector EC
            Real x;
        end EC;
        
        EC ec;
        Real y;
    equation
        y = ec.x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr19",
			description="Using member of expandable connector that is not connected to",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1268, column 13:
  Using member of expandable connector is only allowed if the member is connected to in the connection set
")})));
    end ExpandableErr19;
    
    
    model ExpandableErr20
        expandable connector EC
            Real x;
        end EC;
        
        EC ec;
        Real y = ec.x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr20",
			description="Using member of expandable connector that is not connected to",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1289, column 18:
  Using member of expandable connector is only allowed if the member is connected to in the connection set
")})));
    end ExpandableErr20;
    
    
    model ExpandableErr21
        expandable connector EC
            Real x;
        end EC;
		
		model A
			Real y;
		end A;
        
        EC ec;
        A a(y = ec.x);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ExpandableErr21",
			description="Using member of expandable connector that is not connected to",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Semantic error at line 1314, column 17:
  Using member of expandable connector is only allowed if the member is connected to in the connection set
")})));
    end ExpandableErr21;



    model ExpandableCompliance1
        expandable connector EC1
            EC2 ec2;
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        EC1 ec1;

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ExpandableCompliance1",
			description="Nested expandable connectors: direct declaration",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 1656, column 32:
  Nestled expandable connectors are not supported
")})));
    end ExpandableCompliance1;


    model ExpandableCompliance2
        expandable connector EC1
        end EC1;
        
        expandable connector EC2
        end EC2;
        
        EC1 ec1;
		EC2 ec2;
	equation
		connect(ec1, ec2.a);
		connect(ec2.b, ec1);

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ExpandableCompliance2",
			description="Nested expandable connectors: connecting to expandable",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 1688, column 3:
  Nestled expandable connectors are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 1689, column 3:
  Nestled expandable connectors are not supported
")})));
    end ExpandableCompliance2;


    model ExpandableCompliance3
        expandable connector EC
        end EC;
        
		connector C = Real;
		
        EC ec;
		C c;
	equation
        connect(c, ec.a1.a2);
		connect(ec.b1.b2, c);

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ExpandableCompliance3",
			description="Nested expandable connectors: connecting with more than one unknown name",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 1716, column 9:
  Nestled expandable connectors are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ExpandableConnectors.mo':
Compliance error at line 1717, column 3:
  Nestled expandable connectors are not supported
")})));
    end ExpandableCompliance3;


end ExpandableConnectors;
