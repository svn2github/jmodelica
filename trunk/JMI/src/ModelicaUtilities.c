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
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ModelicaUtilities.h"


void ModelicaMessage(const char* string) 
{
    printf("%s", string);
}

void ModelicaFormatMessage(const char* string,...) 
{
    va_list arg_ptr;
    va_start(arg_ptr, string);
    vprintf(string, arg_ptr);
    va_end(arg_ptr);
}

void ModelicaVFormatMessage(const char* string, va_list arg_ptr) 
{
    vprintf(string, arg_ptr);
}

void ModelicaError(const char* string)
{
    fprintf(stderr, "%s", string);
}

void ModelicaFormatError(const char* string,...)
{
    va_list arg_ptr;
    va_start(arg_ptr, string);
    vfprintf(stderr, string, arg_ptr);
    va_end(arg_ptr);
}

void ModelicaVFormatError(const char* string, va_list arg_ptr)
{
    vfprintf(stderr, string, arg_ptr);
}

char* ModelicaAllocateString(size_t len) 
{
    char* c = ModelicaAllocateStringWithErrorReturn(len);
    if (c == NULL) {
        ModelicaFormatError("Could not allocate memory for string with length %d.", len);
    }
    return c;

}

char* ModelicaAllocateStringWithErrorReturn(size_t len) 
{
    return (char*) calloc(len + 1, sizeof(char));
}

