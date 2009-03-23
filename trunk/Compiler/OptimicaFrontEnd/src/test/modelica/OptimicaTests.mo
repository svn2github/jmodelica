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

model OptimicaTests
  
  model AttributeTest1
    Real x(initialGuess=3.5,free=false)=3;
  end AttributeTest1;
  
  optimization ConstraintTest1
    Real x;
    Real y;
  equation 
   x=2;
  constraint
    y=4;
    y>=3;
    y<=5;
  end ConstraintTest1;

  optimization ClassAttrTest1 (objective=x(finalTime)^2,startTime=3,finalTime=4)
    Real x;
    Real y;
  equation 
   x=2;
  constraint
   x<=3;
  equation
    y=4;
  constraint 
    y>=3;
    
  end ClassAttrTest1;
  
  optimization InstantValueTest1 
     (objective=x(finalTime)^2,startTime=0,finalTime(free=true,initialGuess=3))
    Real x(start=0);
    input Real u(free=true);
   equation
    der(x)=u;
   constraint
    x(finalTime)=3; 
    finalTime>=0.1;
    finalTime<=10;
  end InstantValueTest1;
  
  model DoubleIntegrator
  	Real x(start=0);
  	Real v(start=0);
    input Real u;
  equation
    der(x)=v;
    der(v)=u;
  end DoubleIntegrator;
  
  optimization OptDiTest1 (objective=cost(finalTime),
                           startTime=0,
                           finalTime(free=true, initialGuess=tf_guess))
    DoubleIntegrator di(u(free=true));
    Real cost(start=0);
    parameter Real tf_guess=3;
  equation
    der(cost)=1;
  constraint
    finalTime>=0.1;
    finalTime<=5;
    di.x(finalTime)=1;
    di.v(finalTime)=0;
    di.u>=-1;
    di.u<=1;
    di.v<=0.5;
  end OptDiTest1;
  
optimization DIMinTime (objective=cost(finalTime),
                        startTime=0,
                        finalTime(free=true,initialGuess=1))
  
  Real cost;
  DoubleIntegrator di(u(free=true,initialGuess=0.0));

  parameter Integer N = 100;
  parameter Real m[N] = ones(N)*(finalTime-startTime)/N;
  parameter Real c_p[3] = {0.1550,
                           0.6449,
                           1.0000};
  parameter Real l_c_a[3,3] = [2.4158, -3.9739, 1.5581;
                               -5.7491, 6.6406, -0.8914;
                               3.3333, -2.6667, 0.3333];
  parameter Real l_c_d[4,4] = [-10, 18, -9, 1;
                               15.5808, -25.6296, 10.0488, 0;
                               -8.9141, 10.2963, -1.3821, 0;
                               3.3333, -2.6667, 0.3333, 0];
  annotation(__Optimica(DirectCollocationLagrange(
                        mesh=m,
                        collocationPoints=c_p,
                        lagrangeCoefficientsAlgebraic=l_c_a,
                        lagrangeCoefficientsDynamic=l_c_d)));

equation
  der(cost) = 1;
constraint
  finalTime>=0.5;
  finalTime<=10;
  di.x(finalTime)=1;
  di.v(finalTime)=0;
  di.v<=0.5;
  di.u>=-1; di.u<=1;
end DIMinTime;

model Servo 
  
  Modelica.Mechanics.Translational.SlidingMass slidingMass(m=m1);
  Modelica.Mechanics.Translational.Force force;
  Modelica.Blocks.Interfaces.RealInput F;
  Modelica.Mechanics.Translational.SpringDamper springDamper(c=c, d=d,s_rel(min=-2000)) ;
  Modelica.Blocks.Interfaces.RealOutput y;
  Modelica.Mechanics.Translational.SlidingMass slidingMass1(m=m2);
  parameter Real m1 = 1;
  parameter Real m2 = 1;
  parameter Real d = 0.1;
  parameter Real c = 0.01;
  Modelica.Mechanics.Translational.Sensors.SpeedSensor speedSensor;
equation 
  connect(F, force.f);
  connect(springDamper.flange_b, slidingMass.flange_a);
  connect(slidingMass1.flange_b, springDamper.flange_a);
  connect(force.flange_b, slidingMass1.flange_a);
  connect(speedSensor.flange_a, slidingMass.flange_b);
  connect(y,speedSensor. v);
end Servo;

optimization ServoParameterOptimization (objective=cost,
                                         startTime=0,
                                         finalTime=100)
                                         
  Servo servo(m1(free=true,initialGuess=0.7),
              slidingMass.s(start=s0));
  Modelica.Blocks.Sources.Sine sine(amplitude=1, freqHz=0.1);
 
  parameter Real s0(free=true,initialGuess=0.1);
  
  parameter Integer N = 1;
  parameter Real data_vals[N] = {1.2};
  parameter Real data_times[N] = {0.0};
  
  Real cost = sum((data_vals[i]-servo.y(data_times[i]))^2 for i in 1:N );
equation
  connect(sine.y, servo.F);     
constraint
  servo.m1>=0.5; servo.m1<=1.5;
  s0>=-1; s0<=1;

end ServoParameterOptimization;


model QuadTank
  
  // Process parameters
  parameter Real A1=28, A2=32, A3=28, A4=32;
  parameter Real a1=0.071, a2=0.057, a3=0.071, a4=0.057;
  parameter Real kc=0.5; 
  parameter Real g=981;  
  parameter Real k1_nmp=3.14, k2_nmp=3.29; 
  parameter Real g1_nmp=0.30, g2_nmp=0.30;

  // Tank levels
  Real x[4](start={1,1,1,1},
            min={0.1,0.1,0.1,0.1},
            max={20,20,20,20}); 
  
  // Inputs
  input Real u[2]; // Control inputs

equation
  der(x[1]) = -a1/A1*sqrt(2*g*x[1]) + a3/A1*sqrt(2*g*x[3]) + 
                 g1_nmp*k1_nmp/A1*u[1];
  der(x[2]) = -a2/A2*sqrt(2*g*x[2]) + a4/A2*sqrt(2*g*x[4]) + 
                 g2_nmp*k2_nmp/A2*u[2];
  der(x[3]) = -a3/A3*sqrt(2*g*x[3]) + (1-g2_nmp)*k2_nmp/A3*u[2];
  der(x[4]) = -a4/A4*sqrt(2*g*x[4]) + (1-g1_nmp)*k1_nmp/A4*u[1];
end QuadTank;

/*
class QuadTankOpt
  x(lowerBound = {0.2,0.2,0.2,0.2},
    upperBound={20,20,20,20},
    initialGuess={1,1,1,1});
  oq u(lowerBound = {0,0}, 
       upperBound={10,10}, 
       initialGuess={1,1});
optimization
  grid(static=true);
  minimize(terminalCost=u[1]^2+u[2]^2);
subject to
  x[1]=4;
end QuadTankOpt;
*/

optimization QuadTankOptimization (objective=cost,
                                   static=true)
        
  QuadTank quadTank(u(each free=true, initialGuess={1,1}));  
  
  Real cost = quadTank.u[1]^2+quadTank.u[2];
constraint
  quadTank.u <= {10,10};
  quadTank.u >= {0,0};
  quadTank.x <= {20,20,20,20};
  quadTank.x >= {0.2,0.2,0.2,0.2};
  quadTank.x[1] = 4;
end QuadTankOptimization;



  
  model DoubleTank 
    parameter Modelica.SIunits.Area A = 2.8e-3 
      "Cross section area of the tanks";
    parameter Modelica.SIunits.Area a = 7e-6 "Cross section area of the holes";
    parameter Real k(unit="m^3/s/V") = 2.7e-6 
      "Constant of proportionality for the pump";
    parameter Real beta(unit="m/s/V") = k/A;
    parameter Real gamma = a/A;
    parameter Real g(unit="m/s^2") = 9.81;
    
    Modelica.SIunits.Length h1(start=0.0682) "Level in upper tank";
    Modelica.SIunits.Length h2(start=0.0682) "Level in lower tank";
    
    Modelica.Blocks.Interfaces.RealInput u ;
    Modelica.Blocks.Interfaces.RealOutput y=h2;
    
  equation 
    der(h1) = -gamma*sqrt(2*g*h1) + beta*u;
    der(h2) = gamma*sqrt(2*g*h1) - gamma*sqrt(2*g*h2);
    
  end DoubleTank;
 
  model DoubleTankCL 
    DoubleTank doubleTank;
    PID pid;
    
    Modelica.Blocks.Math.Feedback feedback;
    Modelica.Blocks.Interfaces.RealInput ref 
    annotation (extent=[-122,-20; -82,20]);
    Modelica.Blocks.Interfaces.RealOutput y;
    Modelica.Blocks.Interfaces.RealInput d;
    Modelica.Blocks.Math.Feedback feedback1;
    Modelica.Blocks.Math.Add add;
    Modelica.Blocks.Sources.Constant Constant(k=3);
    Modelica.Blocks.Math.Add add1(k2=-1);
    Modelica.Blocks.Sources.Constant Constant1(k=0.0682);
  equation 
    connect(feedback.y, pid.u);
    connect(feedback1.y, doubleTank.u);
    connect(d, feedback1.u2);
    connect(ref, feedback.u1);
    connect(add.y, feedback1.u1);
    connect(pid.y, add.u2);
    connect(Constant.y, add.u1);
    connect(doubleTank.y, add1.u1);
    connect(Constant1.y, add1.u2);
    connect(add1.y, feedback.u2);
    connect(add1.y, y);
  end DoubleTankCL;
  
  model PerformanceEvaluation 
    DoubleTankCL doubleTankCL(pid(k =   K,Ti =   Ti,Td =   Td));
    Modelica.Blocks.Sources.Step step(
      offset=0,
      startTime=30,
      height=0.01);
    Modelica.Blocks.Sources.Step step1(height=1, startTime=1000);
    
    parameter Real K=29;
    parameter Real Ti=24;
    parameter Real Td=60;
    
  equation 
    connect(step1.y, doubleTankCL.d);
    connect(step.y, doubleTankCL.ref);
  end PerformanceEvaluation;
  
  block PID 
  extends Modelica.Blocks.Interfaces.SISO;
  
  block Derivative 
    
    Modelica.Blocks.Interfaces.RealInput u;
    Modelica.Blocks.Interfaces.RealOutput y;
    
    parameter Real K=1;
    parameter Real Td= 1;
    parameter Real N = 100;
  protected 
      Real x(start=0);
  equation 
    der(x)=-N/Td*x-K*N^2/Td*u;
    y=x + K*N*u;
  end Derivative;
  
  
  parameter Real k=1 "Gain";
  parameter Modelica.SIunits.Time Ti(min=Modelica.Constants.small)=0.5 
    "Time Constant of Integrator";
  parameter Modelica.SIunits.Time Td(min=0)=0.1 
    "Time Constant of Derivative block";
  parameter Real Nd(min=Modelica.Constants.small) = 10 
    "The higher Nd, the more ideal the derivative block";
  
    Modelica.Blocks.Math.Gain P "Proportional part of PID controller" ;
  Modelica.Blocks.Continuous.Integrator I(k=1/Ti) 
    "Integral part of PID controller";
  Modelica.Blocks.Math.Gain Gain(k=k) "Gain of PID controller" ;
  Modelica.Blocks.Math.Add3 Add ;
  Derivative derivative(K=1,Td=Td,N=Nd);
  
equation 
  connect(P.y, Add.u1);
  connect(I.y, Add.u2);
  connect(Add.y, Gain.u);
  connect(y, Gain.y);
  connect(u, I.u);
  connect(u, P.u);
  connect(u, Add.u3);
  connect(derivative.y, Add.u3);
end PID;
  

optimization DoubleTankOptimization (objective = cost,
                                     startTime=0,
                                     finalTime=2000)

  parameter Real K(free=true, initialGuess=29);
  parameter Real Ti(free=true, initialGuess=24);
  parameter Real Td(free=true, initialGuess=60);
   
  Real cost(start=0);
 
  DoubleTankCL doubleTankCL_1(Constant(k=1), 
                              Constant1(k=0.007583), 
                              doubleTank(h1(start=0.007583), 
                                         h2(start=0.007583)), 
                              pid(k=K,Ti=Ti,Td=Td));  
  
  DoubleTankCL doubleTankCL_3(pid(k=K,Ti=Ti,Td=Td));
  
  DoubleTankCL doubleTankCL_5(Constant(k=5),
                              Constant1(k=0.1896), 
                              doubleTank(h1(start=0.1896),
                                         h2(start=0.1896)), 
                              pid(k=K,Ti=Ti,Td=Td));
 
  Modelica.Blocks.Sources.Step refStep(offset=0,startTime=30,height=0.01);
  Modelica.Blocks.Sources.Step dStep(startTime=1000, height=1);
  
equation 
  connect(dStep.y, doubleTankCL_1.d);
  connect(refStep.y, doubleTankCL_1.ref);
  connect(dStep.y, doubleTankCL_3.d);
  connect(dStep.y, doubleTankCL_5.d);
  connect(refStep.y, doubleTankCL_5.ref);
  connect(refStep.y, doubleTankCL_3.ref);
  der(cost) = (refStep.y-doubleTankCL_1.y)^2+
              (refStep.y-doubleTankCL_3.y)^2+
              (refStep.y-doubleTankCL_5.y)^2;
constraint
 K>=0;
 Ti>=0;
 Td>=0;
end DoubleTankOptimization;


end OptimicaTests;