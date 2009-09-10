optimization CSTR2_Opt(startTime=0,finalTime=10,objective=cost(finalTime))

  extends CSTRLib.Examples.CSTRs_Opt(u1(min=0.1,max=3,start=1),u2(min=0.1,max=3,start=1));

  Real cost(start=0);

  parameter Real CA1_ref = 0.03;
  parameter Real CA2_ref = 0.001;
  parameter Real u1_ref = 1;
  parameter Real u2_ref = 1;
  parameter Real alpha = 1e5;
  parameter Real beta = 1e2;

equation
  
  der(cost) = alpha*(CA1_ref - two_CSTRs_Series.CA1)^2 + 
alpha*(CA2_ref - two_CSTRs_Series.CA2)^2 +beta*(u1_ref-u1)^2 + beta*(u2_ref-u2)^2;

end CSTR2_Opt;