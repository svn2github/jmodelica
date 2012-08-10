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
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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


     Reservoir r;
     Real h = inStream(r.fluidPort.h_outflow);
  end StreamTest1;

  model StreamTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 h = noEvent((if r.fluidPort.m_flow > 0.0 then r.fluidPort.h_outflow else r.fluidPort.h_outflow));

end StreamTests.StreamTest2;

")})));

     Reservoir r;
     Real h = actualStream(r.fluidPort.h_outflow);
  end StreamTest2;

  model StreamTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 res.port_a.m_flow = res.port_a.p - ( res.port_b.p );
 res.port_a.m_flow + res.port_b.m_flow = 0;
 res.port_a.h_outflow = r2.fluidPort.h_outflow;
 res.port_b.h_outflow = r1.fluidPort.h_outflow;
 r1.fluidPort.m_flow + res.port_a.m_flow = 0;
 r1.fluidPort.p = res.port_a.p;
 r2.fluidPort.m_flow + res.port_b.m_flow = 0;
 r2.fluidPort.p = res.port_b.p;

end StreamTests.StreamTest3;

")})));


     Reservoir r1;
     Reservoir r2;
     LinearResistance res;
  equation 
     connect(r1.fluidPort,res.port_a);
     connect(r2.fluidPort,res.port_b);
  end StreamTest3;
  
  model StreamTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

     Reservoir r[2];
     Real h[2] = inStream(r.fluidPort.h_outflow);
  end StreamTest4;
	
  model StreamTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 h[1] = noEvent((if r[1].fluidPort.m_flow > 0.0 then r[1].fluidPort.h_outflow else r[1].fluidPort.h_outflow));
 h[2] = noEvent((if r[2].fluidPort.m_flow > 0.0 then r[2].fluidPort.h_outflow else r[2].fluidPort.h_outflow));

end StreamTests.StreamTest5;
")})));

	 Reservoir r[2];
	 Real h[2] = actualStream(r.fluidPort.h_outflow);
  end StreamTest5;
  
  model StreamTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 f[1] = noEvent((if d.a > 0.0 then d.b[1] else d.b[1]));
 f[2] = noEvent((if d.a > 0.0 then d.b[2] else d.b[2]));
 f[1] = 1;
 f[2] = 2;
 d.c = 0;
 d.a = 0;

end StreamTests.StreamTest6;
")})));

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


model StreamComplErr
 // This is actually a compliance error but is kept here in order to avoid copying dependent classes.
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ComplianceErrorTestCase(name="StreamComplErr",
        description="Compliance error for stream connections with more than two connectors",
        errorMessage=
"
Error: in file 'StreamTests.StreamComplErr.mof':
Compliance error at line 0, column 0:
  Stream connections with more than two connectors are not supported: Connection set (stream): {res1.port_b.h_outflow (i), res2.port_a.h_outflow (i), res3.port_a.h_outflow (i)}
")})));

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
end StreamComplErr;

package StreamExample
 import SI = Modelica.SIunits;

 package Examples

   package Interfaces
     connector FlowPort
       flow SI.MassFlowRate m_flow;
       SI.Pressure p(nominal=100000,start=100000);
       stream SI.SpecificEnthalpy h_outflow(nominal=400000, start=400000);
       annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
                 -100},{100,100}}), graphics={Ellipse(
               extent={{-100,100},{100,-100}},
               lineColor={0,0,255},
               fillColor={0,0,127},
               fillPattern=FillPattern.Solid)}));
     end FlowPort;

   end Interfaces;

   package Components
     model MultiPortVolume

       parameter Integer nP=2 "Number of flow ports";
       parameter SI.Volume V;
       parameter SI.Temperature T_start;
       parameter SI.Pressure p_start;
       parameter SI.SpecificHeatCapacity cp;
       parameter SI.SpecificHeatCapacity R;
       Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort(T(start=T_start)) 
         annotation (Placement(transformation(extent={{-100,-10},{-80,10}}),
             iconTransformation(extent={{-100,-10},{-80,10}})));
       Interfaces.FlowPort[nP] flowPort 
         annotation (Placement(transformation(extent={{-22,-20},{18,20}}),
             iconTransformation(extent={{-22,-20},{18,20}})));
       SI.EnthalpyFlowRate[nP] H_flow(each nominal=400000, each start=400000)
          "Enthalpy flow rates";
       SI.MassFlowRate dM "Mass storage";
       SI.EnergyFlowRate dU(nominal=100000, start=100000)
          "Internal energy storage";
       Real du(nominal=100000, start=100000);
       SI.Mass M;
       SI.Temperature T(start=T_start, nominal = 300) "Temperature";
       SI.Pressure p(start = p_start, nominal= 1e5);
       SI.SpecificEnthalpy h(nominal= 400000, start=300000);
       SI.SpecificInternalEnergy u(nominal=250000, start=250000);
       SI.Density rho(nominal=1.0);
       SI.InternalEnergy U(nominal=250000, start=250000);

     equation
        //Energy balance
       dU=sum(H_flow) + heatPort.Q_flow;
       //Mass balance
       dM=sum(flowPort.m_flow);
       dM=(-p/R/T/T*der(T)+1/R/T*der(p))*V;
       M=rho*V;

       U=u*M;
        dU=dM*u+du*M;
       du=(cp-R)*der(T);
       u=h-R*T;
       h=cp*T;
       p=rho*R*T;

       for i in 1:nP loop
       H_flow[i]=flowPort[i].m_flow*actualStream(flowPort[i].h_outflow);
       //Port properties
       flowPort[i].p=p;
       flowPort[i].h_outflow=h;
       end for;

       //Heat transfer
       heatPort.T=T;
     initial equation
         p=p_start;
         T=T_start;
       annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}), graphics={Ellipse(
               extent={{-80,80},{80,-80}},
               lineColor={170,213,255},
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
               preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
             graphics));
     end MultiPortVolume;

     model FlowSource
          parameter SI.MassFlowRate mflow0;
         parameter SI.Temperature T0;
         parameter SI.SpecificHeatCapacity cp;
          SI.SpecificEnthalpy h(nominal= 400000);
       Interfaces.FlowPort flowPort 
         annotation (Placement(transformation(extent={{60,-20},{100,20}}),
             iconTransformation(extent={{60,-20},{100,20}})));

     equation
       h=cp*T0;
       flowPort.m_flow=-mflow0;
       flowPort.h_outflow=h;
       annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}), graphics={Rectangle(
               extent={{-80,80},{80,-80}},
               lineColor={170,213,255},
               fillColor={170,213,255},
               fillPattern=FillPattern.Solid), Polygon(
               points={{-36,48},{-36,-50},{48,2},{-36,48}},
               lineColor={85,170,255},
               smooth=Smooth.None,
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
               preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
             graphics));
     end FlowSource;

     model Reservoir
         parameter SI.Pressure p0;
         parameter SI.Temperature T0;
         parameter SI.SpecificHeatCapacity cp;
      parameter SI.SpecificEnthalpy h0=cp*T0;
       Interfaces.FlowPort flowPort 
         annotation (Placement(transformation(extent={{60,-20},{100,20}}),
             iconTransformation(extent={{60,-20},{100,20}})));

     equation
       flowPort.p=p0;
       flowPort.h_outflow=h0;
       annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}), graphics={Rectangle(
               extent={{-80,80},{80,-80}},
               lineColor={170,213,255},
               fillColor={170,213,255},
               fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
               preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
             graphics));
     end Reservoir;

     model LinearResistance
        Interfaces.FlowPort port_a 
         annotation (Placement(transformation(extent={{-100,-20},{-60,20}})));
       Interfaces.FlowPort port_b 
         annotation (Placement(transformation(extent={{60,-20},{100,20}})));

       Modelica.Blocks.Interfaces.RealInput u(start=1) annotation (Placement(transformation(
               extent={{-22,44},{18,84}}), iconTransformation(
             extent={{20,-20},{-20,20}},
             rotation=90,
             origin={0,20})));
     equation
       port_a.m_flow=(port_a.p-port_b.p)/u;
       port_a.m_flow+port_b.m_flow=0;
       port_a.h_outflow=inStream(port_b.h_outflow);
       port_b.h_outflow=inStream(port_a.h_outflow);

       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}),
                              graphics), Icon(coordinateSystem(preserveAspectRatio=true,
               extent={{-100,-100},{100,100}}), graphics={Polygon(
               points={{-80,60},{-80,-60},{0,0},{80,-60},{80,60},{0,0},{-80,60}},
               lineColor={85,170,255},
               smooth=Smooth.None,
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}));
     end LinearResistance;

     model LinearResistanceWrap
        Interfaces.FlowPort port_a 
         annotation (Placement(transformation(extent={{-100,-20},{-60,20}})));
       Interfaces.FlowPort port_b 
         annotation (Placement(transformation(extent={{60,-20},{100,20}})));
       Modelica.Blocks.Interfaces.RealInput u annotation (Placement(transformation(
               extent={{-20,44},{20,84}}), iconTransformation(
             extent={{20,-20},{-20,20}},
             rotation=90,
             origin={0,20})));
       LinearResistance linearResistance 
         annotation (Placement(transformation(extent={{-2,-10},{18,10}})));
     equation
       connect(linearResistance.port_b, port_b) annotation (Line(
           points={{16,0},{80,0}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.port_a, port_a) annotation (Line(
           points={{0,0},{-80,0}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.u, u) annotation (Line(
           points={{8,2},{8,64},{0,64}},
           color={0,0,127},
           smooth=Smooth.None));
       annotation (Icon(graphics={                        Polygon(
               points={{-80,60},{-80,-60},{0,0},{80,-60},{80,60},{0,0},{-80,60}},
               lineColor={85,170,255},
               smooth=Smooth.None,
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}), Diagram(graphics));
     end LinearResistanceWrap;
   end Components;

   package Systems
     model HeatedGas
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="StreamExample_Examples_Systems_HeatedGas",
         description="Test of stream connectors",
         eliminate_alias_variables=false,
         flatModel="
fclass StreamTests.StreamExample.Examples.Systems.HeatedGas
 parameter Modelica.SIunits.SpecificHeatCapacity R_gas = ( 8.314472 ) / ( 0.0289651159 ) /* 287.0512249529787 */;
 parameter Modelica.SIunits.SpecificHeatCapacity cp = 1000 /* 1000 */;
 parameter Modelica.SIunits.MassFlowRate flowSource.mflow0 = 1 /* 1 */;
 parameter Modelica.SIunits.Temperature flowSource.T0 = 303.15 /* 303.15 */;
 parameter Modelica.SIunits.SpecificHeatCapacity flowSource.cp;
 Modelica.SIunits.SpecificEnthalpy flowSource.h(nominal = 400000);
 Modelica.SIunits.MassFlowRate flowSource.flowPort.m_flow;
 Modelica.SIunits.Pressure flowSource.flowPort.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy flowSource.flowPort.h_outflow(nominal = 400000,start = 400000);
 parameter Integer multiPortVolume.nP = 2 \"Number of flow ports\" /* 2 */;
 parameter Modelica.SIunits.Volume multiPortVolume.V = 1 /* 1 */;
 parameter Modelica.SIunits.Temperature multiPortVolume.T_start = 303.15 /* 303.15 */;
 parameter Modelica.SIunits.Pressure multiPortVolume.p_start = 100000 /* 100000 */;
 parameter Modelica.SIunits.SpecificHeatCapacity multiPortVolume.cp;
 parameter Modelica.SIunits.SpecificHeatCapacity multiPortVolume.R;
 Modelica.SIunits.Temperature multiPortVolume.heatPort.T(start = multiPortVolume.T_start) \"Port temperature\";
 Modelica.SIunits.HeatFlowRate multiPortVolume.heatPort.Q_flow \"Heat flow rate (positive if flowing from outside into the component)\";
 Modelica.SIunits.MassFlowRate multiPortVolume.flowPort[1].m_flow;
 Modelica.SIunits.Pressure multiPortVolume.flowPort[1].p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy multiPortVolume.flowPort[1].h_outflow(nominal = 400000,start = 400000);
 Modelica.SIunits.MassFlowRate multiPortVolume.flowPort[2].m_flow;
 Modelica.SIunits.Pressure multiPortVolume.flowPort[2].p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy multiPortVolume.flowPort[2].h_outflow(nominal = 400000,start = 400000);
 Modelica.SIunits.EnthalpyFlowRate multiPortVolume.H_flow[1](nominal = 400000,start = 400000) \"Enthalpy flow rates\";
 Modelica.SIunits.EnthalpyFlowRate multiPortVolume.H_flow[2](nominal = 400000,start = 400000) \"Enthalpy flow rates\";
 Modelica.SIunits.MassFlowRate multiPortVolume.dM \"Mass storage\";
 Modelica.SIunits.EnergyFlowRate multiPortVolume.dU(nominal = 100000,start = 100000) \"Internal energy storage\";
 Real multiPortVolume.du(nominal = 100000,start = 100000);
 Modelica.SIunits.Mass multiPortVolume.M;
 Modelica.SIunits.Temperature multiPortVolume.T(start = multiPortVolume.T_start,nominal = 300) \"Temperature\";
 Modelica.SIunits.Pressure multiPortVolume.p(start = multiPortVolume.p_start,nominal = 100000.0);
 Modelica.SIunits.SpecificEnthalpy multiPortVolume.h(nominal = 400000,start = 300000);
 Modelica.SIunits.SpecificInternalEnergy multiPortVolume.u(nominal = 250000,start = 250000);
 Modelica.SIunits.Density multiPortVolume.rho(nominal = 1.0);
 Modelica.SIunits.InternalEnergy multiPortVolume.U(nominal = 250000,start = 250000);
 parameter Modelica.SIunits.HeatFlowRate heatSource.Q_flow = 100000 \"Fixed heat flow rate at port\" /* 100000 */;
 parameter Modelica.SIunits.Temperature heatSource.T_ref = 373.15 \"Reference temperature\" /* 373.15 */;
 parameter Modelica.SIunits.LinearTemperatureCoefficient heatSource.alpha = 0 \"Temperature coefficient of heat flow rate\" /* 0 */;
 Modelica.SIunits.Temperature heatSource.port.T \"Port temperature\";
 Modelica.SIunits.HeatFlowRate heatSource.port.Q_flow \"Heat flow rate (positive if flowing from outside into the component)\";
 Modelica.SIunits.MassFlowRate linearResistance.port_a.m_flow;
 Modelica.SIunits.Pressure linearResistance.port_a.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy linearResistance.port_a.h_outflow(nominal = 400000,start = 400000);
 Modelica.SIunits.MassFlowRate linearResistance.port_b.m_flow;
 Modelica.SIunits.Pressure linearResistance.port_b.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy linearResistance.port_b.h_outflow(nominal = 400000,start = 400000);
 Modelica.Blocks.Interfaces.RealInput linearResistance.u(start = 1);
 parameter Modelica.SIunits.Pressure reservoir.p0 = 100000 /* 100000 */;
 parameter Modelica.SIunits.Temperature reservoir.T0 = 303.15 /* 303.15 */;
 parameter Modelica.SIunits.SpecificHeatCapacity reservoir.cp;
 parameter Modelica.SIunits.SpecificEnthalpy reservoir.h0;
 Modelica.SIunits.MassFlowRate reservoir.flowPort.m_flow;
 Modelica.SIunits.Pressure reservoir.flowPort.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy reservoir.flowPort.h_outflow(nominal = 400000,start = 400000);
 parameter Real ramp.height = 10000.0 \"Height of ramps\" /* 10000.0 */;
 parameter Modelica.SIunits.Time ramp.duration(min = 1.0E-60,start = 2) = 1 \"Durations of ramp\" /* 1 */;
 parameter Real ramp.offset = 10000.0 \"Offset of output signal\" /* 10000.0 */;
 parameter Modelica.SIunits.Time ramp.startTime = 5 \"Output = offset for time < startTime\" /* 5 */;
 Modelica.Blocks.Interfaces.RealOutput ramp.y \"Connector of Real output signal\";
initial equation 
 multiPortVolume.p = multiPortVolume.p_start;
 multiPortVolume.T = multiPortVolume.T_start;
parameter equation
 flowSource.cp = cp;
 multiPortVolume.cp = cp;
 multiPortVolume.R = R_gas;
 reservoir.cp = cp;
 reservoir.h0 = ( reservoir.cp ) * ( reservoir.T0 );
equation
 flowSource.h = ( flowSource.cp ) * ( flowSource.T0 );
 flowSource.flowPort.m_flow =  - ( flowSource.mflow0 );
 flowSource.flowPort.h_outflow = flowSource.h;
 multiPortVolume.dU = multiPortVolume.H_flow[1] + multiPortVolume.H_flow[2] + multiPortVolume.heatPort.Q_flow;
 multiPortVolume.dM = multiPortVolume.flowPort[1].m_flow + multiPortVolume.flowPort[2].m_flow;
 multiPortVolume.dM = ( ( ( ( (  - ( multiPortVolume.p ) ) / ( multiPortVolume.R ) ) / ( multiPortVolume.T ) ) / ( multiPortVolume.T ) ) * ( multiPortVolume.der(T) ) + ( ( ( 1 ) / ( multiPortVolume.R ) ) / ( multiPortVolume.T ) ) * ( multiPortVolume.der(p) ) ) * ( multiPortVolume.V );
 multiPortVolume.M = ( multiPortVolume.rho ) * ( multiPortVolume.V );
 multiPortVolume.U = ( multiPortVolume.u ) * ( multiPortVolume.M );
 multiPortVolume.dU = ( multiPortVolume.dM ) * ( multiPortVolume.u ) + ( multiPortVolume.du ) * ( multiPortVolume.M );
 multiPortVolume.du = ( multiPortVolume.cp - ( multiPortVolume.R ) ) * ( multiPortVolume.der(T) );
 multiPortVolume.u = multiPortVolume.h - ( ( multiPortVolume.R ) * ( multiPortVolume.T ) );
 multiPortVolume.h = ( multiPortVolume.cp ) * ( multiPortVolume.T );
 multiPortVolume.p = ( ( multiPortVolume.rho ) * ( multiPortVolume.R ) ) * ( multiPortVolume.T );
 multiPortVolume.H_flow[1] = ( multiPortVolume.flowPort[1].m_flow ) * ( noEvent((if multiPortVolume.flowPort[1].m_flow > 0.0 then flowSource.flowPort.h_outflow else multiPortVolume.flowPort[1].h_outflow)) );
 multiPortVolume.flowPort[1].p = multiPortVolume.p;
 multiPortVolume.flowPort[1].h_outflow = multiPortVolume.h;
 multiPortVolume.H_flow[2] = ( multiPortVolume.flowPort[2].m_flow ) * ( noEvent((if multiPortVolume.flowPort[2].m_flow > 0.0 then linearResistance.port_a.h_outflow else multiPortVolume.flowPort[2].h_outflow)) );
 multiPortVolume.flowPort[2].p = multiPortVolume.p;
 multiPortVolume.flowPort[2].h_outflow = multiPortVolume.h;
 multiPortVolume.heatPort.T = multiPortVolume.T;
 heatSource.port.Q_flow = (  - ( heatSource.Q_flow ) ) * ( 1 + ( heatSource.alpha ) * ( heatSource.port.T - ( heatSource.T_ref ) ) );
 linearResistance.port_a.m_flow = ( linearResistance.port_a.p - ( linearResistance.port_b.p ) ) / ( linearResistance.u );
 linearResistance.port_a.m_flow + linearResistance.port_b.m_flow = 0;
 linearResistance.port_a.h_outflow = reservoir.flowPort.h_outflow;
 linearResistance.port_b.h_outflow = multiPortVolume.flowPort[2].h_outflow;
 reservoir.flowPort.p = reservoir.p0;
 reservoir.flowPort.h_outflow = reservoir.h0;
 ramp.y = ramp.offset + (if time < ramp.startTime then 0 elseif time < ramp.startTime + ramp.duration then ( ( time - ( ramp.startTime ) ) * ( ramp.height ) ) / ( ramp.duration ) else ramp.height);
 heatSource.port.Q_flow + multiPortVolume.heatPort.Q_flow = 0;
 heatSource.port.T = multiPortVolume.heatPort.T;
 flowSource.flowPort.m_flow + multiPortVolume.flowPort[1].m_flow = 0;
 flowSource.flowPort.p = multiPortVolume.flowPort[1].p;
 linearResistance.port_b.m_flow + reservoir.flowPort.m_flow = 0;
 linearResistance.port_b.p = reservoir.flowPort.p;
 linearResistance.port_a.m_flow + multiPortVolume.flowPort[2].m_flow = 0;
 linearResistance.port_a.p = multiPortVolume.flowPort[2].p;
 linearResistance.u = ramp.y;

public
 type Modelica.SIunits.SpecificHeatCapacity = Real(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 type Modelica.SIunits.MassFlowRate = Real(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 type Modelica.SIunits.Temperature = Real(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\");
 type Modelica.SIunits.SpecificEnthalpy = Real(final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 type Modelica.SIunits.Pressure = Real(final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 type Modelica.SIunits.Volume = Real(final quantity = \"Volume\",final unit = \"m3\");
 type Modelica.SIunits.HeatFlowRate = Real(final quantity = \"Power\",final unit = \"W\");
 type Modelica.SIunits.EnthalpyFlowRate = Real(final quantity = \"EnthalpyFlowRate\",final unit = \"W\");
 type Modelica.SIunits.EnergyFlowRate = Real(final quantity = \"Power\",final unit = \"W\");
 type Modelica.SIunits.Mass = Real(quantity = \"Mass\",final unit = \"kg\",min = 0);
 type Modelica.SIunits.SpecificInternalEnergy = Real(final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 type Modelica.SIunits.Density = Real(final quantity = \"Density\",final unit = \"kg/m3\",displayUnit = \"g/cm3\",min = 0);
 type Modelica.SIunits.InternalEnergy = Real(final quantity = \"Energy\",final unit = \"J\");
 type Modelica.SIunits.LinearTemperatureCoefficient = Real(final quantity = \"LinearTemperatureCoefficient\",final unit = \"1/K\");
 type Modelica.Blocks.Interfaces.RealInput = Real;
 type Modelica.SIunits.Time = Real(final quantity = \"Time\",final unit = \"s\");
 type Modelica.Blocks.Interfaces.RealOutput = Real;
end StreamTests.StreamExample.Examples.Systems.HeatedGas;
")})));

       parameter SI.SpecificHeatCapacity R_gas=Modelica.Constants.R/0.0289651159;
       parameter SI.SpecificHeatCapacity cp=1000;
       StreamExample.Examples.Components.FlowSource flowSource(
          mflow0=1,
         cp=cp,
         T0=303.15) 
         annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
       StreamExample.Examples.Components.MultiPortVolume multiPortVolume(
         V=1,
         nP=2,
         cp=cp,
         R=R_gas,
          T_start=303.15,
          p_start=100000) 
         annotation (Placement(transformation(extent={{0,0},{-20,20}})));
       Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow heatSource(Q_flow=
             100000, T_ref=373.15) 
         annotation (Placement(transformation(extent={{42,-2},{22,18}})));
       Components.LinearResistance linearResistance annotation (Placement(
             transformation(
             extent={{10,-10},{-10,10}},
             rotation=-90,
             origin={-6,36})));
       Components.Reservoir reservoir(
         p0=100000,
         T0=303.15,
         cp=cp) 
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
       Modelica.Blocks.Sources.Ramp ramp(
         offset=1e4,
         duration=1,
         startTime=5,
         height=1e4) 
         annotation (Placement(transformation(extent={{36,34},{16,54}})));

     equation
       connect(multiPortVolume.heatPort, heatSource.port) annotation (Line(
           points={{-1,10},{10,10},{10,8},{22,8}},
           color={191,0,0},
           smooth=Smooth.None));
       connect(flowSource.flowPort, multiPortVolume.flowPort[1]) annotation (
           Line(
           points={{-42,10},{-25.9,10},{-25.9,9},{-9.8,9}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(reservoir.flowPort, linearResistance.port_b) annotation (Line(
           points={{-32,54},{-14,54},{-14,56},{-6,56},{-6,44}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.port_a, multiPortVolume.flowPort[2]) 
         annotation (Line(
           points={{-6,28},{-8,28},{-8,11},{-9.8,11}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.u, ramp.y) annotation (Line(
           points={{-4,36},{6,36},{6,44},{15,44}},
           color={0,0,127},
           smooth=Smooth.None));
       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                  -100},{100,100}}),     graphics));
     end HeatedGas;

     model HeatedGas_Simple
       parameter SI.SpecificHeatCapacity R_gas=Modelica.Constants.R/0.0289651159;
       parameter SI.SpecificHeatCapacity cp=1000;
       StreamExample.Examples.Components.FlowSource flowSource(
          mflow0=1,
         cp=cp,
         T0=303.15,flowPort(p(start=1e5))) 
         annotation (Placement(transformation(extent={{-42,0},{-22,20}})));
       Components.LinearResistance linearResistance(u(start=1)) annotation (Placement(
             transformation(
             extent={{10,-10},{-10,10}},
             rotation=-90,
             origin={-6,36})));
       Components.Reservoir reservoir(
         p0=100000,
         T0=303.15,
         cp=cp) 
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
       Modelica.Blocks.Sources.Ramp ramp(
         offset=1e4,
         duration=1,
         startTime=5,
         height=1e4) 
         annotation (Placement(transformation(extent={{36,34},{16,54}})));

     equation
       connect(reservoir.flowPort, linearResistance.port_b) annotation (Line(
           points={{-32,54},{-14,54},{-14,56},{-6,56},{-6,44}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.u, ramp.y) annotation (Line(
           points={{-4,36},{6,36},{6,44},{15,44}},
           color={0,0,127},
           smooth=Smooth.None));
       connect(flowSource.flowPort, linearResistance.port_a) annotation (Line(
           points={{-24,10},{-6,10},{-6,28}},
           color={0,0,255},
           smooth=Smooth.None));
       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}),      graphics));
     end HeatedGas_Simple;

     model HeatedGas_SimpleWrap
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="StreamExample_Examples_Systems_HeatedGas_SimpleWrap",
         description="Test of inside and outside stream connectors",
         eliminate_alias_variables=false,
         flatModel="
fclass StreamTests.StreamExample.Examples.Systems.HeatedGas_SimpleWrap
 parameter Modelica.SIunits.SpecificHeatCapacity R_gas = ( 8.314472 ) / ( 0.0289651159 ) /* 287.0512249529787 */;
 parameter Modelica.SIunits.SpecificHeatCapacity cp = 1000 /* 1000 */;
 parameter Modelica.SIunits.MassFlowRate flowSource.mflow0 = 1 /* 1 */;
 parameter Modelica.SIunits.Temperature flowSource.T0 = 303.15 /* 303.15 */;
 parameter Modelica.SIunits.SpecificHeatCapacity flowSource.cp;
 Modelica.SIunits.SpecificEnthalpy flowSource.h(nominal = 400000);
 Modelica.SIunits.MassFlowRate flowSource.flowPort.m_flow;
 Modelica.SIunits.Pressure flowSource.flowPort.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy flowSource.flowPort.h_outflow(nominal = 400000,start = 400000);
 parameter Modelica.SIunits.Pressure reservoir.p0 = 100000 /* 100000 */;
 parameter Modelica.SIunits.Temperature reservoir.T0 = 303.15 /* 303.15 */;
 parameter Modelica.SIunits.SpecificHeatCapacity reservoir.cp;
 parameter Modelica.SIunits.SpecificEnthalpy reservoir.h0;
 Modelica.SIunits.MassFlowRate reservoir.flowPort.m_flow;
 Modelica.SIunits.Pressure reservoir.flowPort.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy reservoir.flowPort.h_outflow(nominal = 400000,start = 400000);
 parameter Real ramp.height = 10000.0 \"Height of ramps\" /* 10000.0 */;
 parameter Modelica.SIunits.Time ramp.duration(min = 1.0E-60,start = 2) = 1 \"Durations of ramp\" /* 1 */;
 parameter Real ramp.offset = 10000.0 \"Offset of output signal\" /* 10000.0 */;
 parameter Modelica.SIunits.Time ramp.startTime = 5 \"Output = offset for time < startTime\" /* 5 */;
 Modelica.Blocks.Interfaces.RealOutput ramp.y \"Connector of Real output signal\";
 Modelica.SIunits.MassFlowRate linearResistanceWrap.port_a.m_flow;
 Modelica.SIunits.Pressure linearResistanceWrap.port_a.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy linearResistanceWrap.port_a.h_outflow(nominal = 400000,start = 400000);
 Modelica.SIunits.MassFlowRate linearResistanceWrap.port_b.m_flow;
 Modelica.SIunits.Pressure linearResistanceWrap.port_b.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy linearResistanceWrap.port_b.h_outflow(nominal = 400000,start = 400000);
 Modelica.Blocks.Interfaces.RealInput linearResistanceWrap.u;
 Modelica.SIunits.MassFlowRate linearResistanceWrap.linearResistance.port_a.m_flow;
 Modelica.SIunits.Pressure linearResistanceWrap.linearResistance.port_a.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy linearResistanceWrap.linearResistance.port_a.h_outflow(nominal = 400000,start = 400000);
 Modelica.SIunits.MassFlowRate linearResistanceWrap.linearResistance.port_b.m_flow;
 Modelica.SIunits.Pressure linearResistanceWrap.linearResistance.port_b.p(nominal = 100000,start = 100000);
 Modelica.SIunits.SpecificEnthalpy linearResistanceWrap.linearResistance.port_b.h_outflow(nominal = 400000,start = 400000);
 Modelica.Blocks.Interfaces.RealInput linearResistanceWrap.linearResistance.u(start = 1);
parameter equation
 flowSource.cp = cp;
 reservoir.cp = cp;
 reservoir.h0 = ( reservoir.cp ) * ( reservoir.T0 );
equation
 flowSource.h = ( flowSource.cp ) * ( flowSource.T0 );
 flowSource.flowPort.m_flow =  - ( flowSource.mflow0 );
 flowSource.flowPort.h_outflow = flowSource.h;
 reservoir.flowPort.p = reservoir.p0;
 reservoir.flowPort.h_outflow = reservoir.h0;
 ramp.y = ramp.offset + (if time < ramp.startTime then 0 elseif time < ramp.startTime + ramp.duration then ( ( time - ( ramp.startTime ) ) * ( ramp.height ) ) / ( ramp.duration ) else ramp.height);
 linearResistanceWrap.linearResistance.port_a.m_flow = ( linearResistanceWrap.linearResistance.port_a.p - ( linearResistanceWrap.linearResistance.port_b.p ) ) / ( linearResistanceWrap.linearResistance.u );
 linearResistanceWrap.linearResistance.port_a.m_flow + linearResistanceWrap.linearResistance.port_b.m_flow = 0;
 linearResistanceWrap.linearResistance.port_a.h_outflow = reservoir.flowPort.h_outflow;
 linearResistanceWrap.linearResistance.port_b.h_outflow = flowSource.flowPort.h_outflow;
 linearResistanceWrap.u = ramp.y;
 linearResistanceWrap.port_b.m_flow + reservoir.flowPort.m_flow = 0;
 linearResistanceWrap.port_b.p = reservoir.flowPort.p;
 flowSource.flowPort.m_flow + linearResistanceWrap.port_a.m_flow = 0;
 flowSource.flowPort.p = linearResistanceWrap.port_a.p;
 linearResistanceWrap.linearResistance.port_b.h_outflow = linearResistanceWrap.port_b.h_outflow;
 linearResistanceWrap.linearResistance.port_b.m_flow - ( linearResistanceWrap.port_b.m_flow ) = 0;
 linearResistanceWrap.linearResistance.port_b.p = linearResistanceWrap.port_b.p;
 linearResistanceWrap.linearResistance.port_a.h_outflow = linearResistanceWrap.port_a.h_outflow;
 linearResistanceWrap.linearResistance.port_a.m_flow - ( linearResistanceWrap.port_a.m_flow ) = 0;
 linearResistanceWrap.linearResistance.port_a.p = linearResistanceWrap.port_a.p;
 linearResistanceWrap.linearResistance.u = linearResistanceWrap.u;

public
 type Modelica.SIunits.SpecificHeatCapacity = Real(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 type Modelica.SIunits.MassFlowRate = Real(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 type Modelica.SIunits.Temperature = Real(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\");
 type Modelica.SIunits.SpecificEnthalpy = Real(final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 type Modelica.SIunits.Pressure = Real(final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 type Modelica.SIunits.Time = Real(final quantity = \"Time\",final unit = \"s\");
 type Modelica.Blocks.Interfaces.RealOutput = Real;
 type Modelica.Blocks.Interfaces.RealInput = Real;
end StreamTests.StreamExample.Examples.Systems.HeatedGas_SimpleWrap;
")})));

       parameter SI.SpecificHeatCapacity R_gas=Modelica.Constants.R/0.0289651159;
       parameter SI.SpecificHeatCapacity cp=1000;
       StreamExample.Examples.Components.FlowSource flowSource(
          mflow0=1,
         cp=cp,
         T0=303.15) 
         annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
       Components.Reservoir reservoir(
         p0=100000,
         T0=303.15,
         cp=cp) 
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
       Modelica.Blocks.Sources.Ramp ramp(
         offset=1e4,
         duration=1,
         startTime=5,
         height=1e4) 
         annotation (Placement(transformation(extent={{36,34},{16,54}})));

       Components.LinearResistanceWrap linearResistanceWrap annotation (
           Placement(transformation(
             extent={{10,-10},{-10,10}},
             rotation=270,
             origin={-6,32})));
     equation
       connect(linearResistanceWrap.u, ramp.y) annotation (Line(
           points={{-4,32},{6,32},{6,44},{15,44}},
           color={0,0,127},
           smooth=Smooth.None));
       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                  -100},{100,100}}),     graphics));
        connect(reservoir.flowPort, linearResistanceWrap.port_b) annotation (
            Line(
            points={{-32,54},{-6,54},{-6,40}},
            color={0,0,255},
            smooth=Smooth.None));
        connect(flowSource.flowPort, linearResistanceWrap.port_a) annotation (
            Line(
            points={{-32,10},{-6,10},{-6,24}},
            color={0,0,255},
            smooth=Smooth.None));
     end HeatedGas_SimpleWrap;
   end Systems;
 end Examples;

 annotation (uses(Modelica(version="3.1")));
end StreamExample;


end StreamTests;
