model DependentParameterTest
  parameter Real p1 = 1;
  parameter Real p2 = p1*3;
  parameter Real p3 = p2 + p4;
  parameter Real p4 = 5;
end DependentParameterTest;