/*
    Copyright (C) 2009 Modelon AB

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


model ConnectTests

  class ConnectTest1

	connector Ca
		flow Real x;
		Real y;
	end Ca;
	
	connector Cb
		flow Real x;
		Real y;
	end Cb;
	
	model C2
		Ca ca;
		Cb cb;
	equation
      connect(ca,cb);
    end C2;
    
    C2 c2;  
      
   end ConnectTest1;

    class ConnectTest2_Err

   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ConnectTest2_Err",
                                               description="Basic test of name lookup in connect clauses",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/ConnectTests.mo':
Semantic error at line 53, column 15:
  Cannot find class or component declaration for cc
")})));

	connector Ca
		flow Real x;
		Real y;
	end Ca;
	
	connector Cb
		flow Real x;
		Real y;
	end Cb;
	
	model C2
		Ca ca;
		Cb cb;
	equation
      connect(cc,cb);
    end C2;
    
    C2 c2;  
      
   end ConnectTest2_Err;
   
model ConnectTest3


  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ConnectTest3",
        description="Test of generation of connection equations.",
                                               flatModel=
"fclass ConnectTests.ConnectTest3
 parameter Real gain.k = 1 \"Gain value multiplied with input signal\";
 Real gain.u \"Input signal connector\";
 Real gain.y \"Output signal connector\";
 parameter Real const.k = 1 \"Constant output value\";
 Real const.y \"Connector of Real output signal\";
equation
 gain.y = ( gain.k ) * ( gain.u );
 const.y = const.k;
 const.y = gain.u;
end ConnectTests.ConnectTest3;

")})));



 block Gain 
  "Output the product of a gain value with the input signal" 
  
  parameter Real k=1 "Gain value multiplied with input signal";
public 
  RealInput u "Input signal connector";
  RealOutput y "Output signal connector";
equation 
  y = k*u;
end Gain;
 
connector RealInput = input RealSignal "'input Real' as connector";
 
connector RealSignal 
  "Real port (both input/output possible)" 
  replaceable type SignalType = Real;
  
  extends SignalType;
  
end RealSignal;
 
connector RealOutput = output RealSignal "'output Real' as connector";
 
block Constant 
  "Generate constant signal of type Real" 
  parameter Real k=1 "Constant output value";
  extends SO;
equation 
  y = k;
end Constant;
 
partial block SO 
  "Single Output continuous control block" 
  RealOutput y "Connector of Real output signal";
end SO;  
  
  Gain gain;
  Constant const;
equation 
  connect(const.y, gain.u);


end ConnectTest3;



model Electrical
  
  connector Pin "Pin of an electrical component" 
    Real v "Potential at the pin";
    flow Real i "Current flowing into the pin";
  end Pin;

  connector PositivePin "Positive pin of an electric component" 
    Real v "Potential at the pin";
    flow Real i "Current flowing into the pin";
  end PositivePin;
  
  connector NegativePin "Negative pin of an electric component" 
    Real v "Potential at the pin";
    flow Real i "Current flowing into the pin";
  end NegativePin;
  
  partial model TwoPin "Component with one electrical port" 
    Real v "Voltage drop between the two pins (= p.v - n.v)";
    PositivePin p "Positive pin";
    NegativePin n "Negative pin";
  equation 
    v = p.v - n.v;
  end TwoPin;

  partial model OnePort 
    "Component with two electrical pins p and n and current i from p to n" 
    
    Real v "Voltage drop between the two pins (= p.v - n.v)";
    Real i "Current flowing from pin p to pin n";
    PositivePin p ;
    NegativePin n ;
  equation 
    v = p.v - n.v;
    0 = p.i + n.i;
    i = p.i;
  end OnePort;

 model Resistor "Ideal linear electrical resistor" 
    extends OnePort;
    parameter Real R=1 "Resistance";
  equation 
    R*i = v;
  end Resistor;

 model Capacitor "Ideal linear electrical capacitor" 
    extends OnePort;
    parameter Real C=1 "Capacitance";
  equation 
    i = C*der(v);
  end Capacitor;

  model Inductor "Ideal linear electrical inductor" 
    extends OnePort;
    parameter Real L=1 "Inductance";
  equation 
    L*der(i) = v;
  end Inductor;

 model ConstantVoltage "Source for constant voltage" 
    parameter Real V=1 "Value of constant voltage";
    extends OnePort;
  equation 
    v = V;
  end ConstantVoltage;

  model Ground "Ground node" 
    Pin p;
  equation 
    p.v = 0;
  end Ground;



end Electrical;

  model CircuitTest1
  
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="CircuitTest1",
        description="Test of generation of connection equations.",
                                               flatModel=
"fclass ConnectTests.CircuitTest1
 parameter Real cv.V=1 \"Value of constant voltage\";
 Real cv.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real cv.i \"Current flowing from pin p to pin n\";
 Real cv.p.v \"Potential at the pin\";
 Real cv.p.i \"Current flowing into the pin\";
 Real cv.n.v \"Potential at the pin\";
 Real cv.n.i \"Current flowing into the pin\";
 Real g.p.v \"Potential at the pin\";
 Real g.p.i \"Current flowing into the pin\";
 parameter Real r.R=1 \"Resistance\";
 Real r.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real r.i \"Current flowing from pin p to pin n\";
 Real r.p.v \"Potential at the pin\";
 Real r.p.i \"Current flowing into the pin\";
 Real r.n.v \"Potential at the pin\";
 Real r.n.i \"Current flowing into the pin\";
 parameter Real c.C=1 \"Capacitance\";
 Real c.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real c.i \"Current flowing from pin p to pin n\";
 Real c.p.v \"Potential at the pin\";
 Real c.p.i \"Current flowing into the pin\";
 Real c.n.v \"Potential at the pin\";
 Real c.n.i \"Current flowing into the pin\";
equation 
 cv.v = cv.V;
 cv.v = cv.p.v - ( cv.n.v );
 0 = cv.p.i + cv.n.i;
 cv.i = cv.p.i;
 g.p.v = 0;
 ( r.R ) * ( r.i ) = r.v;
 r.v = r.p.v - ( r.n.v );
 0 = r.p.i + r.n.i;
 r.i = r.p.i;
 c.i = ( c.C ) * ( c.der(v) );
 c.v = c.p.v - ( c.n.v );
 0 = c.p.i + c.n.i;
 c.i = c.p.i;
 c.p.v = cv.p.v;
 cv.p.v = r.p.v;
 c.p.i + cv.p.i + r.p.i = 0.0;
 c.n.v = cv.n.v;
 cv.n.v = g.p.v;
 g.p.v = r.n.v;
 c.n.i + cv.n.i + g.p.i + r.n.i = 0.0;
end ConnectTests.CircuitTest1;
")})));
  
    Electrical.ConstantVoltage cv;
    Electrical.Ground g;
    Electrical.Resistor r;
    Electrical.Capacitor c;
  equation
    connect(cv.p,r.p);
    connect(r.p,c.p);
    connect(cv.n,g.p);
    connect(cv.n,r.n);
    connect(r.n,c.n);
  end CircuitTest1;

  model CircuitTest2
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="CircuitTest2",
        description="Test of generation of connection equations.",
                                               flatModel=
"fclass ConnectTests.CircuitTest2
 parameter Real cv.V=1 \"Value of constant voltage\";
 Real cv.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real cv.i \"Current flowing from pin p to pin n\";
 Real cv.p.v \"Potential at the pin\";
 Real cv.p.i \"Current flowing into the pin\";
 Real cv.n.v \"Potential at the pin\";
 Real cv.n.i \"Current flowing into the pin\";
 Real g.p.v \"Potential at the pin\";
 Real g.p.i \"Current flowing into the pin\";
 parameter Real r.R=1 \"Resistance\";
 Real r.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real r.i \"Current flowing from pin p to pin n\";
 Real r.p.v \"Potential at the pin\";
 Real r.p.i \"Current flowing into the pin\";
 Real r.n.v \"Potential at the pin\";
 Real r.n.i \"Current flowing into the pin\";
 parameter Real f.r.R=1 \"Resistance\";
 Real f.r.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real f.r.i \"Current flowing from pin p to pin n\";
 Real f.r.p.v \"Potential at the pin\";
 Real f.r.p.i \"Current flowing into the pin\";
 Real f.r.n.v \"Potential at the pin\";
 Real f.r.n.i \"Current flowing into the pin\";
 parameter Real f.c.C=1 \"Capacitance\";
 Real f.c.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real f.c.i \"Current flowing from pin p to pin n\";
 Real f.c.p.v \"Potential at the pin\";
 Real f.c.p.i \"Current flowing into the pin\";
 Real f.c.n.v \"Potential at the pin\";
 Real f.c.n.i \"Current flowing into the pin\";
 Real f.v \"Voltage drop between the two pins (= p.v - n.v)\";
 Real f.p.v \"Potential at the pin\";
 Real f.p.i \"Current flowing into the pin\";
 Real f.n.v \"Potential at the pin\";
 Real f.n.i \"Current flowing into the pin\";
equation 
 cv.v = cv.V;
 cv.v = cv.p.v - ( cv.n.v );
 0 = cv.p.i + cv.n.i;
 cv.i = cv.p.i;
 g.p.v = 0;
 ( r.R ) * ( r.i ) = r.v;
 r.v = r.p.v - ( r.n.v );
 0 = r.p.i + r.n.i;
 r.i = r.p.i;
 ( f.r.R ) * ( f.r.i ) = f.r.v;
 f.r.v = f.r.p.v - ( f.r.n.v );
 0 = f.r.p.i + f.r.n.i;
 f.r.i = f.r.p.i;
 f.c.i = ( f.c.C ) * ( f.c.der(v) );
 f.c.v = f.c.p.v - ( f.c.n.v );
 0 = f.c.p.i + f.c.n.i;
 f.c.i = f.c.p.i;
 f.v = f.p.v - ( f.n.v );
 cv.p.v = f.p.v;
 f.p.v = r.p.v;
 cv.p.i + f.p.i + r.p.i = 0.0;
 cv.n.v = f.n.v;
 f.n.v = g.p.v;
 g.p.v = r.n.v;
 cv.n.i + f.n.i + g.p.i + r.n.i = 0.0;
 f.c.p.v = f.p.v;
 f.p.v = f.r.p.v;
 f.c.p.i - ( f.p.i ) + f.r.p.i = 0.0;
 f.c.n.v = f.n.v;
 f.n.v = f.r.n.v;
 f.c.n.i - ( f.n.i ) + f.r.n.i = 0.0;
end ConnectTests.CircuitTest2;
")})));
  
    model F
      extends Electrical.OnePort;
      Electrical.Resistor r;
      Electrical.Capacitor c;
    equation
      connect(p,r.p);
      connect(p,c.p);
      connect(n,r.n);
      connect(n,c.n);
    end F;

    model F2
      extends Electrical.TwoPin;
      Electrical.Resistor r;
      Electrical.Capacitor c;
    equation
      connect(p,r.p);
      connect(p,c.p);
      connect(n,r.n);
      connect(n,c.n);
    end F2;
  
    Electrical.ConstantVoltage cv;
    Electrical.Ground g;
    Electrical.Resistor r;
    F2 f;
  equation
    connect(cv.p,r.p);
    connect(r.p,f.p);
    connect(cv.n,g.p);
    connect(cv.n,r.n);
    connect(r.n,f.n);
  end CircuitTest2;

model ConnectorTest

  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ConnectorTest",
        description="Test of generation of connection equations.",
                                               flatModel=
"fclass ConnectTests.ConnectorTest
 parameter Real c.b.firstOrder.k = 1 \"Gain\" /* 1.0 */;
 parameter Real c.b.firstOrder.T(start = 1,final quantity = \"Time\",final unit = \"s\") = 1 \"Time Constant\" /* 1.0 */;
 parameter Real c.b.firstOrder.y_start = 0 \"Initial or guess value of output (= state)\" /* 0.0 */;
 Real c.b.firstOrder.u \"Connector of Real input signal\";
 Real c.b.firstOrder.y(start = c.b.firstOrder.y_start) \"Connector of Real output signal\";
 Real c.b.feedback.u1;
 Real c.b.feedback.u2;
 Real c.b.feedback.y;
 Real c.b.u;
 parameter Real c.const.k(start = 1) = 1 \"Constant output value\" /* 1.0 */;
 Real c.const.y \"Connector of Real output signal\";
initial equation 
 c.b.firstOrder.y = c.b.firstOrder.y_start;
equation 
 c.b.firstOrder.der(y) = ( ( c.b.firstOrder.k ) * ( c.b.firstOrder.u ) - ( c.b.firstOrder.y ) ) / ( c.b.firstOrder.T );
 c.b.feedback.y = c.b.feedback.u1 - ( c.b.feedback.u2 );
 c.const.y = c.const.k;
 c.b.feedback.u1 = c.b.u;
 c.b.u = c.const.y;
 c.b.feedback.y = c.b.firstOrder.u;
 c.b.feedback.u2 = c.b.firstOrder.y;
end ConnectTests.ConnectorTest;
")})));

   model A
 
     RealInput u
      annotation (Placement(transformation(extent={{-120,-20},{-80,20}})));
     RealOutput y
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
     parameter Real k = 1;
   equation 
     y = k*u;
   end A;
 
   model B
		FirstOrder firstOrder
		  annotation (Placement(transformation(extent={{30,12},{50,32}})));
    Feedback feedback
      annotation (Placement(transformation(extent={{-46,12},{-26,32}})));
    annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{
              -100,-100},{100,100}}), graphics));
    RealInput u
      annotation (Placement(transformation(extent={{-120,-20},{-80,20}})));
   equation 
    connect(feedback.y, firstOrder.u) annotation (Line(
        points={{-27,22},{28,22}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(firstOrder.y, feedback.u2) annotation (Line(
        points={{51,22},{74,22},{74,-22},{-36,-22},{-36,14}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(feedback.u1, u) annotation (Line(
        points={{-44,22},{-66,22},{-66,0},{-100,0}},
        color={0,0,127},
        smooth=Smooth.None));
   end B;


   
	  block FirstOrder "First order transfer function block (= 1 pole)"
	   parameter Real k=1 "Gain";
	   parameter Modelica.SIunits.Time T(start=1)=1 "Time Constant";
	   parameter Real y_start=0 "Initial or guess value of output (= state)";
	
	   extends SISO(y(start=y_start));
	
	 initial equation 
		 y = y_start;
	 equation 
	   der(y) = (k*u - y)/T;
	 end FirstOrder;
	
	connector RealInput =  input Real "'input Real' as connector";
	
   connector RealOutput = output Real "'output Real' as connector";
	
   block Feedback 
	 "Output difference between commanded and feedback input"
	
	 input RealInput u1;
	 input RealInput u2;
	 output RealOutput y;
	
   equation 
	 y = u1 - u2;
   end Feedback;
	
	partial block SISO 
	 "Single Input Single Output continuous control block"
	 extends BlockIcon;
	
	 RealInput u "Connector of Real input signal";
	 RealOutput y "Connector of Real output signal";
   end SISO;
	
   partial block BlockIcon 
	 "Basic graphical layout of input/output block"
	
	
   equation
	
   end BlockIcon;
	
   block Constant 
	 "Generate constant signal of type Real"
	 parameter Real k(start=1) "Constant output value";
	 extends SO;
	
   equation 
	 y = k;
   end Constant;
	
   partial block SO 
	 "Single Output continuous control block"
	 extends BlockIcon;
	
	 RealOutput y "Connector of Real output signal";
	
   end SO;
    model C
    B b annotation (Placement(transformation(extent={{28,6},{48,26}})));
    Constant const(k=1)
      annotation (Placement(transformation(extent={{-60,8},{-40,28}})));
    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{
              -100,-100},{100,100}}), graphics));
  equation 
    connect(const.y, b.u) annotation (Line(
        points={{-39,18},{-6,18},{-6,16},{28,16}},
        color={0,0,127},
        smooth=Smooth.None));
  end C;
  
  C c;
end ConnectorTest;


end ConnectTests;
