/*
    Copyright (C) 2011-2013 Modelon AB

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

package StreamTests
  connector FluidPort
     flow Real m_flow;
     stream Real h_outflow;
     Real p;
  end FluidPort;

model Reservoir
    parameter Real p0 = 1;
    parameter Real h0 = 1;
    FluidPort fluidPort;
equation 
  fluidPort.p=p0;
  fluidPort.h_outflow=h0;
end Reservoir;

model LinearResistance

  FluidPort port_a;
  FluidPort port_b;
equation 
  port_a.m_flow=(port_a.p-port_b.p);
  port_a.m_flow+port_b.m_flow=0;
  port_a.h_outflow=inStream(port_b.h_outflow);
  port_b.h_outflow=inStream(port_a.h_outflow);
end LinearResistance;

  model StreamTest1

     Reservoir r;
     Real h = inStream(r.fluidPort.h_outflow);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamTest1",
			description="Test of inside and outside stream connectors.",
			eliminate_alias_variables=false,
			flatModel="
fclass StreamTests.StreamTest1
 parameter Real r.p0 = 1 /* 1 */;
 parameter Real r.h0 = 1 /* 1 */;
 constant Real r.fluidPort.m_flow = 0;
 parameter Real r.fluidPort.p;
 parameter Real r.fluidPort.h_outflow;
 parameter Real h;
parameter equation
 r.fluidPort.p = r.p0;
 r.fluidPort.h_outflow = r.h0;
 h = r.fluidPort.h_outflow;
end StreamTests.StreamTest1;
")})));
  end StreamTest1;

  model StreamTest2
     Reservoir r;
     Real h = actualStream(r.fluidPort.h_outflow);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamTest2",
			description="Test of inside and outside stream connectors.",
			eliminate_alias_variables=false,
			flatModel="
fclass StreamTests.StreamTest2
 parameter Real r.p0 = 1 /* 1 */;
 parameter Real r.h0 = 1 /* 1 */;
 constant Real r.fluidPort.m_flow = 0;
 parameter Real r.fluidPort.p;
 parameter Real r.fluidPort.h_outflow;
 parameter Real h;
parameter equation
 r.fluidPort.p = r.p0;
 r.fluidPort.h_outflow = r.h0;
 h = noEvent(r.fluidPort.h_outflow);
end StreamTests.StreamTest2;
")})));
  end StreamTest2;

  model StreamTest3
     Reservoir r1;
     Reservoir r2;
     LinearResistance res;
  equation 
     connect(r1.fluidPort,res.port_a);
     connect(r2.fluidPort,res.port_b);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamTest3",
			description="Test of inside and outside stream connectors.",
			eliminate_alias_variables=false,
			flatModel="
fclass StreamTests.StreamTest3
 parameter Real r1.p0 = 1 /* 1 */;
 parameter Real r1.h0 = 1 /* 1 */;
 parameter Real r1.fluidPort.p;
 parameter Real r1.fluidPort.h_outflow;
 parameter Real r2.fluidPort.p;
 parameter Real r2.p0 = 1 /* 1 */;
 parameter Real r2.h0 = 1 /* 1 */;
 parameter Real r2.fluidPort.h_outflow;
 parameter Real res.port_a.p;
 parameter Real res.port_b.h_outflow;
 parameter Real res.port_b.p;
 parameter Real res.port_a.h_outflow;
 parameter Real res.port_a.m_flow;
 parameter Real res.port_b.m_flow;
 parameter Real r1.fluidPort.m_flow;
 parameter Real r2.fluidPort.m_flow;
parameter equation
 r1.fluidPort.p = r1.p0;
 r1.fluidPort.h_outflow = r1.h0;
 r2.fluidPort.p = r2.p0;
 r2.fluidPort.h_outflow = r2.h0;
 res.port_a.p = (- r1.fluidPort.p) / -1.0;
 res.port_b.h_outflow = r1.fluidPort.h_outflow;
 res.port_b.p = (- r2.fluidPort.p) / -1.0;
 res.port_a.h_outflow = r2.fluidPort.h_outflow;
 res.port_a.m_flow = res.port_a.p + (- res.port_b.p);
 res.port_b.m_flow = - res.port_a.m_flow;
 r1.fluidPort.m_flow = - res.port_a.m_flow;
 r2.fluidPort.m_flow = - res.port_b.m_flow;
end StreamTests.StreamTest3;
")})));
  end StreamTest3;
  
  model StreamTest4
     Reservoir r[2];
     Real h[2] = inStream(r.fluidPort.h_outflow);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamTest4",
			description="Using inStream() on array.",
			eliminate_alias_variables=false,
			flatModel="
fclass StreamTests.StreamTest4
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 constant Real r[1].fluidPort.m_flow = 0;
 parameter Real r[1].fluidPort.p;
 parameter Real r[1].fluidPort.h_outflow;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 constant Real r[2].fluidPort.m_flow = 0;
 parameter Real r[2].fluidPort.p;
 parameter Real r[2].fluidPort.h_outflow;
 parameter Real h[1];
 parameter Real h[2];
parameter equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 h[1] = r[1].fluidPort.h_outflow;
 h[2] = r[2].fluidPort.h_outflow;
end StreamTests.StreamTest4;
")})));
  end StreamTest4;
	
  model StreamTest5
	 Reservoir r[2];
	 Real h[2] = actualStream(r.fluidPort.h_outflow);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamTest5",
			description="Using actualStream() on stream variables from array of connectors.",
			eliminate_alias_variables=false,
			flatModel="
fclass StreamTests.StreamTest5
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 constant Real r[1].fluidPort.m_flow = 0;
 parameter Real r[1].fluidPort.p;
 parameter Real r[1].fluidPort.h_outflow;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 constant Real r[2].fluidPort.m_flow = 0;
 parameter Real r[2].fluidPort.p;
 parameter Real r[2].fluidPort.h_outflow;
 parameter Real h[1];
 parameter Real h[2];
parameter equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 h[1] = noEvent(r[1].fluidPort.h_outflow);
 h[2] = noEvent(r[2].fluidPort.h_outflow);
end StreamTests.StreamTest5;
")})));
  end StreamTest5;
  
  model StreamTest6
	  connector A
		 flow Real a;
		 stream Real[2] b;
		 Real c;
	  end A;
	  
	  A d;
	  Real f[2];
  equation
	  f = actualStream(d.b);
	  f = {1,2};
	  d.c = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamTest6",
			description="Using actualStream() on array of stream variables.",
			eliminate_alias_variables=false,
			flatModel="
fclass StreamTests.StreamTest6
 constant Real d.a = 0;
 Real d.b[1];
 Real d.b[2];
 constant Real d.c = 0;
 constant Real f[1] = 1;
 constant Real f[2] = 2;
equation
 1.0 = noEvent(d.b[1]);
 2.0 = noEvent(d.b[2]);
end StreamTests.StreamTest6;
")})));
  end StreamTest6;
  
// TODO: rewrite from actualStream() does not handle this
  model StreamTest7
	  connector A
		 flow Real a;
		 stream Real b;
		 Real c;
	  end A;
	  
	  A d;
	  A e;
	  Real f;
  equation
	  connect(d, e);
	  f = actualStream(d.b);
  end StreamTest7;


model StreamMinMax1
    Reservoir r[3](fluidPort(m_flow(min={-1,0,1})));
    LinearResistance l[3];
    Real h[3] = actualStream(r.fluidPort.h_outflow);
    Real g[3] = r.fluidPort.m_flow .* actualStream(r.fluidPort.h_outflow);
equation
    connect(r.fluidPort,l.port_a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamMinMax1",
			description="Expansion of actualStream() with max on flow variable",
			eliminate_alias_variables=false,
			variability_propagation=false,
			flatModel="
fclass StreamTests.StreamMinMax1
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 Real r[1].fluidPort.m_flow(min = - 1);
 Real r[1].fluidPort.h_outflow;
 Real r[1].fluidPort.p;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 Real r[2].fluidPort.m_flow(min = 0);
 Real r[2].fluidPort.h_outflow;
 Real r[2].fluidPort.p;
 parameter Real r[3].p0 = 1 /* 1 */;
 parameter Real r[3].h0 = 1 /* 1 */;
 Real r[3].fluidPort.m_flow(min = 1);
 Real r[3].fluidPort.h_outflow;
 Real r[3].fluidPort.p;
 Real l[1].port_a.m_flow;
 Real l[1].port_a.h_outflow;
 Real l[1].port_a.p;
 Real l[1].port_b.m_flow;
 Real l[1].port_b.h_outflow;
 Real l[1].port_b.p;
 Real l[2].port_a.m_flow;
 Real l[2].port_a.h_outflow;
 Real l[2].port_a.p;
 Real l[2].port_b.m_flow;
 Real l[2].port_b.h_outflow;
 Real l[2].port_b.p;
 Real l[3].port_a.m_flow;
 Real l[3].port_a.h_outflow;
 Real l[3].port_a.p;
 Real l[3].port_b.m_flow;
 Real l[3].port_b.h_outflow;
 Real l[3].port_b.p;
 Real h[1];
 Real h[2];
 Real h[3];
 Real g[1];
 Real g[2];
 Real g[3];
equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 r[3].fluidPort.p = r[3].p0;
 r[3].fluidPort.h_outflow = r[3].h0;
 l[1].port_a.m_flow = l[1].port_a.p - l[1].port_b.p;
 l[1].port_a.m_flow + l[1].port_b.m_flow = 0;
 l[1].port_a.h_outflow = l[1].port_b.h_outflow;
 l[1].port_b.h_outflow = r[1].fluidPort.h_outflow;
 l[2].port_a.m_flow = l[2].port_a.p - l[2].port_b.p;
 l[2].port_a.m_flow + l[2].port_b.m_flow = 0;
 l[2].port_a.h_outflow = l[2].port_b.h_outflow;
 l[2].port_b.h_outflow = r[2].fluidPort.h_outflow;
 l[3].port_a.m_flow = l[3].port_a.p - l[3].port_b.p;
 l[3].port_a.m_flow + l[3].port_b.m_flow = 0;
 l[3].port_a.h_outflow = l[3].port_b.h_outflow;
 l[3].port_b.h_outflow = r[3].fluidPort.h_outflow;
 l[1].port_a.m_flow + r[1].fluidPort.m_flow = 0;
 l[1].port_a.p = r[1].fluidPort.p;
 l[2].port_a.m_flow + r[2].fluidPort.m_flow = 0;
 l[2].port_a.p = r[2].fluidPort.p;
 l[3].port_a.m_flow + r[3].fluidPort.m_flow = 0;
 l[3].port_a.p = r[3].fluidPort.p;
 l[1].port_b.m_flow = 0;
 l[2].port_b.m_flow = 0;
 l[3].port_b.m_flow = 0;
 h[1] = noEvent(if r[1].fluidPort.m_flow > 0.0 then l[1].port_a.h_outflow else r[1].fluidPort.h_outflow);
 h[2] = noEvent(if r[2].fluidPort.m_flow > 0.0 then l[2].port_a.h_outflow else r[2].fluidPort.h_outflow);
 h[3] = l[3].port_a.h_outflow;
 g[1] = r[1].fluidPort.m_flow .* noEvent(if r[1].fluidPort.m_flow > 0.0 then l[1].port_a.h_outflow else r[1].fluidPort.h_outflow);
 g[2] = r[2].fluidPort.m_flow .* l[2].port_a.h_outflow;
 g[3] = r[3].fluidPort.m_flow .* l[3].port_a.h_outflow;
end StreamTests.StreamMinMax1;
")})));
end StreamMinMax1;

    
model StreamMinMax2
    Reservoir r[3](fluidPort(m_flow(max={-1,0,1})));
    LinearResistance l[3];
    Real h[3] = actualStream(r.fluidPort.h_outflow);
    Real g[3] = r.fluidPort.m_flow .* actualStream(r.fluidPort.h_outflow);
equation
    connect(r.fluidPort,l.port_a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StreamMinMax2",
			description="Expansion of actualStream() with max on flow variable",
			eliminate_alias_variables=false,
			variability_propagation=false,
			flatModel="
fclass StreamTests.StreamMinMax2
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 Real r[1].fluidPort.m_flow(max = - 1);
 Real r[1].fluidPort.h_outflow;
 Real r[1].fluidPort.p;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 Real r[2].fluidPort.m_flow(max = 0);
 Real r[2].fluidPort.h_outflow;
 Real r[2].fluidPort.p;
 parameter Real r[3].p0 = 1 /* 1 */;
 parameter Real r[3].h0 = 1 /* 1 */;
 Real r[3].fluidPort.m_flow(max = 1);
 Real r[3].fluidPort.h_outflow;
 Real r[3].fluidPort.p;
 Real l[1].port_a.m_flow;
 Real l[1].port_a.h_outflow;
 Real l[1].port_a.p;
 Real l[1].port_b.m_flow;
 Real l[1].port_b.h_outflow;
 Real l[1].port_b.p;
 Real l[2].port_a.m_flow;
 Real l[2].port_a.h_outflow;
 Real l[2].port_a.p;
 Real l[2].port_b.m_flow;
 Real l[2].port_b.h_outflow;
 Real l[2].port_b.p;
 Real l[3].port_a.m_flow;
 Real l[3].port_a.h_outflow;
 Real l[3].port_a.p;
 Real l[3].port_b.m_flow;
 Real l[3].port_b.h_outflow;
 Real l[3].port_b.p;
 Real h[1];
 Real h[2];
 Real h[3];
 Real g[1];
 Real g[2];
 Real g[3];
equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 r[3].fluidPort.p = r[3].p0;
 r[3].fluidPort.h_outflow = r[3].h0;
 l[1].port_a.m_flow = l[1].port_a.p - l[1].port_b.p;
 l[1].port_a.m_flow + l[1].port_b.m_flow = 0;
 l[1].port_a.h_outflow = l[1].port_b.h_outflow;
 l[1].port_b.h_outflow = r[1].fluidPort.h_outflow;
 l[2].port_a.m_flow = l[2].port_a.p - l[2].port_b.p;
 l[2].port_a.m_flow + l[2].port_b.m_flow = 0;
 l[2].port_a.h_outflow = l[2].port_b.h_outflow;
 l[2].port_b.h_outflow = r[2].fluidPort.h_outflow;
 l[3].port_a.m_flow = l[3].port_a.p - l[3].port_b.p;
 l[3].port_a.m_flow + l[3].port_b.m_flow = 0;
 l[3].port_a.h_outflow = l[3].port_b.h_outflow;
 l[3].port_b.h_outflow = r[3].fluidPort.h_outflow;
 l[1].port_a.m_flow + r[1].fluidPort.m_flow = 0;
 l[1].port_a.p = r[1].fluidPort.p;
 l[2].port_a.m_flow + r[2].fluidPort.m_flow = 0;
 l[2].port_a.p = r[2].fluidPort.p;
 l[3].port_a.m_flow + r[3].fluidPort.m_flow = 0;
 l[3].port_a.p = r[3].fluidPort.p;
 l[1].port_b.m_flow = 0;
 l[2].port_b.m_flow = 0;
 l[3].port_b.m_flow = 0;
 h[1] = r[1].fluidPort.h_outflow;
 h[2] = r[2].fluidPort.h_outflow;
 h[3] = noEvent(if r[3].fluidPort.m_flow > 0.0 then l[3].port_a.h_outflow else r[3].fluidPort.h_outflow);
 g[1] = r[1].fluidPort.m_flow .* r[1].fluidPort.h_outflow;
 g[2] = r[2].fluidPort.m_flow .* r[2].fluidPort.h_outflow;
 g[3] = r[3].fluidPort.m_flow .* noEvent(if r[3].fluidPort.m_flow > 0.0 then l[3].port_a.h_outflow else r[3].fluidPort.h_outflow);
end StreamTests.StreamMinMax2;
")})));
end StreamMinMax2;



connector StreamConnector
    Real p;
    flow Real f;
    stream Real s;
end StreamConnector;


model StreamN1M0
    model A
        StreamConnector c;
    end A;
    
    A a(c(s=1, p=2));
	Real x = inStream(a.c.s);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN1M0",
            description="Test stream connectors connected N=1, M=0",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN1M0
 Real a.c.p;
 Real a.c.f;
 Real a.c.s;
 Real x;
equation
 a.c.f = 0;
 a.c.p = 2;
 a.c.s = 1;
 x = a.c.s;
end StreamTests.StreamN1M0;
")})));
end StreamN1M0;


model StreamN2M0
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=2));
    A a2(c(s=3, f=time - 1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
	connect(a1.c, a2.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN2M0",
            description="Test stream connectors connected N=2, M=0",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN2M0
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f = 0;
 a1.c.p = a2.c.p;
 a1.c.p = 2;
 a1.c.s = 1;
 a2.c.f = time - 1;
 a2.c.s = 3;
 x1 = a2.c.s;
 x2 = a1.c.s;
end StreamTests.StreamN2M0;
")})));
end StreamN2M0;


model StreamN1M1
    model A
        StreamConnector c;
    end A;
    
    A a(c(s=1, p=2));
    StreamConnector c;
    Real x1 = inStream(a.c.s);
    Real x2 = inStream(c.s);
equation
    connect(a.c, c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN1M1",
            description="Test stream connectors connected N=1, M=1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN1M1
 Real a.c.p;
 Real a.c.f;
 Real a.c.s;
 Real c.p;
 Real c.f;
 Real c.s;
 Real x1;
 Real x2;
equation
 a.c.f - c.f = 0;
 a.c.p = c.p;
 c.s = a.c.s;
 c.f = 0;
 a.c.p = 2;
 a.c.s = 1;
 x1 = c.s;
 x2 = c.s;
end StreamTests.StreamN1M1;
")})));
end StreamN1M1;


model StreamN0M2
    model A
        StreamConnector c1;
        StreamConnector c2;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
    equation
        connect(c1, c2);
    end A;
    
    model B
        StreamConnector c3(p = 5, f = 6, s = 3);
        StreamConnector c4(s = 4);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c3);
    connect(a.c2, b.c4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN0M2",
            description="Test stream connectors connected N=0, M=2",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN0M2
 Real a.c1.p;
 Real a.c1.f;
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f;
 Real a.c2.s;
 Real a.x1;
 Real a.x2;
 Real b.c3.p;
 Real b.c3.f;
 Real b.c3.s;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
equation
 a.c1.f + b.c3.f = 0;
 a.c1.p = b.c3.p;
 a.c2.f + b.c4.f = 0;
 a.c2.p = b.c4.p;
 - a.c1.f - a.c2.f = 0;
 a.c1.p = a.c2.p;
 a.c1.s = b.c4.s;
 a.c2.s = b.c3.s;
 a.x1 = b.c3.s;
 a.x2 = b.c4.s;
 b.c3.p = 5;
 b.c3.f = 6;
 b.c3.s = 3;
 b.c4.s = 4;
end StreamTests.StreamN0M2;
")})));
end StreamN0M2;


model StreamN3M0
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f=time));
    A a2(c(s=2, f=time-1));
    A a3(c(s=3));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
    Real x3 = inStream(a3.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, a3.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN3M0",
            description="Test stream connectors connected N=3, M=0",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN3M0
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 Real a3.c.p;
 Real a3.c.f;
 Real a3.c.s;
 Real x1;
 Real x2;
 Real x3;
equation
 a1.c.f + a2.c.f + a3.c.f = 0;
 a1.c.p = a2.c.p;
 a2.c.p = a3.c.p;
 a1.c.p = 4;
 a1.c.f = time;
 a1.c.s = 1;
 a2.c.f = time - 1;
 a2.c.s = 2;
 a3.c.s = 3;
 x1 = (max(- a2.c.f, 1.0E-8) * a2.c.s + max(- a3.c.f, 1.0E-8) * a3.c.s) / (max(- a2.c.f, 1.0E-8) + max(- a3.c.f, 1.0E-8));
 x2 = (max(- a1.c.f, 1.0E-8) * a1.c.s + max(- a3.c.f, 1.0E-8) * a3.c.s) / (max(- a1.c.f, 1.0E-8) + max(- a3.c.f, 1.0E-8));
 x3 = (max(- a1.c.f, 1.0E-8) * a1.c.s + max(- a2.c.f, 1.0E-8) * a2.c.s) / (max(- a1.c.f, 1.0E-8) + max(- a2.c.f, 1.0E-8));
end StreamTests.StreamN3M0;
")})));
end StreamN3M0;


model StreamN2M1
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4));
    A a2(c(s=2));
    StreamConnector c;
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
    Real x3 = inStream(c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="StreamN2M1",
            description="Test stream connectors connected N=2, M=1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN2M1
 Real a1.c.p = 4;
 Real a1.c.f;
 Real a1.c.s = 1;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s = 2;
 Real c.p;
 Real c.f;
 Real c.s;
 Real x1 = inStream(a1.c.s);
 Real x2 = inStream(a2.c.s);
 Real x3 = inStream(c.s);
equation
 a1.c.f + a2.c.f - c.f = 0;
 a1.c.p = a2.c.p;
 a2.c.p = c.p;
 c.s = (max(- a1.c.f, 1.0E-8) * a1.c.s + max(- a2.c.f, 1.0E-8) * a2.c.s) / (max(- a1.c.f, 1.0E-8) + max(- a2.c.f, 1.0E-8));
 c.f = 0;
end StreamTests.StreamN2M1;
")})));
end StreamN2M1;


model StreamN1M2
    model A
        StreamConnector c;
    end A;
    
    A a(c(s=1, p=2));
    StreamConnector c1;
    StreamConnector c2;
    Real x1 = inStream(a.c.s);
    Real x2 = inStream(c1.s);
    Real x3 = inStream(c2.s);
equation
    connect(a.c, c1);
    connect(a.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="StreamN1M2",
            description="Test stream connectors connected N=1, M=2",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN1M2
 Real a.c.p = 2;
 Real a.c.f;
 Real a.c.s = 1;
 Real c1.p;
 Real c1.f;
 Real c1.s;
 Real c2.p;
 Real c2.f;
 Real c2.s;
 Real x1 = inStream(a.c.s);
 Real x2 = inStream(c1.s);
 Real x3 = inStream(c2.s);
equation
 a.c.f - c1.f - c2.f = 0;
 a.c.p = c1.p;
 c1.p = c2.p;
 c1.s = (max(- a.c.f, 1.0E-8) * a.c.s + max(c2.f, 1.0E-8) * inStream(c2.s)) / (max(- a.c.f, 1.0E-8) + max(c2.f, 1.0E-8));
 c2.s = (max(- a.c.f, 1.0E-8) * a.c.s + max(c1.f, 1.0E-8) * inStream(c1.s)) / (max(- a.c.f, 1.0E-8) + max(c1.f, 1.0E-8));
 c1.f = 0;
 c2.f = 0;
end StreamTests.StreamN1M2;
")})));
end StreamN1M2;


model StreamN0M3
    model A
        StreamConnector c1;
        StreamConnector c2;
        StreamConnector c3;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN0M3",
            description="Test stream connectors connected N=0, M=3",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN0M3
 Real a.c1.p;
 Real a.c1.f;
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f;
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f;
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
equation
 a.c1.f + b.c4.f = 0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = (max(a.c2.f, 1.0E-8) * b.c5.s + max(a.c3.f, 1.0E-8) * b.c6.s) / (max(a.c2.f, 1.0E-8) + max(a.c3.f, 1.0E-8));
 a.c2.s = (max(a.c1.f, 1.0E-8) * b.c4.s + max(a.c3.f, 1.0E-8) * b.c6.s) / (max(a.c1.f, 1.0E-8) + max(a.c3.f, 1.0E-8));
 a.c3.s = (max(a.c1.f, 1.0E-8) * b.c4.s + max(a.c2.f, 1.0E-8) * b.c5.s) / (max(a.c1.f, 1.0E-8) + max(a.c2.f, 1.0E-8));
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
end StreamTests.StreamN0M3;
")})));
end StreamN0M3;


model StreamN2M2
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f=time));
    A a2(c(s=2));
    StreamConnector c1;
    StreamConnector c2;
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
    Real x3 = inStream(c1.s);
    Real x4 = inStream(c2.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN2M2",
            description="Test stream connectors connected N=2, M=2",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN2M2
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 Real c1.p;
 Real c1.f;
 Real c1.s;
 Real c2.p;
 Real c2.f;
 Real c2.s;
 Real x1;
 Real x2;
 Real x3;
 Real x4;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = (max(- a1.c.f, 1.0E-8) * a1.c.s + max(- a2.c.f, 1.0E-8) * a2.c.s + max(c2.f, 1.0E-8) * c2.s) / (max(- a1.c.f, 1.0E-8) + max(- a2.c.f, 1.0E-8) + max(c2.f, 1.0E-8));
 c2.s = (max(- a1.c.f, 1.0E-8) * a1.c.s + max(- a2.c.f, 1.0E-8) * a2.c.s + max(c1.f, 1.0E-8) * c1.s) / (max(- a1.c.f, 1.0E-8) + max(- a2.c.f, 1.0E-8) + max(c1.f, 1.0E-8));
 c1.f = 0;
 c2.f = 0;
 a1.c.p = 4;
 a1.c.f = time;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = (max(- a2.c.f, 1.0E-8) * a2.c.s + max(c1.f, 1.0E-8) * c1.s + max(c2.f, 1.0E-8) * c2.s) / (max(- a2.c.f, 1.0E-8) + max(c1.f, 1.0E-8) + max(c2.f, 1.0E-8));
 x2 = (max(- a1.c.f, 1.0E-8) * a1.c.s + max(c1.f, 1.0E-8) * c1.s + max(c2.f, 1.0E-8) * c2.s) / (max(- a1.c.f, 1.0E-8) + max(c1.f, 1.0E-8) + max(c2.f, 1.0E-8));
 x3 = c1.s;
 x4 = c2.s;
end StreamTests.StreamN2M2;
")})));
end StreamN2M2;


model StreamMinMax3
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f(min=1) = time+1));
    A a2(c(s=2, f(min=-1)));
    StreamConnector c1(f(max=-1));
    StreamConnector c2(f(max=1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax3",
            description="Test stream connectors connected N=2, M=2, with min/max limiting which connectors contribute",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax3
 Real a1.c.p;
 Real a1.c.f(min = 1);
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f(min = - 1);
 Real a2.c.s;
 Real c1.p;
 Real c1.f(max = - 1);
 Real c1.s;
 Real c2.p;
 Real c2.f(max = 1);
 Real c2.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = (max(- a2.c.f, 1.0E-8) * a2.c.s + max(c2.f, 1.0E-8) * c2.s) / (max(- a2.c.f, 1.0E-8) + max(c2.f, 1.0E-8));
 c2.s = a2.c.s;
 c1.f = 0;
 c2.f = 0;
 a1.c.p = 4;
 a1.c.f = time + 1;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = (max(- a2.c.f, 1.0E-8) * a2.c.s + max(c2.f, 1.0E-8) * c2.s) / (max(- a2.c.f, 1.0E-8) + max(c2.f, 1.0E-8));
 x2 = c2.s;
end StreamTests.StreamMinMax3;
")})));
end StreamMinMax3;


model StreamMinMax4
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f(min=1) = time+1));
    A a2(c(s=2, f(min=-1)));
    StreamConnector c1(f(max=-1));
    StreamConnector c2(f(max=-1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax4",
            description="Test stream connectors connected N=2, M=2, with min/max limiting which connectors contribute",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax4
 Real a1.c.p;
 Real a1.c.f(min = 1);
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f(min = - 1);
 Real a2.c.s;
 Real c1.p;
 Real c1.f(max = - 1);
 Real c1.s;
 Real c2.p;
 Real c2.f(max = - 1);
 Real c2.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = a2.c.s;
 c2.s = a2.c.s;
 c1.f = 0;
 c2.f = 0;
 a1.c.p = 4;
 a1.c.f = time + 1;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = a2.c.s;
 x2 = a2.c.s;
end StreamTests.StreamMinMax4;
")})));
end StreamMinMax4;


model StreamMinMax5
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f(min=1) = time+1));
    A a2(c(s=2, f(min=1)));
    StreamConnector c1(f(max=-1));
    StreamConnector c2(f(max=1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax5",
            description="Test stream connectors connected N=2, M=2, with min/max limiting which connectors contribute",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax5
 Real a1.c.p;
 Real a1.c.f(min = 1);
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f(min = 1);
 Real a2.c.s;
 Real c1.p;
 Real c1.f(max = - 1);
 Real c1.s;
 Real c2.p;
 Real c2.f(max = 1);
 Real c2.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = c2.s;
 c2.s = 0;
 c1.f = 0;
 c2.f = 0;
 a1.c.p = 4;
 a1.c.f = time + 1;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = c2.s;
 x2 = c2.s;
end StreamTests.StreamMinMax5;
")})));
end StreamMinMax5;


model StreamNominal1
    model A
        StreamConnector c1(f(nominal=0.1));
        StreamConnector c2;
        StreamConnector c3(f(nominal=2));
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamNominal1",
            description="Test affect on inStream() from nomainals on flow vars",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamNominal1
 Real a.c1.p;
 Real a.c1.f(nominal = 0.1);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f;
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
equation
 a.c1.f + b.c4.f = 0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = (max(a.c2.f, 1.0E-9) * b.c5.s + max(a.c3.f, 1.0E-9) * b.c6.s) / (max(a.c2.f, 1.0E-9) + max(a.c3.f, 1.0E-9));
 a.c2.s = (max(a.c1.f, 1.0E-9) * b.c4.s + max(a.c3.f, 1.0E-9) * b.c6.s) / (max(a.c1.f, 1.0E-9) + max(a.c3.f, 1.0E-9));
 a.c3.s = (max(a.c1.f, 1.0E-9) * b.c4.s + max(a.c2.f, 1.0E-9) * b.c5.s) / (max(a.c1.f, 1.0E-9) + max(a.c2.f, 1.0E-9));
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
end StreamTests.StreamNominal1;
")})));
end StreamNominal1;


model StreamNominal2
    model A
        StreamConnector c1(f(nominal=10));
        StreamConnector c2(f(nominal=10));
        StreamConnector c3(f(nominal=2));
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamNominal2",
            description="Test affect on inStream() from nomainals on flow vars",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamNominal2
 Real a.c1.p;
 Real a.c1.f(nominal = 10);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f(nominal = 10);
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
equation
 a.c1.f + b.c4.f = 0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = (max(a.c2.f, 2.0E-8) * b.c5.s + max(a.c3.f, 2.0E-8) * b.c6.s) / (max(a.c2.f, 2.0E-8) + max(a.c3.f, 2.0E-8));
 a.c2.s = (max(a.c1.f, 2.0E-8) * b.c4.s + max(a.c3.f, 2.0E-8) * b.c6.s) / (max(a.c1.f, 2.0E-8) + max(a.c3.f, 2.0E-8));
 a.c3.s = (max(a.c1.f, 2.0E-8) * b.c4.s + max(a.c2.f, 2.0E-8) * b.c5.s) / (max(a.c1.f, 2.0E-8) + max(a.c2.f, 2.0E-8));
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
end StreamTests.StreamNominal2;
")})));
end StreamNominal2;


model StreamAttributesOnType
    connector StreamConnector2 = StreamConnector(f(nominal=2,max=-1));

    model A
        StreamConnector c1(f(nominal=10));
        StreamConnector c2(f(nominal=10));
        StreamConnector2 c3;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamAttributesOnType",
            description="Test that attributes on types affect generation of stream equations",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamAttributesOnType
 Real a.c1.p;
 Real a.c1.f(nominal = 10);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f(nominal = 10);
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2,max = - 1);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
equation
 a.c1.f + b.c4.f = 0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = b.c5.s;
 a.c2.s = b.c4.s;
 a.c3.s = (max(a.c1.f, 2.0E-8) * b.c4.s + max(a.c2.f, 2.0E-8) * b.c5.s) / (max(a.c1.f, 2.0E-8) + max(a.c2.f, 2.0E-8));
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
end StreamTests.StreamAttributesOnType;
")})));
end StreamAttributesOnType;


// TODO: Add error tests (e.g. stream connector without flow)

end StreamTests;
