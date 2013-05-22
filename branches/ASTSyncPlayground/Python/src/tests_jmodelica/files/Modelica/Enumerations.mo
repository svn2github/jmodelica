package Enumerations

model Enumeration1
    type enum = enumeration(one, two);
    Real x = noEvent(if y == enum.one then 7 else if y == enum.two then 9 else time);
    parameter enum y = enum.one;

end Enumeration1;

end Enumerations;
