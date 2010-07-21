within ;
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
     replaceable package Fluid =StreamExample.Fluids.Gases.IdealGasXY;
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
         name="HeatedGas",
         description="Test of stream connectors.",
         eliminate_alias_variables=false,
         flatModel="
fclass StreamExample.Examples.Systems.HeatedGas
 parameter Real R_gas(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\") = ( 8.314472 ) / ( 0.0289651159 ) /* 287.0512249529787 */;
 parameter Real cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\") = 1000 /* 1000.0 */;
 parameter Real flowSource.mflow0(quantity = \"MassFlowRate\",final unit = \"kg/s\") = 1 /* 1.0 */;
 parameter Real flowSource.T0(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") = 303.15 /* 303.15 */;
 parameter Real flowSource.cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 Real flowSource.h(nominal = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real flowSource.flowPort.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real flowSource.flowPort.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real flowSource.flowPort.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 parameter Integer multiPortVolume.nP = 2 \"Number of flow ports\" /* 2 */;
 parameter Real multiPortVolume.V(final quantity = \"Volume\",final unit = \"m3\") = 1 /* 1.0 */;
 parameter Real multiPortVolume.T_start(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") = 303.15 /* 303.15 */;
 parameter Real multiPortVolume.p_start(final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\") = 100000 /* 100000.0 */;
 parameter Real multiPortVolume.cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 parameter Real multiPortVolume.R(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 Real multiPortVolume.heatPort.T(start = multiPortVolume.T_start,final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") \"Port temperature\";
 Real multiPortVolume.heatPort.Q_flow(final quantity = \"Power\",final unit = \"W\") \"Heat flow rate (positive if flowing from outside into the component)\";
 Real multiPortVolume.flowPort[1].m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real multiPortVolume.flowPort[1].p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real multiPortVolume.flowPort[1].h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real multiPortVolume.flowPort[2].m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real multiPortVolume.flowPort[2].p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real multiPortVolume.flowPort[2].h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real multiPortVolume.H_flow[1](nominal = 400000,start = 400000,final quantity = \"EnthalpyFlowRate\",final unit = \"W\") \"Enthalpy flow rates\";
 Real multiPortVolume.H_flow[2](nominal = 400000,start = 400000,final quantity = \"EnthalpyFlowRate\",final unit = \"W\") \"Enthalpy flow rates\";
 Real multiPortVolume.dM(quantity = \"MassFlowRate\",final unit = \"kg/s\") \"Mass storage\";
 Real multiPortVolume.dU(nominal = 100000,start = 100000,final quantity = \"Power\",final unit = \"W\") \"Internal energy storage\";
 Real multiPortVolume.du(nominal = 100000,start = 100000);
 Real multiPortVolume.M(quantity = \"Mass\",final unit = \"kg\",min = 0);
 Real multiPortVolume.T(start = multiPortVolume.T_start,nominal = 300,final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") \"Temperature\";
 Real multiPortVolume.p(start = multiPortVolume.p_start,nominal = 1e5,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real multiPortVolume.h(nominal = 400000,start = 300000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real multiPortVolume.u(nominal = 250000,start = 250000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real multiPortVolume.rho(nominal = 1.0,final quantity = \"Density\",final unit = \"kg/m3\",displayUnit = \"g/cm3\",min = 0);
 Real multiPortVolume.U(nominal = 250000,start = 250000,final quantity = \"Energy\",final unit = \"J\");
 parameter Real heatSource.Q_flow(final quantity = \"Power\",final unit = \"W\") = 100000 \"Fixed heat flow rate at port\" /* 100000.0 */;
 parameter Real heatSource.T_ref(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") = 373.15 \"Reference temperature\" /* 373.15 */;
 parameter Real heatSource.alpha(final quantity = \"LinearTemperatureCoefficient\",final unit = \"1/K\") = 0 \"Temperature coefficient of heat flow rate\" /* 0.0 */;
 Real heatSource.port.T(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") \"Port temperature\";
 Real heatSource.port.Q_flow(final quantity = \"Power\",final unit = \"W\") \"Heat flow rate (positive if flowing from outside into the component)\";
 Real linearResistance.port_a.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real linearResistance.port_a.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real linearResistance.port_a.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real linearResistance.port_b.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real linearResistance.port_b.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real linearResistance.port_b.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real linearResistance.u(start = 1);
 parameter Real reservoir.p0(final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\") = 100000 /* 100000.0 */;
 parameter Real reservoir.T0(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") = 303.15 /* 303.15 */;
 parameter Real reservoir.cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 parameter Real reservoir.h0(final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real reservoir.flowPort.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real reservoir.flowPort.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real reservoir.flowPort.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 parameter Real ramp.height = 1e4 \"Height of ramps\" /* 10000.0 */;
 parameter Real ramp.duration(min = 1.0E-60,start = 2,final quantity = \"Time\",final unit = \"s\") = 1 \"Durations of ramp\" /* 1.0 */;
 parameter Real ramp.offset = 1e4 \"Offset of output signal\" /* 10000.0 */;
 parameter Real ramp.startTime(final quantity = \"Time\",final unit = \"s\") = 5 \"Output = offset for time < startTime\" /* 5.0 */;
 Real ramp.y \"Connector of Real output signal\";
initial equation 
 multiPortVolume.p = multiPortVolume.p_start;
 multiPortVolume.T = multiPortVolume.T_start;
initial equation /* dependent parameters */
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
 multiPortVolume.H_flow[1] = ( multiPortVolume.flowPort[1].m_flow ) * ( (if multiPortVolume.flowPort[1].m_flow > 0 then flowSource.flowPort.h_outflow else multiPortVolume.flowPort[1].h_outflow) );
 multiPortVolume.flowPort[1].p = multiPortVolume.p;
 multiPortVolume.flowPort[1].h_outflow = multiPortVolume.h;
 multiPortVolume.H_flow[2] = ( multiPortVolume.flowPort[2].m_flow ) * ( (if multiPortVolume.flowPort[2].m_flow > 0 then linearResistance.port_a.h_outflow else multiPortVolume.flowPort[2].h_outflow) );
 multiPortVolume.flowPort[2].p = multiPortVolume.p;
 multiPortVolume.flowPort[2].h_outflow = multiPortVolume.h;
 multiPortVolume.heatPort.T = multiPortVolume.T;
 heatSource.port.Q_flow = (  - ( heatSource.Q_flow ) ) * ( 1 + ( heatSource.alpha ) * ( heatSource.port.T - ( heatSource.T_ref ) ) );
 linearResistance.port_a.m_flow = ( linearResistance.port_a.p - ( linearResistance.port_b.p ) ) / ( linearResistance.u );
 linearResistance.port_a.m_flow + linearResistance.port_b.m_flow = 0;
 linearResistance.port_a.h_outflow = reservoir.flowPort.h_outflow;
 linearResistance.port_b.h_outflow = linearResistance.port_a.h_outflow;
 reservoir.flowPort.p = reservoir.p0;
 reservoir.flowPort.h_outflow = reservoir.h0;
 ramp.y = ramp.offset + (if time < ramp.startTime then 0 elseif time < ramp.startTime + ramp.duration then ( ( time - ( ramp.startTime ) ) * ( ramp.height ) ) / ( ramp.duration ) else ramp.height);
 heatSource.port.T = multiPortVolume.heatPort.T;
 heatSource.port.Q_flow + multiPortVolume.heatPort.Q_flow = 0;
 flowSource.flowPort.m_flow + multiPortVolume.flowPort[1].m_flow = 0;
 flowSource.flowPort.p = multiPortVolume.flowPort[1].p;
 linearResistance.port_b.m_flow + reservoir.flowPort.m_flow = 0;
 linearResistance.port_b.p = reservoir.flowPort.p;
 linearResistance.port_a.m_flow + multiPortVolume.flowPort[2].m_flow = 0;
 linearResistance.port_a.p = multiPortVolume.flowPort[2].p;
 linearResistance.u = ramp.y;
end StreamExample.Examples.Systems.HeatedGas;
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
         name="HeatedGas_SimpleWrap",
         description="Test of inside and outside stream connectors.",
         eliminate_alias_variables=false,
         flatModel="
fclass StreamExample.Examples.Systems.HeatedGas_SimpleWrap
 parameter Real R_gas(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\") = ( 8.314472 ) / ( 0.0289651159 ) /* 287.0512249529787 */;
 parameter Real cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\") = 1000 /* 1000.0 */;
 parameter Real flowSource.mflow0(quantity = \"MassFlowRate\",final unit = \"kg/s\") = 1 /* 1.0 */;
 parameter Real flowSource.T0(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") = 303.15 /* 303.15 */;
 parameter Real flowSource.cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 Real flowSource.h(nominal = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real flowSource.flowPort.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real flowSource.flowPort.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real flowSource.flowPort.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 parameter Real reservoir.p0(final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\") = 100000 /* 100000.0 */;
 parameter Real reservoir.T0(final quantity = \"ThermodynamicTemperature\",final unit = \"K\",min = 0,displayUnit = \"degC\") = 303.15 /* 303.15 */;
 parameter Real reservoir.cp(final quantity = \"SpecificHeatCapacity\",final unit = \"J/(kg.K)\");
 parameter Real reservoir.h0(final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real reservoir.flowPort.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real reservoir.flowPort.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real reservoir.flowPort.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 parameter Real ramp.height = 1e4 \"Height of ramps\" /* 10000.0 */;
 parameter Real ramp.duration(min = 1.0E-60,start = 2,final quantity = \"Time\",final unit = \"s\") = 1 \"Durations of ramp\" /* 1.0 */;
 parameter Real ramp.offset = 1e4 \"Offset of output signal\" /* 10000.0 */;
 parameter Real ramp.startTime(final quantity = \"Time\",final unit = \"s\") = 5 \"Output = offset for time < startTime\" /* 5.0 */;
 Real ramp.y \"Connector of Real output signal\";
 Real linearResistanceWrap.port_a.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real linearResistanceWrap.port_a.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real linearResistanceWrap.port_a.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real linearResistanceWrap.port_b.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real linearResistanceWrap.port_b.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real linearResistanceWrap.port_b.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real linearResistanceWrap.u;
 Real linearResistanceWrap.linearResistance.port_a.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real linearResistanceWrap.linearResistance.port_a.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real linearResistanceWrap.linearResistance.port_a.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real linearResistanceWrap.linearResistance.port_b.m_flow(quantity = \"MassFlowRate\",final unit = \"kg/s\");
 Real linearResistanceWrap.linearResistance.port_b.p(nominal = 100000,start = 100000,final quantity = \"Pressure\",final unit = \"Pa\",displayUnit = \"bar\");
 Real linearResistanceWrap.linearResistance.port_b.h_outflow(nominal = 400000,start = 400000,final quantity = \"SpecificEnergy\",final unit = \"J/kg\");
 Real linearResistanceWrap.linearResistance.u(start = 1);
initial equation /* dependent parameters */
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
 linearResistanceWrap.linearResistance.u = linearResistanceWrap.u;
 linearResistanceWrap.u = ramp.y;
 linearResistanceWrap.port_b.m_flow + reservoir.flowPort.m_flow = 0;
 linearResistanceWrap.port_b.p = reservoir.flowPort.p;
 flowSource.flowPort.m_flow + linearResistanceWrap.port_a.m_flow = 0;
 flowSource.flowPort.p = linearResistanceWrap.port_a.p;
 linearResistanceWrap.linearResistance.port_b.m_flow - ( linearResistanceWrap.port_b.m_flow ) = 0;
 linearResistanceWrap.linearResistance.port_b.p = linearResistanceWrap.port_b.p;
 linearResistanceWrap.linearResistance.port_b.h_outflow = linearResistanceWrap.port_b.h_outflow;
 linearResistanceWrap.linearResistance.port_a.m_flow - ( linearResistanceWrap.port_a.m_flow ) = 0;
 linearResistanceWrap.linearResistance.port_a.p = linearResistanceWrap.port_a.p;
 linearResistanceWrap.linearResistance.port_a.h_outflow = linearResistanceWrap.port_a.h_outflow;
end StreamExample.Examples.Systems.HeatedGas_SimpleWrap;
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
