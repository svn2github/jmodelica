/*
    Copyright (C) 2016 Modelon AB

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

#include "jmi_types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void jmi_set_str(char **dest, const char* src) {
    size_t len = JMI_MIN(JMI_LEN(src), JMI_STR_MAX) + 1;
    *dest = calloc(len, sizeof(char));
    strncpy(*dest, src, len);
    (*dest)[len-1] = '\0';
}
