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


#include <stdlib.h>
#include <jm_types.h>
#include "minizip.h"

jm_status_enu_t fmi_zip_zip(const char* zip_file_path, int n_files_to_zip, const char** files_to_zip)
{
	/*
	Usage : minizip [-o] [-a] [-0 to -9] [-p password] [-j] file.zip [files_to_add]

	-o  Overwrite existing file.zip
	-a  Append to existing file.zip
	-0  Store only
	-1  Compress faster
	-9  Compress better

	-j  exclude path. store only the file name.
	*/
#define N_BASIC_ARGS 5
	int argc;
	const char** argv;
	int k;

	argc = N_BASIC_ARGS + n_files_to_zip;
	argv = calloc(sizeof(char*), argc);	

	argv[0]="minizip";
	argv[1]="-o";
	argv[2]="-1";
	argv[3]="-j";
	argv[4]=zip_file_path;

	for (k = 0; k < n_files_to_zip; k++) {
		argv[N_BASIC_ARGS + k] = files_to_zip[k];
	}

	if (minizip(argc, (char**)argv) == 0) {
		return jm_status_success;
	} else {
		return jm_status_error;	
	}
}