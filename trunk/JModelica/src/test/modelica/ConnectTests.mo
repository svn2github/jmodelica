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
 c.i = ( c.C ) * ( der(c.v) );
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
 f.c.i = ( f.c.C ) * ( der(f.c.v) );
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


end ConnectTests;
