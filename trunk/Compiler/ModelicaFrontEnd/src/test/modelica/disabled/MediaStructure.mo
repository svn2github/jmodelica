within ;
package MediaStructure
  import SI = Modelica.SIunits;
  package Fluids
    package Interfaces
      partial package PartialFluid
        constant SI.Pressure p_reference;
        constant SI.Temperature T_reference;
        constant SI.MassFraction[:] X_reference;
        replaceable partial model DynamicVolume =
            MediaStructure.Fluids.DynamicVolumes.PartialDynamicVolume;
      end PartialFluid;

    partial package PartialConstrainingFluid
        "Constraining type for each medium property package in a component"
    extends PartialFluid;
    extends Media.Interfaces.PartialMedium;
    end PartialConstrainingFluid;
    end Interfaces;

    package DynamicVolumes
      partial model PartialDynamicVolume
        replaceable package Medium =
            MediaStructure.Media.Interfaces.PartialMedium;
        SI.Pressure p(start=p_start);
        SI.Temperature T(start=T_start);
        SI.MassFraction[Medium.nS] X(start=X_start);
        SI.MoleFraction[Medium.nS] Y(start=Y_start);
        SI.SpecificEnthalpy h;
        input Real dU;
        input Real[Medium.nS] dni;
        parameter SI.Volume V;
        parameter SI.Pressure p_start;
        parameter SI.Temperature T_start;
        parameter SI.MassFraction[Medium.nS] X_start=MediaStructure.Media.moleToMassFractions(
                                                                                        Y_start,Medium.MMX);
        parameter SI.MoleFraction[Medium.nS] Y_start=MediaStructure.Media.massToMoleFractions(
                                                                                        X_start,Medium.MMX);
      equation

      end PartialDynamicVolume;

      model DynamicVolumeGas "Numerical states are T and ni"
        extends PartialDynamicVolume(redeclare replaceable package Medium =
              MediaStructure.Media.Gases.GasXY                                                             constrainedby
            MediaStructure.Media.Templates.PartialGas);
        final parameter SI.AmountOfSubstance[Medium.nS] ni_start=Y_start*n_start;
        final parameter SI.AmountOfSubstance n_start=V*p_start/Rm/T_start;
        Real u "Molar specific internal energy";
        Medium.ThermodynamicState state;
        SI.AmountOfSubstance[Medium.nS] ni;
        SI.AmountOfSubstance n;
        SI.MolarMass MM;
        SI.MolarMass[Medium.nS] MMi;
        constant Real Rm=Modelica.Constants.R;
        SI.SpecificHeatCapacity cp;
      protected
        Real MM_inv;
        Real du;
        Real dn;
        SI.SpecificEnthalpy[Medium.nS] hi;
      equation
        state=Medium.setState_pTX(p,T,X);
        h=Medium.specificEnthalpy(state);
        cp=Medium.specificHeatCapacityCp(state);
        hi={Medium.specificEnthalpy_index(state,i) for i in 1:Medium.nS};

          //Derivatives in terms of chosen states (T, ni)
        dU = du*n + dn*u;
        du = (cp*MM-Rm) *der(T) + 1/n*sum({(hi[i]*MMi[i]-h*MM)*dni[i] for i in 1:Medium.nS});
        dn = sum(dni);
        dni=der(ni);

        //Mole and mass fractions
        Y = ni/n;
        n=sum(ni);
        MMi = Medium.MMX;
        MM = Y*MMi;
        MM_inv=1/MM;
        X = Y.*MMi*MM_inv;

        //Ideal gas law
        p = Rm*T/V*n;
        u = h*MM - Rm*T;
      initial equation
        ni=ni_start;
        T=T_start;
      end DynamicVolumeGas;
    end DynamicVolumes;

    package Gases

      package IdealGasXY
        extends MediaStructure.Media.Gases.GasXY;
        extends Interfaces.PartialFluid(
        p_reference=1e5,
        T_reference=300,
        X_reference={1.0,0.0},
          redeclare model DynamicVolume =
              DynamicVolumes.DynamicVolumeGas (redeclare package Medium =
                  MediaStructure.Media.Gases.GasXY));
      end IdealGasXY;
    end Gases;
  end Fluids;

  package Media

    package Interfaces
      partial package PartialMedium
        constant Integer nS(min=1);
        constant SI.MolarMass[nS] MMX;
      replaceable partial record ThermodynamicState
          extends Modelica.Icons.Record;
      end ThermodynamicState;

      replaceable partial function setState_pTX
        input SI.Pressure p;
        input SI.Temperature T;
        input SI.MassFraction[nS] X;
        output ThermodynamicState state;
      end setState_pTX;

      replaceable partial function setState_phX
        input SI.Pressure p;
        input SI.SpecificEnthalpy h;
        input SI.MassFraction[nS] X;
        output ThermodynamicState state;
      end setState_phX;

      replaceable partial function density
        input ThermodynamicState state;
        output SI.Density rho;
      end density;

      replaceable partial function pressure
        input ThermodynamicState state;
        output SI.Pressure p;
      end pressure;

      replaceable partial function temperature
        input ThermodynamicState state;
        output SI.Temperature T;
      end temperature;

      replaceable partial function specificEnthalpy
        input ThermodynamicState state;
        output SI.SpecificEnthalpy h;
      end specificEnthalpy;

      replaceable partial function specificHeatCapacityCp
        input ThermodynamicState state;
        output SI.SpecificHeatCapacity cp;
      end specificHeatCapacityCp;

      replaceable partial function specificEnthalpy_index
        input ThermodynamicState state;
        input Integer index;
        output SI.SpecificEnthalpy h;
      end specificEnthalpy_index;

      end PartialMedium;
    end Interfaces;

    package Templates
      package PartialGas
        extends MediaStructure.Media.Interfaces.PartialMedium(nS=EOS.data.nS, MMX=EOS.data.MMX);

      replaceable package EOS =
            MediaStructure.Media.EquationsOfState.Templates.IdealGas
      constrainedby
          MediaStructure.Media.EquationsOfState.Interfaces.PartialEquationOfState;

      redeclare record ThermodynamicState
        SI.Pressure p;
        SI.Temperature T;
        SI.MassFraction[nS] X;
      end ThermodynamicState;

      redeclare function extends setState_pTX
      algorithm
        state.p:=p;
        state.T:=T;
        state.X:=X;
      end setState_pTX;

      redeclare function setState_phX
        input SI.Pressure p;
        input SI.SpecificEnthalpy h;
        input SI.MassFraction[nS] X;
        output ThermodynamicState state;
      algorithm
        state.p:=p;
        state.T:=EOS.T_phX(p,h,X);
        state.X:=X;
      end setState_phX;

      redeclare function density
        input ThermodynamicState state;
        output SI.Density rho;
      algorithm
        rho:=EOS.rho_pTX(state.p,state.T,state.X);
      end density;

      redeclare function extends pressure
      algorithm
        p:=state.p;
      end pressure;

      redeclare function extends temperature
      algorithm
        T:=state.T;
      end temperature;

      redeclare function extends specificEnthalpy
      algorithm
        h:=EOS.h_pTX(state.p,state.T,state.X);
      end specificEnthalpy;

      redeclare function extends specificEnthalpy_index
      algorithm
        h:=EOS.h0_Tindex(state.T,index);
      end specificEnthalpy_index;

      redeclare function extends specificHeatCapacityCp
      algorithm
        cp:=EOS.cp_pTX(state.p,state.T,state.X);
      end specificHeatCapacityCp;
      end PartialGas;
    end Templates;

    package DataRecords
      record IdealGasData
        parameter Integer nS;
        Boolean constCp;
        Real[nS] MMX;
        SI.SpecificEnthalpy[nS] h0;
        Real[nS,:] cpCoeff;
        SI.Temperature T0;
        /*constant Boolean constCp;
  constant Real[nS] MMX;
  constant SI.SpecificEnthalpy[nS] h0;
  constant Real[nS,:] cpCoeff;
  constant SI.Temperature T0;*/
      end IdealGasData;
    end DataRecords;

    package EquationsOfState

      package Interfaces
        package PartialEquationOfState "Interface package equation of state"

        constant Integer nS=data.nS;
        constant Integer hPolOrder=if data.constCp then 1 else 2;
        constant MediaStructure.Media.DataRecords.IdealGasData data;

          replaceable partial function h0_Tindex
            input SI.Temperature T;
            input Integer index;
            output SI.SpecificEnthalpy h;
          end h0_Tindex;

        replaceable partial function rho_pTX
            input SI.Pressure p;
            input SI.Temperature T;
            input SI.MassFraction[nS] X;
            output SI.Density rho;
        end rho_pTX;

        replaceable partial function h_pTX
            input SI.Pressure p;
            input SI.Temperature T;
            input SI.MassFraction[nS] X;
            output SI.SpecificEnthalpy h;
        end h_pTX;

        replaceable partial function cp_pTX
            input SI.Pressure p;
            input SI.Temperature T;
            input SI.MassFraction[nS] X;
            output SI.SpecificHeatCapacity cp;
        end cp_pTX;

        replaceable partial function T_phX
           input SI.Pressure p;
            input SI.SpecificEnthalpy h;
            input SI.MassFraction[nS] X;
            output SI.Temperature T;
        end T_phX;

        end PartialEquationOfState;
      end Interfaces;

      package Templates
        package IdealGas "Template package for an ideal gas"
         extends
            MediaStructure.Media.EquationsOfState.Interfaces.PartialEquationOfState;
          redeclare function extends rho_pTX
          algorithm
            rho:=p/T/Modelica.Constants.R/sum({X[i]/data.MMX[i] for i in 1:nS});
          end rho_pTX;

          redeclare function extends h0_Tindex
          algorithm
          h:=data.h0[index] + sum({data.cpCoeff[index,i]/i*(T-data.T0)^i for i in 1:hPolOrder});
          end h0_Tindex;

          redeclare function extends h_pTX
          algorithm
          h:=X*{h0_Tindex(T,i) for i in 1:nS};
          end h_pTX;

          redeclare function extends cp_pTX
          algorithm
          cp:=X*{sum({data.cpCoeff[j,i]*(T-data.T0)^(i-1) for i in 1:hPolOrder}) for j in 1:nS};
          end cp_pTX;

        redeclare function extends T_phX

        algorithm
          T:=(h-data.h0*X+(data.cpCoeff[:,1]*X)*data.T0)/(data.cpCoeff[:,1]*X);
        end T_phX;

        end IdealGas;
      end Templates;

      package Gases
        package GasXY "Example ideal gas mixture"
          extends MediaStructure.Media.EquationsOfState.Templates.IdealGas(data(
              nS=2,
              constCp=true,
              MMX={0.018,0.044},
              h0={0,0},
              cpCoeff={{1850},{846}},
              T0=298.15));
        end GasXY;
      end Gases;
    end EquationsOfState;

    package Gases
      package GasXY
        extends MediaStructure.Media.Templates.PartialGas(redeclare package EOS
            = MediaStructure.Media.EquationsOfState.Gases.GasXY);
      end GasXY;
    end Gases;

  function massToMoleFractions "Return mole fractions from mass fractions X"
    extends Modelica.Icons.Function;
    input SI.MassFraction X[:] "Mass fractions of mixture";
    input SI.MolarMass[:] MMX "molar masses of components";
    output SI.MoleFraction moleFractions[size(X,
        1)] "Mole fractions of gas mixture";
    protected
    Real invMMX[size(X, 1)] "inverses of molar weights";
    SI.MolarMass Mmix "molar mass of mixture";

  algorithm
    for i in 1:size(X, 1) loop
      invMMX[i] := 1/MMX[i];
    end for;
    Mmix := 1/(X*invMMX);
    for i in 1:size(X, 1) loop
      moleFractions[i] := Mmix*X[i]/MMX[i];
    end for;

  annotation(smoothOrder=5);
  end massToMoleFractions;

  function moleToMassFractions "Return mass fractions X from mole fractions"
    extends Modelica.Icons.Function;
    input SI.MoleFraction moleFractions[:] "Mole fractions of mixture";
    input SI.MolarMass[:] MMX "molar masses of components";
    output SI.MassFraction X[size(moleFractions,
        1)] "Mass fractions of gas mixture";

    protected
    SI.MolarMass Mmix=moleFractions*MMX "molar mass of mixture";
  algorithm
    for i in 1:size(moleFractions, 1) loop
      X[i] := moleFractions[i]*MMX[i] /Mmix;
    end for;

  annotation(smoothOrder=5);
  end moleToMassFractions;
  end Media;

  package Examples

    package Interfaces
      connector FlowPort
        replaceable package Fluid=MediaStructure.Media.Interfaces.PartialMedium;
        flow SI.MassFlowRate m_flow;
        SI.Pressure p;
        flow SI.EnthalpyFlowRate H_flow;
        SI.SpecificEnthalpy h;
        flow SI.MassFlowRate[Fluid.nS] mX_flow;
        SI.MassFraction[Fluid.nS] X;
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

        replaceable package Fluid =MediaStructure.Fluids.Gases.IdealGasXY
                                                                         constrainedby
          MediaStructure.Fluids.Interfaces.PartialConstrainingFluid         annotation(choicesAllMatching);

        constant Real[Fluid.nS] MM_inv={1/Fluid.MMX[i] for i in 1:Fluid.nS};
        constant SI.MolarMass[Fluid.nS] MM=Fluid.MMX;
        parameter Integer nP=1 "Number of flow ports";
        parameter SI.Volume V;
        parameter SI.Temperature T_start;
        parameter SI.Pressure p_start;
        parameter SI.MoleFraction[Fluid.nS] Y_start;
        Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort
          annotation (Placement(transformation(extent={{-100,-10},{-80,10}}),
              iconTransformation(extent={{-100,-10},{-80,10}})));
        Interfaces.FlowPort[nP] flowPort(redeclare each package Fluid = Fluid)
          annotation (Placement(transformation(extent={{-22,-20},{18,20}}),
              iconTransformation(extent={{-22,-20},{18,20}})));
        SI.MolarFlowRate[nP, Fluid.nS] n_flow "Species molar flow rates";
        SI.EnthalpyFlowRate[nP] H_flow "Enthalpy flow rates";
        SI.MolarFlowRate[Fluid.nS] dn "Amount storage";
        SI.EnergyFlowRate dU "Internal energy storage";
        Fluid.DynamicVolume fluid(dni=dn, dU=dU,V=V, p_start=p_start,T_start=T_start,Y_start=Y_start) annotation (Placement(transformation(extent={{-28,48},
                  {-8,68}})));

      equation
        //Energy balance
        dU=sum(H_flow) + heatPort.Q_flow;

        //Amount balances
        for i in 1:Fluid.nS loop
          dn[i]=sum(n_flow[:,i]);
        end for;
        //Energy balance
        for i in 1:nP loop
        n_flow[i,:]=flowPort[i].mX_flow./MM;
        H_flow[i]=flowPort[i].H_flow;

        //Port properties
        flowPort[i].p=fluid.p;
        flowPort[i].h=fluid.h;
        flowPort[i].X=fluid.X;
        end for;

        //Heat transfer
        heatPort.T=fluid.T;

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
      replaceable package Fluid =MediaStructure.Fluids.Gases.IdealGasXY
                                                                       constrainedby
          MediaStructure.Fluids.Interfaces.PartialConstrainingFluid            annotation(choicesAllMatching);
          parameter SI.MassFlowRate mflow0;
          parameter SI.Temperature T0;
          parameter SI.MassFraction[Fluid.nS] X0;
        SI.SpecificEnthalpy h;
        Interfaces.FlowPort flowPort(redeclare package Fluid=Fluid)
          annotation (Placement(transformation(extent={{60,-20},{100,20}}),
              iconTransformation(extent={{60,-20},{100,20}})));

      equation
        h=Fluid.specificEnthalpy(Fluid.setState_pTX(flowPort.p,T0,X0));
        flowPort.m_flow=-mflow0;
        flowPort.mX_flow=-mflow0*(if flowPort.m_flow>=0 then flowPort.X else X0);
        flowPort.H_flow=-mflow0*(if flowPort.m_flow>=0 then flowPort.h else h);
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
      replaceable package Fluid =MediaStructure.Fluids.Gases.IdealGasXY
                                                                       constrainedby
          MediaStructure.Fluids.Interfaces.PartialConstrainingFluid                       annotation(choicesAllMatching);
          parameter SI.Pressure p0;
          parameter SI.Temperature T0;
          parameter SI.MassFraction[Fluid.nS] X0;
        parameter SI.SpecificEnthalpy h0=Fluid.specificEnthalpy(Fluid.setState_pTX(p0,T0,X0));
        Interfaces.FlowPort flowPort(redeclare package Fluid=Fluid)
          annotation (Placement(transformation(extent={{60,-20},{100,20}}),
              iconTransformation(extent={{60,-20},{100,20}})));

      equation
        flowPort.p=p0;
        flowPort.h=h0;
        flowPort.X=X0;
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
      replaceable package Fluid =MediaStructure.Fluids.Gases.IdealGasXY constrainedby
          MediaStructure.Fluids.Interfaces.PartialConstrainingFluid                                                                              annotation(choicesAllMatching);
        Interfaces.FlowPort port_a(redeclare package Fluid=Fluid)
          annotation (Placement(transformation(extent={{-100,-20},{-60,20}})));
        Interfaces.FlowPort port_b(redeclare package Fluid=Fluid)
          annotation (Placement(transformation(extent={{60,-20},{100,20}})));

        Modelica.Blocks.Interfaces.RealInput u annotation (Placement(transformation(
                extent={{-22,44},{18,84}}), iconTransformation(
              extent={{20,-20},{-20,20}},
              rotation=90,
              origin={0,20})));
      equation
        port_a.m_flow+port_b.m_flow=0;
        port_a.H_flow+port_b.H_flow=0;
        port_a.mX_flow+port_b.mX_flow=zeros(Fluid.nS);
        port_a.H_flow=port_a.h*port_a.m_flow;
        port_a.mX_flow=port_a.m_flow*port_a.X;

        port_a.m_flow=(port_a.p-port_b.p)/u;

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
    end Components;

    package Systems
      model HeatedGas
        MediaStructure.Examples.Components.FlowSource flowSource(
          redeclare package Fluid = MediaStructure.Fluids.Gases.IdealGasXY,
          mflow0=1,
          X0={0.2,0.8},
          T0=333.15)
          annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
        MediaStructure.Examples.Components.MultiPortVolume multiPortVolume(
          V=1,
          Y_start={0.2,0.8},
          redeclare package Fluid = MediaStructure.Fluids.Gases.IdealGasXY,
          nP=2,
          T_start=303.15,
          p_start=100000)
          annotation (Placement(transformation(extent={{0,0},{-20,20}})));
        Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow heatSource(Q_flow=0,
            T_ref=303.15)
          annotation (Placement(transformation(extent={{42,-2},{22,18}})));
        Components.LinearResistance linearResistance(redeclare package Fluid =
              MediaStructure.Fluids.Gases.IdealGasXY)
                                                     annotation (Placement(
              transformation(
              extent={{10,-10},{-10,10}},
              rotation=-90,
              origin={-6,36})));
        Components.Reservoir reservoir(
          p0=100000,
          T0=303.15,
          X0={1,0})
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
        Modelica.Blocks.Sources.Ramp ramp(
          offset=1e4,
          height=1e6,
          duration=1,
          startTime=5)
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
                  -100},{100,100}}),      graphics));
      end HeatedGas;
    end Systems;
  end Examples;


  annotation (uses(Modelica(version="3.1")));
end MediaStructure;
