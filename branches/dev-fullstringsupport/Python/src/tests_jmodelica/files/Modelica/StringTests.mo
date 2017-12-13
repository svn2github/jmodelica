package StringTests 

model TestStringParameterEval1
    constant String ci = "string1";
    constant String cd = ci;
    parameter String ps = "string2";
    parameter String pe = ps annotation(Evaluate=true);
    final parameter String pf = "string3";
    parameter String pi = "string4";
    parameter String pd = pi;
end TestStringParameterEval1;

model TestStringParameterScalar1
    parameter String pi = "string";
    parameter String pd = pi + "1";
end TestStringParameterScalar1;

model TestStringParameterArray1
    parameter String[:] pi = {"str1", "str2"};
    parameter String[:] pd = pi + pi;
end TestStringParameterArray1;

model TestString1
    parameter String s0 = "";
    parameter Real t(fixed=false);
    parameter String s1 = String(t);
    parameter String s2 = s1 + s1;
initial equation
    t = time + 0.5;
end TestString1;

model TestString2
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    s2 = s1 + s1;
end TestString2;

end StringTests;
