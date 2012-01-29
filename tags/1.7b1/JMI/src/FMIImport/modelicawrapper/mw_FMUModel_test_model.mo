within ;
model mw_FMUModel_test_model
  class FMUModelME1
    extends ExternalObject;

    function constructor
                         //FMUModelME1 Constructor
      output FMUModelME1 obj;
    external"C" obj = mw_FMUModelME1(
            "C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu",
            "MODELNAMEUSED",
            1);
      annotation (Library="modelica_c_fmi_interface", Include="#include <modelica_c_fmi_interface.h>");
    end constructor;

    function destructor
                        //FMUModelME1 Destructor
      input FMUModelME1 obj;
    algorithm
    end destructor;

    function fmiGetModelTypesPlatform
      input FMUModelME1 obj;
      output String str;
    external"C" str = mw_fmiGetModelTypesPlatform(obj);
    annotation (Library="modelica_c_fmi_interface", Include="#include <modelica_c_fmi_interface.h>");
    end fmiGetModelTypesPlatform;

    function fmiGetVersion
      input FMUModelME1 obj;
      output String str;
    external"C" str = mw_fmiGetVersion(obj);
    annotation (Library="modelica_c_fmi_interface", Include="#include <modelica_c_fmi_interface.h>");
    end fmiGetVersion;

    function fmiSetDebugLogging
      input FMUModelME1 obj;
      input Boolean loggingOn;
      output Integer fmiFlag;
    external"C" fmiFlag = mw_fmiSetDebugLogging(obj, loggingOn);
    annotation (Library="modelica_c_fmi_interface", Include="#include <modelica_c_fmi_interface.h>");
    end fmiSetDebugLogging;

  end FMUModelME1;

  parameter FMUModelME1 testobj = FMUModelME1();
  Integer y;
equation
y = testobj.fmiSetDebugLogging(testobj,true);
  annotation (uses(Modelica(version="3.2")));
end mw_FMUModel_test_model;
