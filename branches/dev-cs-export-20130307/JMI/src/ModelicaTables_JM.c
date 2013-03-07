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
#include "ModelicaTables.h"
#include "jmtables.h"

int ModelicaTables_CombiTable1D_init(
                  const  char*  tableName,
                  const  char*  fileName,
                  double const* table, int nRow, int nColumn,
                  int smoothness) {
  return jmtables_1D_init(tableName,
                          fileName,
                          table, nRow, nColumn,
                          smoothness);
}

void ModelicaTables_CombiTable1D_close(int tableID) {
  jmtables_1D_close(tableID);
}

double ModelicaTables_CombiTable1D_interpolate(int tableID, int icol, double u) {
  return jmtables_1D_interpolate(tableID, icol, u);
}

int ModelicaTables_CombiTable2D_init(
                   const char*   tableName,
                   const char*   fileName,
                   double const* table, int nRow, int nColumn,
                   int smoothness) {
  return jmtables_2D_init(tableName,
                          fileName,
                          table, nRow, nColumn,
                          smoothness);
}

void ModelicaTables_CombiTable2D_close(int tableID) {
  jmtables_2D_close(tableID);
}

double ModelicaTables_CombiTable2D_interpolate(int tableID, double u1, double u2) {
  jmtables_2D_interpolate(tableID, u1, u2);
}

int ModelicaTables_CombiTimeTable_init(
                      const char*   tableName,
                      const char*   fileName,
                      double const* table, int nRow, int nColumn,
                      double        startTime,
                      int           smoothness,
                      int           extrapolation) {
  return jmtables_timetable_init(tableName,
                                 fileName,
                                 table, nRow, nColumn,
                                 startTime,
                                 smoothness,
                                 extrapolation);
}

void ModelicaTables_CombiTimeTable_close(int tableID) {
  jmtables_timetable_close(tableID);
}

double ModelicaTables_CombiTimeTable_minimumTime(int tableID) {
  return jmtables_timetable_minimumTime(tableID);
}

double ModelicaTables_CombiTimeTable_maximumTime(int tableID) {
  return jmtables_timetable_maximumTime(tableID);
}

double ModelicaTables_CombiTimeTable_interpolate(int tableID, int icol, double u) {
  return jmtables_timetable_interpolate(tableID, icol, u);
}
