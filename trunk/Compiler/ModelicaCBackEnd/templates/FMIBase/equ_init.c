/*
    Copyright (C) 2015 Modelon AB

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

$C_enum_strings$

$C_dae_init_blocks_residual_functions$

$CAD_dae_init_blocks_residual_functions$

void model_init_add_blocks(jmi_t** jmi) {
$C_dae_init_add_blocks_residual_functions$

$CAD_dae_init_add_blocks_residual_functions$
}

int model_ode_initialize(jmi_t* jmi) {
    int ef = 0;
$C_ode_initialization$
    return ef;
}

int model_init_R0(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_initial_event_indicator_residuals$
    return 0;
}
