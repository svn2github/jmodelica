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


// This is actually a compliance error but is kept here in order to avoid copying dependent classes.
model StreamComplErr1
Reservoir r1;
Reservoir r2;
Reservoir r3;

LinearResistance res1;
LinearResistance res2;
LinearResistance res3;

equation 
connect(r1.fluidPort,res1.port_a);
connect(res1.port_b,res2.port_a);
connect(res1.port_b,res3.port_a);
connect(res2.port_b,r2.fluidPort);
connect(res3.port_b,r3.fluidPort);

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="StreamComplErr1",
			description="Compliance error for stream connections with more than two connectors",
			errorMessage="
Error: in file 'StreamTests.StreamComplErr1.mof':
Compliance error at line 0, column 0:
  Stream connections with more than two connectors are not supported: Connection set (stream): {res1.port_b.h_outflow (i), res2.port_a.h_outflow (i), res3.port_a.h_outflow (i)}
")})));
end StreamComplErr1;


model StreamComplErr2
	model A
		FluidPort p(h_outflow(start = 1));
		Real x, y, z;
	equation
		x = y + 1 - z;
		y = x + inStream(p.h_outflow) + 1;
		x = 1*y + z;
		p.p = time;
		inStream(p.h_outflow) = p.p + 3;
	end A;
	
	FluidPort p1, p2;
	A a;
equation
	connect(p1, p2);
	connect(p1, a.p);
	p1.h_outflow = 1 / time;
	p2.h_outflow = 1 - 1/time;

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="StreamComplErr2",
			description="Too many stream connectors in set, with inStream() used in linear equation system",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/StreamTests.mo':
Compliance error at line 0, column 0:
  Stream connections with more than two connectors are not supported: Connection set (stream): {a.p.h_outflow (i), p1.h_outflow (o), p2.h_outflow (o)}

")})));
end StreamComplErr2;

    
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


end StreamTests;
