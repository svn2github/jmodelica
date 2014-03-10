package ExtFunctionTests

model ExtFunctionTest1
 Real a(start=1) = 1;
 Real b(start=2) = 2;
 Real c(start=2);

equation
  c = add(a,b);

end ExtFunctionTest1;

function add
 input Real a;
 input Real b;
 output Real c;

 external "C" annotation(Library="addNumbers",
                         Include="#include \"addNumbers.h\"");
end add;

model ExtFunctionTest2
	
function extFunc1
	input Real m;
	input Real[:,:,:] a;
	input Integer[size(a,1),size(a,2),size(a,3)] b;
	input Boolean[size(a,1),size(a,2)] c;
	output Real sum;
	output Real[size(a,1),size(a,2),size(a,3)] o;
	output Real[size(a,1)*size(a,2)*size(a,3)] step;
	external "C" annotation(
		Library="arrayFunctions",
		Include="#include \"arrayFunctions.h\"");
end extFunc1;

Real[3,3,3] x;
Real s;
Real[27] step;

constant Real arg1 = 3.14;
constant Real[3,3,3] arg2 = {{{1e1,1e2,1e3},{1e4,1e5,1e6},{1e7,1e8,1e9}},{{1,1,1},{1,1,1},{1,1,1}},{{1e-1,1e-2,1e-3},{1e-4,1e-5,1e-6},{1e-7,1e-8,1e-9}}};
constant Integer[3,3,3] arg3 = {{{1,2,3},{4,5,6},{7,8,9}},{{11,12,13},{14,15,16},{17,18,19}},{{21,22,23},{24,25,26},{27,28,29}}};
constant Boolean[3,3] arg4 = {{true,true,true},{true, false, true},{false,true,false}};
equation
	(s,x,step) = extFunc1(arg1, arg2, arg3, arg4);

end ExtFunctionTest2;

model ExtFunctionBool
	
function copyBoolArray
	input Boolean[:] a;
	output Boolean[size(a,1)] b;
	external "C" annotation(
		Library="arrayFunctions",
		Include="#include \"arrayFunctions.h\"");
end copyBoolArray;

constant Boolean[8] arg = {true,true,true,false,true,false,false,true};
Boolean[8] res;
equation
	res = copyBoolArray(arg);
end ExtFunctionBool;

model ExtFunctionTest3
 Real a(start=10);
 Real b;
   
 equation
   b = testModelicaMessages(5);
   testModelicaErrorMessages();
   testModelicaAllocateStrings();
   der(a) = a;
 
end ExtFunctionTest3;

function testModelicaMessages
input Real a;
output Real b;
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

model ExternalInfinityTest
function whileTrue
	input Real a;
	output Real b;
	external "C" annotation(
		Library="arrayFunctions",
		Include="#include \"arrayFunctions.h\"");
end whileTrue;
	Real x;
equation
	x = whileTrue(1);
end ExternalInfinityTest;

package CEval
  package C
    model RealTest
      function fRealScalar
        input  Real x_in;
        output Real x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fRealScalar;
      
      function fRealArray
        input  Real[2] x_in;
        output Real[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fRealArray;
      
      function fRealArrayUnknown
        input  Real[:] x_in;
        output Real[size(x_in,1)] x_out;
      external "C" fRealArray(x_in, x_out) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fRealArrayUnknown;

      constant Real    xScalar        = fRealScalar(3);
      constant Real[2] xArray         = fRealArray({4,5});
      constant Real[2] xArrayUnknown  = fRealArrayUnknown({6,7});
    end RealTest;
    
    model IntegerTest
      function fIntegerScalar
        input  Integer x_in;
        output Integer x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fIntegerScalar;
      
      function fIntegerArray
        input  Integer[2] x_in;
        output Integer[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fIntegerArray;
      
      function fIntegerArrayUnknown
        input  Integer[:] x_in;
        output Integer[size(x_in,1)] x_out;
      external "C" fIntegerArray(x_in, x_out) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fIntegerArrayUnknown;

      constant Integer    xScalar        = fIntegerScalar(3);
      constant Integer[2] xArray         = fIntegerArray({4,5});
      constant Integer[2] xArrayUnknown  = fIntegerArrayUnknown({6,7});
    end IntegerTest;
    
    model BooleanTest
      function fBooleanScalar
        input  Boolean x_in;
        output Boolean x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fBooleanScalar;
      
      function fBooleanArray
        input  Boolean[2] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fBooleanArray;
      
      function fBooleanArrayUnknown
        input  Boolean[:] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "C" fBooleanArray(x_in, x_out) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fBooleanArrayUnknown;

      constant Boolean    xScalar        = fBooleanScalar(true);
      constant Boolean[2] xArray         = fBooleanArray({false,false});
      constant Boolean[2] xArrayUnknown  = fBooleanArrayUnknown({false,true});
    end BooleanTest;
    
    model StringTest
      function fStringScalar
        input  String x_in;
        output String x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringScalar;
      
      function fStringArray
        input  String[2] x_in;
        output String[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringArray;
      
      function fStringArrayUnknown
        input  String[:] x_in;
        output String[size(x_in,1)] x_out;
      external "C" fStringArray(x_in, x_out) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringArrayUnknown;

      constant String    xScalar        = fStringScalar("abcde");
      constant String[2] xArray         = fStringArray({"abc","def"});
      constant String[2] xArrayUnknown  = fStringArrayUnknown({"abc","def"});
    end StringTest;
    
    model EnumTest
      type E = enumeration(E1,E2);
      function fEnumScalar
        input  E x_in;
        output E x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fEnumScalar;
      
      function fEnumArray
        input  E[2] x_in;
        output E[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fEnumArray;
    
      function fEnumArrayUnknown
        input  E[:] x_in;
        output E[size(x_in,1)] x_out;
      external "C" fEnumArray(x_in, x_out) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fEnumArrayUnknown;
      
      constant E    xScalar        = fEnumScalar(E.E1);
      constant E[2] xArray         = fEnumArray({E.E2,E.E1});
      constant E[2] xArrayUnknown  = fEnumArrayUnknown({E.E1,E.E2});
    end EnumTest;
  end C;
  
  package Fortran
    model RealTest
      function frealscalar
        input  Real x_in;
        output Real x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end frealscalar;
      
      function frealarray
        input  Real[2] x_in;
        output Real[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end frealarray;
    
      function frealarrayunknown
        input  Real[:] x_in;
        output Real[size(x_in,1)] x_out;
      external "FORTRAN 77" frealarray(x_in, x_out) annotation(
        Library="externalFunctionsFortran");
      end frealarrayunknown;
      
      constant Real    xScalar        = frealscalar(3);
      constant Real[2] xArray         = frealarray({4,5});
      constant Real[2] xArrayUnknown  = frealarrayunknown({6,7});
    end RealTest;
    
    model IntegerTest
      function fintegerscalar
        input  Integer x_in;
        output Integer x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fintegerscalar;
      
      function fintegerarray
        input  Integer[2] x_in;
        output Integer[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fintegerarray;
    
      function fintegerarrayunknown
        input  Integer[:] x_in;
        output Integer[size(x_in,1)] x_out;
      external "FORTRAN 77" fintegerarray(x_in, x_out) annotation(
        Library="externalFunctionsFortran");
      end fintegerarrayunknown;
      
      constant Integer    xScalar        = fintegerscalar(3);
      constant Integer[2] xArray         = fintegerarray({4,5});
      constant Integer[2] xArrayUnknown  = fintegerarrayunknown({6,7});
    end IntegerTest;
    
    model BooleanTest
      function fbooleanscalar
        input  Boolean x_in;
        output Boolean x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fbooleanscalar;
      
      function fbooleanarray
        input  Boolean[2] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fbooleanarray;
    
      function fbooleanarrayunknown
        input  Boolean[:] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "FORTRAN 77" fbooleanarray(x_in, x_out) annotation(
        Library="externalFunctionsFortran");
      end fbooleanarrayunknown;
      
      constant Boolean    xScalar        = fbooleanscalar(true);
      constant Boolean[2] xArray         = fbooleanarray({false,false});
      constant Boolean[2] xArrayUnknown  = fbooleanarrayunknown({false,true});
    end BooleanTest;

    model EnumTest
      type E = enumeration(E1,E2);
      function fenumscalar
        input  E x_in;
        output E x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fenumscalar;
      
      function fenumarray
        input  E[2] x_in;
        output E[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fenumarray;
    
      function fenumarrayunknown
        input  E[:] x_in;
        output E[size(x_in,1)] x_out;
      external "FORTRAN 77" fenumarray(x_in, x_out) annotation(
        Library="externalFunctionsFortran");
      end fenumarrayunknown;
      
      constant E    xScalar        = fenumscalar(E.E1);
      constant E[2] xArray         = fenumarray({E.E2,E.E1});
      constant E[2] xArrayUnknown  = fenumarrayunknown({E.E1,E.E2});
    end EnumTest;
  end Fortran;
end CEval;

end ExtFunctionTests;
