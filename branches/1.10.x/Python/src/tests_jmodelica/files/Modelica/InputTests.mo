package Inputs

    model SimpleInput
        Real x(start = 0);
        Real y(start = 0);
        input Real u;
    equation
        der(x) = sin(time);
        y = u;
    end SimpleInput;
    
    model SimpleInput2
        Real x(start = 0);
        Real y(start = 0);
        Real z(start = 0);
        input Real u1;
        input Real u2;
    equation
        der(x) = sin(time);
        y = u1;
        z = u2;
    end SimpleInput2;
    
    model InputDiscontinuity
        Real x(start = 0);
        input Real u;
    equation
        x = if u > 0.5 then 1 else 0;
    end InputDiscontinuity;

end Inputs;
