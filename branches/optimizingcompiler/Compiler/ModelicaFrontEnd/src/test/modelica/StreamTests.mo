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
 Real r.fluidPort.m_flow;
 Real r.fluidPort.h_outflow;
 Real r.fluidPort.p;
 Real h;
equation
 r.fluidPort.p = r.p0;
 r.fluidPort.h_outflow = r.h0;
 r.fluidPort.m_flow = 0;
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
 Real r.fluidPort.m_flow;
 Real r.fluidPort.h_outflow;
 Real r.fluidPort.p;
 Real h;
equation
 r.fluidPort.p = r.p0;
 r.fluidPort.h_outflow = r.h0;
 r.fluidPort.m_flow = 0;
 h = noEvent(if r.fluidPort.m_flow > 0.0 then r.fluidPort.h_outflow else r.fluidPort.h_outflow);
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
 Real r1.fluidPort.m_flow;
 Real r1.fluidPort.h_outflow;
 Real r1.fluidPort.p;
 parameter Real r2.p0 = 1 /* 1 */;
 parameter Real r2.h0 = 1 /* 1 */;
 Real r2.fluidPort.m_flow;
 Real r2.fluidPort.h_outflow;
 Real r2.fluidPort.p;
 Real res.port_a.m_flow;
 Real res.port_a.h_outflow;
 Real res.port_a.p;
 Real res.port_b.m_flow;
 Real res.port_b.h_outflow;
 Real res.port_b.p;
equation
 r1.fluidPort.p = r1.p0;
 r1.fluidPort.h_outflow = r1.h0;
 r2.fluidPort.p = r2.p0;
 r2.fluidPort.h_outflow = r2.h0;
 res.port_a.m_flow = res.port_a.p - res.port_b.p;
 res.port_a.m_flow + res.port_b.m_flow = 0;
 res.port_a.h_outflow = r2.fluidPort.h_outflow;
 res.port_b.h_outflow = r1.fluidPort.h_outflow;
 r1.fluidPort.m_flow + res.port_a.m_flow = 0;
 r1.fluidPort.p = res.port_a.p;
 r2.fluidPort.m_flow + res.port_b.m_flow = 0;
 r2.fluidPort.p = res.port_b.p;
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
 Real r[1].fluidPort.m_flow;
 Real r[1].fluidPort.h_outflow;
 Real r[1].fluidPort.p;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 Real r[2].fluidPort.m_flow;
 Real r[2].fluidPort.h_outflow;
 Real r[2].fluidPort.p;
 Real h[1];
 Real h[2];
equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 r[1].fluidPort.m_flow = 0;
 r[2].fluidPort.m_flow = 0;
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
 Real r[1].fluidPort.m_flow;
 Real r[1].fluidPort.h_outflow;
 Real r[1].fluidPort.p;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 Real r[2].fluidPort.m_flow;
 Real r[2].fluidPort.h_outflow;
 Real r[2].fluidPort.p;
 Real h[1];
 Real h[2];
equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 r[1].fluidPort.m_flow = 0;
 r[2].fluidPort.m_flow = 0;
 h[1] = noEvent(if r[1].fluidPort.m_flow > 0.0 then r[1].fluidPort.h_outflow else r[1].fluidPort.h_outflow);
 h[2] = noEvent(if r[2].fluidPort.m_flow > 0.0 then r[2].fluidPort.h_outflow else r[2].fluidPort.h_outflow);
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
 Real d.a;
 Real d.b[1];
 Real d.b[2];
 Real d.c;
 Real f[1];
 Real f[2];
equation
 f[1] = noEvent(if d.a > 0.0 then d.b[1] else d.b[1]);
 f[2] = noEvent(if d.a > 0.0 then d.b[2] else d.b[2]);
 f[1] = 1;
 f[2] = 2;
 d.c = 0;
 d.a = 0;
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
model StreamComplErr
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
			name="StreamComplErr",
			description="Compliance error for stream connections with more than two connectors",
			errorMessage="
Error: in file 'StreamTests.StreamComplErr.mof':
Compliance error at line 0, column 0:
  Stream connections with more than two connectors are not supported: Connection set (stream): {res1.port_b.h_outflow (i), res2.port_a.h_outflow (i), res3.port_a.h_outflow (i)}
")})));
end StreamComplErr;


end StreamTests;
