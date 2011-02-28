/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "jmi_array_none.h"

void jmi_transpose_matrix(jmi_array_t* arr, jmi_ad_var_t* src, jmi_ad_var_t* dest) {
	int i, j, tmp1, tmp2, k, n, dim;

	n = arr->num_elems;
	dim = sizeof(arr->size);

	for (i = 0; i < arr->n; i++) {
		j = 0;
		tmp1 = i;
		tmp2 = 0;

		for (k = 0; k < dim; k++) {
			tmp2 = tmp1%(arr->size[k]);
			tmp1 /= (arr->size[k]);
			j *= (arr->size[k]);
			j += tmp2;
		}

		dest[i] = src[j];
	}
}
