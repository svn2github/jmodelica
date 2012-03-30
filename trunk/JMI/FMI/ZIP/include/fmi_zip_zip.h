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


#ifndef FMI_ZIP_ZIP_H_
#define FMI_ZIP_ZIP_H_

#ifdef __cplusplus 
extern "C" {
#endif

#include <jm_types.h>

/**
 * \brief Compress files to the zip format
 * 
 * @param zip_file_path Full file path to the final compressed file. The folders must exist.
 * @param n_files_to_zip Number of files to compress
 * @param files_to_zip List of the full file names to compress
 * @return Error status.
 */
jm_status_enu_t fmi_zip_zip(const char* zip_file_path, int n_files_to_zip, const char** files_to_zip);

#ifdef __cplusplus 
}
#endif

#endif /* End of header file FMI_ZIP_ZIP_H_ */

