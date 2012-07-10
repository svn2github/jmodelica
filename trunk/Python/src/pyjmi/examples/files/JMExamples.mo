within ;
package JMExamples
  package BangControl
    model BangControl
      //state start values
      parameter Real x1_0=0;
      parameter Real x2_0=0;
      //states
      Real x1(start=x1_0,fixed=true);
      Real x2(start=x2_0,fixed=true);
      //control signal
      Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(x1) = x2;
      der(x2) = u;
      annotation (experiment(StopTime=30), __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
  <p>
  This is a minimum-time problem with two states and one
  input. To convert this optimal control problem with free
  final time to static optimization problem, first it needs to be
  transcribed to a fixed final time problem by using an extra
  state variable. The idea is to specify a nominal time interval,
  [0, Tf ], and to use the extra state as a scale factor to scale
  the duration of the real time.
  </p>
  <p>
  Simulation time: 30s
  </p>
</HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{-48,-26},{0,-74}},
              lineColor={255,170,85},
              lineThickness=0.5),
            Ellipse(
              extent={{-30,-2},{40,-60}},
              lineColor={255,0,128},
              lineThickness=0.5),
            Ellipse(
              extent={{-38,64},{82,-20}},
              lineColor={0,0,255},
              lineThickness=0.5),
            Ellipse(
              extent={{14,12},{88,-66}},
              lineColor={255,170,213},
              lineThickness=0.5),
            Ellipse(
              extent={{-68,58},{2,-18}},
              lineColor={0,127,0},
              lineThickness=0.5)}));
    end BangControl;

    package Examples
      model BangControlInput
        BangControl bangControl
          annotation (Placement(transformation(extent={{20,20},{40,40}})));
        Modelica.Blocks.Sources.Constant const(k=1)
          annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
      equation
        connect(const.y, bangControl.u) annotation (Line(
            points={{-19,30},{5,30},{5,30},{20,30}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
        Documentation(info="<HTML>
    <p>
    The model is based on BangControl and a constant input is set.
    </p>
    <p>
    Simulation time: 30s
    </p>
    
    </HTML>"));
      end BangControlInput;

      model BangControlTimetable
        BangControl bangControl
          annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.TimeTable timeTable(table=[0,1; 20,1; 21,0; 30,0])
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(timeTable.y, bangControl.u) annotation (Line(
            points={{-19,10},{5,10},{5,10},{20,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
        Documentation(info="<HTML>
    <p>
    The model is based on BangControl and a step function is set as an input.
    </p>
    <p>
    Simulation time: 30s
    </p>
    
    </HTML>"));
      end BangControlTimetable;
    end Examples;
  end BangControl;

  package BatchFermentor
    model BatchFermentor
      //state start values
      parameter Real x1_0=1.5;
      parameter Real x2_0=0;
      parameter Real x3_0=0;
      parameter Real x4_0=7;
      parameter Real u_0=0;
      //states
      Real x1(start=x1_0, fixed=true);
      Real x2(start=x2_0, fixed=true);
      Real x3(start=x3_0, fixed=true);
      Real x4(start=x4_0, fixed=true);
      Real h1;
      Real h2;
      //control input
      Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(x1) = h1*x1-u*x1/500/x4;
      der(x2) = h2*x1-0.01*x2-u*x2/500/x4;
      der(x3) = -h1*x1/0.47-h2*x1/1.2-x1*0.029*x3/(0.0001+x3)+u/x4*(1-x3/500);
      der(x4) = u/500;
      h1 = 0.11*x3/(0.006*x1+x3);
      h2 = 0.0055*x3/(0.0001+x3*(1+10*x3));
      annotation (experiment(StopTime=150, NumberOfIntervals=1),
          __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>  
<p>
   This problem considers a fed-batch reactor for the production of penicillin. 
   We consider here the free terminal time version where the objective is to maximize 
   the amount of penicillin using the feed rate as the control variable.  
</p>   
<p>
References:
</p>    
<p>
Dynamic optimization of bioprocesses: efficient and robust numerical strategies 2003, 
Julio R. Banga, Eva Balsa-Cantro, Carmen G. Moles and Antonio A. Alonso
</p>    
<p>
Case Study I: Optimal Control of a Fed-Batch Fermentor for Penicillin Production
</p>
<p>
Simulation time:150s
</p>
</HTML>"),
        Icon(graphics));
    end BatchFermentor;

    model BatchFermentor2
      //state start values
      parameter Real x1_0=1.5;
      parameter Real x2_0=0;
      parameter Real x3_0=0;
      parameter Real x4_0=7;
      parameter Real u_0=0;
      //states
      Real x1(start=x1_0, fixed=true);
      Real x2(start=x2_0, fixed=true);
      Real x3(start=x3_0, fixed=true);
      Real x4(start=x4_0, fixed=true);
      Real u(start=0, fixed=true);
      Real h1;
      Real h2;
      //control input
      Modelica.Blocks.Interfaces.RealInput du
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(x1) = h1*x1-u*x1/500/x4;
      der(x2) = h2*x1-0.01*x2-u*x2/500/x4;
      der(x3) = -h1*x1/0.47-h2*x1/1.2-x1*0.029*x3/(0.0001+x3)+u/x4*(1-x3/500);
      der(x4) = u/500;
      der(u) = du;
      h1 = 0.11*x3/(0.006*x1+x3);
      h2 = 0.0055*x3/(0.0001+x3*(1+10*x3));
      annotation (experiment(StopTime=150, NumberOfIntervals=1),
          __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
</p>    
<p>
   This problem considers a fed-batch reactor for the production of penicillin. 
   We consider here the free terminal time version where the objective is to maximize 
   the amount of penicillin using the feed rate as the control variable.  
<p>
References:
</p>    
<p>
Dynamic optimization of bioprocesses: efficient and robust numerical strategies 2003, 
Julio R. Banga, Eva Balsa-Cantro, Carmen G. Moles and Antonio A. Alonso
</p>    
<p>
Case Study I: Optimal Control of a Fed-Batch Fermentor for Penicillin Production
</p>
<p>
Simulation time:150s
</p>
</HTML>"),
        Icon(graphics));
    end BatchFermentor2;
  end BatchFermentor;

  package BloodGlucose
    model BloodGlucose
      //State start values
      parameter Real G_init = 4.5;
      parameter Real X_init = 15;
      parameter Real I_init = 15;
      //States
      Real G(start = G_init, fixed=true) "Plasma Glucose Conc. (mmol/L)";
      Real X(start = X_init, fixed=true) "Plasma Insulin Conc. (mu/L)";
      Real I(start = I_init, fixed=true) "Plasma Insulin Conc. (mu/L)";
      Real dist "Meal glucose disturbance (mmol/L)";
      Real D;
      //parameter
      parameter Real P1 = 0.028735;
      parameter Real P2 = 0.028344;
      parameter Real P3 = 5.035e-5;
      parameter Real V1 = 12;
      parameter Real n = 5/54;
      //Control Signal
      Modelica.Blocks.Interfaces.RealInput dD "Insulin Infusion rate"
       annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(G) = -P1 * (G - G_init) - (X - X_init) * G + dist;
      der(X) = -P2 * (X - X_init) + P3 * (I - I_init);
      der(I) = -n * I + D / V1;
      dist = 3*exp(-0.05*time);
      der(D) =dD
      annotation (experiment(StopTime=400), __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
This is a model that predicts the blood glucose levels of a type-I diabetic. 
The objective is to predict the relationship between insulin injection and blood glucose levels. 
With a sufficiently accurate mathematical model of a patient, the correct insulin injection rate 
could be prescribed. 
By automating the sensing of blood glucose and the injection of insulin, this system would serve 
as an artificial pancreas. The model is composed of differential and algebraic equations. 
</p>
<p>
Reference:
</p>
<p>
S. M. Lynch and B. W. Bequette, Estimation based Model Predictive Control of Blood Glucose in 
Type I Diabetes: A Simulation Study, Proc. 27th IEEE Northeast Bioengineering Conference, IEEE, 2001.
</p>
<p>
and
</p>
<p>
S. M. Lynch and B. W. Bequette, Model Predictive Control of Blood Glucose in type I Diabetics 
using Subcutaneous Glucose Measurements, Proc. ACC, Anchorage, AK, 2002. 
</p>
</HTML>"));
      annotation (Documentation(info="<HTML>
      <p>
      The model is equivalent to BloodGlucose1 but dD (the derivative of D) is set as an input instead of D. That makes it possible to use the derivative in the cost function when formulating the optimization problem.
      </p>
      <p>
      Simulation time: 400s
      </p>
      </HTML>"),
          Icon(graphics={
            Ellipse(
              extent={{-8,30},{-56,4}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-34,-8},{26,-38}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{24,12},{84,-18}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-18,-12},{8,-22}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{40,8},{68,-4}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-46,26},{-20,16}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid)}));
    end BloodGlucose;

    model BloodGlucose_scaled
      import SI = Modelica.SIunits;
      //State start values
      parameter SI.Concentration G_init = 4.5;
      parameter SI.MolecularConcentration X_init = 15;
      parameter SI.MolecularConcentration I_init = 15;
      //States
      SI.Concentration G(start = G_init, fixed=true)
        "Plasma Glucose Conc. (mol/m3)";
      SI.MolecularConcentration X(start = X_init, fixed=true)
        "Plasma Insulin Conc. (u/m3)";
      SI.MolecularConcentration I(start = I_init, fixed=true)
        "Plasma Insulin Conc. (u/m3)";
      Real dist "Meal glucose disturbance (mol/m3/s)";
      Real D;
      //parameter
      parameter Real P1 = 0.028735 "1/min";
      parameter Real P2 = 0.028344 "1/min";
      parameter Real P3 = 5.035e-5 "1/min";
      parameter SI.Volume V1 = 12 "l";
      parameter Real n = 5/54 "1/min";
      //Control Signal
      Modelica.Blocks.Interfaces.RealInput dD "Insulin Infusion rate"
       annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(G) = (-P1 * (G*5 - G_init) - (X - X_init) * G*5 + dist)/5;
      der(X) = -P2 * (X - X_init) + P3 * (I - I_init);
      der(I) = -n * I + D / V1;
      dist = 3*exp(-0.05*time);
      der(D) =dD
      annotation (experiment(StopTime=400), __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
This is a model that predicts the blood glucose levels of a type-I diabetic. 
The objective is to predict the relationship between insulin injection and blood glucose levels. 
With a sufficiently accurate mathematical model of a patient, the correct insulin injection rate 
could be prescribed. 
By automating the sensing of blood glucose and the injection of insulin, this system would serve 
as an artificial pancreas. The model is composed of differential and algebraic equations. 
</p>
<p>
Reference:
</p>
<p>
S. M. Lynch and B. W. Bequette, Estimation based Model Predictive Control of Blood Glucose in 
Type I Diabetes: A Simulation Study, Proc. 27th IEEE Northeast Bioengineering Conference, IEEE, 2001.
</p>
<p>
and
</p>
<p>
S. M. Lynch and B. W. Bequette, Model Predictive Control of Blood Glucose in type I Diabetics 
using Subcutaneous Glucose Measurements, Proc. ACC, Anchorage, AK, 2002. 
</p>
<p>
Simulation time: 400s
</p>
</HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{-8,30},{-56,4}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-34,-8},{26,-38}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{24,12},{84,-18}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-18,-12},{8,-22}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{40,8},{68,-4}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-46,26},{-20,16}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid)}));
    end BloodGlucose_scaled;

    model BloodGlucoseSIunits
      import SI = Modelica.SIunits;
      //State start values
      parameter SI.Concentration G_init = 4.5;
      parameter SI.MolecularConcentration X_init = 15;
      parameter SI.MolecularConcentration I_init = 15;
      //States
      SI.Concentration G(start = G_init, fixed=true)
        "Plasma Glucose Conc. (mol/m3)";
      SI.MolecularConcentration X(start = X_init, fixed=true)
        "Plasma Insulin Conc. (u/m3)";
      SI.MolecularConcentration I(start = I_init, fixed=true)
        "Plasma Insulin Conc. (u/m3)";
      Real dist "Meal glucose disturbance (mol/m3/s)";
      //parameter
      parameter SI.Frequency P1 = 0.028735/60 "1/min";
      parameter SI.Frequency P2 = 0.028344/60 "1/min";
      parameter SI.Frequency P3 = 5.035e-5/60 "1/min";
      parameter SI.Volume V1 = 0.012 "m3";
      parameter SI.Frequency n = 5/54/60 "1/min";
      parameter SI.VolumeFlowRate f=1/60 "m3/s";
      //Control Signal
      Modelica.Blocks.Interfaces.RealInput D "Insulin Infusion rate"
       annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(G) = (-P1 * (G*4.5 - G_init) - (X - X_init) * G*4.5 *f + dist)/4.5;
      der(X) = -P2 * (X - X_init) + P3 * (I - I_init);
      der(I) = -n * I + D / V1;
      dist = 3*exp(-0.05*time/60)/60;
      annotation (experiment(StopTime=24000),
                                            __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
This is a model that predicts the blood glucose levels of a type-I diabetic. 
The objective is to predict the relationship between insulin injection and blood glucose levels. 
With a sufficiently accurate mathematical model of a patient, the correct insulin injection rate 
could be prescribed. 
By automating the sensing of blood glucose and the injection of insulin, this system would serve 
as an artificial pancreas. The model is composed of differential and algebraic equations. 
</p>
<p>
Reference:
</p>
<p>
S. M. Lynch and B. W. Bequette, Estimation based Model Predictive Control of Blood Glucose in 
Type I Diabetes: A Simulation Study, Proc. 27th IEEE Northeast Bioengineering Conference, IEEE, 2001.
</p>
<p>
and
</p>
<p>
S. M. Lynch and B. W. Bequette, Model Predictive Control of Blood Glucose in type I Diabetics 
using Subcutaneous Glucose Measurements, Proc. ACC, Anchorage, AK, 2002. 
</p>
<p>
Simulation time: 400s
</p>
</HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{-8,30},{-56,4}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-34,-8},{26,-38}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{24,12},{84,-18}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-18,-12},{8,-22}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{40,8},{68,-4}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-46,26},{-20,16}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid)}));
    end BloodGlucoseSIunits;

    model BloodGlucose1
      //State start values
      parameter Real G_init = 4.5;
      parameter Real X_init = 15;
      parameter Real I_init = 15;
      //States
      Real G(start = G_init, fixed=true) "Plasma Glucose Conc. (mmol/L)";
      Real X(start = X_init, fixed=true) "Plasma Insulin Conc. (mu/L)";
      Real I(start = I_init, fixed=true) "Plasma Insulin Conc. (mu/L)";
      Real dist "Meal glucose disturbance (mmol/L)";
      //parameter
      parameter Real D=3 "Insulin infusion rate (mU/min)";
      parameter Real P1 = 0.028735;
      parameter Real P2 = 0.028344;
      parameter Real P3 = 5.035e-5;
      parameter Real V1 = 12;
      parameter Real n = 5/54;
    equation
      der(G) = -P1 * (G - G_init) - (X - X_init) * G + dist;
      der(X) = -P2 * (X - X_init) + P3 * (I - I_init);
      der(I) = -n * I + D / V1;
      dist = 3*exp(-0.05*time);
      annotation (experiment(StopTime=400), __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
This is a model that predicts the blood glucose levels of a type-I diabetic. 
The objective is to predict the relationship between insulin injection and blood glucose levels. 
With a sufficiently accurate mathematical model of a patient, the correct insulin injection rate 
could be prescribed. 
By automating the sensing of blood glucose and the injection of insulin, this system would serve 
as an artificial pancreas. The model is composed of differential and algebraic equations. 
</p>
<p>
Reference:
</p>
<p>
S. M. Lynch and B. W. Bequette, Estimation based Model Predictive Control of Blood Glucose in 
Type I Diabetes: A Simulation Study, Proc. 27th IEEE Northeast Bioengineering Conference, IEEE, 2001.
</p>
<p>
and
</p>
<p>
S. M. Lynch and B. W. Bequette, Model Predictive Control of Blood Glucose in type I Diabetics 
using Subcutaneous Glucose Measurements, Proc. ACC, Anchorage, AK, 2002. 
</p>
</HTML>"),        Documentation(info="<HTML>
      <p>
      The model is equivalent to BloodGlucose1 but dD (the derivative of D) is set as an input instead of D. That makes it possible to use the derivative in the cost function when formulating the optimization problem.
      </p>
      <p>
      Simulation time: 400s
      </p>
      </HTML>"),
          Icon(graphics={
            Ellipse(
              extent={{-8,30},{-56,4}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-34,-8},{26,-38}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{24,12},{84,-18}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-18,-12},{8,-22}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{40,8},{68,-4}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-46,26},{-20,16}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillColor={168,0,0},
              fillPattern=FillPattern.Solid)}),
        Diagram(graphics));
    end BloodGlucose1;

    model BloodGlucose2
      //State start values
      parameter Real Gb = 98;
      parameter Real Xb = 0;
      parameter Real Ib = 0;
      parameter Real Yb = 0;
      parameter Real Fb = 380;
      parameter Real Zb = 380;
      //States
      Real G(start = Gb, fixed=true) "Blood Glucose (mg/dL)";
      Real X(start = Xb, fixed=true) "Remote insulin (micro-U/mL)";
      Real I(start = Ib, fixed=true) "Insulin (micro-U/mL)";
      Real Y(start = Gb, fixed=true) "Insulin for Lipogenesis (micro-U/mL)";
      Real F(start = Xb, fixed=true) "Plasma Free Fatty Acid (micro-mol/L)";
      Real Z(start = Ib, fixed=true) "Remote Free Fatty Acid (micro-mol/L)";
      //parameter
      parameter Real U=3 "Insulin infusion rate (mU/min)";
      parameter Real G_basal = 4.5 "mmol/L";
      parameter Real X_basal = 15 "mU/L";
      parameter Real I_basal = 15 "mU/L";
      parameter Real p1 = 0.068;
      parameter Real p2 = 0.037;
      parameter Real p3 = 0.000012;
      parameter Real p4 = 1.3;
      parameter Real p5 = 0.000568;
      parameter Real p6 = 0.00006;
      parameter Real p7 = 0.03;
      parameter Real p8 = 4.5;
      parameter Real k1 = 0.02;
      parameter Real k2 = 0.03;
      parameter Real pF2 = 0.17;
      parameter Real pF3 = 0.00001;
      parameter Real n = 0.142;
      parameter Real VolG = 117;
      parameter Real VolF = 11.7;
      parameter Real  u1 = 3 "insulin infusion rate";
      parameter Real  u2 = 300 "glucose uptake rate";
      parameter Real  u3 = 0 "external lipid infusion";
    equation
      der(G) = -p1*G - p4*X*G + p6*G*Z + p1*Gb - p6*Gb*Zb + u2/VolG
        "Glucose dynamics";
      der(X) = -p2*X + p3*I "Remote insulin compartment dynamics";
      der(I) = -n * I + p5 / u1 "Insulin dynamics";
      der(Y) = -pF2*Y + pF3*I "Insulin dynamics for lipogenesis";
      der(F) = -p7*(F-Fb) - p8*Y*F + 0.00021 * exp(-0.0055*G) * (F*G-Fb*Gb) + u3/VolF
        "Plasma Free Fatty Acid (FFA) dynamics";
      der(Z) = -k2*(Z-Zb) + k1*(F-Fb) "Remote FFA dynamics";
      annotation (Diagram(graphics),
        Documentation(info="<HTML>
<p>
This is a model that predicts the blood glucose levels of a type-I diabetic. 
The objective is to predict the relationship between insulin injection and blood glucose levels. 
With a sufficiently accurate mathematical model of a patient, the correct insulin injection rate 
could be prescribed. 
By automating the sensing of blood glucose and the injection of insulin, this system would serve 
as an artificial pancreas. The model is composed of differential and algebraic equations. 
</p>
<p>
Reference:
</p>
<p>
A. Roy and R.S. Parker. Dynamic Modeling of Free Fatty Acids, Glucose, and Insulin: An Extended 
Minimal Model, Diabetes Technology and Therapeutics 8(6), 617-626, 2006. 
</p>
<p>
Simulation time: 400s
</p>
</HTML>"));
    end BloodGlucose2;

    package Examples
      model BloodGlucoseInput
        Modelica.Blocks.Sources.Constant const(k=10)
          annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
        BloodGlucose bloodGlucose
          annotation (Placement(transformation(extent={{20,20},{40,40}})));
      equation
        connect(const.y, bloodGlucose.D) annotation (Line(
            points={{-19,30},{20,30}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=400),
          __Dymola_experimentSetupOutput,
          Documentation(info="<HTML>
    <p>
    The model is based on BloodGlucose1 and a constant input is set.
    </p>
    <p>
    Simulation time: 400s
    </p>
    
    </HTML>"));
      end BloodGlucoseInput;

      model BloodGlucoseInputscaled
        Modelica.Blocks.Sources.Constant const(k=2)
          annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
        BloodGlucose_scaled bloodGlucose_scaled
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
      equation
        connect(const.y, bloodGlucose_scaled.D) annotation (Line(
            points={{-39,10},{0,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (
          Diagram(graphics),
          experiment(StopTime=400),
          __Dymola_experimentSetupOutput);
      end BloodGlucoseInputscaled;
    end Examples;
  end BloodGlucose;

  package CatalystMixing
    model CatalystMixing
      //state start values
      parameter Real x1_0=1;
      parameter Real x2_0=0;
      //states
      Real x1(start=x1_0,fixed=true);
      Real x2(start=x2_0,fixed=true);
      //control signal
      Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(x1) = u*(10*x2-x1);
      der(x2) = u*(x1-10*x2) - (1-u)*x2;
      annotation (experiment, __Dymola_experimentSetupOutput,
      Documentation(info="<HTML>
  <p>
  This problem considers a plug-flow reactor, packed with two catalysts, involving the reactions S1 <-> S2 -> S3.
  The optimal mixing policy of the two catalysts has to be determined in order to maximize the production of species S3. 
  This dynamic optimization problem was originally proposed by Gunn and Thomas (1965), and subsequently considered by Logsdon (1990) and Vassiliadis (1993).
  </p>
  <p>
  Reference:
  </p>
  <p>
  Second-order sensitivities of general dynamic systems with application to optimal control problems. 1999, Vassilios S. Vassiliadis, Eva Balsa Canto, Julio R. Banga
  Case Study 6.2: Catalyst mixing
  </p>
  <p>
  Simulation time: 1s
  </p>
  </HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{-40,34},{62,6}},
              lineColor={0,0,255},
              lineThickness=0.5),
            Ellipse(
              extent={{-40,-26},{62,-54}},
              lineColor={0,0,255},
              lineThickness=0.5),
            Line(
              points={{-40,20},{-40,-40}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{62,20},{62,-40}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{62,66},{12,-14}},
              color={255,0,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{10,-6},{4,-8},{2,-10},{2,-12},{2,-14},{4,-16},{6,-18},{10,-20},
                  {16,-22},{20,-22},{24,-20},{26,-18},{26,-16},{24,-12},{22,-10}},
              color={255,0,0},
              thickness=0.5,
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled})}));
    end CatalystMixing;
  end CatalystMixing;

  package CatalyticCracking
    model CatalyticCracking
     //parameter
      parameter Real y1_0=1;
      parameter Real y2_0=0;
      parameter Real theta1=1;
      parameter Real theta2=1;
      parameter Real theta3=1;
      //states
      Real y1(start=y1_0);
      Real y2(start=y2_0);
    equation
      der(y1) = -(theta1+theta3)*y1^2;
      der(y2) = theta1*y1^2-theta2*y2;
       annotation (
        Documentation(info="<HTML>
<p>
Determine the reaction coefficients for the catalytic cracking of gas oil into gas and other
byproducts. The objective is to minimize the error between the concentration measurements and
the computed data.
</p>
<p>
Simulation time: 1s
</p>
</HTML>"), Icon(graphics={
            Line(
              points={{-26,14},{-30,18},{-36,22},{-44,26},{-50,32},{-52,40},{
                  -50,46},{-46,50},{-40,52},{-36,52},{-28,48},{-22,42},{-18,32},
                  {-14,22},{-12,14},{-10,2},{-10,0},{-10,-8},{-12,-6},{-16,4},{
                  -20,10},{-26,14}},
              color={0,0,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{0,18},{-4,32},{-10,44},{-16,54},{-20,64},{-22,74},{-20,
                  82},{-14,88},{-6,92},{2,92},{10,88},{14,78},{14,68},{10,52},{
                  4,38},{2,28},{0,20}},
              color={0,0,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{10,-20},{10,-4},{12,12},{20,28},{32,40},{42,44},{48,44},
                  {52,42},{54,38},{54,30},{52,26},{46,22},{38,18},{30,14},{24,8},
                  {20,0},{14,-8},{12,-14},{10,-20},{10,-24}},
              color={0,0,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{0,-50},{-2,-38},{-8,-26},{-18,-18},{-30,-14},{-34,-16},{
                  -36,-18},{-36,-20},{-34,-22},{-30,-24},{-24,-24},{-18,-24},{
                  -12,-28},{-8,-34},{-4,-40},{-2,-44},{0,-48}},
              color={0,0,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{2,-74},{4,-60},{8,-52},{14,-44},{20,-40},{26,-40},{28,
                  -44},{28,-48},{26,-52},{22,-54},{20,-56},{16,-58},{14,-60},{
                  10,-62},{8,-64},{4,-70},{2,-74},{2,-78}},
              color={0,0,0},
              thickness=0.5,
              smooth=Smooth.None)}),
        experiment,
        __Dymola_experimentSetupOutput);
    end CatalyticCracking;
  end CatalyticCracking;

  package ContState
    model ContState
         //State start values
         parameter Real x1_0 = 0;
         parameter Real x2_0= -1;
         //States
         Real x1(start = x1_0, fixed=true);
         Real x2(start = x2_0, fixed=true);
         Real p;
         //Control Signal
          Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
          p = 8*(time-0.5)^2-0.5-x2;
          der(x1) = x2;
          der(x2) = -x2+u;
      annotation (uses(Modelica(version="3.2")), Diagram(graphics),
        Icon(graphics={Line(
              points={{-66,0},{-58,-10},{-46,-18},{-28,-26},{52,-26},{62,-24},{
                  68,-20},{76,-8},{80,2},{82,14}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None)}),
                Documentation(info="<HTML>
<p>
Model with continous states and a path constraint
</p>
<p>
Simulation time: 1s
</p>

</HTML>"));
    end ContState;

    package Examples
      model ContStateExp
        ContState contState
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
        Modelica.Blocks.Sources.Exponentials exponentials
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(exponentials.y, contState.u) annotation (Line(
            points={{-19,10},{-5.4,10},{-5.4,10},{0,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          Documentation(info="<HTML>
<p>
input: exponential function
</p>
<p>
Simulation time: 1s
</p>


</HTML>"));
      end ContStateExp;

      model ContStateSine
        import JMExamples;
        JMExamples.ContState contState
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
        Modelica.Blocks.Sources.Sine sine
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(sine.y, contState.u) annotation (Line(
            points={{-19,10},{-5.4,10},{-5.4,11.2},{8.2,11.2}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          Documentation(info="<HTML>
<p>
input: sine function
</p>
<p>
Simulation time: 1s
</p>


</HTML>"));
      end ContStateSine;
    end Examples;
  end ContState;

  package CSTR
    model CSTR "Continuous stirred tank reaction"
      parameter Modelica.SIunits.VolumeFlowRate F0=100/1000/60 "Inflow";
      parameter Modelica.SIunits.Concentration c0=1000
        "Concentration of inflow";
      parameter Modelica.SIunits.VolumeFlowRate F=100/1000/60 "Outflow";
      parameter Modelica.SIunits.Temp_K T0 = 350;
      parameter Modelica.SIunits.Length r = 0.219;
      parameter Real k0 = 7.2e10/60;
      parameter Real EdivR = 8750;
      parameter Real U = 915.6;
      parameter Real rho = 1000;
      parameter Real Cp = 0.239*1000;
      parameter Real dH = -5e4;
      parameter Modelica.SIunits.Volume V = 100 "Reactor Volume";
      parameter Modelica.SIunits.Concentration c_init = 1000;
      parameter Modelica.SIunits.Temp_K T_init = 350;
      Real c(start=c_init,fixed=true,nominal=c0);
      Real T(start=T_init,fixed=true,nominal=T0);
      Modelica.Blocks.Interfaces.RealInput Tc "cooling temperature"
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(c) = F0*(c0-c)/V-k0*c*exp(-EdivR/T);
      der(T) = F0*(T0-T)/V-dH/(rho*Cp)*k0*c*exp(-EdivR/T)+2*U/(r*rho*Cp)*(Tc-T);
      annotation (
        Documentation(info="<HTML>
<p>
CSTR The Continuously Stirred Tank Reactors (CSTR) system has two states: the concentration c and the temperature T. 
The control input to the system is the temperature of the cooling flow in the reactor jacket Tc. 
The chemical reaction in the reactor is exothermic and also temperature dependent; 
high temperature results in high reaction rate.
</p>
<p>
Simulation time: 150s
</p>

</HTML>"),
        experiment(StopTime=150),
        __Dymola_experimentSetupOutput,
        Diagram(graphics),
        Icon(graphics={
            Rectangle(
              extent={{-60,60},{60,-80}},
              lineColor={0,0,255},
              lineThickness=0.5),
            Line(
              points={{0,80},{0,-40}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Ellipse(extent={{0,-34},{-42,-46}}, lineColor={0,0,255}),
            Ellipse(extent={{42,-34},{0,-46}}, lineColor={0,0,255}),
            Line(
              points={{-30,78},{-30,20},{-30,22},{-30,16}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{42,-62},{82,-62},{84,-62}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled})}));
    end CSTR;

    model CSTR_Init_Optimization
      CSTR cstr "CSTR component";
      Real cost(start=0,fixed=true);
      Real u = Tc_ref;
      parameter Real c_ref = 500;
      parameter Real T_ref = 320;
      parameter Real Tc_ref = 350;
      parameter Real q_c = 1;
      parameter Real q_T = 1;
      parameter Real q_Tc = 1;
    equation
      cstr.Tc = Tc_ref;
      der(cost) = q_c*(c_ref-cstr.c)^2 + q_T*(T_ref-cstr.T)^2 +
                      q_Tc*(Tc_ref-cstr.Tc)^2;
    end CSTR_Init_Optimization;

    package Examples
      model CSTRconst
        CSTR cSTR annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.Constant const(k=259)
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(const.y, cSTR.Tc) annotation (Line(
            points={{-19,10},{2,10},{2,10},{20,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          Documentation(info="<HTML>
<p>
input: constant function
</p>
<p>
Simulation time: 150s
</p>

</HTML>"));
      end CSTRconst;

      model CSTRexp
        CSTR cSTR annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.Exponentials exponentials(
          riseTime=10,
          riseTimeConst=1,
          offset=230,
          outMax=39)
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(exponentials.y, cSTR.Tc) annotation (Line(
            points={{-19,10},{2,10},{2,10},{20,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          Documentation(info="<HTML>
<p>
input: exponential function
</p>
<p>
Simulation time: 150s
</p>

</HTML>"));
      end CSTRexp;

      model CSTRtimetable
        CSTR cSTR annotation (Placement(transformation(extent={{0,20},{20,40}})));
        Modelica.Blocks.Sources.TimeTable timeTable(table=[0,264.4; 10,264.4; 10,
              200; 50,280; 60,280])
          annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
      equation
        connect(timeTable.y, cSTR.Tc) annotation (Line(
            points={{-39,30},{-18,30},{-18,30},{0,30}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=60),
          __Dymola_experimentSetupOutput,
          Documentation(info="<HTML>
<p>
input: step function
</p>
<p>
Simulation time: 150s
</p>

</HTML>"));
      end CSTRtimetable;
    end Examples;
  end CSTR;

  package Distillation
    model Distillation1
      import SI = Modelica.SIunits;
      parameter Real rr=3.7 "reflux ratio; initial condition: rr_init=3";
      parameter SI.MolarFlowRate Feed =  24.0/360 "Feed Flowrate";
      parameter Real x_Feed = 0.5 "Mole Fraction of Feed";
      parameter SI.MolarFlowRate D=0.5*Feed "Distillate Flowrate";
      parameter SI.MolarFlowRate L=rr*D
        "Flowrate of the Liquid in the Rectification Section";
      parameter SI.MolarFlowRate V=L+D "Vapor Flowrate in the Column";
      parameter SI.MolarFlowRate FL=Feed+L
        "Flowrate of the Liquid in the Stripping Section";
      parameter Real vol=1.6
        "Relative Volatility = (yA/xA)/(yB/xB) = KA/KB = alpha(A,B)";
      parameter Real atray=0.25 "Total Molar Holdup in the Condenser";
      parameter Real acond=0.5 "Total Molar Holdup on each Tray";
      parameter Real areb=1.0 "Total Molar Holdup in the Reboiler";
      parameter Real x_init[32]={0.93541941614016,
       0.90052553715795,
       0.86229645132283,
       0.82169940277993,
       0.77999079584355,
       0.73857168629759,
       0.69880490932694,
       0.66184253445732,
       0.62850777645505,
       0.59925269993058,
       0.57418567956453,
       0.55314422743545,
       0.53578454439850,
       0.52166550959767,
       0.51031495114413,
       0.50127509227528,
       0.49412891686784,
       0.48544992019184,
       0.47420248108803,
       0.45980349896163,
       0.44164297270225,
       0.41919109776836,
       0.39205549194059,
       0.36024592617390,
       0.32407993023343,
       0.28467681591738,
       0.24320921343484,
       0.20181568276528,
       0.16177269003094,
       0.12514970961746,
       0.09245832612765,
       0.06458317697321} "initial conditions for the states";
      Real x[32](start=x_init)
        "mole fraction of A at each state, column vector";
      Real y[32] "vapor Mole Fractions of Component A";
    equation
        y = (x*vol)./(1 .+((vol-1)*x));
       der(x[1]) = 1/acond *(V*(y[2]-x[1])) "condenser";
       der(x[2:16])  = 1/atray *(L*(x[1:15]-x[2:16]) - V*(y[2:16]-y[3:17]))
        "15 column stages";
       der(x[17]) = 1/atray * (Feed*x_Feed + L*x[16] - FL*x[17] - V*(y[17]-y[18]))
        "feed tray";
       der(x[18:31]) = 1/atray * (FL*(x[17:30]-x[18:31]) - V*(y[18:31]-y[19:32]))
        "14 column stages";
       der(x[32]) = 1/areb  * (FL*x[31] - (Feed-D)*x[32] - V*y[32]) "reboiler";
        annotation (Placement(transformation(extent={{-84,12},{-44,52}})),
        experiment(StopTime=7200),
        __Dymola_experimentSetupOutput,
                    Placement(transformation(extent={{-118,0},{-78,40}})),
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
Reference:
</p>
<p>
Hahn, J. and T.F. Edgar, An improved method for nonlinear model reduction using balancing of
empirical gramians, Computers and Chemical Engineering, 26, pp. 1379-1397, (2002)
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"),
        Icon(graphics={
            Rectangle(extent={{-40,80},{40,-80}}, lineColor={127,0,127},
              lineThickness=0.5),
            Line(
              points={{-40,40},{20,40},{20,30}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{40,0},{-20,0},{-20,-12}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{-40,-40},{20,-40},{20,-52}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{0,-72},{0,-50},{0,-48}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,-30},{0,-12},{0,-12},{0,-8}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,10},{0,30}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,48},{0,68}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{88,10},{40,10}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,80},{0,90},{70,90}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{68,-90},{0,-90},{0,-80}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled})}));
    end Distillation1;

    model Distillation1Input
      import SI = Modelica.SIunits;
    //parameters
      parameter SI.MolarFlowRate Feed =  24.0/60 "Feed Flowrate";
      parameter SI.MassFraction x_Feed = 0.5 "Mole Fraction of Feed";
      parameter SI.MolarFlowRate D=0.5*Feed "Distillate Flowrate";
      parameter Real vol=1.6
        "Relative Volatility = (yA/xA)/(yB/xB) = KA/KB = alpha(A,B)";
      parameter SI.AmountOfSubstance atray=0.25
        "Total Molar Holdup in the Condenser";
      parameter SI.AmountOfSubstance acond=0.5
        "Total Molar Holdup on each Tray";
      parameter SI.AmountOfSubstance areb=1.0
        "Total Molar Holdup in the Reboiler";
    //initial conditions
      parameter SI.MoleFraction x_init[32]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        "initial conditions for the states";
    //variables
      SI.MoleFraction x[32](start=x_init, each min=0)
        "mole fraction of A at each state, column vector";
      SI.MoleFraction y[32](each min=0) "vapor Mole Fractions of Component A";
      SI.MolarFlowRate L "Flowrate of the Liquid in the Rectification Section";
      SI.MolarFlowRate V "Vapor Flowrate in the Column";
      SI.MolarFlowRate FL "Flowrate of the Liquid in the Stripping Section";
    //input
      Modelica.Blocks.Interfaces.RealInput rr(start=1)
        annotation (Placement(transformation(extent={{-20,-10},{20,30}})));
    equation
     //ODE
       der(x[1]) = 1/acond *(V*(y[2]-x[1])) "condenser";
       der(x[2:16])  = 1/atray *(L*(x[1:15]-x[2:16]) - V*(y[2:16]-y[3:17]))
        "15 column stages";
       der(x[17]) = 1/atray * (Feed*x_Feed + L*x[16] - FL*x[17] - V*(y[17]-y[18]))
        "feed tray";
       der(x[18:31]) = 1/atray * (FL*(x[17:30]-x[18:31]) - V*(y[18:31]-y[19:32]))
        "14 column stages";
       der(x[32]) = 1/areb  * (FL*x[31] - (Feed-D)*x[32] - V*y[32]) "reboiler";
     //DAE
       y = (x*vol)./(1 .+((vol-1)*x));
       L=rr*D;
       V=L+D;
       FL=Feed+L;
        annotation (Placement(transformation(extent={{-84,12},{-44,52}})),
        experiment(StopTime=7200),
        __Dymola_experimentSetupOutput,
                    Placement(transformation(extent={{-118,0},{-78,40}})),
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
Reference:
</p>
<p>
Hahn, J. and T.F. Edgar, An improved method for nonlinear model reduction using balancing of
empirical gramians, Computers and Chemical Engineering, 26, pp. 1379-1397, (2002)
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"),
        Icon(graphics={
            Rectangle(extent={{-40,80},{40,-80}}, lineColor={127,0,127},
              lineThickness=0.5),
            Line(
              points={{-40,40},{20,40},{20,30}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{40,0},{-20,0},{-20,-12}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{-40,-40},{20,-40},{20,-52}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{0,-72},{0,-50},{0,-48}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,-30},{0,-12},{0,-12},{0,-8}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,10},{0,30}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,48},{0,68}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{88,10},{40,10}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,80},{0,90},{70,90}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{68,-90},{0,-90},{0,-80}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled})}),
        Diagram(graphics));
    end Distillation1Input;

    model Distillation1Inputder
      import SI = Modelica.SIunits;
      parameter SI.MolarFlowRate Feed =  24.0/60 "Feed Flowrate";
      parameter SI.MassFraction x_Feed = 0.5 "Mole Fraction of Feed";
      parameter SI.MolarFlowRate D=0.5*Feed "Distillate Flowrate";
      parameter Real vol=1.6
        "Relative Volatility = (yA/xA)/(yB/xB) = KA/KB = alpha(A,B)";
      parameter SI.AmountOfSubstance atray=0.25
        "Total Molar Holdup in the Condenser";
      parameter SI.AmountOfSubstance acond=0.5
        "Total Molar Holdup on each Tray";
      parameter SI.AmountOfSubstance areb=1.0
        "Total Molar Holdup in the Reboiler";
      parameter SI.MoleFraction x_init[32]={0.93541941614016,
       0.90052553715795,
       0.86229645132283,
       0.82169940277993,
       0.77999079584355,
       0.73857168629759,
       0.69880490932694,
       0.66184253445732,
       0.62850777645505,
       0.59925269993058,
       0.57418567956453,
       0.55314422743545,
       0.53578454439850,
       0.52166550959767,
       0.51031495114413,
       0.50127509227528,
       0.49412891686784,
       0.48544992019184,
       0.47420248108803,
       0.45980349896163,
       0.44164297270225,
       0.41919109776836,
       0.39205549194059,
       0.36024592617390,
       0.32407993023343,
       0.28467681591738,
       0.24320921343484,
       0.20181568276528,
       0.16177269003094,
       0.12514970961746,
       0.09245832612765,
       0.06458317697321} "initial conditions for the states";
      SI.MoleFraction x[32](start=x_init, each min=0)
        "mole fraction of A at each state, column vector";
      SI.MoleFraction y[32](each min=0) "vapor Mole Fractions of Component A";
      SI.MolarFlowRate L "Flowrate of the Liquid in the Rectification Section";
      SI.MolarFlowRate V "Vapor Flowrate in the Column";
      SI.MolarFlowRate FL "Flowrate of the Liquid in the Stripping Section";
      Real rr(start=3.7) "reflux ratio";
      //input
      Modelica.Blocks.Interfaces.RealInput drr
        annotation (Placement(transformation(extent={{-20,-10},{20,30}})));
    equation
        y = (x*vol)./(1 .+((vol-1)*x));
       der(x[1]) = 1/acond *(V*(y[2]-x[1])) "condenser";
       der(x[2:16])  = 1/atray *(L*(x[1:15]-x[2:16]) - V*(y[2:16]-y[3:17]))
        "15 column stages";
       der(x[17]) = 1/atray * (Feed*x_Feed + L*x[16] - FL*x[17] - V*(y[17]-y[18]))
        "feed tray";
       der(x[18:31]) = 1/atray * (FL*(x[17:30]-x[18:31]) - V*(y[18:31]-y[19:32]))
        "14 column stages";
       der(x[32]) = 1/areb  * (FL*x[31] - (Feed-D)*x[32] - V*y[32]) "reboiler";
       der(rr) = drr;
       //DAE
       L=rr*D;
       V=L+D;
       FL=Feed+L;
        annotation (Placement(transformation(extent={{-84,12},{-44,52}})),
        experiment(StopTime=7200),
        __Dymola_experimentSetupOutput,
                    Placement(transformation(extent={{-118,0},{-78,40}})),
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
Reference:
</p>
<p>
Hahn, J. and T.F. Edgar, An improved method for nonlinear model reduction using balancing of
empirical gramians, Computers and Chemical Engineering, 26, pp. 1379-1397, (2002)
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"),
        Icon(graphics={
            Rectangle(extent={{-40,80},{40,-80}}, lineColor={127,0,127},
              lineThickness=0.5),
            Line(
              points={{-40,40},{20,40},{20,30}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{40,0},{-20,0},{-20,-12}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{-40,-40},{20,-40},{20,-52}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{0,-72},{0,-50},{0,-48}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,-30},{0,-12},{0,-12},{0,-8}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,10},{0,30}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,48},{0,68}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{88,10},{40,10}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,80},{0,90},{70,90}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{68,-90},{0,-90},{0,-80}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled})}),
        Diagram(graphics));
    end Distillation1Inputder;

    model Distillation1Input_init
      extends Distillation1Input;
    initial equation
    //steady state
    der(x) = zeros(32);
      annotation (experiment(StopTime=7200), __Dymola_experimentSetupOutput);
    end Distillation1Input_init;

    model Distillation1Inputstep
      import SI = Modelica.SIunits;
      parameter SI.MolarFlowRate Feed =  24.0/60 "Feed Flowrate";
      parameter Real x_Feed = 0.5 "Mole Fraction of Feed";
      parameter SI.MolarFlowRate D=0.5*Feed "Distillate Flowrate";
      parameter Real vol=1.6
        "Relative Volatility = (yA/xA)/(yB/xB) = KA/KB = alpha(A,B)";
      parameter Real atray=0.25 "Total Molar Holdup in the Condenser";
      parameter Real acond=0.5 "Total Molar Holdup on each Tray";
      parameter Real areb=1.0 "Total Molar Holdup in the Reboiler";
      parameter Real x_init[32]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        "initial conditions for the states";
      Real x[32](start=x_init, each min=0)
        "mole fraction of A at each state, column vector";
      Real y[32](each min=0) "vapor Mole Fractions of Component A";
      SI.MolarFlowRate L "Flowrate of the Liquid in the Rectification Section";
      SI.MolarFlowRate V "Vapor Flowrate in the Column";
      SI.MolarFlowRate FL "Flowrate of the Liquid in the Stripping Section";
      Real rr "reflux ratio";
    equation
        y = (x*vol)./(1 .+((vol-1)*x));
       der(x[1]) = 1/acond *(V*(y[2]-x[1])) "condenser";
       der(x[2:16])  = 1/atray *(L*(x[1:15]-x[2:16]) - V*(y[2:16]-y[3:17]))
        "15 column stages";
       der(x[17]) = 1/atray * (Feed*x_Feed + L*x[16] - FL*x[17] - V*(y[17]-y[18]))
        "feed tray";
       der(x[18:31]) = 1/atray * (FL*(x[17:30]-x[18:31]) - V*(y[18:31]-y[19:32]))
        "14 column stages";
       der(x[32]) = 1/areb  * (FL*x[31] - (Feed-D)*x[32] - V*y[32]) "reboiler";
       rr = if time<=10 then 3 else 2.0;
       //DAE
       L=rr*D;
       V=L+D;
       FL=Feed+L;
        annotation (Placement(transformation(extent={{-84,12},{-44,52}})),
        experiment(StopTime=7200),
        __Dymola_experimentSetupOutput,
                    Placement(transformation(extent={{-118,0},{-78,40}})),
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
Reference:
</p>
<p>
Hahn, J. and T.F. Edgar, An improved method for nonlinear model reduction using balancing of
empirical gramians, Computers and Chemical Engineering, 26, pp. 1379-1397, (2002)
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"),
        Icon(graphics={
            Rectangle(extent={{-40,80},{40,-80}}, lineColor={127,0,127},
              lineThickness=0.5),
            Line(
              points={{-40,40},{20,40},{20,30}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{40,0},{-20,0},{-20,-12}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{-40,-40},{20,-40},{20,-52}},
              color={127,0,127},
              smooth=Smooth.None,
              thickness=0.5),
            Line(
              points={{0,-72},{0,-50},{0,-48}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,-30},{0,-12},{0,-12},{0,-8}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,10},{0,30}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,48},{0,68}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{88,10},{40,10}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{0,80},{0,90},{70,90}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled}),
            Line(
              points={{68,-90},{0,-90},{0,-80}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled})}),
        Diagram(graphics));
    end Distillation1Inputstep;

    model Distillation2
      import SI = Modelica.SIunits;
      parameter Real rr=2.7 "reflux ratio; initial condition: rr_init=3";
      parameter SI.MolarFlowRate Feed =  24.0/3600 "Feed Flowrate";
      parameter Real x_Feed = 0.5 "Mole Fraction of Feed";
      parameter SI.MolarFlowRate D=0.5*Feed "Distillate Flowrate";
      parameter SI.MolarFlowRate L=rr*D
        "Flowrate of the Liquid in the Rectification Section";
      parameter SI.MolarFlowRate V=L+D "Vapor Flowrate in the Column";
      parameter SI.MolarFlowRate FL=Feed+L
        "Flowrate of the Liquid in the Stripping Section";
      parameter Real atray=0.25 "Total Molar Holdup in the Condenser";
      parameter Real acond=0.5 "Total Molar Holdup on each Tray";
      parameter Real areb=1.0 "Total Molar Holdup in the Reboiler";
      parameter Real sp_ratio = 1.7
        "Ratio of the Saturation Pressures = PsatA/PsatB";
      parameter Real L12 = 1.618147731;
      parameter Real L21 = 0.50253532
        "Wilson Activity Coefficient Model Parameters";
      parameter Real x_init[32]={0.97339252747326,
       0.95790444111368,
       0.93963386412300,
       0.91821664141445,
       0.89334470835687,
       0.86483847458375,
       0.83273815158540,
       0.79739606050503,
       0.75953677930557,
       0.72024599485005,
       0.68086442052299,
       0.64280066114073,
       0.60731690633284,
       0.57535610831821,
       0.54745802413982,
       0.52377039366803,
       0.50412746272762,
       0.49037636253375,
       0.47205010235430,
       0.44820197086528,
       0.41811322760501,
       0.38159643880344,
       0.33930475369667,
       0.29288862241213,
       0.24483954092739,
       0.19799745874320,
       0.15490859777720,
       0.11732282321971,
       0.08601628593205,
       0.06092130595344,
       0.04141387478979,
       0.02660747253544} "initial conditions for the states";
      Real x[32](start=x_init)
        "mole fraction of A at each state, column vector";
      Real y[32] "vapor Mole Fractions of Component A";
      Real gammaA[32];
      Real gammaB[32];
      Real vol[ 32];
    equation
       for i in 1:32 loop
          gammaA[i] = exp(-log(x[i] + L12 * (1 - x[i])) + (1 - x[i]) * (L12 / (x[i] + L12 * (1 - x[i])) - (L21 / (L21 * x[i] + (1 - x[i])))));
          gammaB[i] = exp(-log((1 - x[i]) + L21 * x[i]) + x[i] * (L21 / ((1 - x[i]) + L21 * x[i]) - (L12 / (L12 * (1 - x[i]) + x[i]))));
       end for "Wilson Equations";
       vol = sp_ratio * (gammaA ./gammaB) "Compute the Relative Volatility";
       y = (x .*vol) ./(1 .+((vol .-1) .*x))
        "Vapor Mole Fractions of Component A";
       der(x[1]) = 1/acond *(V*(y[2]-x[1])) "condenser";
       der(x[2:16])  = 1/atray *(L*(x[1:15]-x[2:16]) - V*(y[2:16]-y[3:17]))
        "15 column stages";
       der(x[17]) = 1/atray * (Feed*x_Feed + L*x[16] - FL*x[17] - V*(y[17]-y[18]))
        "feed tray";
       der(x[18:31]) = 1/atray * (FL*(x[17:30]-x[18:31]) - V*(y[18:31]-y[19:32]))
        "14 column stages";
       der(x[32]) = 1/areb  * (FL*x[31] - (Feed-D)*x[32] - V*y[32]) "reboiler";
        annotation (Placement(transformation(extent={{-84,12},{-44,52}})),
        experiment(StopTime=120, Algorithm="Dassl"),
        __Dymola_experimentSetupOutput(
          textual=true,
          doublePrecision=true,
          derivatives=false,
          inputs=false,
          outputs=false,
          auxiliaries=false),
                    Placement(transformation(extent={{-118,0},{-78,40}})),
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
J.D. Hedengren added a Wilson equation for the Vapor-Liquid Equilibrium. This improved the
model through the Raoult's Law assumption (constant relative volatility).
</p>
<p>
Reference:
</p>
<p>
Hahn, J. and T.F. Edgar, An improved method for nonlinear model reduction using balancing of
empirical gramians, Computers and Chemical Engineering, 26, pp. 1379-1397, (2002)
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"));
    end Distillation2;

    model Distillation3
      import SI = Modelica.SIunits;
      parameter Real rr=2.7 "reflux ratio";
      parameter SI.MolarFlowRate Feed =  24.0/3600 "Feed Flowrate";
      parameter Real x_Feed = 0.5 "Mole Fraction of Feed";
      parameter SI.MolarFlowRate D=0.5*Feed "Distillate Flowrate";
      parameter SI.MolarFlowRate L=rr*D
        "Flowrate of the Liquid in the Rectification Section";
      parameter SI.MolarFlowRate V=L+D "Vapor Flowrate in the Column";
      parameter SI.MolarFlowRate FL=Feed+L
        "Flowrate of the Liquid in the Stripping Section";
      parameter Real atray=0.25 "Total Molar Holdup in the Condenser";
      parameter Real acond=0.5 "Total Molar Holdup on each Tray";
      parameter Real areb=1.0 "Total Molar Holdup in the Reboiler";
      parameter SI.Pressure P=101000 "total pressure in column (Pa)";
      parameter Real[5,2] DIPPR= {{5.1087E1,    8.7829E1},
             {-5.2264E3,   -6.9964E3},
             {-4.2278E0,   -9.8802E0},
              {9.7554E-18,  7.2099E-6},
              {6.0000E0,    2.0000E0}} "Saturated Vapor Pressures
                                    Data from the DIPPR Database (empirical fit";
      parameter Real L12 = 1.618147731
        "Activity Coefficients of Liquid Mixture";
      parameter Real L21 = 0.50253532
        "Wilson Activity Coefficient Model Parameters";
      parameter Real x_init[32]={0.97287970129754,
       0.95636038934316,
       0.93661040294083,
       0.91321282273197,
       0.88585270419340,
       0.85442258268073,
       0.81914368999749,
       0.78066600262237,
       0.74009371717436,
       0.69889223479787,
       0.65867789383232,
       0.62095142736705,
       0.58686770454651,
       0.55711313643268,
       0.53190656888283,
       0.51108997385426,
       0.49425664303546,
       0.47785779539230,
       0.45662374470122,
       0.42987184311163,
       0.39729919963226,
       0.35923134730789,
       0.31678635583970,
       0.27183384568409,
       0.22669854804022,
       0.18369476978786,
       0.14468004616214,
       0.11079600651024,
       0.08244638861628,
       0.05944779752760,
       0.04124685281752,
       0.02712029870246};
      parameter SI.Temperature T_init[32]=100 *{3.54170894061095,
       3.54384309151657,
       3.54642323740009,
       3.54952180753185,
       3.55320509380443,
       3.55751925276361,
       3.56247139366757,
       3.56800942498801,
       3.57400825826251,
       3.58027163739042,
       3.58655486133578,
       3.59260419440273,
       3.59819966694026,
       3.60318627239385,
       3.60748534712935,
       3.61108752771922,
       3.61403480708638,
       3.61693563210643,
       3.62073526774064,
       3.62559227397992,
       3.63161163785833,
       3.63879364907630,
       3.64698872172953,
       3.65588344068293,
       3.66503752584723,
       3.67396743659234,
       3.68224472290915,
       3.68956911381347,
       3.69579402098210,
       3.70090876480212,
       3.70499767004852,
       3.70819628750959};
      Real x[32](start=x_init)
        "mole fraction of A at each state, column vector";
      SI.Temperature T[32](start=T_init) "Temperature at each state";
      Real y[32] "vapor Mole Fractions of Component A";
      Real PsatA[32];
      Real PsatB[32];
      Real gammaA[32];
      Real gammaB[32];
    equation
      for i in 1:32 loop
       PsatA[i] = exp(DIPPR[1,1] + DIPPR[2,1]/T[i] + DIPPR[3,1] * log(T[i]) +
          DIPPR[4,1] * (T[i]^DIPPR[5,1]));
       PsatB[i] = exp(DIPPR[1,2] + DIPPR[2,2]/T[i] + DIPPR[3,2] * log(T[i]) +
          DIPPR[4,2] * (T[i]^DIPPR[5,2]));
      end for;
      for i in 1:32 loop
         gammaA[i] = exp(-log(x[i] + L12 * (1 - x[i])) + (1 - x[i]) * (L12 / (x[i] + L12 * (1 - x[i])) - (L21 / (L21 * x[i] + (1 - x[i])))));
         gammaB[i] = exp(-log((1 - x[i]) + L21 * x[i]) + x[i] * (L21 / ((1 - x[i]) + L21 * x[i]) - (L12 / (L12 * (1 - x[i]) + x[i]))));
      end for "Wilson Equations";
      for i in 1:32 loop
         y[i] = x[i]*gammaA[i]*(PsatA[i] / P)
          "Vapor Mole Fractions of Component A";
      end for;
    //ODE
       der(x[1]) = 1/acond *(V*(y[2]-x[1])) "condenser";
       der(x[2:16])  = 1/atray *(L*(x[1:15]-x[2:16]) - V*(y[2:16]-y[3:17]))
        "15 column stages";
       der(x[17]) = 1/atray * (Feed*x_Feed + L*x[16] - FL*x[17] - V*(y[17]-y[18]))
        "feed tray";
       der(x[18:31]) = 1/atray * (FL*(x[17:30]-x[18:31]) - V*(y[18:31]-y[19:32]))
        "14 column stages";
       der(x[32]) = 1/areb  * (FL*x[31] - (Feed-D)*x[32] - V*y[32]) "reboiler";
    //DAE
       for i in 1:32 loop
          0= ((x[i]*gammaA[i]*PsatA[i]) + ((1-x[i])*gammaB[i]*PsatB[i])-P)/P
          "der( T[i])=0";
       end for;
        annotation (Placement(transformation(extent={{-84,12},{-44,52}})),
        experiment(StopTime=7200, Algorithm="Dassl"),
        __Dymola_experimentSetupOutput(
          textual=true,
          doublePrecision=true,
          inputs=false),
                    Placement(transformation(extent={{-118,0},{-78,40}})),
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
J.D. Hedengren added the Wilson equation for the Vapor-Liquid Equilibrium. This improved the
model through the Raoult's Law assumption (constant relative volatility)and also made the
model into a 64 state DAE with 32 DE and 32 AE (originally a 32 state ODE).
</p>
<p>
Reference:
</p>
<p>
Hahn, J. and T.F. Edgar, An improved method for nonlinear model reduction using balancing of
empirical gramians, Computers and Chemical Engineering, 26, pp. 1379-1397, (2002)
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"));
    end Distillation3;

    model Distillation4
      import SI = Modelica.SIunits;
    // Inputs
      Modelica.Blocks.Interfaces.RealInput Q_elec(start=Q_elec_ref)
        "Input 1: Heat Input to the Reboiler from an Electric Heater Q_elec = u(1,1)";
      Modelica.Blocks.Interfaces.RealInput Vdot_L1(start=Vdot_L1_ref)
        "Input 2: Flow Rate of the Recycled Distillate Vdot_L1 = u(2,1)";
    // Parameters - Steady-state reference values
      parameter Real Q_elec_ref = 2.45e3;
      parameter SI.VolumeFlowRate Vdot_L1_ref = 4.3/1000/3600;
      constant Real absolute_zero = -273.15;
      parameter Real T_14_ref = 88 - absolute_zero;
      parameter Real T_28_ref = 70 - absolute_zero;
    // Parameters - Nominal Operating Conditions
      parameter SI.VolumeFlowRate Vdot_Feed =  14.0 / 3600 / 1000
        "Feed Flowrate (m^3/sec)";
      parameter Real xA_Feed = 0.32 "Mole Fraction of Feed";
      parameter SI.Temp_K Temp_Feed = 71.0 + 273.15 "Feed Temperature (K)";
      parameter SI.Pressure P_top = 0.97 * 1.0e5 "Top Pressure (Pa)";
      parameter SI.Volume V_Condenser = 0.17 / 1000 "Condenser Holdup(m^3)";
      parameter SI.Volume V_Reboiler = 8.5 / 1000 "Reboiler Holdup(m^3)";
      parameter SI.HeatFlowRate Q_loss = 0.51e3
        "Heat Loss from the Reboiler (J/sec)";
      parameter SI.Pressure dP_rect = 1.9e3
        "Pressure Drop in Above Feed Section(Pa)";
      parameter SI.Pressure dP_strip = 2.5e3
        "Pressure Drop in Below Feed Section(Pa)";
      parameter Real alpha_rect = 0.35;
      parameter Real alpha_strip = 0.62 "Tray Efficiencies";
    // Parameters - Physical Properties
      // Molar Volume (m^3/mol) of Component A and B
      parameter Real a1_A = 2.288e3 "Units (mol/m^3)";
      parameter Real a1_B = 1.235e3 "Units (mol/m^3)";
      parameter Real b1_A = 0.2685 "Units (dimensionless)";
      parameter Real b1_B = 0.27136 "Units (dimensionless)";
      parameter Real d1_A = 0.2453 "Units (dimensionless)";
      parameter Real d1_B = 0.2400 "Units (dimensionless)";
      parameter SI.Temp_K c1_A = 512.4 "Units (K)";
      parameter SI.Temp_K c1_B = 536.4 "Units (K)";
      parameter SI.MolarVolume V_mol_A_Feed = (1 / a1_A) * (b1_A ^ (1 + (1 - (Temp_Feed / c1_A)) ^ d1_A));
      parameter SI.MolarVolume V_mol_B_Feed = (1 / a1_B) * (b1_B ^ (1 + (1 - (Temp_Feed / c1_B)) ^ d1_B));
    // Parameters Pure Component A Saturation Pressure - Antione Equation
      parameter Real a2_A = 23.48 "Units (dimensionless)";
      parameter Real a2_B = 22.437 "Units (dimensionless)";
      parameter SI.Temp_K b2_A = 3626.6 "Units (K)";
      parameter SI.Temp_K b2_B = 3166.4 "Units (K)";
      parameter Real c2_A = -34.29 "Units (dimensionless)";
      parameter Real c2_B = -80.15 "Units (dimensionless)";
    // Enthalpy Coefficients
      parameter Real h1_A = 18.31 "Units (1/K)";
      parameter Real h1_B = 31.92 "Units (1/K)";
      parameter Real h2_A = 1.713e-2 "Units (1/K^2)";
      parameter Real h2_B = 4.49e-2 "Units (1/K^2)";
      parameter Real h3_A = 6.399e-5 "Units (1/K^3)";
      parameter Real h3_B = 9.663e-5 "Units (1/K^3)";
      parameter SI.Temp_K Tc_A = 512.6 "Units (K)";
      parameter SI.Temp_K Tc_B = 536.7 "Units (K)";
      parameter SI.Pressure Pc_A = 8.096e6 "Units (Pa)";
      parameter SI.Pressure Pc_B = 5.166e6 "Units (Pa)";
      parameter Real Omega_A = 0.557 "Units (dimensionless)";
      parameter Real Omega_B = 0.612 "Units (dimensionless)";
      parameter SI.Temp_K To = 273.15 "Units (K)";
      parameter Real c1 = 4.186 "Units (J/mol)";
      parameter SI.MolarHeatCapacity Univ_R = 8.31451
        "Universal Gas Law Constant";
      parameter Real[6] c2 = {6.09648,1.28862,1.016,15.6875,13.4721,2.615}
        "Units (dimensionless)";
      parameter SI.Enthalpy hL_A_Feed = c1*(h1_A*(Temp_Feed - To) + h2_A*(Temp_Feed - To)^2 + h3_A*(Temp_Feed - To)^3);
      parameter SI.Enthalpy hL_B_Feed = c1*(h1_B*(Temp_Feed - To) + h2_B*(Temp_Feed - To)^2 + h3_B*(Temp_Feed - To)^3);
      parameter SI.Enthalpy hL_Feed = xA_Feed * hL_A_Feed + (1 - xA_Feed) * hL_B_Feed
        "Feed Enthalpy";
    //initial values
      parameter Real xA_init[42]= {0.9929,
        0.9891,
        0.9844,
        0.9784,
        0.9710,
        0.9617,
        0.9502,
        0.9360,
        0.9186,
        0.8975,
        0.8720,
        0.8418,
        0.8065,
        0.7660,
        0.7209,
        0.6719,
        0.6206,
        0.5692,
        0.5199,
        0.4746,
        0.4331,
        0.3679,
        0.3660,
        0.3633,
        0.3595,
        0.3543,
        0.3471,
        0.3375,
        0.3247,
        0.3082,
        0.2874,
        0.2621,
        0.2325,
        0.1996,
        0.1653,
        0.1317,
        0.1008,
        0.0742,
        0.0526,
        0.0359,
        0.0234,
        0.0113};
      parameter SI.MolarFlowRate V_init[41]= {0.0435,
        0.0435,
        0.0435,
        0.0435,
        0.0435,
        0.0434,
        0.0434,
        0.0433,
        0.0433,
        0.0432,
        0.0431,
        0.0429,
        0.0427,
        0.0425,
        0.0423,
        0.0421,
        0.0419,
        0.0417,
        0.0415,
        0.0413,
        0.0408,
        0.0446,
        0.0447,
        0.0449,
        0.0450,
        0.0452,
        0.0453,
        0.0455,
        0.0457,
        0.0460,
        0.0463,
        0.0466,
        0.0470,
        0.0475,
        0.0481,
        0.0488,
        0.0495,
        0.0501,
        0.0507,
        0.0512,
        0.0516};
      parameter SI.Temp_K Temp_init[42]={
          337.0,         337.82926829, 338.65853659, 339.48780488,
          340.31707317,  341.14634146,  341.97560976,  342.80487805,
          343.63414634,  344.46341463,  345.29268293,  346.12195122,
          346.95121951,  347.7804878,   348.6097561,   349.43902439,
          350.26829268,  351.09756098,  351.92682927,  352.75609756,
          353.58536585,  354.41463415,  355.24390244,  356.07317073,
          356.90243902,  357.73170732,  358.56097561,  359.3902439,
          360.2195122,   361.04878049,  361.87804878,  362.70731707,
          363.53658537,  364.36585366,  365.19512195,  366.02439024,
          366.85365854,  367.68292683,  368.51219512,  369.34146341,
          370.17073171,  371.0};

    // Oridinary Differential Equations (ODEs)
      Real xA[42](start=xA_init, each fixed=true)
        "Liquid Mole Fraction of Component A";
    // Algebraic Equations (AEs)
      SI.MolarFlowRate V[41](start=V_init, each fixed=true) "Vapor Molar Flux";
      SI.Temp_K Temp[42](start=Temp_init, each fixed=true) "Temperature (K)";
    // other variables
      SI.Pressure Press[42](each start=1.4e5);
      SI.MolarVolume V_mol_A[42] "Pure Component Molar Volumes (m^3/mol)";
      SI.MolarVolume V_mol_B[42];
      SI.MolarVolume V_mol[42] "Mixture Molar Volumes (m^3/mol)";
      SI.MolarVolume V_mol_Feed(start=7.2e-5)
        "Feed Tray Molar Volume (m^3/mol)";
      SI.MolarFlowRate Feed "Feed Tray Molar Flowrate (mol/sec)";
      SI.MolarFlowRate F[42] "Feed Flow rates";
      Real L[41](each start=0.05);
      SI.Enthalpy hL_A[42] "Pure Component Liquid Enthalpies (J/mol)";
      SI.Enthalpy hL_B[42] "Pure Component Liquid Enthalpies (J/mol)";
      SI.Enthalpy hL[42] "Mixture Liquid Enthalpies (J/mol)";
    // Real nL[42];
      SI.Pressure Psat_A[42] "Pure Component Saturation Pressures (Pa)";
      SI.Pressure Psat_B[42] "Pure Component Saturation Pressures (Pa)";
      SI.Enthalpy hV_A[42] "Pure Component Vapor Enthalpies (J/mol)";
      SI.Enthalpy hV_B[42];
      SI.Enthalpy hV[42] "Mixture Vapor Enthalpies (J/mol)";
      Real yA_equil[41] "Raoult's Law for Phase Equilibrium";
      Real yA[42] "vapor Mole Fractions of Component A";
      Real dh_dxA[42];
      Real dhL_A_dTemp[42];
      Real dhL_B_dTemp[42];
      Real dh_dTemp[42];
      Real dPsat_A_dTemp[42](each start=3e5);
      Real dPsat_B_dTemp[42](each start=9e4);
      Real h_dot[42];
      SI.MolarFlowRate Dist "Distillate Molar Flowrate Flowrate";
      SI.MolarFlowRate Bott "Determine the Bottoms Molar Flow Rate";
      SI.Temp_K Temp_dot[42] "help variables";
      Real ent_term_A[42](each max=1) "help variables for vapor enthalpies";
      Real ent_term_B[42](each max=1) "help variables for vapor enthalpies";
    equation
    //Pressure
      Press[1] = P_top;
      for i in 2:21 loop
        Press[i] = Press[i-1] + dP_rect;
      end for;
      for i in 22:42 loop
      Press[i] = Press[i-1] + dP_strip;
      end for;
    //Molar Volumes
      for i in 1:42 loop
         V_mol_A[i] = (1 / a1_A) * (b1_A ^ (1 + (1 - (Temp[i] / c1_A)) ^ d1_A));
         V_mol_B[i] = (1 / a1_B) * (b1_B ^ (1 + (1 - (Temp[i] / c1_B)) ^ d1_B));
         V_mol[i] = xA[i] * V_mol_A[i] + (1 - xA[i]) * V_mol_B[i];
      end for;
      V_mol_Feed = xA_Feed * V_mol_A[42] + (1 - xA_Feed) * V_mol_B[42];
      Feed =  Vdot_Feed / V_mol_Feed;
    //Feed
      for i in 1:21 loop
         F[i] = 0;
      end for;
      F[22] = Feed;
      for i in 23:42 loop
        F[i] = 0;
      end for;
    //Condenser Recycle Molar Flowrate (mol/sec)
      L[1] =  Vdot_L1 / V_mol[1];
      L[2:41] = L[1:40] + V[2:41] - V[1:40] + F[2:41]
        "Solve for the Liquid Flow rates (mol/sec) explicitly";
       Dist = V[1] - L[1];
       Bott = L[41] - V[41] "Determine the Bottoms Molar Flow Rate";
    //Pure Component Saturation Pressures (Pa)
      for i in 1:42 loop
         Psat_A[i] = exp(a2_A - b2_A/(Temp[i] + c2_A));
         Psat_B[i] = exp(a2_B - b2_B/(Temp[i] + c2_B));
      end for;
    //Enthalpies
      for i in 1:42 loop
         hL_A[i] = c1 * (h1_A * (Temp[i] - To) + h2_A * (Temp[i] - To)^2 + h3_A * (Temp[i] - To)^3);
         hL_B[i] = c1 * (h1_B * (Temp[i] - To) + h2_B * (Temp[i] - To)^2 + h3_B * (Temp[i] - To)^3);
         hL[i] = xA[i] * hL_A[i] + (1 - xA[i]) * hL_B[i];
      end for;
    //Pure Component Vapor Enthalpies (J/mol)"
      for i in 1:42 loop
         ent_term_A[i] = (Press[i]/Pc_A) / (Temp[i]/Tc_A)^3;
         ent_term_B[i] = (Press[i]/Pc_B) / (Temp[i]/Tc_B)^3;
         hV_A[i] = hL_A[i] + Univ_R * Tc_A * sqrt(1 - ent_term_A[i]) *
            (c2[1] - c2[2]*(Temp[i]/Tc_A) + c2[3]*(Temp[i]/Tc_A)^7 +
            Omega_A * (c2[4] - c2[5]*(Temp[i]/Tc_A) + c2[6]*(Temp[i]/Tc_A)^7));
         hV_B[i] = hL_B[i] + Univ_R * Tc_B * sqrt(1 - ent_term_B[i]) *
            (c2[1] - c2[2]*(Temp[i]/Tc_B) + c2[3]*(Temp[i]/Tc_B)^7 +
            Omega_A * (c2[4] - c2[5]*(Temp[i]/Tc_B) + c2[6]*(Temp[i]/Tc_B)^7));
         hV[i] = xA[i] * hV_A[i] + (1 - xA[i]) * hV_B[i]
          "Mixture Vapor Enthalpies (J/mol)";
       end for;
    //Raoult's Law for Phase Equilibrium
      yA_equil[1]=0;
      for i in 2:41 loop
        yA_equil[i] = xA[i]* Psat_A[i]/ Press[i];
      end for;
    //The vapor passing through the liquid gets (alpha * 100%) of the way to equilibrium
      yA[42] = xA[42] * Psat_A[42] / Press[42];
      for i in 1:20 loop
         yA[42-i] = alpha_strip * (yA_equil[42-i] - yA[43-i]) + yA[43-i];
      end for;
      for i in 1:20 loop
         yA[22-i] = alpha_rect * (yA_equil[22-i] - yA[23-i]) + yA[23-i];
      end for;
    //Mole Balance for A at Each State
        der(xA[1])= 1/2.1221253477356540 * (yA[2] * V[1] - xA[1] * L[1] - xA[1] * Dist)
        "Condenser";
        for i in 2:41 loop
        der(xA[i]) = 1/2.1221253477356540 * (yA[i+1] * V[i] + xA[i-1] * L[i-1] - yA[i] * V[i-1] -
           xA[i] * L[i] + xA_Feed * F[i]) "Trays";
        end for;
        der(xA[42]) = 1/113 * (xA[41]*L[41] - xA[42]*Bott - yA[42]*V[41])
        "Reboiler";
    //Enthalpy Balance at Each Stage - Algebraic Equations to Determine the Vapor Flow Rates
      for i in 2:42 loop
         dh_dxA[i] = hL_A[i] - hL_B[i] "Partial of Liquid Enthalpy w.r.t. xA";
         dhL_A_dTemp[i]  = c1 * (h1_A + 2 * h2_A * (Temp[i]  - To) + 3 * h3_A * (Temp[i] - To)^2);
         dhL_B_dTemp[i] = c1 * (h1_B + 2 * h2_B * (Temp[i] - To) + 3 * h3_B * (Temp[i] - To)^2);
         dh_dTemp[i] = xA[i] * dhL_A_dTemp[i] + (1 - xA[i]) * dhL_B_dTemp[i]
          "Partial of Liquid Enthalpy w.r.t. Temp";
         dPsat_A_dTemp[i] = Psat_A[i] * b2_A / (Temp[i] + c2_A)^2;
         dPsat_B_dTemp[i] = Psat_B[i] * b2_B / (Temp[i] + c2_B)^2;
         Temp_dot[i] = (Psat_B[i] - Psat_A[i]) * der(xA[i]) / (dPsat_A_dTemp[i] * xA[i] + dPsat_B_dTemp[i] * (1 - xA[i]));
         h_dot[i] = dh_dTemp[i] * Temp_dot[i] + dh_dxA[i] * der(xA[i])
          "Enthalpy Total Differential";
      end for;
    //Set up Algebraic Equations, der(V[i])=0
      for i in 2:41 loop
          der(V[i-1]) = (1/2.1221253477356540 * (hV[i+1] * V[i] + hL[i-1] * L[i-1] - hV[i] * V[i-1] -
            hL[i] * L[i] + hL_Feed * F[i]) - h_dot[i]) "Trays";
      end for;
      der(V[41])= 1/113* (hL[41]*L[41] - hL[42]*Bott - hV[42]*V[41] + Q_elec - Q_loss) - h_dot[42]
        "Reboiler";
    // Algebraic equations to determine the temperature at each stage; der(Temp[i])=0
    for i in 1:42 loop
       der(Temp[i]) = (Press[i] - Psat_A[i] * xA[i] - Psat_B[i] * (1 - xA[i])) / Press[i];
    end for;
    dh_dTemp[1]=0;
    dh_dxA[1]=0;
    dhL_A_dTemp[1]=0;
    dhL_B_dTemp[1]=0;
    dPsat_A_dTemp[1]=0;
    dPsat_B_dTemp[1]=0;
    h_dot[1]=0;
    Temp_dot[1]=0;
    yA[1]=0;
      annotation (experiment(StopTime=6000, Algorithm="Dassl"),
          __Dymola_experimentSetupOutput,
        Diagram(graphics),
        DymolaStoredErrors,
        Documentation(info="<HTML>
<p>
This distillation column is a separation of cyclohexane (component A) and n-heptane (component B). 
The two components are separated over 30 theoretical trays. In general, distillation column models 
are generally good test cases for nonlinear model reduction and identification. The concentrations 
at each stage or tray are highly correlated. The dynamics of the distillation process can be described 
by a relatively few number of underlying dynamic states. 
</p>
<p>
From the equilibrium assumption and mole balances
</p>
<ul>
<li>  vol = (yA/xA) / (yB/xB) </li>
<li> xA + xB = 1 </li>
<li> yA + yB = 1 </li>
</ul>
<p>
The model found here uses the data from the above two references but with one modification.  The liquid
flowrate from each tray can be solved explicitly thereby eliminating 40 algebraic equations.  The total
for this model is 42 differential equations and 125 algebraic equations.  The extra equation is an
energy balance to determine the vapor flowrate from the reboiler.
</p>
<p>
Reference:
</p>
<p>
Diehl, M., 'Real-Time Optimization for Large Scale Nonlinear Processes', PhD thesis, University
of Heidelberg, 2001.
</p>
<p>
The model is a 204 state DAE with 82 differential equations and 122 algebraic equations.
</p>
<p>
and
</p>
<p>
Diehl, M., et. al. 'Real-Time Optimization for Large Scale Nonlinear Processes: Nonlinear
 Model Predictive Control of a High Purity Distillation Column', In Groetschel, Krumke,
Rambau (editors): Online Optimization of Large Scale Systems: State of the Art, Springer 2001.
</p>
<p>
The model is a 164 state DAE with 42 differential equations and 122 algebraic equations. This model
was used to control the pilot plant distillation column.  It is a simplification from Diehl's thesis
work in that constant molar holdup is assumed for each tray.
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"));
    end Distillation4;

    model Distillation4Init
      Distillation4 d(xA(each fixed=false), V(each fixed=false),
                      Temp(each fixed=false));
    equation
      der(d.Q_elec) = 0;
      der(d.Vdot_L1) = 0;
    initial equation
      for i in 1:41 loop
        der(d.xA[i]) = 0;
        der(d.V[i]) = 0;
        der(d.Temp[i]) = 0;
      end for;
      der(d.xA[42]) = 0;
      der(d.Temp[42]) = 0;
      d.Temp[14] = d.T_28_ref;
      d.Temp[28] = d.T_14_ref;
    end Distillation4Init;

    model Distillation4Breakdown
      Distillation4 d;
    equation
      d.Q_elec = d.Q_elec_ref;
      d.Vdot_L1 = if noEvent(time < 700) then
                  d.Vdot_L1_ref else
                  (0.5 / 1000 / 3600);
    end Distillation4Breakdown;

    model Distillation4Reference
      Distillation4 d;
      
      constant Real time_constant = 35;
    equation
      d.Q_elec = d.Q_elec_ref;
      d.Vdot_L1 = (1 - time_constant / 2 / (time_constant + 5000 - 0.005)) * d.Vdot_L1_ref +
                  time_constant / 2 * d.Vdot_L1_ref / (time_constant + time);
      // d.Vdot_L1 = d.Vdot_L1_ref;
    end Distillation4Reference;

    model Distillation4Input
      import SI = Modelica.SIunits;
    //input
      Modelica.Blocks.Interfaces.RealInput Q_elec
        "Input 1: Heat Input to the Reboiler from an Electric Heater Q_elec = u(1,1)"
        annotation (Placement(transformation(extent={{-42,8},{-2,48}})));
    // Parameters - Nominal Operating Conditions
      parameter SI.VolumeFlowRate Vdot_Feed =  14.0 / 3600 / 1000
        "Feed Flowrate (m^3/sec)";
      parameter SI.VolumeFlowRate Vdot_L1= 4.3 /1000/3600
        "Input 2: Flow Rate of the Recycled Distillate Vdot_L1 = u(2,1)";
      //parameter SI.HeatFlowRate Q_elec= 2.45e3"Input 1: Heat Input to the Reboiler from an Electric Heater Q_elec = u(1,1)"
      parameter Real xA_Feed = 0.32 "Mole Fraction of Feed";
      parameter SI.Temp_K Temp_Feed = 71.0 + 273.15 "Feed Temperature (K)";
      parameter SI.Pressure P_top = 0.97 * 1.0e5 "Top Pressure (Pa)";
      parameter SI.Volume V_Condenser = 0.17 / 1000 "Condenser Holdup(m^3)";
      parameter SI.Volume V_Reboiler = 8.5 / 1000 "Reboiler Holdup(m^3)";
      parameter SI.HeatFlowRate Q_loss = 0.51e3
        "Heat Loss from the Reboiler (J/sec)";
      parameter SI.Pressure dP_rect = 1.9e3
        "Pressure Drop in Above Feed Section(Pa)";
      parameter SI.Pressure dP_strip = 2.5e3
        "Pressure Drop in Below Feed Section(Pa)";
      parameter Real alpha_rect = 0.35;
      parameter Real alpha_strip = 0.62 "Tray Efficiencies";
    // Parameters - Physical Properties
      // Molar Volume (m^3/mol) of Component A and B
      parameter Real a1_A = 2.288e3 "Units (mol/m^3)";
      parameter Real a1_B = 1.235e3 "Units (mol/m^3)";
      parameter Real b1_A = 0.2685 "Units (dimensionless)";
      parameter Real b1_B = 0.27136 "Units (dimensionless)";
      parameter Real d1_A = 0.2453 "Units (dimensionless)";
      parameter Real d1_B = 0.2400 "Units (dimensionless)";
      parameter SI.Temp_K c1_A = 512.4 "Units (K)";
      parameter SI.Temp_K c1_B = 536.4 "Units (K)";
      parameter SI.MolarVolume V_mol_A_Feed = (1 / a1_A) * (b1_A ^ (1 + (1 - (Temp_Feed / c1_A)) ^ d1_A));
      parameter SI.MolarVolume V_mol_B_Feed = (1 / a1_B) * (b1_B ^ (1 + (1 - (Temp_Feed / c1_B)) ^ d1_B));
    // Parameters Pure Component A Saturation Pressure - Antione Equation
      parameter Real a2_A = 23.48 "Units (dimensionless)";
      parameter Real a2_B = 22.437 "Units (dimensionless)";
      parameter SI.Temp_K b2_A = 3626.6 "Units (K)";
      parameter SI.Temp_K b2_B = 3166.4 "Units (K)";
      parameter Real c2_A = -34.29 "Units (dimensionless)";
      parameter Real c2_B = -80.15 "Units (dimensionless)";
    // Enthalpy Coefficients
      parameter Real h1_A = 18.31 "Units (1/K)";
      parameter Real h1_B = 31.92 "Units (1/K)";
      parameter Real h2_A = 1.713e-2 "Units (1/K^2)";
      parameter Real h2_B = 4.49e-2 "Units (1/K^2)";
      parameter Real h3_A = 6.399e-5 "Units (1/K^3)";
      parameter Real h3_B = 9.663e-5 "Units (1/K^3)";
      parameter SI.Temp_K Tc_A = 512.6 "Units (K)";
      parameter SI.Temp_K Tc_B = 536.7 "Units (K)";
      parameter SI.Pressure Pc_A = 8.096e6 "Units (Pa)";
      parameter SI.Pressure Pc_B = 5.166e6 "Units (Pa)";
      parameter Real Omega_A = 0.557 "Units (dimensionless)";
      parameter Real Omega_B = 0.612 "Units (dimensionless)";
      parameter SI.Temp_K To = 273.15 "Units (K)";
      parameter Real c1 = 4.186 "Units (J/mol)";
      parameter SI.MolarHeatCapacity Univ_R = 8.31451
        "Universal Gas Law Constant";
      parameter Real[6] c2 = {6.09648,1.28862,1.016,15.6875,13.4721,2.615}
        "Units (dimensionless)";
      parameter SI.Enthalpy hL_A_Feed = c1*(h1_A*(Temp_Feed - To) + h2_A*(Temp_Feed - To)^2 + h3_A*(Temp_Feed - To)^3);
      parameter SI.Enthalpy hL_B_Feed = c1*(h1_B*(Temp_Feed - To) + h2_B*(Temp_Feed - To)^2 + h3_B*(Temp_Feed - To)^3);
      parameter SI.Enthalpy hL_Feed = xA_Feed * hL_A_Feed + (1 - xA_Feed) * hL_B_Feed
        "Feed Enthalpy";
    //initial values
      parameter Real xA_init[42]= {0.9929,
        0.9891,
        0.9844,
        0.9784,
        0.9710,
        0.9617,
        0.9502,
        0.9360,
        0.9186,
        0.8975,
        0.8720,
        0.8418,
        0.8065,
        0.7660,
        0.7209,
        0.6719,
        0.6206,
        0.5692,
        0.5199,
        0.4746,
        0.4331,
        0.3679,
        0.3660,
        0.3633,
        0.3595,
        0.3543,
        0.3471,
        0.3375,
        0.3247,
        0.3082,
        0.2874,
        0.2621,
        0.2325,
        0.1996,
        0.1653,
        0.1317,
        0.1008,
        0.0742,
        0.0526,
        0.0359,
        0.0234,
        0.0113};
      parameter SI.MolarFlowRate V_init[41]= {0.0435,
        0.0435,
        0.0435,
        0.0435,
        0.0435,
        0.0434,
        0.0434,
        0.0433,
        0.0433,
        0.0432,
        0.0431,
        0.0429,
        0.0427,
        0.0425,
        0.0423,
        0.0421,
        0.0419,
        0.0417,
        0.0415,
        0.0413,
        0.0408,
        0.0446,
        0.0447,
        0.0449,
        0.0450,
        0.0452,
        0.0453,
        0.0455,
        0.0457,
        0.0460,
        0.0463,
        0.0466,
        0.0470,
        0.0475,
        0.0481,
        0.0488,
        0.0495,
        0.0501,
        0.0507,
        0.0512,
        0.0516};
      parameter SI.Temp_K Temp_init[42]= { 336.7037,
        337.2658,
        337.8392,
        338.4292,
        339.0418,
        339.6848,
        340.3672,
        341.1000,
        341.8960,
        342.7699,
        343.7382,
        344.8181,
        346.0258,
        347.3745,
        348.8695,
        350.5037,
        352.2530,
        354.0735,
        355.9048,
        357.6824,
        359.4009,
        362.1238,
        362.6950,
        363.2875,
        363.9119,
        364.5823,
        365.3167,
        366.1379,
        367.0730,
        368.1526,
        369.4068,
        370.8586,
        372.5146,
        374.3528,
        376.3160,
        378.3143,
        380.2436,
        382.0123,
        383.5625,
        384.8769,
        385.9711,
        387.0558};
    // Oridinary Differential Equations (ODEs)
      Real xA[42](start=xA_init) "Liquid Mole Fraction of Component A";
    // Algebraic Equations (AEs)
      SI.MolarFlowRate V[41](start=V_init) "Vapor Molar Flux";
      SI.Temp_K Temp[42](start=Temp_init) "Temperature (K)";
    // other variables
      SI.Pressure Press[42];
      SI.MolarVolume V_mol_A[42] "Pure Component Molar Volumes (m^3/mol)";
      SI.MolarVolume V_mol_B[42];
      SI.MolarVolume V_mol[42] "Mixture Molar Volumes (m^3/mol)";
      SI.MolarVolume V_mol_Feed "Feed Tray Molar Volume (m^3/mol)";
      SI.MolarFlowRate Feed "Feed Tray Molar Flowrate (mol/sec)";
      SI.MolarFlowRate F[42] "Feed Flow rates";
      Real L[41];
      SI.Enthalpy hL_A[42] "Pure Component Liquid Enthalpies (J/mol)";
      SI.Enthalpy hL_B[42] "Pure Component Liquid Enthalpies (J/mol)";
      SI.Enthalpy hL[42] "Mixture Liquid Enthalpies (J/mol)";
    //  Real nL[42];
      SI.Pressure Psat_A[42] "Pure Component Saturation Pressures (Pa)";
      SI.Pressure Psat_B[42] "Pure Component Saturation Pressures (Pa)";
      SI.Enthalpy hV_A[42] "Pure Component Vapor Enthalpies (J/mol)";
      SI.Enthalpy hV_B[42];
      SI.Enthalpy hV[42] "Mixture Vapor Enthalpies (J/mol)";
      Real yA_equil[41] "Raoult's Law for Phase Equilibrium";
      Real yA[42] "vapor Mole Fractions of Component A";
      Real dh_dxA[42];
      Real dhL_A_dTemp[42];
      Real dhL_B_dTemp[42];
      Real dh_dTemp[42];
      Real dPsat_A_dTemp[42];
      Real dPsat_B_dTemp[42];
      Real h_dot[42];
      SI.Temp_K Temp_dot[42] "help variables";
      SI.MolarFlowRate Dist "Distillate Molar Flowrate Flowrate";
      SI.MolarFlowRate Bott "Determine the Bottoms Molar Flow Rate";
    equation
    //Pressure
      Press[1] = P_top;
      for i in 2:21 loop
        Press[i] = Press[i-1] + dP_rect;
      end for;
      for i in 22:42 loop
      Press[i] = Press[i-1] + dP_strip;
      end for;
    //Molar Volumes
      for i in 1:42 loop
         V_mol_A[i] = (1 / a1_A) * (b1_A ^ (1 + (1 - (Temp[i] / c1_A)) ^ d1_A));
         V_mol_B[i] = (1 / a1_B) * (b1_B ^ (1 + (1 - (Temp[i] / c1_B)) ^ d1_B));
         V_mol[i] = xA[i] * V_mol_A[i] + (1 - xA[i]) * V_mol_B[i];
      end for;
      V_mol_Feed = xA_Feed * V_mol_A[42] + (1 - xA_Feed) * V_mol_B[42];
      Feed =  Vdot_Feed / V_mol_Feed;
    //Feed
      for i in 1:21 loop
         F[i] = 0;
      end for;
      F[22] = Feed;
      for i in 23:42 loop
        F[i] = 0;
      end for;
    //Condenser Recycle Molar Flowrate (mol/sec)
      L[1] =  Vdot_L1 / V_mol[1];
      L[2:41] = L[1:40] + V[2:41] - V[1:40] + F[2:41]
        "Solve for the Liquid Flow rates (mol/sec) explicitly";
       Dist = V[1] - L[1];
       Bott = L[41] - V[41] "Determine the Bottoms Molar Flow Rate";
    //Pure Component Saturation Pressures (Pa)
      for i in 1:42 loop
         Psat_A[i] = exp(a2_A - b2_A/(Temp[i] + c2_A));
         Psat_B[i] = exp(a2_B - b2_B/(Temp[i] + c2_B));
      end for;
    //Enthalpies
      for i in 1:42 loop
         hL_A[i] = c1 * (h1_A * (Temp[i] - To) + h2_A * (Temp[i] - To)^2 + h3_A * (Temp[i] - To)^3);
         hL_B[i] = c1 * (h1_B * (Temp[i] - To) + h2_B * (Temp[i] - To)^2 + h3_B * (Temp[i] - To)^3);
         hL[i] = xA[i] * hL_A[i] + (1 - xA[i]) * hL_B[i];
      end for;
    //Pure Component Vapor Enthalpies (J/mol)"
      for i in 1:42 loop
         hV_A[i] = hL_A[i] + Univ_R * Tc_A * sqrt(abs(1 - (Press[i]/Pc_A) / (Temp[i]/Tc_A)^3)) *
            (c2[1] - c2[2]*(Temp[i]/Tc_A) + c2[3]*(Temp[i]/Tc_A)^7 +
            Omega_A * (c2[4] - c2[5]*(Temp[i]/Tc_A) + c2[6]*(Temp[i]/Tc_A)^7));
         hV_B[i] = hL_B[i] + Univ_R * Tc_B * sqrt(abs(1 - (Press[i]/Pc_B) / (Temp[i]/Tc_B)^3)) *
            (c2[1] - c2[2]*(Temp[i]/Tc_B) + c2[3]*(Temp[i]/Tc_B)^7 +
            Omega_A * (c2[4] - c2[5]*(Temp[i]/Tc_B) + c2[6]*(Temp[i]/Tc_B)^7));
         hV[i] = xA[i] * hV_A[i] + (1 - xA[i]) * hV_B[i]
          "Mixture Vapor Enthalpies (J/mol)";
       end for;
    //Raoult's Law for Phase Equilibrium
      yA_equil[1]=0;
      for i in 2:41 loop
        yA_equil[i] = xA[i]* Psat_A[i]/ Press[i];
      end for;
    //The vapor passing through the liquid gets (alpha * 100%) of the way to equilibrium
      yA[42] = xA[42] * Psat_A[42] / Press[42];
      for i in 1:20 loop
         yA[42-i] = alpha_strip * (yA_equil[42-i] - yA[43-i]) + yA[43-i];
      end for;
      for i in 1:20 loop
         yA[22-i] = alpha_rect * (yA_equil[22-i] - yA[23-i]) + yA[23-i];
      end for;
    //Mole Balance for A at Each State
        der(xA[1])= 1/2.1221253477356540 * (yA[2] * V[1] - xA[1] * L[1] - xA[1] * Dist)
        "Condenser";
        for i in 2:41 loop
        der(xA[i]) = 1/2.1221253477356540 * (yA[i+1] * V[i] + xA[i-1] * L[i-1] - yA[i] * V[i-1] -
           xA[i] * L[i] + xA_Feed * F[i]) "Trays";
        end for;
        der(xA[42]) = 1/113 * (xA[41]*L[41] - xA[42]*Bott - yA[42]*V[41])
        "Reboiler";
    //Enthalpy Balance at Each Stage - Algebraic Equations to Determine the Vapor Flow Rates
      for i in 2:42 loop
         dh_dxA[i] = hL_A[i] - hL_B[i] "Partial of Liquid Enthalpy w.r.t. xA";
         dhL_A_dTemp[i]  = c1 * (h1_A + 2 * h2_A * (Temp[i]  - To) + 3 * h3_A * (Temp[i] - To)^2);
         dhL_B_dTemp[i] = c1 * (h1_B + 2 * h2_B * (Temp[i] - To) + 3 * h3_B * (Temp[i] - To)^2);
         dh_dTemp[i] = xA[i] * dhL_A_dTemp[i] + (1 - xA[i]) * dhL_B_dTemp[i]
          "Partial of Liquid Enthalpy w.r.t. Temp";
         dPsat_A_dTemp[i] = Psat_A[i] * b2_A / (Temp[i] + c2_A)^2;
         dPsat_B_dTemp[i] = Psat_B[i] * b2_B / (Temp[i] + c2_B)^2;
         Temp_dot[i] = (Psat_B[i] - Psat_A[i]) * der(xA[i]) / (dPsat_A_dTemp[i] * xA[i] + dPsat_B_dTemp[i] * (1 - xA[i]));
         h_dot[i] = dh_dTemp[i] * Temp_dot[i] + dh_dxA[i] * der(xA[i])
          "Enthalpy Total Differential";
      end for;
    //Set up Algebraic Equations, der(V[i])=0
      for i in 2:41 loop
          der(V[i-1]) = (1/2.1221253477356540 * (hV[i+1] * V[i] + hL[i-1] * L[i-1] - hV[i] * V[i-1] -
            hL[i] * L[i] + hL_Feed * F[i]) - h_dot[i]) "Trays";
      end for;
      der(V[41])= 1/113* (hL[41]*L[41] - hL[42]*Bott - hV[42]*V[41] + Q_elec - Q_loss) - h_dot[42]
        "Reboiler";
    // Algebraic equations to determine the temperature at each stage; der(Temp[i])=0
    for i in 1:42 loop
       der(Temp[i]) = (Press[i] - Psat_A[i] * xA[i] - Psat_B[i] * (1 - xA[i])) / Press[i];
    end for;
    dh_dTemp[1]=0;
    dh_dxA[1]=0;
    dhL_A_dTemp[1]=0;
    dhL_B_dTemp[1]=0;
    dPsat_A_dTemp[1]=0;
    dPsat_B_dTemp[1]=0;
    h_dot[1]=0;
    Temp_dot[1]=0;
    yA[1]=0;
    annotation (experiment(StopTime=6000, Algorithm="Dassl"),
          __Dymola_experimentSetupOutput,
        Diagram(graphics),
        DymolaStoredErrors,
        Documentation(info="<HTML>
<p>
Based on the Distillation4 model the Heat Input to the reboiler is defined as RealInput
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"));
    end Distillation4Input;

    package Examples
      model Distillation4test
        JMExamples.Distillation.Distillation4Input
                           distillation4Input
          annotation (Placement(transformation(extent={{20,20},{40,40}})));
        Modelica.Blocks.Sources.Constant const(k=2.3e3)
          annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
      equation
        connect(const.y, distillation4Input.Q_elec) annotation (Line(
            points={{-19,30},{4,30},{4,32.8},{27.8,32.8}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (
          Diagram(graphics),
          experiment(StopTime=6000),
          __Dymola_experimentSetupOutput,
                  experiment(StopTime=6000, Algorithm="Dassl"),
            __Dymola_experimentSetupOutput,
          Diagram(graphics),
          DymolaStoredErrors,
          Documentation(info="<HTML>
<p>
A constant value of k=2.3e3 is set as RealInput
</p>
<p>
Simulation time: 7200s
</p>

</HTML>"));
      end Distillation4test;

      model Distillation1const
        Modelica.Blocks.Sources.Constant const(k=3.7)
          annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
        Distillation1Input distillation1Input
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
      equation
        connect(const.y, distillation1Input.rr) annotation (Line(
            points={{-39,10},{-14.5,10},{-14.5,11},{10,11}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (
          Diagram(graphics),
          experiment(StopTime=7200),
          __Dymola_experimentSetupOutput);
      end Distillation1const;

      model Distillation1step
        Modelica.Blocks.Sources.Step step(
          height=0.7,
          offset=3,
          startTime=1000)
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
        Distillation1Input distillation1Input
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
      equation
        connect(step.y, distillation1Input.rr) annotation (Line(
            points={{-19,10},{-4.5,10},{-4.5,11},{10,11}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=7200),
          __Dymola_experimentSetupOutput);
      end Distillation1step;
    end Examples;
  end Distillation;

  package DoubleTank
    model DoubleTank
         import SI = Modelica.SIunits;
         //State start values
         parameter Real x1_0 = 0;
         parameter Real x2_0= 1;
         //States
         Real x1(start = x1_0, fixed=true);
         Real x2(start = x2_0, fixed=true);
         SI.DampingCoefficient gamma;
         SI.DampingCoefficient delta;
         //Parameter
         parameter SI.Area A = 4.9*10e-4 "Tank cross section";
         parameter SI.Area a = 3.1*10e-6 "Outlet cross section";
         parameter SI.VolumeFlowRate alpha = 2.1*10e-5
        "Conversion factor from control to flow";
         parameter SI.PhaseCoefficient beta = 6.25
        "Conversion factor from height to measurement";
         parameter SI.Acceleration g = 9.81 "Acceleration of gravity";
         //Control Signal
          Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
          gamma = a/A*sqrt(2*g*beta);
          delta = alpha*beta/A;
          der(x1) = -gamma*sqrt(x1)+delta*u;
          der(x2) = gamma*(sqrt(x1)-sqrt(x2));
      annotation (DymolaStoredErrors);
    end DoubleTank;
  end DoubleTank;

  package FlightPath
    model FlightPath
      //state start values
      parameter Real x1_0 = 153.73;
      parameter Real x2_0 = 0;
      parameter Real x3_0 = 0;
      //states
      Real x1(start = x1_0, fixed=true);
      Real x2(start = x2_0, fixed=true);
      Real x3(start = x3_0, fixed=true);
      //control
      Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,20},{-80,60}}),
            iconTransformation(extent={{-120,20},{-80,60}})));
      Modelica.Blocks.Interfaces.RealInput v
        annotation (Placement(transformation(extent={{-120,-40},{-80,0}}),
            iconTransformation(extent={{-120,-40},{-80,0}})));
      //parameter
      parameter Real L = 65.3;
      parameter Real D = 3.18;
      parameter Real m = 160e3;
      parameter Real g = 9.81;
      parameter Real c = 6;
    equation
      der(x1) = (-D/m*x1^2-g*sin(x2)+u/m);
      der(x2) = L/m*x1*(1-c*x2)-g*cos(x2)/x1+L*c/m*v;
      der(x3) = (x1*sin(x2));
      annotation (experiment(StopTime=100), __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
Minimum Cost Optimal Control: An Application to Flight Level Tracking 
</p>
<p>
Reference:
</p>
<p>
John Lygeros, Department of Engineering, University of Cambridge, Cambridge, UK
</p>
<p>
PROPT - Matlab Optimal Control Software (DAE, ODE)
</p>
<p>
Simulation time: 100s
</p>
</HTML>"),
        Icon(graphics={Line(
              points={{-66,-40},{10,-40},{26,-36},{36,-30},{46,-20},{58,-4},{68,12},
                  {70,14}},
              color={0,0,255},
              smooth=Smooth.None,
              arrow={Arrow.None,Arrow.Filled},
              thickness=0.5)}));
    end FlightPath;

    package Examples
      model FlightPathExp
        FlightPath flightPath
          annotation (Placement(transformation(extent={{20,20},{40,40}})));
        Modelica.Blocks.Sources.RealExpression realExpression(y=25)
          annotation (Placement(transformation(extent={{-34,-2},{-14,18}})));
        Modelica.Blocks.Sources.Exponentials exponentials(outMax=10, riseTime=80)
          annotation (Placement(transformation(extent={{-40,40},{-20,60}})));
      equation
        connect(realExpression.y, flightPath.u1) annotation (Line(
            points={{-13,8},{6,8},{6,30.6},{26,30.6}},
            color={0,0,127},
            smooth=Smooth.None));
        connect(exponentials.y, flightPath.u2) annotation (Line(
            points={{-19,50},{2,50},{2,34.6},{26.2,34.6}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          Documentation(info="<HTML>
<p>
input: exponential function
</p>
<p>
Simulation time: 100s
</p>

</HTML>"));
      end FlightPathExp;

      model FlightPathSine
        FlightPath flightPath
          annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.Sine sine(amplitude=20, freqHz=10)
          annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
        Modelica.Blocks.Sources.Sine sine1(amplitude=20, freqHz=10)
          annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));
      equation
        connect(sine1.y, flightPath.u1) annotation (Line(
            points={{-19,-10},{4,-10},{4,10.6},{26,10.6}},
            color={0,0,127},
            smooth=Smooth.None));
        connect(sine.y, flightPath.u2) annotation (Line(
            points={{-19,30},{2,30},{2,14.6},{26.2,14.6}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          Documentation(info="<HTML>
<p>
input: sine function
</p>
<p>
Simulation time: 100s
</p>


</HTML>"));
      end FlightPathSine;
    end Examples;
    annotation (Icon(graphics));
  end FlightPath;

  package Greenhouse
    model Greenhouse
      import SI = Modelica.SIunits;
      //parameter
      parameter Real pW = 3e-6/40;
      parameter Real pT = 1;
      parameter Real pH = 0.1;
      parameter Real pHc = 7.5e-2/220;
      parameter Real pWc = 3e4/220;
      parameter Real pi = 3.14159;
      parameter Real tf = 48;
      //state start values
      parameter Real x1_0 = 0;
      parameter Real x2_0 = 10;
      parameter Real x3_0 = 0;
      //states
      SI.Mass x1(start=x1_0,fixed=true) "dry weight";
      SI.Temp_C x2(start=x2_0,fixed=true) "Greenhouse temperature";
      SI.Energy x3(start=x3_0,fixed=true);
      SI.Power sun "sunlight";
      SI.Temp_C temp "outside temperature";
      //control signal
      Modelica.Blocks.Interfaces.RealInput u
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      der(x1) = pW*sun*x2;
      der(x2) = pT*(temp-x2)+pH*u;
      der(x3) = pHc*u;
      sun = 800*sin(4*pi*time/tf-0.65*pi);
      temp = 15+10*sin(4*pi*time/tf-0.65*pi);
      annotation (experiment(StopTime=48), __Dymola_experimentSetupOutput,
        Icon(graphics={
            Ellipse(
              extent={{-40,22},{-26,8}},
              lineColor={255,255,0},
              lineThickness=0.5,
              fillPattern=FillPattern.Sphere,
              fillColor={255,213,170}),
            Ellipse(
              extent={{54,38},{68,24}},
              lineColor={0,0,255},
              lineThickness=0.5,
              fillColor={170,170,255},
              fillPattern=FillPattern.Solid),
            Line(
              points={{-38,20},{-42,22},{-46,26},{-50,32},{-50,36},{-48,42},{-42,46},
                  {-36,46},{-32,44},{-30,38},{-30,32},{-30,26},{-32,22}},
              color={255,0,128},
              thickness=0.5,
              smooth=Smooth.None),
            Ellipse(
              extent={{56,62},{62,38}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,85,85}),
            Ellipse(
              extent={{68,34},{96,28}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,85,85}),
            Ellipse(
              extent={{60,24},{68,2}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,85,85}),
            Ellipse(
              extent={{54,30},{32,24}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillColor={255,85,85},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{32,38},{54,32}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,85,85}),
            Ellipse(
              extent={{68,28},{96,20}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,85,85}),
            Ellipse(
              extent={{66,60},{62,38}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,85,85}),
            Ellipse(
              extent={{54,24},{60,0}},
              lineColor={255,85,85},
              lineThickness=0.5,
              fillColor={255,85,85},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{48,46},{76,16}},
              lineColor={170,170,255},
              lineThickness=0.5),
            Line(
              points={{-28,20},{-26,28},{-22,32},{-14,36},{-6,34},{-4,28},{-4,
                  24},{-6,20},{-14,18},{-20,18},{-26,18}},
              color={255,0,128},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-26,12},{-18,12},{-10,10},{-4,6},{-2,4},{-2,0},{-4,-4},{
                  -10,-8},{-18,-8},{-26,-2},{-28,2},{-28,6},{-28,8}},
              color={255,0,128},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-34,8},{-32,4},{-32,-4},{-36,-10},{-44,-12},{-50,-10},{
                  -52,-4},{-48,4},{-44,6},{-38,10}},
              color={255,0,128},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-40,18},{-46,24},{-52,28},{-60,28},{-66,26},{-68,22},{
                  -68,18},{-66,14},{-62,10},{-54,8},{-46,8},{-40,10},{-38,10}},
              color={255,0,128},
              thickness=0.5,
              smooth=Smooth.None),
            Ellipse(
              extent={{-6,68},{28,38}},
              lineColor={255,170,255},
              lineThickness=0.5,
              fillColor={255,170,255},
              fillPattern=FillPattern.Solid),
            Line(
              points={{-4,54},{-12,60},{4,58},{0,70},{8,62},{20,72},{20,60},{34,
                  56},{22,50},{26,40},{14,44},{8,34},{4,46},{-12,42},{-2,52},{
                  -4,54}},
              color={170,85,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-32,8},{-26,-16},{-12,-42},{10,-68},{18,-84},{18,-60},{
                  20,-42},{22,-26},{22,-6},{18,8},{14,24},{14,32},{14,38}},
              color={0,127,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{52,12},{46,-2},{44,-28},{38,-48},{32,-62},{26,-72},{22,
                  -78},{18,-84}},
              color={0,127,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{4,-60},{-8,-54},{-24,-40},{-30,-32},{-34,-32},{-38,-36},
                  {-36,-48},{-26,-54},{-14,-60},{-4,-62},{4,-64},{10,-70},{14,
                  -74}},
              color={0,127,0},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{36,-52},{44,-42},{54,-32},{66,-28},{72,-30},{78,-36},{78,-42},
                  {74,-46},{64,-48},{48,-50},{42,-54},{36,-60},{32,-64},{30,-66}},
              color={0,127,0},
              thickness=0.5,
              smooth=Smooth.None)}),
        Diagram(graphics),
        Documentation(info="<HTML>
<p>
A solar greenhouse has been designed that maximizes solar energy use and minimizes
fossil energy consumption. It is based on a conventional greenhouse extended with a heat
pump, a heat exchanger, an aquifer and ventilation with heat recovery. The aim is to
minimize fossil energy consumption, while maximizing crop dry weight and keeping
temperature and humidity within certain limits. These requirements are defined in a goal
function, which is minimized by optimal control. A greenhouse with crop model is used
to simulate the process behaviour. It is found that open loop optimal control trajectories
can be determined. The boiler use is reduced to a minimum, thus reducing fossil energy
use. Compared to a conventional greenhouse it is found that the energy costs are
decreased and the crop dry weight is increased.
</p>
<p>
Reference:
</p>
<p>
OPTIMAL CONTROL OF A SOLAR GREENHOUSE, R.J.C. van Ooteghem, J.D. Stigter, L.G. van Willigenburg, G. van Straten
</p>
<p>
  Simulation time: 48s
  </p>
</HTML>"));
    end Greenhouse;
  end Greenhouse;

  package Helicopter
    model Helicopter
         import SI = Modelica.SIunits;
         //State start values and parameters
         parameter SI.MomentOfInertia Je = 0.91
        "Moment of inertia about elevation axis";
         parameter SI.Length la = 0.66
        "Arm length from elevation axis to helicopter body";
         parameter Real Kf = 0.5 "Motor force constant";
         parameter SI.Force Fg = 0.5
        "Differential force due to gravity and counter weight";
         parameter SI.Torque Tg = 0.33 "Differential torque";
         parameter SI.MomentOfInertia Jp = 0.0364
        "Moment of inertia about pitch axis";
         parameter SI.Length lh = 0.177
        "Distance from pitch axis to either motor";
         parameter SI.MomentOfInertia Jt = 0.91
        "Moment of inertia about travel axis";
         //States
         Real te(fixed=true);
         Real tr(fixed=true);
         Real tp(fixed=true);
         Real dte(fixed=true);
         Real dtr(fixed=true);
         Real dtp(fixed=true);
         //Control Signal
      Modelica.Blocks.Interfaces.RealInput Vf
        annotation (Placement(transformation(extent={{-120,20},{-80,60}}),
            iconTransformation(extent={{-120,20},{-80,60}})));
      Modelica.Blocks.Interfaces.RealInput Vb
        annotation (Placement(transformation(extent={{-120,-40},{-80,0}}),
            iconTransformation(extent={{-120,-40},{-80,0}})));
    equation
         der(te) = dte;
         der(tr) = dtr;
         der(tp) = dtp;
         der(dte)= (Kf*la/Je)*(Vf+Vb)-Tg/Je;
         der(dtr)= -(Fg*la/Jt)*sin(tp);
         der(dtp)= (Kf*lh/Jp)*(Vf-Vb);
      annotation (experiment(StopTime=30), __Dymola_experimentSetupOutput,
      Documentation(info="<HTML>   
  <p>
   As an example of a process with fast dynamics, a helicopter is considered.
   The helicopter consists of an arm mounted to a base, enabling the arm to rotate freely. 
  </p>       
  <p>
  References:
  </p>    
  <p>
  Operator Interaction and Optimization in Control Systems, Johan Åkesson
  </p>    
  <p>
  Simulation time:150s
  </p>
  </HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{-34,36},{66,-22}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillPattern=FillPattern.Forward,
              fillColor={255,170,170}),
            Polygon(
              points={{-80,20},{-28,20},{-34,12},{-80,20}},
              lineColor={0,0,255},
              lineThickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-34,-22},{40,-36},{46,-36},{50,-34},{54,-32}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-20,-14},{-22,-22},{-22,-24}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{20,-22},{18,-32}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{58,-24},{52,-28},{46,-30},{40,-30},{32,-28},{24,-26},{10,-22}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Polygon(
              points={{26,26},{30,-4},{56,-4},{52,16},{26,26}},
              lineColor={255,0,0},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillPattern=FillPattern.Forward,
              fillColor={255,170,170}),
            Polygon(
              points={{14,54},{6,32},{22,32},{14,54}},
              lineColor={213,170,255},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillColor={213,170,255},
              fillPattern=FillPattern.Forward),
            Polygon(
              points={{12,54},{-54,46},{-58,58},{12,54}},
              lineColor={170,85,255},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillPattern=FillPattern.CrossDiag,
              fillColor={213,170,255}),
            Polygon(
              points={{16,54},{84,68},{86,50},{16,54}},
              lineColor={170,85,255},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillColor={213,170,255},
              fillPattern=FillPattern.CrossDiag),
            Polygon(
              points={{-80,20},{-84,30},{-88,8},{-80,20}},
              lineColor={0,0,255},
              lineThickness=0.5,
              smooth=Smooth.None)}));
    end Helicopter;

    model HelicopterDer
      import SI = Modelica.SIunits;
         //State start values and parameters
         parameter SI.MomentOfInertia Je = 0.91
        "Moment of inertia about elevation axis";
         parameter SI.Length la = 0.66
        "Arm length from elevation axis to helicopter body";
         parameter Real Kf = 0.5 "Motor force constant";
         parameter SI.Force Fg = 0.5
        "Differential force due to gravity and counter weight";
         parameter SI.Torque Tg = 0.33 "Differential torque";
         parameter SI.MomentOfInertia Jp = 0.0364
        "Moment of inertia about pitch axis";
         parameter SI.Length lh = 0.177
        "Distance from pitch axis to either motor";
         parameter SI.MomentOfInertia Jt = 0.91
        "Moment of inertia about travel axis";
         //States
         Real te(start=0,fixed=true);
         Real tr(start=0,fixed=true);
         Real tp(start=0,fixed=true);
         Real dte(start=1,fixed=true);
         Real dtr(start=0,fixed=true);
         Real dtp(start=-2,fixed=true);
         Real Vf(start=0,fixed=true);
         Real Vb(start=0,fixed=true);
         //Control Signal
      Modelica.Blocks.Interfaces.RealInput dVf
        annotation (Placement(transformation(extent={{-52,10},{-12,50}})));
      Modelica.Blocks.Interfaces.RealInput dVb
        annotation (Placement(transformation(extent={{-50,-46},{-10,-6}})));
    equation
         der(te) = dte;
         der(tr) = dtr;
         der(tp) = dtp;
         der(dte)= (Kf*la/Je)*(Vf+Vb)-Tg/Je;
         der(dtr)= -(Fg*la/Jt)*sin(tp);
         der(dtp)= (Kf*lh/Jp)*(Vf-Vb);
         der(Vf) = dVf;
         der(Vb) = dVb;
         annotation (experiment(StopTime=30), __Dymola_experimentSetupOutput,
        Diagram(graphics),
        Documentation(info="<HTML>   
    <p>
     The model is equivalent to Helicopter but the derivatives of the input a given. That makes it possible to use the derivatives in the cost function when setting up the optimization problem.
    </p>    
    <p>
    Simulation time:150s
    </p>
    </HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{-34,36},{66,-22}},
              lineColor={255,0,0},
              lineThickness=0.5,
              fillPattern=FillPattern.Forward,
              fillColor={255,170,170}),
            Polygon(
              points={{-80,20},{-28,20},{-34,12},{-80,20}},
              lineColor={0,0,255},
              lineThickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-34,-22},{40,-36},{46,-36},{50,-34},{54,-32}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{-20,-14},{-22,-22},{-22,-24}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{20,-22},{18,-32}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Line(
              points={{58,-24},{52,-28},{46,-30},{40,-30},{32,-28},{24,-26},{10,-22}},
              color={0,0,255},
              thickness=0.5,
              smooth=Smooth.None),
            Polygon(
              points={{26,26},{30,-4},{56,-4},{52,16},{26,26}},
              lineColor={255,0,0},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillPattern=FillPattern.Forward,
              fillColor={255,170,170}),
            Polygon(
              points={{14,54},{6,32},{22,32},{14,54}},
              lineColor={213,170,255},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillColor={213,170,255},
              fillPattern=FillPattern.Forward),
            Polygon(
              points={{12,54},{-54,46},{-58,58},{12,54}},
              lineColor={170,85,255},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillPattern=FillPattern.CrossDiag,
              fillColor={213,170,255}),
            Polygon(
              points={{16,54},{84,68},{86,50},{16,54}},
              lineColor={170,85,255},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillColor={213,170,255},
              fillPattern=FillPattern.CrossDiag),
            Polygon(
              points={{-80,20},{-84,30},{-88,8},{-80,20}},
              lineColor={0,0,255},
              lineThickness=0.5,
              smooth=Smooth.None)}));
    end HelicopterDer;

    package Examples
      model HelicopterInput
        HelicopterDer helicopterDer
          annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.TimeTable timeTable(table=[0,0.3; 7,0.3; 7,0; 15,
              0; 15,0.3; 22,0.3; 22,0; 30,0])
          annotation (Placement(transformation(extent={{-60,22},{-40,42}})));
        Modelica.Blocks.Sources.TimeTable timeTable1(table=[0,3; 15,3; 15,0; 30,0])
          annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
      equation
        connect(timeTable.y, helicopterDer.u) annotation (Line(
            points={{-39,32},{-8,32},{-8,13.4},{23.4,13.4}},
            color={0,0,127},
            smooth=Smooth.None));
        connect(timeTable1.y, helicopterDer.u1) annotation (Line(
            points={{-39,-30},{-8,-30},{-8,7.8},{23,7.8}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
        Documentation(info="<HTML>
    <p>
    The model is based on HelicopterDer and step functions are set as an input.
    </p>
    <p>
    Simulation time: 150s
    </p>
    </HTML>"));
      end HelicopterInput;
    end Examples;
  end Helicopter;

  package MarinePopulation
    model MarinePopulation
      //parameter
      parameter Real m[8]={0,0,0,0,0,0,0,0};
      parameter Real g[7]={0,0,0,0,0,0,0};
      //states
      Real y[8](start={ 20000, 17000, 10000, 15000, 12000, 9000, 7000, 3000}, each fixed=true);
    equation
      der(y) = cat(1,{0},g).*cat(1,{0},y[1:7]) - (m+cat(1,g,{0})).*y;
      annotation (experiment(StopTime=10), __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
Given estimates of the abundance of the population of a marine species at each stage (for
example, nauplius, juvenile, adult) as a function of time, determine stage speci c growth
and mortality rates.
The objective is to minimize the error between computed and observed data.
m and g are the unknown mortality and growth rates at the stages with g0=0.
</p>
<p>
Simulation time: 10s
</p>
</HTML>"),
        Diagram(graphics),
        Icon(graphics={
            Ellipse(
              extent={{-40,20},{84,-20}},
              lineColor={0,0,255},
              fillPattern=FillPattern.Sphere),
            Polygon(
              points={{-36,2},{-76,22},{-76,-18},{-36,2}},
              lineColor={0,0,255},
              smooth=Smooth.None,
              fillPattern=FillPattern.CrossDiag,
              fillColor={167,167,0}),
            Line(
              points={{22,-6},{22,-12},{20,-18},{16,-26},{10,-28},{4,-28},{-2,
                  -26},{-4,-24},{-4,-20},{0,-16},{4,-12},{8,-6}},
              color={0,127,0},
              smooth=Smooth.None,
              thickness=1),
            Ellipse(
              extent={{56,10},{62,4}},
              lineColor={0,0,255},
              fillColor={0,127,0},
              fillPattern=FillPattern.CrossDiag),
            Line(
              points={{74,-12},{66,-8},{78,-8}},
              color={0,127,0},
              thickness=1,
              smooth=Smooth.None),
            Line(
              points={{-14,12},{-14,28},{-8,24},{-2,30},{4,26},{12,32},{18,28},
                  {26,32},{30,26},{42,24},{42,14}},
              color={0,127,0},
              thickness=1,
              smooth=Smooth.None)}));
    end MarinePopulation;
  end MarinePopulation;

  package MoonLander
    model MoonLander
      import SI = Modelica.SIunits;
      //parameter
      //state start values
      parameter SI.Height   h_0 = 1;
      parameter SI.Velocity v_0 = -0.783;
      parameter SI.Mass     m_0 = 1;
      //states
      SI.Height   h(start=h_0, fixed=true);
      SI.Velocity v(start=v_0, fixed=true);
      SI.Mass     m(start=m_0, fixed=true);
      //control input
      Modelica.Blocks.Interfaces.RealInput u "thrust" annotation (Placement(transformation(
              extent={{-120,-20},{-80,20}}),
                                          iconTransformation(extent={{-120,-20},
                {-80,20}})));
    equation
      der(h) = v;
      der(v) = -1+u/m;
      der(m) = -u/2.349;
      annotation (experiment(NumberOfIntervals=1),
          __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
Example about landing an object.
</p>
<p>
Simulation time: 1s 
</p>
</HTML>"),
        Icon(graphics={
            Ellipse(
              extent={{0,38},{-10,36}},
              lineColor={255,164,90},
              lineThickness=0.5,
              fillPattern=FillPattern.Sphere,
              fillColor={255,213,170}),
            Ellipse(
              extent={{-54,60},{70,-58}},
              lineColor={255,164,90},
              lineThickness=0.5),
            Ellipse(
              extent={{28,16},{54,4}},
              lineColor={255,164,90},
              lineThickness=0.5,
              fillPattern=FillPattern.Sphere,
              fillColor={255,213,170}),
            Ellipse(
              extent={{-36,30},{-16,22}},
              lineColor={255,164,90},
              lineThickness=0.5,
              fillColor={255,213,170},
              fillPattern=FillPattern.Sphere),
            Ellipse(
              extent={{-26,-4},{0,-16}},
              lineColor={255,164,90},
              lineThickness=0.5,
              fillPattern=FillPattern.Sphere,
              fillColor={255,213,170}),
            Ellipse(
              extent={{8,-28},{38,-38}},
              lineColor={255,164,90},
              lineThickness=0.5,
              fillPattern=FillPattern.Sphere,
              fillColor={255,213,170}),
            Line(
              points={{10,48},{10,10},{10,10}},
              color={127,0,0},
              thickness=0.5,
              smooth=Smooth.None),
            Polygon(
              points={{10,48},{38,44},{38,26},{10,30},{10,48}},
              lineColor={127,0,0},
              lineThickness=0.5,
              smooth=Smooth.None,
              fillColor={255,170,170},
              fillPattern=FillPattern.Forward)}));
    end MoonLander;

    package Examples
      model MoonLanderInput
        MoonLander moonLander
          annotation (Placement(transformation(extent={{20,20},{40,40}})));
        Modelica.Blocks.Sources.TimeTable timeTable(table=[0,0; 0.2,0; 0.25,1.227;
              1.5,1.227])
          annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
      equation
        connect(timeTable.y, moonLander.u) annotation (Line(
            points={{-19,30},{20,30}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (
          Diagram(graphics),
          experiment(StopTime=1.5, NumberOfIntervals=1),
          __Dymola_experimentSetupOutput,
          Documentation(info="<HTML>
    <p>
    The model is based on MoonLander and a step function is set as an input.
    </p>
    <p>
    Simulation time: 1s
    </p>
    </HTML>"));
      end MoonLanderInput;
    end Examples;
  end MoonLander;

  package PenicillinPlant
    model PenicillinPlant1
      import SI = Modelica.SIunits;
      parameter Real miu_m = 0.02;
      parameter Real Km =   0.05;
      parameter Real Ki = 5;
      parameter Real Yx =    0.5;
      parameter Real Yp =   1.2;
      parameter Real v = 0.004;
      parameter Real Sin =   200;
      //state start values
      parameter Real X1_0=1;
      parameter Real S1_0=0.5;
      parameter Real P1_0=0;
      parameter Real V1_0=150;
      parameter Real u1_0=1;
      //state start values
      Real X1(start=X1_0,fixed=true) "Cell mass concentration";
      Real S1(start=S1_0,fixed=true) "Substrate concentration";
      Real P1(start=P1_0,fixed=true) "Penicillin concentration";
      Real V1(start=V1_0,fixed=true) "Volume of medium";
      Real u1(start=u1_0,fixed=true);
      Real miu1;
      //control signal
      Modelica.Blocks.Interfaces.RealInput du1 "Feed Flowrate derivative"
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      miu1 = (miu_m*S1)/(Km+S1+S1^2/Ki);
      der(X1) = miu1*X1-u1/V1*X1;
      der(S1) = -miu1*X1/Yx - v*X1/Yp + u1/V1*(Sin - S1);
      der(P1) = v*X1 - u1/V1*P1;
      der(V1) = u1;
      der(u1) = du1;
      annotation (experiment(StopTime=150, NumberOfIntervals=100),
          __Dymola_experimentSetupOutput,
     Documentation(info="<HTML>
 <p>
In this problem, the objective is to maximize the concentration of penicillin, P, produced 
in a fed-batch bioreactor, given a finite amount of time.
</p>
<ul>
<li> Reactions: S -> X, S -> P  </li>
<li> Conditions: Fed-batch, isothermal </li>
<li> Objective: Maximize the concentration of product P at a given final time </li>
<li> Manipulated variable: Feed rate of S </li>
<li> Constraints: Input bounds; upper limit on the biomass concentration,
which is motivated by oxygen-transfer limitation typically occurring at
large biomass concentration </li>
</ul>
 <p>
Two phases occur in the model. After the cell mass concetration X has reached a certain value 
(3.7), the constraint for u changes. In the Python file 'penicillin_plant_time.py' an optimal
time for the phase change is determed (80.334).
</p>
 <p>
Reference:
</p>
<p>
Fed-batch Fermentor Control: Dynamic Optimization of Batch Processes II. Role of Measurements 
in Handling Uncertainty 2001, B. Srinivasan, D. Bonvin, E. Visser, S. Palanki 
</p>
<p>
PROPT - Matlab Optimal Control Software (DAE, ODE)
</p>
<p>
Simulation time: 150s
</p>

</HTML>"),
        Diagram(graphics),
        Icon(graphics={
            Rectangle(
              extent={{-20,40},{20,0}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,128},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-20,0},{20,-40}},
              lineColor={255,170,213},
              lineThickness=0.5,
              fillColor={255,170,213},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-20,60},{20,20}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,128},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-20,-20},{20,-60}},
              lineColor={255,170,213},
              lineThickness=0.5,
              fillColor={255,170,213},
              fillPattern=FillPattern.Solid)}));
    end PenicillinPlant1;

    model PenicillinPlant2
      import SI = Modelica.SIunits;
       //parameter
          parameter Real miu_m = 0.02;
          parameter Real Km =   0.05;
          parameter Real Ki = 5;
          parameter Real Yx = 0.5;
          parameter Real Yp = 1.2;
          parameter Real v = 0.004;
          parameter Real Sin = 200;
          //state start values, equal to final values of first phase
          parameter Real X2_0 = 3.7;
          parameter Real S2_0 = 0;
          parameter Real P2_0 = 0.6;
          parameter Real V2_0 = 150;
          parameter Real u2_0 = 0.03;
          parameter Real du2_0 = 0;
          //state start values
          Real X2(start=X2_0,fixed=true);
          Real S2(start=S2_0,fixed=true);
          Real P2(start=P2_0,fixed=true);
          Real V2(start=V2_0,fixed=true);
          Real u2(start=u2_0,fixed=true);
          Real miu2;
          //control signal
      Modelica.Blocks.Interfaces.RealInput du2 annotation (Placement(transformation(
              extent={{-120,-20},{-80,20}}),
                                         iconTransformation(extent={{-120,-20},
                {-80,20}})));
    equation
          miu2 = (miu_m*S2)/(Km+S2+S2^2/Ki);
          der(X2) = miu2*X2-u2/V2*X2;
          der(S2) = -miu2*X2/Yx - v*X2/Yp + u2/V2*(Sin - S2);
          der(P2) = v*X2 - u2/V2*P2;
          der(V2) = u2;
          der(u2) = du2;
      annotation (Documentation(info="<HTML>
<p>
The model is equivalent to PenicillinPlant1 except the input value. Furthermore the upper constraint for u is set to 0.03.
</p>
<p>
Simulation time: 150s
</p>

</HTML>"),
    Icon(graphics={
            Rectangle(
              extent={{-20,40},{20,0}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,128},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-20,0},{20,-40}},
              lineColor={255,170,213},
              lineThickness=0.5,
              fillColor={255,170,213},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-20,60},{20,20}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,128},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-20,-20},{20,-60}},
              lineColor={255,170,213},
              lineThickness=0.5,
              fillColor={255,170,213},
              fillPattern=FillPattern.Solid)}));
    end PenicillinPlant2;

    model PenicillinPlantTest
      import SI = Modelica.SIunits;
      parameter Real miu_m = 0.02;
      parameter Real Km =   0.05;
      parameter Real Ki = 5;
      parameter Real Yx =    0.3;
      parameter Real Yp =   1.2;
      parameter Real v = 0.004;
      parameter Real Sin =   200;
      //state start values
      parameter Real X1_0=1;
      parameter Real S1_0=0.5;
      parameter Real P1_0=0;
      parameter Real V1_0=150;
      //state start values
      Real X1(start=X1_0,fixed=true) "Cell mass concentration";
      Real S1(start=S1_0,fixed=true) "Substrate concentration";
      Real P1(start=P1_0,fixed=true) "Penicillin concentration";
      Real V1(start=V1_0,fixed=true) "Volume of medium";
      Real miu1;
      //control signal
      Modelica.Blocks.Interfaces.RealInput u1 "Feed Flowrate"
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
    equation
      miu1 = (miu_m*S1)/(Km+S1+S1^2/Ki);
      der(X1) = miu1*X1-u1/V1*X1;
      der(S1) = -miu1*X1/Yx - v*X1/Yp + u1/V1*(Sin - S1);
      der(P1) = v*X1 - u1/V1*P1;
      der(V1) = u1;
      annotation (experiment(StopTime=150, NumberOfIntervals=100),
          __Dymola_experimentSetupOutput,
          Diagram(graphics),
          Documentation(info="<HTML>
      <p>
      The model is equivalent to PenicillinPlant1 but u is set as an input instead of du. That makes it possible to experiment with input values in Dymola.
      </p>
      <p>
      Simulation time: 150s
      </p>

      </HTML>"),
        Icon(graphics={
            Rectangle(
              extent={{-20,40},{20,0}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,128},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-20,0},{20,-40}},
              lineColor={255,170,213},
              lineThickness=0.5,
              fillColor={255,170,213},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-20,60},{20,20}},
              lineColor={255,0,128},
              lineThickness=0.5,
              fillColor={255,0,128},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-20,-20},{20,-60}},
              lineColor={255,170,213},
              lineThickness=0.5,
              fillColor={255,170,213},
              fillPattern=FillPattern.Solid)}));
    end PenicillinPlantTest;

    package Examples
      model PenicillinPlantInput
        PenicillinPlantTest penicillinPlantTest
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
        Modelica.Blocks.Sources.Trapezoid trapezoid(
          amplitude=0.09,
          rising=75,
          width=0,
          falling=0.1,
          period=150,
          nperiod=1,
          offset=0.01)
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(trapezoid.y, penicillinPlantTest.u1) annotation (Line(
            points={{-19,10},{-6.5,10},{-6.5,10},{0,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (
          Diagram(graphics),
          experiment(StopTime=150),
          __Dymola_experimentSetupOutput,
          Documentation(info="<HTML>
    <p>
    The model is based on PenicillinPlantTest and an input function which is adjusted to optimization results is set.
    </p>
    <p>
    Simulation time: 150s
    </p>
    
    </HTML>"));
      end PenicillinPlantInput;

      model PenicillinPlantInputConst
        PenicillinPlantTest penicillinPlantTest
          annotation (Placement(transformation(extent={{0,0},{20,20}})));
        Modelica.Blocks.Sources.Constant const(k=0.03)
          annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
      equation
        connect(const.y, penicillinPlantTest.u1) annotation (Line(
            points={{-39,10},{-16,10},{-16,10},{0,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (
          Diagram(graphics),
          experiment(StopTime=150),
          __Dymola_experimentSetupOutput,
          Documentation(info="<HTML>
    <p>
    The model is based on PenicillinPlantTest and a constant input is set.
    </p>
    <p>
    Simulation time: 150s
    </p>
    
    </HTML>"));
      end PenicillinPlantInputConst;
    end Examples;
  end PenicillinPlant;

  package Polyeth
    model Polyeth
      import SI = Modelica.SIunits;
        //define constants:
        parameter SI.Volume Vg = 500;
        parameter SI.Volume Vp = 0.5;
        parameter Real Pv = 17;
        parameter SI.Mass Bw = 7e4;
        parameter SI.SpecificHeatCapacity Cpm1 = 11*4.1868;
        parameter Real Cv = 7.5;
        parameter SI.SpecificHeatCapacity Cpw = 4.1868e3;
        parameter SI.SpecificHeatCapacity CpIn = 6.9*4.1868;
        parameter SI.SpecificHeatCapacity Cppol = 0.85e3 * 4.1868;
        parameter SI.MolarMass Mw1 = 28.05e-3;
        parameter SI.Mass Mw = 3.314e4;
        parameter SI.AmountOfSubstance Mg = 6060.5;
        parameter SI.HeatCapacity MrCpr = 1.4*4.1868e7;
        parameter SI.SpecificEnergy Hreac = -894*4.1868e3;
        parameter Real UA = 1.14*4.1868e6 "J/(K*s)";
        parameter SI.MolarFlowRate FIn = 5;
        parameter SI.MolarFlowRate FM1 = 190;
        parameter SI.MolarFlowRate Fg = 8500;
        parameter SI.MassFlowRate Fw = 3.11e5*18e-3;
        parameter SI.Temperature Tf = 360;
        parameter SI.Temperature Twi = 289.56;
        parameter Real RR = 8.20575e-5;
        parameter SI.MolarHeatCapacity R = 8.314;
        //define parameter theta
         parameter SI.IonicStrength ac = 0.548;
         parameter Real kp0 = 85e-3;
         parameter Real Ea = 9e3*4.1868 "J/mol";
         parameter Real kd = 1e-4 "s^-1";
        // Control Signal
        parameter SI.MassFlowRate Fc = 1.5/3600;
        parameter SI.Temperature Tfeed = 293 "scalar or vector??";
        //Fc (start = Fc_ss) could be defined as input for optimization problems
        //Tfeed (start = Tfeed_ss) step control signal value could be defined as input for optimization problems
         //States
         SI.Concentration In_con(start = 483.5818, fixed=true)
        "Molar concentration of inert in the gas phase";
         SI.Concentration M1_con(start = 218.6872, fixed=true)
        "Molar concentration of ethylene in the gas phase";
         SI.AmountOfSubstance Y1(start = 5.0385) "Moles of active site type 1";
         SI.AmountOfSubstance Y2(start = 5.0385) "Moles of active site type 2";
         SI.Temperature T(start = 360.069) "Reactor temperature";
         SI.Temperature Tw(start = 290.3755)
        "Cooling water temperature from exchanger";
         SI.Temperature Tg(start = 294.3801) "Recycle gas temperature";
         Real bt;
         Real RM1;
         Real Cpg;
         Real Hf;
         Real Hg1;
         Real Hg0;
         Real Hr;
         Real Hpol;
    equation
         //Algebric equations:
         0 = Vp * Cv * sqrt((M1_con+In_con) * RR * T - Pv) -bt;
         0 = M1_con * kp0 * exp(-Ea/R*(1/T-1/Tf)) * (Y1+Y2) -RM1;
         0 = M1_con/(M1_con + In_con) * Cpm1 + In_con/(M1_con + In_con) * CpIn-Cpg;
         0 = FM1 * Cpm1 * ( Tfeed - Tf) + FIn * CpIn * (Tfeed - Tf)-Hf;
         0 = Fg * (Tg - Tf) * Cpg-Hg1;
         0 = (Fg + bt) * (T - Tf) * Cpg-Hg0;
         0 = Hreac * Mw1 * RM1-Hr;
         0 = Cppol * (T - Tf) * RM1 * Mw1-Hpol;
         // Differential equations:
         der(In_con) = (FIn - In_con/(M1_con + In_con) * bt)/Vg;
         der(M1_con) = (FM1 - M1_con/(M1_con + In_con) * bt - RM1)/Vg;
         der(Y1)     = Fc * ac - kd * Y1 - RM1 * Mw1 * Y1/ Bw;
         der(Y2)     = Fc * ac - kd * Y2 - RM1 * Mw1 * Y2/ Bw;
         der(T)      = (Hf + Hg1 - Hg0 - Hr - Hpol)/(MrCpr + Bw * Cppol);
         der(Tw)     = Fw/Mw * (Twi - Tw) - UA/(Mw * Cpw) * (Tw - Tg);
         der(Tg)     = Fg/Mg * (T - Tg)   + UA/(Mg * Cpg) * (Tw - Tg);
      annotation (Icon(graphics),
        experiment(StopTime=36000),
        __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
reference:
</p>
<p>
A. Gani et al. Journal of Process Control, 17 (2007), pp. 439-451
</p>
<p>
temperature control of industrial gas phase polyethylene reactors, S. A. Dadebo, 
P. J. McLellan and K. B. McAuley, J Proc. Cont. Vol. 7 No. 2, pp. 83 95, 1997.
</p>
<p>
effects of perating conditions on stability of gas-phase polyethylene reactors, K. B. McAuley,
D. A. Macdonald, and P. J. Mclellan, AIChE Journal, Vol. 41, pp. 868-879
</p>
<p>
Simulation time: 36000s
</p>
</HTML>"));
    end Polyeth;

    model PolyethTest
      import SI = Modelica.SIunits;
        //define constants:
        parameter SI.Volume Vg = 500;
        parameter SI.Volume Vp = 0.5;
        parameter Real Pv = 17;
        parameter SI.Mass Bw = 7e4;
        parameter SI.SpecificHeatCapacity Cpm1 = 11*4.1868;
        parameter Real Cv = 7.5;
        parameter SI.SpecificHeatCapacity Cpw = 4.1868e3;
        parameter SI.SpecificHeatCapacity CpIn = 6.9*4.1868;
        parameter SI.SpecificHeatCapacity Cppol = 0.85e3 * 4.1868;
        parameter SI.MolarMass Mw1 = 28.05e-3;
        parameter SI.Mass Mw = 3.314e4;
        parameter SI.AmountOfSubstance Mg = 6060.5;
        parameter SI.HeatCapacity MrCpr = 1.4*4.1868e7;
        parameter SI.SpecificEnergy Hreac = -894*4.1868e3;
        parameter Real UA = 1.14*4.1868e6 "J/(K*s)";
        parameter SI.MolarFlowRate FIn = 5;
        parameter SI.MolarFlowRate FM1 = 190;
        parameter SI.MolarFlowRate Fg = 8500;
        parameter SI.MassFlowRate Fw = 3.11e5*18e-3;
        parameter SI.Temperature Tf = 360;
        parameter SI.Temperature Twi = 289.56;
        parameter Real RR = 8.20575e-5;
        parameter SI.MolarHeatCapacity R = 8.314;
        parameter SI.Temperature Tfeed=293;
        //define parameter theta
         parameter SI.IonicStrength ac = 0.548;
         parameter Real kp0 = 85e-3;
         parameter Real Ea = 9e3*4.1868 "J/mol";
         parameter Real kd = 1e-4 "s^-1";
         //States
         SI.Concentration In_con(start = 483.5818, fixed=true)
        "Molar concentration of inert in the gas phase";
         SI.Concentration M1_con(start = 218.6872, fixed=true)
        "Molar concentration of ethylene in the gas phase";
         SI.AmountOfSubstance Y1(start = 5.0385) "Moles of active site type 1";
         SI.AmountOfSubstance Y2(start = 5.0385) "Moles of active site type 2";
         SI.Temperature T(start = 360.069) "Reactor temperature";
         SI.Temperature Tw(start = 290.3755)
        "Cooling water temperature from exchanger";
         SI.Temperature Tg(start = 294.3801) "Recycle gas temperature";
         Real bt;
         Real RM1;
         Real Cpg;
         Real Hf;
         Real Hg1;
         Real Hg0;
         Real Hr;
         Real Hpol;
         // Control Signal
      Modelica.Blocks.Interfaces.RealInput Fc annotation (Placement(transformation(
              extent={{-60,20},{-20,60}}), iconTransformation(extent={{-60,20},{-20,
                60}})));
    equation
         //Algebric equations:
         bt = Vp * Cv * sqrt((M1_con+In_con) * RR * T - Pv);
         0 = M1_con * kp0 * exp(-Ea/R*(1/T-1/Tf)) * (Y1+Y2) -RM1;
         0 = M1_con/(M1_con + In_con) * Cpm1 + In_con/(M1_con + In_con) * CpIn-Cpg;
         0 = FM1 * Cpm1 * ( Tfeed - Tf) + FIn * CpIn * (Tfeed - Tf)-Hf;
         0 = Fg * (Tg - Tf) * Cpg-Hg1;
         0 = (Fg + bt) * (T - Tf) * Cpg-Hg0;
         0 = Hreac * Mw1 * RM1-Hr;
         0 = Cppol * (T - Tf) * RM1 * Mw1-Hpol;
         // Differential equations:
         der(In_con) = (FIn - In_con/(M1_con + In_con) * bt)/Vg;
         der(M1_con) = (FM1 - M1_con/(M1_con + In_con) * bt - RM1)/Vg;
         der(Y1)     = Fc * ac - kd * Y1 - RM1 * Mw1 * Y1/ Bw;
         der(Y2)     = Fc * ac - kd * Y2 - RM1 * Mw1 * Y2/ Bw;
         der(T)      = (Hf + Hg1 - Hg0 - Hr - Hpol)/(MrCpr + Bw * Cppol);
         der(Tw)     = Fw/Mw * (Twi - Tw) - UA/(Mw * Cpw) * (Tw - Tg);
         der(Tg)     = Fg/Mg * (T - Tg) + UA/(Mg * Cpg) * (Tw - Tg);
      annotation (Icon(graphics),
        experiment(StopTime=36000),
        __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
    <p>
    Based on the Polyeth model the Feed is defined as an input to experiment in Dymola.
    </p>
    <p>
    Simulation time: 36000s
    </p>
    </HTML>"));
    end PolyethTest;

    package Examples
      model PolyethInput
        JMExamples.Polyeth.PolyethTest
                     polyethInput
          annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.Constant const(k=1/1800) "1"
          annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      equation
        connect(const.y, polyethInput.Fc) annotation (Line(
            points={{-19,10},{4,10},{4,14},{26,14}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=36000),
          __Dymola_experimentSetupOutput,
           Documentation(info="<HTML>
    <p>
    The model is based on PolyethTest and a constant input is set.
    </p>
    <p>
    Simulation time: 36000s
    </p>
    
    </HTML>"));
      end PolyethInput;
    end Examples;
  end Polyeth;

  package QuadrupleTank
    model QuadrupleTank
        import SI = Modelica.SIunits;
         //State start values
         parameter Real x1_0 = 8.2444;
         parameter Real x2_0= 19.0163;
         parameter Real x3_0 = 4.3146;
         parameter Real x4_0= 8.8065;
         parameter Real u1_0 = 3;
         parameter Real u2_0= 3;
         //States
         Real x1(start = x1_0, fixed=true);
         Real x2(start = x2_0, fixed=true);
         Real x3(start = x3_0, fixed=true);
         Real x4(start = x4_0, fixed=true);
         //Parameter
         parameter SI.Area Al = 28*10e-4 "Tank cross section of lower tanks";
         parameter SI.Area Au = 32*10e-4 "Tank cross section of upper tanks";
         parameter SI.Area al = 7.1*10e-6 "Outlet cross section of lower tanks";
         parameter SI.Area au = 5.7*10e-6 "Outlet cross section of upper tanks";
         parameter Real k1 = 3.33*10e-6;
         parameter Real k2 = 3.35*10e-6;
         parameter Real kc = 50;
         parameter Real gamma1 = 0.25 "Position of the valves";
         parameter Real gamma2 = 0.35 "Position of the valves";
         parameter SI.Acceleration g = 9.81 "Acceleration of gravity";
         //Control Signal
          Modelica.Blocks.Interfaces.RealInput u2(start=u2_0, fixed=true)
        annotation (Placement(transformation(extent={{-120,-20},{-80,20}}),
            iconTransformation(extent={{-120,-20},{-80,20}})));
      Modelica.Blocks.Interfaces.RealInput u1(start=u1_0, fixed=true)
        annotation (Placement(transformation(extent={{-120,30},{-80,70}})));
    equation
          der(x1) = -al/Al*sqrt(2*g*x1) + au/Al*sqrt(2*g*x3) + gamma1*k1/Al*u1;
          der(x2) = -al/Al*sqrt(2*g*x2) + au/Al*sqrt(2*g*x4) + gamma2*k2/Al*u2;
          der(x3) = -au/Au*sqrt(2*g*x3) + (1-gamma1)*k2/Au*u2;
          der(x4) = -au/Au*sqrt(2*g*x4) + (1-gamma2)*k1/Au*u1;
      annotation (Diagram(graphics),
        experiment(StopTime=60),
        __Dymola_experimentSetupOutput);
    end QuadrupleTank;

    package Examples
      model QuadrupleTankInput
        QuadrupleTank quadrupleTank
          annotation (Placement(transformation(extent={{20,0},{40,20}})));
        Modelica.Blocks.Sources.Constant const(k=3)
          annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
        Modelica.Blocks.Sources.Constant const1(k=3)
          annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));
      equation
        connect(const.y, quadrupleTank.u1) annotation (Line(
            points={{-19,30},{0,30},{0,15},{20,15}},
            color={0,0,127},
            thickness=0.5,
            smooth=Smooth.None));
        connect(const1.y, quadrupleTank.u2) annotation (Line(
            points={{-19,-10},{0,-10},{0,10},{20,10}},
            color={0,0,127},
            thickness=0.5,
            smooth=Smooth.None));
        annotation (Diagram(graphics));
      end QuadrupleTankInput;
    end Examples;
  end QuadrupleTank;

package VDP
  model VDP "Van der Pol model"
     // State start values
     parameter Real x1_0 = 0;
     parameter Real x2_0 = 1;
     // The states
     Real x1(start = x1_0);
     Real x2(start = x2_0);
     // The control signal
    Modelica.Blocks.Interfaces.RealInput u
      annotation (Placement(transformation(extent={{-120,-20},{-80,20}})));
  equation
     der(x1) = (1 - x2^2) * x1 - x2 + u;
     der(x2) = x1;
    annotation (
      Documentation(info="<HTML>
<p>
The model represents the behavior of a free Van-der-Pol oscillator, which is an oscillatory system with non-linear damping.
It evolves in time according to a second order differential equation, where x1 and x2 are the position coordinates.

For small amplitudes the damping is negativ. The amplitude increases up to a certain limit, where the damping becomes positive. 
The system stabilises and a limit cycle develops.
</p>
<p>
Simulation time: 10s
</p>


</HTML>"),
        experiment(StopTime=10),
        __Dymola_experimentSetupOutput,
      Icon(graphics={Line(
            points={{40,4},{40,0},{38,-4},{34,-10},{28,-16},{22,-20},{16,-24},{0,-34},
                {-6,-36},{-10,-36},{-14,-34},{-18,-32},{-22,-28},{-26,-22},{-30,-18},
                {-32,-14},{-36,-8},{-36,-4},{-36,2},{-36,8},{-34,16},{-30,20},{-24,
                26},{-14,32},{2,42},{12,50},{20,54},{30,56},{40,56},{46,54},{54,48},
                {60,42},{64,34},{66,28},{66,22},{66,18},{66,12},{64,6},{62,2},{58,
                -2},{48,-12},{38,-20},{24,-30},{6,-40},{-4,-44},{-14,-44},{-22,-42},
                {-30,-36},{-36,-30},{-42,-24},{-46,-18},{-50,-10},{-50,0},{-48,12},
                {-44,20},{-36,26},{-30,30}},
            color={0,0,255},
            smooth=Smooth.None)}));
  end VDP;

  package Examples
    model VDPexpsin
      VDP vDP annotation (Placement(transformation(extent={{20,0},{40,20}})));
      Modelica.Blocks.Sources.ExpSine expSine(amplitude=10)
        annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
    equation
      connect(expSine.y, vDP.u) annotation (Line(
          points={{-19,10},{20,10}},
          color={0,0,127},
          smooth=Smooth.None));
      annotation (Diagram(graphics),
        Documentation(info="<HTML>
<p>
input: expsin function
</p>
<p>
Simulation time: 10s
</p>


</HTML>"));
    end VDPexpsin;

    model VDPramp
      VDP vDP annotation (Placement(transformation(extent={{20,0},{40,20}})));
      Modelica.Blocks.Sources.Ramp ramp
        annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
    equation
      connect(ramp.y, vDP.u) annotation (Line(
          points={{-19,10},{20,10}},
          color={0,0,127},
          smooth=Smooth.None));
      annotation (
        Diagram(graphics),
        experiment(StopTime=10, NumberOfIntervals=50),
        __Dymola_experimentSetupOutput,
        Documentation(info="<HTML>
<p>
input: ramp function
</p>
<p>
Simulation time: 10s
</p>


</HTML>"));
    end VDPramp;

    model VDPexp
      VDP vDP annotation (Placement(transformation(extent={{20,0},{40,20}})));
      Modelica.Blocks.Sources.Exponentials exponentials(riseTime=10)
        annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
    equation
      connect(exponentials.y, vDP.u) annotation (Line(
          points={{-19,10},{20,10}},
          color={0,0,127},
          smooth=Smooth.None));
      annotation (Diagram(graphics),
        Documentation(info="<HTML>
<p>
input: exponential function
</p>
<p>
Simulation time: 10s
</p>


</HTML>"));
    end VDPexp;

    model VDPpulse
      VDP vDP annotation (Placement(transformation(extent={{0,0},{20,20}})));
      Modelica.Blocks.Sources.Pulse pulse(amplitude=10)
        annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
    equation
      connect(pulse.y, vDP.u) annotation (Line(
          points={{-39,10},{0,10}},
          color={0,0,127},
          smooth=Smooth.None));
      annotation (Diagram(graphics),
        Documentation(info="<HTML>
<p>
input: pulse function
</p>
<p>
Simulation time: 10s
</p>


</HTML>"));
    end VDPpulse;

    model VDPsine
      VDP vDP annotation (Placement(transformation(extent={{20,0},{40,20}})));
      Modelica.Blocks.Sources.Sine sine(amplitude=5, freqHz=1)
        annotation (Placement(transformation(extent={{-32,0},{-12,20}})));
    equation
      connect(sine.y, vDP.u) annotation (Line(
          points={{-11,10},{20,10}},
          color={0,0,127},
          smooth=Smooth.None));
      annotation (Diagram(graphics),
        Documentation(info="<HTML>
<p>
input: sine function
</p>
<p>
Simulation time: 10s
</p>


</HTML>"));
    end VDPsine;
  end Examples;
end VDP;
  annotation (uses(Modelica(version="3.2")));
end JMExamples;
