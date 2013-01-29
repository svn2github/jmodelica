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
#ifndef JMTABLES_H
#define JMTABLES_H

typedef struct jmtables {
  void** tblarray;
  int    next_id;
  int    size;
} jmtables_t;

int jmtables_1D_init(const  char*  tableName,
                     const  char*  fileName,
                     double const* table, int nRow, int nColumn,
                     int           smoothness);

void jmtables_1D_close(int tableID);

double jmtables_1D_interpolate(int tableID, int icol, double u);

int jmtables_2D_init(const char*   tableName,
                     const char*   fileName,
                     double const* table, int nRow, int nColumn,
                     int           smoothness);

void jmtables_2D_close(int tableID);

double jmtables_2D_interpolate(int tableID, double u1, double u2);

int jmtables_timetable_init(const char*   tableName,
                            const char*   fileName,
                            double const* table, int nRow, int nColumn,
                            double        startTime,
                            int           smoothness,
                            int           extrapolation);

void jmtables_timetable_close(int tableID);

double jmtables_timetable_minimumTime(int tableID);

double jmtables_timetable_maximumTime(int tableID);

double jmtables_timetable_interpolate(int tableID, int icol, double u);

#endif /* JMTABLES */
