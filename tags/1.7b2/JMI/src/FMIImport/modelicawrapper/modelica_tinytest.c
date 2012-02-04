#include <stdio.h>
#include "modelica_c_fmi_interface.h"

#ifdef __cplusplus
extern "C" {
#endif

	void mylogger(fmiComponent c, fmiString instanceName, fmiStatus status, fmiString category, fmiString message, ...)
	{
		char msg[2024];
		va_list argp;	
		va_start(argp, message);
		vsprintf(msg, message, argp);
		if (!instanceName) instanceName = "?";
		if (!category) category = "?";
		printf("fmiStatus = %d;  %s (%s): %s\n", status, instanceName, category, msg);
	}

int main(int argc, char *argv[])
{
	fmiCallbackFunctions callBackFunctions;
	void* fmu;
	int k;
	callBackFunctions.logger = mylogger;
	callBackFunctions.allocateMemory = calloc;
	callBackFunctions.freeMemory = free;


	fmu = mw_FMUModelME1("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu", "hejFMU", fmiTrue);
	//main(0,NULL);


	//FMU* fmu;//= fmiInstantiateModel("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu", "hej", fmiTrue);	
	//fmu = FMUModelME1("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu");

	//fmu->fmiInstantiateModel()
	printf("hej! %s\n", mw_fmiGetVersion(fmu));


	//mw_fmiInstantiateModel(fmu);

	if (mw_fmiSetDebugLogging(fmu, 1) == fmiOK)
		printf("mw_fmiSetDebugLogging==OK!\n");
	else
		printf("mw_fmiSetDebugLogging==FAILed!\n");

	for (k=0;k<10;k++) {
			if (mw_fmiSetDebugLogging(fmu, 1) == fmiOK)
		printf("mw_fmiSetDebugLogging==OK!\n");
	else
		printf("mw_fmiSetDebugLogging==FAILed!\n");
	}


	//if (fmiInstantiateSlave(fmu))
	//	printf("fmiInstantiateSlave==OK!\n");
	//else
	//	printf("fmiInstantiateSlave==FAILed!\n");

	//unzipFMU("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu","C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\temporaryfolder\\");
	
	//if (fmiInitialize(fmu, fmiTrue, 0.1, &))

	FMUModelME1Destroy(fmu);	
	system("PAUSE");
}

#ifdef __cplusplus
}
#endif
