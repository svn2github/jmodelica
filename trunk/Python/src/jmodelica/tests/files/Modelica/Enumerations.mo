package Enumerations

model Enumeration1
    type enum = enumeration(one, two);
    Real x = if y == enum.one then 7 else 9;
    parameter enum y = enum.one;

end Enumeration1;

end Enumerations;
