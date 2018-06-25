/*
    Copyright (C) 2009 Modelon AB

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


package OptimicaCADCodeGenTests


model SparseJacTest1
 parameter Real p1=2;
 parameter Integer p2 = 1;
 parameter Boolean p3 = false;
 parameter Real p4[3] = {1,4,6};
 parameter Real p5[3](each free=true) = {3,4,5};
 parameter Real p6 = 4;
 parameter Real p7[3](each free=true) = {3,4,5};
 Real x[3]; 
 Real x2[2];
 Real y[3];
 Real y2;
 input Real u[3];
 input Real u2[2];
equation
 der(x2) = -x2;
 der(x) = x + y + u + p7;
 y = {1,2,3} + p5;
 y2 = sum(u2);

	annotation(__JModelica(UnitTesting(tests={
		CADCodeGenTestCase(
			name="SparseJacTest1",
			description="Test that sparsity information is generated correctly",
			generate_dae_jacobian=true,
			variability_propagation=false,
			template="
$C_DAE_equation_sparsity$
",
         generatedCode="
static const int CAD_dae_real_p_opt_n_nz = 6;
static const int CAD_dae_real_dx_n_nz = 5;
static const int CAD_dae_real_x_n_nz = 5;
static const int CAD_dae_real_u_n_nz = 5;
static const int CAD_dae_real_w_n_nz = 7;
static int CAD_dae_n_nz = 28;
static const int CAD_dae_nz_rows[28] = {5,6,7,2,3,4,0,1,2,3,4,0,1,2,3,4,2,3,4,8,8,2,5,3,6,4,7,8};
static const int CAD_dae_nz_cols[28] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,21,22,22,23,23,24};
")})));
end SparseJacTest1;


end OptimicaCADCodeGenTests;
