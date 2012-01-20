#include <stdio.h>
#include <windows.h>
#include <c_fmi_interface_me_1_0.h>

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
	FMU* fmu;
	callBackFunctions.logger = mylogger;
	callBackFunctions.allocateMemory = calloc;
	callBackFunctions.freeMemory = free;


	fmu = FMUModelME1("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu", "hejFMU", fmiTrue, callBackFunctions);
	//main(0,NULL);


	//FMU* fmu;//= fmiInstantiateModel("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu", "hej", fmiTrue);	
	//fmu = FMUModelME1("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu");

	//fmu->fmiInstantiateModel()
	printf("hej! %s\n",fmiGetVersion(fmu));
	if (fmiInstantiateModel(fmu))
		printf("fmiInstantiate==OK!\n");
	else
		printf("fmiInstantiate==FAILed!\n");

	//if (fmiInstantiateSlave(fmu))
	//	printf("fmiInstantiateSlave==OK!\n");
	//else
	//	printf("fmiInstantiateSlave==FAILed!\n");

	//unzipFMU("C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\Furuta.fmu","C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\temporaryfolder\\");

	//if (fmiInitialize(fmu, fmiTrue, 0.1, &))
	FMUModelME1Destroy(fmu);	
	system("PAUSE");
}


