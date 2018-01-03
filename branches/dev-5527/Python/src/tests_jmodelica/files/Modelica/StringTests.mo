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

end StringTests;
