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


#include "minizip/miniunz.h"
#include "jm_types.h"

/* Returns 1 if the FMU was successfully unziped. Otherwise 0 is returned */
jm_status_enu_t fmi_zip_unzip(const char* zip_file_path, const char* output_folder)
{
    int argc = 5;
	const char *argv[5] = {"miniunz", "-o", zip_file_path, "-d", output_folder};

	if (miniunz(argc, argv) == 0) {
		return jm_status_success;
	} else {
		return jm_status_error;	
	}
}
