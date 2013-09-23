model simpleModelWithFunctions
    Real a1(start=0.1, fixed=true);
    Real a2(start=0.4, fixed=true);
    Real b1(start=-1.0);
    Real b2(start=1.0);
    function f
        input Real in1;
        input Real in2;
        output Real out1;
        output Real out2;
        Real internal;
    algorithm
        (out1, out2) := f2(in1,in2);
        internal := out1;
        out2 := out2-internal;
        out1 := out1*2.0;
        (out1, out2) := f2(in1,in2);
    end f;
    function f2
        input Real in1;
        input Real in2;
        output Real out1;
        output Real out2;
    algorithm
        out1 := in1*0.5;
        out2 := in2+out1;
    end f2;
equation
    der(a1) = -3.14*a1-0.1-b2;
    der(a2) = -2.7*a2-0.3;
    (b1, b2) = f(a1,a2);
end simpleModelWithFunctions;


model unknownSizeInRecord
record A 
	Real[:] unKnown;
end A;

A a(unKnown={2, time*2});
A b(unKnown={2, time*2,10});
Real c;
equation
a = A(unKnown={time, time*2});
b = A(unKnown={time, time*2,2});
der(c) = a.unKnown[1] + b.unKnown[2];
end unknownSizeInRecord;
