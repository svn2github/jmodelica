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
#include <string.h>
#include <stdlib.h>
#include "ModelicaUtilities.h"
#include "jmtables.h"
#include "tblAccess.h"

/* Table list constants*/
#define INITIAL_SIZE 10

/* Table constants*/
/* TableType */
#define TYPE_FROM_ARRAY 1
#define TYPE_FROM_FILE 2
#define TYPE_ACCESS_ARRAY 3
#define TYPE_ACCESS_FILE 4
/* Extrapolation methods */
#define EXTRAPOLATE_HOLD_LAST 1
#define EXTRAPOLATE_LINEAR 2
#define EXTRAPOLATE_PERIODIC 3

/* Global tables struct*/
static jmtables_t tables = {NULL, 0, 0};

static int init_table_array() {
  tables.next_id = 1;
  tables.size = INITIAL_SIZE;
  tables.tblarray = (void**)calloc(INITIAL_SIZE, sizeof(void*));

  if (tables.tblarray == NULL) {
      return -1;
  } else {
      return 0;
  }
}

static int double_array() {
  int i;
  void** old_array = tables.tblarray;
  int pre_size = tables.size;
  tables.size = pre_size * 2;
  tables.tblarray = (void**)calloc(tables.size, sizeof(void*));
  if (tables.tblarray == NULL)
      return -1;
  for (i = 0; i < pre_size; i++) {
      tables.tblarray[i] = old_array[i];
  }
  free(old_array);
  return 0;
}

static int add_table(void* tbl) {
  /* Add the table tbl to array in tables struct and return table ID*/
  int retval;
  int id;

  if (tables.tblarray == NULL) {
      /* Initialize array*/
      retval = init_table_array();
      if (retval != 0) {
          ModelicaError("Failed to add new table. Could not initialize array.");
      }
  }

  if (tables.size == tables.next_id-1) {
      /* Double array*/
      retval = double_array();
      if (retval != 0) {
          ModelicaError("Failed to add new table. Could not increase array.");
      }
  }

  id = tables.next_id;
  tables.tblarray[id-1] = tbl;
  tables.next_id++;
  return id;
}

static int table_init(const char* tableName, const char* fileName,
                      double const* table, int nRow, int nColumn,
                      const int interpolation,
                      const int dim) {
  int type, extrapLow, extrapUp;
  void* tbl;
  int tblsize[2];
  tblsize[0] = nRow;
  tblsize[1] = nColumn;
  extrapLow = EXTRAPOLATE_LINEAR;
  extrapUp = EXTRAPOLATE_LINEAR;

  if (strcmp(fileName, "NoName") == 0 || strcmp(fileName, "") == 0)
    type = TYPE_FROM_ARRAY;
  else
    type = TYPE_FROM_FILE;

  tbl = ModelonTableCreate(dim,
                           interpolation,
                           extrapLow,
                           extrapUp,
                           type,
                           tableName,
                           fileName,
                           table,
                           tblsize);
  return add_table(tbl);
}

int jmtables_1D_init(const  char*  tableName,
                     const  char*  fileName,
                     double const* table, int nRow, int nColumn,
                     int smoothness) {
  return table_init(tableName, fileName, table, nRow, nColumn, smoothness, 1);
}

void jmtables_1D_close(int tableID) {
  ModelonTableClose(tables.tblarray[tableID-1]);
}

double jmtables_1D_interpolate(int tableID, int icol, double u) {
  return ModelonTableInterp1(tables.tblarray[tableID-1], icol, u);
}

int jmtables_2D_init(const char*   tableName,
                     const char*   fileName,
                     double const* table, int nRow, int nColumn,
                     int smoothness) {
  return table_init(tableName, fileName, table, nRow, nColumn, smoothness, 2);
}

void jmtables_2D_close(int tableID) {
  ModelonTableClose(tables.tblarray[tableID-1]);
}

double jmtables_2D_interpolate(int tableID, double u1, double u2) {
  return ModelonTableInterp2(tables.tblarray[tableID-1], u1, u2);
}

int jmtables_timetable_init(const char*   tableName,
                  const char*   fileName,
                  double const* table, int nRow, int nColumn,
                  double        startTime,
                  int           smoothness,
                  int           extrapolation) {
  ModelicaError("CombiTimeTables are not supported.");
  return 0;
}

void jmtables_timetable_close(int tableID) {
  ;
}

double jmtables_timetable_minimumTime(int tableID) {
  return 0;
}

double jmtables_timetable_maximumTime(int tableID) {
  return 0;
}

double jmtables_timetable_interpolate(int tableID, int icol, double u) {
  return 0;
}
