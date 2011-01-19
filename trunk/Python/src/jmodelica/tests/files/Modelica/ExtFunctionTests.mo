package ExtFunctionTests

model ExtFunctionTest1
 Real a(start=1) = 1;
 Real b(start=2) = 2;
 Real c(start=3);

 algorithm
  c := add(a,b);

end ExtFunctionTest1;

function add
 input Real a;
 input Real b;
 output Real c;

 external "C" annotation(Library="addNumbers1",
                         Include="#include \"addNumbers1.h\"",
                         LibraryDirectory="file:///Library",
                         IncludeDirectory="file:///Include");
end add;

model ExtFunctionTest2
 Real a(start=1) = 1;
 Real b(start=2) = 2;
 Real c(start=3);
 Real d(start=3);
 
 algorithm
   c := add(a,b);
   d := add2(a,b);
   
end ExtFunctionTest2;

function add2
 input Real a;
 input Real b;
 output Real c;
 
 external "C" annotation(Library="addNumbers2",
                         Include="#include \"addNumbers2.h\"",
                         LibraryDirectory="file:///Libs/lib1",
                         IncludeDirectory="file:///Incl/incl1");
end add2;

model ExtFunctionTest3
 Real a(start=10);
   
 equation
   testModelicaMessage();
   der(a) = a;
 
end ExtFunctionTest3;

function testModelicaMessage
    
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");

end testModelicaMessage;

end ExtFunctionTests;
