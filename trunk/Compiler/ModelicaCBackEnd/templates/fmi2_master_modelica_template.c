/*
    Copyright (C) 2013 Modelon AB

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

#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_log.h"
#include "ModelicaUtilities.h"
#include "ModelicaStandardTables.h"

#include "fmi2_me.h"
#include "fmi2_cs.h"
#include "fmiFunctions.h"
#include "fmiFunctionTypes.h"
#include "fmiTypesPlatform.h"

$INCLUDE: fmi_code_gen_template.c$

void _emit(log_t *log, char* message) { }
void create_log_file_if_needed(log_t *log) { }
BOOL emitted_category(log_t *log, category_t category) { 0; }

$INCLUDE: fmi2_functions_common_template.c$

#ifdef FMUME20
$INCLUDE: fmi2_functions_me_template.c$
#endif

#ifdef FMUCS20
$INCLUDE: fmi2_functions_cs_template.c$
#endif
