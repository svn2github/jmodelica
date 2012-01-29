#include "c_fmi_unzip.h"
#include "miniunz.h"
#include "windows.h"

/* Returns 1 if the FMU was successfully unziped. Otherwise 0 is returned */
int unzipFMU(char* zipFilePath, char* outputFolder)
{
    int argc = 5;
	char *argv[5] = {"miniunz","-o",zipFilePath, "-d", outputFolder};

	return miniunz(argc, argv) ? 0 : 1;  
	/* This is the renamed main function of miniunz 
	miniunz can be called like like this according to minunz.c:
		printf("Usage : miniunz [-e] [-x] [-v] [-l] [-o] [-p password] file.zip [file_to_extr.] [-d extractdir]\n\n" \
		"  -e  Extract without pathname (junk paths)\n" \
		"  -x  Extract with pathname\n" \
		"  -v  list files\n" \
		"  -l  list files\n" \
		"  -d  directory to extract into\n" \
		"  -o  overwrite files without prompting\n" \
		"  -p  extract crypted file using password\n\n");
	*/
}