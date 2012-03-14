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

#include "fmi1_enums.h"

const char* fmi1_naming_convention2string(fmi1_variable_naming_convension_enu_t convention) {
    if(convention == fmi1_naming_enu_flat) return "flat";
    if(convention == fmi1_naming_enu_structured) return "structured";
    return "Invalid";
}

const char* fmi1_fmu_kind2string(fmi1_fmu_kind_enu_t kind) {
    switch (kind) {
    case fmi1_fmu_kind_enu_me: return "ModelExchange";
    case fmi1_fmu_kind_enu_cs_standalone: return "CoSimulation_StandAlone";
    case fmi1_fmu_kind_enu_cs_tool: return "CoSimulation_Tool";
    }
    return "Invalid";
}

const char* fmi1_variability_to_string(fmi1_variability_enu_t v) {
    switch(v) {
    case fmi1_variability_enu_constant: return "constant";
    case fmi1_variability_enu_parameter: return "parameter";
    case fmi1_variability_enu_discrete: return "discrete";
    case fmi1_variability_enu_continuous: return "continuous";
    }
    return "Error";
}

const char* fmi1_causality_to_string(fmi1_causality_enu_t c) {
    switch(c) {
    case fmi1_causality_enu_input: return "input";
    case fmi1_causality_enu_output: return "output";
    case fmi1_causality_enu_internal: return "internal";
    case fmi1_causality_enu_none: return "none";
    };
    return "Error";
}
