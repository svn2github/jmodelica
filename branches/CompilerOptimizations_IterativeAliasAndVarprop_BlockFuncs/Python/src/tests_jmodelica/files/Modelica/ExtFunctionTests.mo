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

 external "C" annotation(Library="addNumbers",
                         Include="#include \"addNumbers.h\"");
end add;

//model ExtFunctionTest2
// Real a(start=1) = 1;
// Real b(start=2) = 2;
// Real c(start=3);
// Real d(start=3);
// 
// algorithm
//   c := add(a,b);
//   d := add2(a,b);
//   
//end ExtFunctionTest2;
//
//function add2
// input Real a;
// input Real b;
// output Real c;
// 
// external "C" annotation(Library="addNumbers",
//                         Include="#include \"addNumbers.h\"");
//end add2;

model ExtFunctionTest3
 Real a(start=10);
   
 equation
   testModelicaMessages();
   testModelicaErrorMessages();
   testModelicaAllocateStrings();
   der(a) = a;
 
end ExtFunctionTest3;

function testModelicaMessages
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");
end testModelicaMessages;

function testModelicaErrorMessages
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");
end testModelicaErrorMessages;

function testModelicaAllocateStrings
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");
end testModelicaAllocateStrings;

model ExtFunctionTest4
	Integer[3] myArray = {1,2,3};
	Integer[3] myResult = doubleArray(myArray);
	
end ExtFunctionTest4;

function doubleArray
	input Integer[3] arr;
	output Integer[3] res;

    external "C" multiplyAnArray(arr, res, 3, 2) annotation(Include="#include \"addNumbers.h\"", Library="addNumbers");
end doubleArray;

class FileOnDelete
	extends ExternalObject;
    
    function constructor
        input String name;
        output FileOnDelete out;
        external "C" out = constructor_string(name) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end constructor;
    
    function destructor
        input FileOnDelete obj;
        external "C" destructor_string_create_file(obj) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end destructor;	
end FileOnDelete;

function use_FOD
	input FileOnDelete obj;
	output Real x;
    external "C" x = constant_extobj_func(obj) 
        annotation(Library="extObjects", Include="#include \"extObjects.h\"");
end use_FOD;

model ExternalObjectTests1
	FileOnDelete obj = FileOnDelete("test_ext_object.marker");
	Real x = use_FOD(obj);
end ExternalObjectTests1;

model ExternalObjectTests2
    FileOnDelete myEOs[2] = { FileOnDelete("test_ext_object_array1.marker"), FileOnDelete("test_ext_object_array2.marker")};
    Real z;

 function get_y
    input FileOnDelete eos[:];
    output Real y;
 algorithm
    y := use_FOD(eos[1]);
 end get_y;
 
equation
    z = get_y(myEOs);  
end ExternalObjectTests2;

end ExtFunctionTests;
