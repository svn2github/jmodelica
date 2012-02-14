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

#ifndef JM_TYPES_H
#define JM_TYPES_H

typedef const char* jm_string;

typedef void* jm_voidp;

typedef struct jm_name_ID_map_t {
    jm_string name;
    unsigned int ID;
} jm_name_ID_map_t;

typedef enum {
	STATUS_SUCCESS,
	STATUS_ERROR
} jm_status_enu_t;

/* JM_TYPES_H */
#endif
