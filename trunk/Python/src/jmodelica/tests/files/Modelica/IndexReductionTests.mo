package IndexReductionTests

  model Mechanical1
     extends Modelica.Mechanics.Rotational.Examples.First(freqHz=5,amplitude=10,
    damper(phi_rel(stateSelect=StateSelect.always),w_rel(stateSelect=StateSelect.always)));
  end Mechanical1;

end IndexReductionTests;