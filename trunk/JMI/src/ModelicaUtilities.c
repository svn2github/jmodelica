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
#include "ModelicaUtilities.h"


void ModelicaMessage(const char* string) 
{
    printf("*** ModelicaMessage: %s ***\n", string);
}

void ModelicaFormatMessage(const char* string,...) 
{
    printf("*** ModelicaFormatMessage ***\n");
}

void ModelicaVFormatMessage(const char* string, va_list arg_ptr) 
{
    printf("*** ModelicaVFormatMessage ***\n");
}

void ModelicaError(const char* string)
{
    printf("*** ModelicaError ***\n");
}

void ModelicaFormatError(const char* string,...)
{
    printf("*** ModelicaFormatError ***\n");
}

void ModelicaVFormatError(const char* string, va_list arg_ptr)
{
    printf("*** ModelicaVFormatError ***\n");
}

char* ModelicaAllocateString(size_t len) 
{
    char* retval = (char*) malloc(len * sizeof(char) );
    printf("*** ModelicaAllocateString ***\n");
    
    return retval;
}

char* ModelicaAllocateStringWithErrorReturn(size_t len) 
{
    char* retval = (char*) malloc(len * sizeof(char) );
    printf("*** ModelicaAllocateStringWithErrorReturn ***\n");

    return retval;
}

