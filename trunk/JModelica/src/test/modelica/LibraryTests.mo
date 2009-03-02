model LibraryTests 

   model LibraryTest1
     Modelica.Electrical.Analog.Basic.Capacitor c;
     equation
   end LibraryTest1;  

  model LibraryTest2
    Modelica.Blocks.Interfaces.RealInput u;
  end LibraryTest2;

model LibraryTest3
  annotation (uses(Modelica(version="3.0")), Diagram(coordinateSystem(
          preserveAspectRatio=true, extent={{-100,-100},{100,100}}), graphics));
  Modelica.Electrical.Analog.Basic.Resistor resistor
    annotation (Placement(transformation(extent={{-46,28},{-26,48}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-8,14})));
  Modelica.Electrical.Analog.Basic.Ground ground
    annotation (Placement(transformation(extent={{-44,-56},{-24,-36}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-8,-18})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-58,-2})));
  Modelica.Blocks.Sources.Sine sine
    annotation (Placement(transformation(extent={{-102,-12},{-82,8}})));
equation 
  connect(resistor.n, inductor.p) annotation (Line(
      points={{-26,38},{-8,38},{-8,24}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.p, inductor.n) annotation (Line(
      points={{-8,-8},{-8,-4.5},{-8,-4.5},{-8,-1},{-8,4},{-8,4}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(ground.p, capacitor.n) annotation (Line(
      points={{-34,-36},{-8,-36},{-8,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.n, resistor.p) annotation (Line(
      points={{-58,8},{-58,38},{-46,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.p, ground.p) annotation (Line(
      points={{-58,-12},{-58,-36},{-34,-36}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(sine.y, signalVoltage.v) annotation (Line(
      points={{-81,-2},{-73,-2},{-73,-2},{-65,-2}},
      color={0,0,127},
      smooth=Smooth.None));
end LibraryTest3;

model LibraryTest4
  Modelica.Blocks.Interfaces.RealInput in_port;
  Modelica.Blocks.Interfaces.RealOutput out_port;
equation
connect(in_port,out_port);
end LibraryTest4;

end LibraryTests;