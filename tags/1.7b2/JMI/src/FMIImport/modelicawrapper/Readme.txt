Build_modelica.bat builds the modelica_c_fmi_interface.lib. The lib is placed with all header files in the results folder. modelica_c_fmi_interface.lib depends on the c_fmi_interface.lib that must already be built.

A tiny test example is also generated to test the interface.

To build and simulate the mw_FMUModel_test_model.mo in Dymola, the build.bat must be replaced with the one in this folder.  This build.bat moves the included windows.h up to the top in some build file... otherwise this causes some strange errors in the winnt.h.