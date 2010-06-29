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

  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ConnectTest2",
        description="Test of generation of connection equations.",
                                               flatModel=
"fclass ConnectTests.ConnectTest1
 Real c2.ca.x;
 Real c2.ca.y;
 Real c2.cb.x;
 Real c2.cb.y;
equation
  - ( c2.ca.x ) - ( c2.cb.x ) = 0;
 c2.ca.y = c2.cb.y;
 c2.ca.x = 0;
 c2.cb.x = 0;
end ConnectTests.ConnectTest1;
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

  class ConnectTest4

  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ConnectTest4",
        description="Test of generation of connection equations.",
                                               flatModel=
"
fclass ConnectTests.ConnectTest4
 Real c2.ca.x;
 Real c2.ca.y;
 Real c2.cb.x;
 Real c2.cb.y;
 Real c2.ca2.x;
 Real c2.ca2.y;
equation
 c2.ca2.x = 3;
  - ( c2.ca.x ) - ( c2.cb.x ) = 0;
 c2.ca.y = c2.cb.y;
 c2.ca.x = 0;
 c2.cb.x = 0;
 c2.ca2.x = 0;
end ConnectTests.ConnectTest4;
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
                Ca ca2;
	equation
        ca2.x =3;
      connect(ca,cb);
    end C2;
    
    C2 c2;  
      
   end ConnectTest4;

model ConnectTest5
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ConnectTest5",
        description="Test of generation of connection equations.",
                                               flatModel=
"fclass ConnectTests.ConnectTest5
 parameter Integer c1.n = 2 /* 2 */;
 Real c1.x[2];
 parameter Integer c2.n = 2 /* 2 */;
 Real c2.x[2];
equation
 c1.x[1:2] = {1,2};
 c1.x[1:2] = c2.x[1:2];
end ConnectTests.ConnectTest5;
")})));

  connector C
    parameter Integer n = 2;
    Real x[n];
  end C;
  C c1;
  C c2;

equation
  connect(c1,c2);
  c1.x = {1,2};

end ConnectTest5;


model ConnectTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ConnectTest6",
         description="Connecting array flow variables",
         flatModel="
fclass ConnectTests.ConnectTest6
 Real b1.a1.y[2];
 Real b1.a1.x[2];
 Real b1.a2.y[2];
 Real b1.a2.x[2];
 Real b2.a1.y[2];
 Real b2.a1.x[2];
 Real b2.a2.y[2];
 Real b2.a2.x[2];
equation
 b1.a1.y[1:2] = b2.a2.y[1:2];
 b1.a1.x[1:2] + b2.a2.x[1:2] = zeros(2);
 b1.a2.x = zeros(2);
 b2.a1.x = zeros(2);
end ConnectTests.ConnectTest6;
")})));

	connector A
		Real y[2];
		flow Real x[2];
	end A;
	
	model B
		A a1;
		A a2;
	end B;
	
	B b1;
	B b2;
equation
	connect(b1.a1, b2.a2);
end ConnectTest6;



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
 c.p.i + cv.p.i + r.p.i = 0;
 c.n.v = cv.n.v;
 cv.n.v = g.p.v;
 g.p.v = r.n.v;
 c.n.i + cv.n.i + g.p.i + r.n.i = 0;
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
 cv.p.i + f.p.i + r.p.i = 0;
 cv.n.v = f.n.v;
 f.n.v = g.p.v;
 g.p.v = r.n.v;
 cv.n.i + f.n.i + g.p.i + r.n.i = 0;
 f.c.p.v = f.p.v;
 f.p.v = f.r.p.v;
 f.c.p.i - ( f.p.i ) + f.r.p.i = 0;
 f.c.n.v = f.n.v;
 f.n.v = f.r.n.v;
 f.c.n.i - ( f.n.i ) + f.r.n.i = 0;
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

model CauerLowPassAnalog

  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="CauerLowPassAnalog",
        description="Test of generation of connection equations.",
                                               flatModel=
"
fclass ConnectTests.CauerLowPassAnalog
 parameter Real l1(final quantity = \"Inductance\",final unit = \"H\") = 1.304 \"filter coefficient I1\" /* 1.304 */;
 parameter Real l2(final quantity = \"Inductance\",final unit = \"H\") = 0.8586 \"filter coefficient I2\" /* 0.8586 */;
 parameter Real c1(final quantity = \"Capacitance\",final unit = \"F\",min = 0) = 1.072 \"filter coefficient c1\" /* 1.072 */;
 parameter Real c2(final quantity = \"Capacitance\",final unit = \"F\",min = 0) = ( 1 ) / ( ( 1.704992 ^ 2 ) * ( l1 ) ) \"filter coefficient c2\";
 parameter Real c3(final quantity = \"Capacitance\",final unit = \"F\",min = 0) = 1.682 \"filter coefficient c3\" /* 1.682 */;
 parameter Real c4(final quantity = \"Capacitance\",final unit = \"F\",min = 0) = ( 1 ) / ( ( 1.179945 ^ 2 ) * ( l2 ) ) \"filter coefficient c4\";
 parameter Real c5(final quantity = \"Capacitance\",final unit = \"F\",min = 0) = 0.7262 \"filter coefficient c5\" /* 0.7262 */;
 Real G.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real G.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real C1.C(start = 1,final quantity = \"Capacitance\",final unit = \"F\",min = 0) = c1 \"Capacitance\";
 Real C1.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real C1.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real C1.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C1.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real C1.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C1.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real C2.C(start = 1,final quantity = \"Capacitance\",final unit = \"F\",min = 0) = c2 \"Capacitance\";
 Real C2.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real C2.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real C2.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C2.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real C2.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C2.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real C3.C(start = 1,final quantity = \"Capacitance\",final unit = \"F\",min = 0) = c3 \"Capacitance\";
 Real C3.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real C3.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real C3.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C3.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real C3.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C3.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real C4.C(start = 1,final quantity = \"Capacitance\",final unit = \"F\",min = 0) = c4 \"Capacitance\";
 Real C4.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real C4.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real C4.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C4.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real C4.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C4.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real C5.C(start = 1,final quantity = \"Capacitance\",final unit = \"F\",min = 0) = c5 \"Capacitance\";
 Real C5.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real C5.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real C5.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C5.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real C5.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real C5.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real L1.L(start = 1,final quantity = \"Inductance\",final unit = \"H\") = l1 \"Inductance\";
 Real L1.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real L1.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real L1.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real L1.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real L1.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real L1.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real L2.L(start = 1,final quantity = \"Inductance\",final unit = \"H\") = l2 \"Inductance\";
 Real L2.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real L2.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real L2.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real L2.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real L2.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real L2.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real R1.R(start = 1,final quantity = \"Resistance\",final unit = \"Ohm\") = 1 \"Resistance\" /* 1.0 */;
 Real R1.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real R1.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real R1.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real R1.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real R1.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real R1.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real R2.R(start = 1,final quantity = \"Resistance\",final unit = \"Ohm\") = 1 \"Resistance\" /* 1.0 */;
 Real R2.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real R2.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real R2.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real R2.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real R2.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real R2.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 parameter Real V.V(start = 1,final quantity = \"ElectricPotential\",final unit = \"V\") = 0 \"Height of step\" /* 0.0 */;
 parameter Real V.offset(final quantity = \"ElectricPotential\",final unit = \"V\") = 0 \"Voltage offset\" /* 0.0 */;
 parameter Real V.startTime(final quantity = \"Time\",final unit = \"s\") = 1 \"Time offset\" /* 1.0 */;
 parameter Real V.signalSource.height = V.V \"Height of step\";
 parameter Real V.signalSource.offset = V.offset \"Offset of output signal y\";
 parameter Real V.signalSource.startTime(final quantity = \"Time\",final unit = \"s\") = V.startTime \"Output y = offset for time < startTime\";
 Real V.signalSource.y \"Connector of Real output signal\";
 Real V.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Voltage drop between the two pins (= p.v - n.v)\";
 Real V.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing from pin p to pin n\";
 Real V.p.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real V.p.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
 Real V.n.v(final quantity = \"ElectricPotential\",final unit = \"V\") \"Potential at the pin\";
 Real V.n.i(final quantity = \"ElectricCurrent\",final unit = \"A\") \"Current flowing into the pin\";
equation 
 G.p.v = 0;
 C1.i = ( C1.C ) * ( C1.der(v) );
 C1.v = C1.p.v - ( C1.n.v );
 0 = C1.p.i + C1.n.i;
 C1.i = C1.p.i;
 C2.i = ( C2.C ) * ( C2.der(v) );
 C2.v = C2.p.v - ( C2.n.v );
 0 = C2.p.i + C2.n.i;
 C2.i = C2.p.i;
 C3.i = ( C3.C ) * ( C3.der(v) );
 C3.v = C3.p.v - ( C3.n.v );
 0 = C3.p.i + C3.n.i;
 C3.i = C3.p.i;
 C4.i = ( C4.C ) * ( C4.der(v) );
 C4.v = C4.p.v - ( C4.n.v );
 0 = C4.p.i + C4.n.i;
 C4.i = C4.p.i;
 C5.i = ( C5.C ) * ( C5.der(v) );
 C5.v = C5.p.v - ( C5.n.v );
 0 = C5.p.i + C5.n.i;
 C5.i = C5.p.i;
 ( L1.L ) * ( L1.der(i) ) = L1.v;
 L1.v = L1.p.v - ( L1.n.v );
 0 = L1.p.i + L1.n.i;
 L1.i = L1.p.i;
 ( L2.L ) * ( L2.der(i) ) = L2.v;
 L2.v = L2.p.v - ( L2.n.v );
 0 = L2.p.i + L2.n.i;
 L2.i = L2.p.i;
 ( R1.R ) * ( R1.i ) = R1.v;
 R1.v = R1.p.v - ( R1.n.v );
 0 = R1.p.i + R1.n.i;
 R1.i = R1.p.i;
 ( R2.R ) * ( R2.i ) = R2.v;
 R2.v = R2.p.v - ( R2.n.v );
 0 = R2.p.i + R2.n.i;
 R2.i = R2.p.i;
 V.v = V.signalSource.y;
 V.signalSource.y = V.signalSource.offset + (if time < V.signalSource.startTime then 0
 else V.signalSource.height);
 V.v = V.p.v - ( V.n.v );
 0 = V.p.i + V.n.i;
 V.i = V.p.i;
 C1.p.v = C2.p.v;
 C2.p.v = L1.p.v;
 L1.p.v = R1.n.v;
 C1.p.i + C2.p.i + L1.p.i + R1.n.i = 0;
 C1.n.v = C3.n.v;
 C3.n.v = C5.n.v;
 C5.n.v = G.p.v;
 G.p.v = R2.n.v;
 R2.n.v = V.n.v;
 C1.n.i + C3.n.i + C5.n.i + G.p.i + R2.n.i + V.n.i = 0;
 C2.n.v = C3.p.v;
 C3.p.v = C4.p.v;
 C4.p.v = L1.n.v;
 L1.n.v = L2.p.v;
 C2.n.i + C3.p.i + C4.p.i + L1.n.i + L2.p.i = 0;
 C4.n.v = C5.p.v;
 C5.p.v = L2.n.v;
 L2.n.v = R2.p.v;
 C4.n.i + C5.p.i + L2.n.i + R2.p.i = 0;
 R1.p.v = V.p.v;
 R1.p.i + V.p.i = 0;
end ConnectTests.CauerLowPassAnalog;
")})));

extends Modelica.Electrical.Analog.Examples.CauerLowPassAnalog(R1(R=1),R2(R=1),V(V=0));

end CauerLowPassAnalog; 



// TODO: These equations are wrong. Change test when stream equations are generated properly!
model StreamTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="StreamTest1",
		 description="Stream variables: basic test",
		 flatModel="
fclass ConnectTests.StreamTest1
 Real g.e.a;
 Real g.e.b;
 Real g.e.c;
 Real g.e.d;
 Real g.f.a;
 Real g.f.b;
 Real g.f.c;
 Real g.f.d;
equation
 g.e.a = g.f.a;
  - ( g.e.b ) - ( g.f.b ) = 0;
 g.e.c = g.f.c;
 g.e.d = g.f.d;
 g.e.b = 0;
 g.f.b = 0;
end ConnectTests.StreamTest1;
")})));

	connector A
		Real a;
		flow Real b;
		stream Real c;
		stream Real d;
	end A;
	
	model B
		A e;
		A f;
	equation
		connect(e,f);
	end B;
	
	B g;
end StreamTest1;


// TODO: These equations are wrong. Change test when stream equations are generated properly!
model StreamTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="StreamTest2",
         description="Basic test of inStream() and actualStream()",
         flatModel="
fclass ConnectTests.StreamTest2
 Real d.b;
 Real d.c;
 Real x;
 Real y;
equation
 x = inStream(d.c);
 y = actualStream(d.c);
 d.b = 0;
end ConnectTests.StreamTest2;
")})));

	connector A
		flow Real b;
		stream Real c;
	end A;
	
	A d;
	Real x;
	Real y;
equation
	x = inStream(d.c);
	y = actualStream(d.c);
end StreamTest2;


model StreamTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="StreamTest3",
         description="Using inStream() and actualStream() on normal var in connector",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ConnectTests.mo':
Semantic error at line 930, column 6:
  Argument of inStream() must be a stream variable
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ConnectTests.mo':
Semantic error at line 931, column 6:
  Argument of actualStream() must be a stream variable
")})));

	connector A
		Real a;
		flow Real b;
		stream Real c;
	end A;
	
	A d;
	Real x;
	Real y;
equation
	x = inStream(d.a);
	y = actualStream(d.a);
end StreamTest3;


model StreamTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="StreamTest4",
         description="Using inStream() and actualStream() on flow var",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ConnectTests.mo':
Semantic error at line 960, column 6:
  Argument of inStream() must be a stream variable
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ConnectTests.mo':
Semantic error at line 961, column 6:
  Argument of actualStream() must be a stream variable
")})));

	connector A
		Real a;
		flow Real b;
		stream Real c;
	end A;
	
	A d;
	Real x;
	Real y;
equation
	x = inStream(d.b);
	y = actualStream(d.b);
end StreamTest4;


model StreamTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="StreamTest5",
         description="Using inStream() and actualStream() on normal var not in connector",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ConnectTests.mo':
Semantic error at line 984, column 6:
  Argument of inStream() must be a stream variable
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ConnectTests.mo':
Semantic error at line 985, column 6:
  Argument of actualStream() must be a stream variable
")})));

	Real a;
	Real x;
	Real y;
equation
	x = inStream(a);
	y = actualStream(a);
end StreamTest5;



end ConnectTests;
