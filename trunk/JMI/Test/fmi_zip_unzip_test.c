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
#include <stdarg.h>
#include <string.h>
#include <errno.h>

#include <jm_types.h>
#include "fmi_zip_unzip.h"

#include "config.h"

void do_exit(int code)
{
	printf("Press any key to exit\n");
	getchar();
	exit(code);
}

/**
 * \brief Unzip test. Tests the fmi_zip_unzip function by uncompressing some file.
 *
 */
int main(int argc, char *argv[])
{
	jm_status_enu_t status;	

	status = fmi_zip_unzip(UNCOMPRESSED_DUMMY_FILE_PATH_SRC, UNCOMPRESSED_DUMMY_FOLDER_PATH_DIST);

	if (status == jm_status_error) {
		printf("Failed to uncompress the file\n");
	} else {
		printf("Succesfully uncompressed the file\n");
	}

	do_exit(1);
}


