
#include "jmi.h"

 int jmi_ad_init(jmi_t* jmi) {
	 return -1;
 }

 int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci) {
	 *ci = jmi->z + jmi->offs_ci;
	 return 0;
 }

 int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd) {
	 *cd = jmi->z + jmi->offs_cd;
	 return 0;
 }

 int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi) {
	 *pi = jmi->z + jmi->offs_pi;
	 return 0;
 }

 int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd) {
	 *pd = jmi->z + jmi->offs_pd;
	 return 0;
 }

 int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx) {
	 *dx = jmi->z + jmi->offs_dx;
	 return 0;
 }

 int jmi_get_x(jmi_t* jmi, jmi_real_t** x) {
	 *x = jmi->z + jmi->offs_x;
	 return 0;
 }

 int jmi_get_u(jmi_t* jmi, jmi_real_t** u) {
	 *u = jmi->z + jmi->offs_u;
	 return 0;
 }

 int jmi_get_w(jmi_t* jmi, jmi_real_t** w) {
	 *w = jmi->z + jmi->offs_w;
	 return 0;
 }

 int jmi_get_t(jmi_t* jmi, jmi_real_t** t) {
	 *t = jmi->z + jmi->offs_t;
	 return 0;
 }

 int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {
     jmi->dae->F(jmi, res);
	 return 0;
 }

 int jmi_dae_dF(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {
	 jmi->dae->dF(jmi, sparsity, skip, mask, jac);
	 return 0;
 }

 int jmi_dae_dF_n_nz(jmi_t* jmi, int* n_nz) {
	 *n_nz = jmi->dae->dF_n_nz;
	 return 0;
 }

 int jmi_dae_dF_nz_indices(jmi_t* jmi, int* row, int* col) {
	 int i;
	 for (i=0;i<jmi->dae->dF_n_nz;i++) {
		 row[i] = jmi->dae->dF_irow[i];
		 col[i] = jmi->dae->dF_icol[i];
	 }
	 return 0;
 }

 int jmi_dae_dF_ad(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {

	 return -1;
 }

 // Not supported in this interface
 int jmi_dae_dF_n_nz_ad(jmi_t* jmi, int* n_nz) {
	 return -1;
 }

 // Not supported in this interface
 int jmi_dae_dF_nz_indices_ad(jmi_t* jmi, int* row, int* col) {
	 return -1;
 }
