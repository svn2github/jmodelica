/*
    Copyright (C) 2012 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <jm_types.h>
#include "fmi_zip_zip.h"

#define PRINT_MY_DEBUG printf("Line: %d \t File: %s \n",__LINE__, __FILE__)

void do_exit(int code)
{
	printf("Press any key to exit\n");
	getchar();
	exit(code);
}

int main(int argc, char *argv[])
{
	jm_status_enu_t status;

	const char* files_to_zip[] = {"C:\\Documents and Settings\\p418_baa\\Desktop\\Capi\\modelDescription.xml"};
	int n_files_to_zip = 1;

	status = fmi_zip_zip("C:\\Documents and Settings\\p418_baa\\Desktop\\Capi\\Furuta.ziptest", n_files_to_zip, files_to_zip);

	if (status == jm_status_error) {
		printf("Failed to unzip the file\n");
	}
	do_exit(1);
}


