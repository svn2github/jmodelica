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


package CCodeGenJacobianTests


model SparseJacobianLinearBlock1
    Real x[3];
    parameter Real b[3] = {2, 1, 4};
equation
    b[1] = 2 * x[1] + x[2];
    b[2] = x[1] + 2 * x[3];
    b[3] = 2 * x[2] + x[3];
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SparseJacobianLinearBlock1",
            description="Test generation of sparse Jacobians for linear systems.",
            generate_sparse_block_jacobian=true,
            template="
$C_dae_blocks_residual_functions$
------
$C_dae_add_blocks_residual_functions$
",
generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_b_2_4), jmi_max(AD_WRAP_LITERAL(1), jmi_abs(AD_WRAP_LITERAL(2))));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_3_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(2, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(2, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 1;
            Q1[0] = -1.0;
            for (i = 0; i < 2; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-2);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (-2);
            }
            Q2[1] = -1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = -2;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_3_2 = x[0];
        }
        _x_2_1 = jmi_divide_equation(jmi, (- _b_3_5 + _x_3_2),-2,\"(- b[3] + x[3]) / -2\");
        _x_1_0 = jmi_divide_equation(jmi, (- _b_1_3 + _x_2_1),-2,\"(- b[1] + x[2]) / -2\");
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_0 + 2 * _x_3_2 - (_b_2_4);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

typedef struct jacobian_quadrant {
    void  (*dim)();
    void  (*col)();
    void  (*row)();
    void  (*eval)();
} jacobian_quadrant_t;

typedef struct jacobian {
    jacobian_quadrant_t A11;
    jacobian_quadrant_t A12;
    jacobian_quadrant_t A21;
    jacobian_quadrant_t A22;
} jacobian_t;

void A11_0_dim(jmi_real_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 2;
    (*jac)[2] = 1;
}
void A12_0_dim(jmi_real_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void A21_0_dim(jmi_real_t **jac) {
    (*jac)[0] = 3;
    (*jac)[1] = 2;
    (*jac)[2] = 2;
}
void A22_0_dim(jmi_real_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 2;
}
void A11_0_col(jmi_real_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 2;
}
void A12_0_col(jmi_real_t **jac) {
    (*jac)[0] = 1;
}
void A21_0_col(jmi_real_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 2;
}
void A22_0_col(jmi_real_t **jac) {
    (*jac)[0] = 1;
}
void A11_0_row(jmi_real_t **jac) {
    (*jac)[0] = 1;
}
void A12_0_row(jmi_real_t **jac) {
    (*jac)[0] = 1;
}
void A21_0_row(jmi_real_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void A22_0_row(jmi_real_t **jac) {
    (*jac)[0] = 1;
}
void A11_0_eval(jmi_real_t **jac) {
    (*jac)[0] = -2;
}
void A12_0_eval(jmi_real_t **jac) {
    (*jac)[0] = -1.0;
}
void A21_0_eval(jmi_real_t **jac) {
    (*jac)[0] = -1.0;
    (*jac)[1] = -2;
    (*jac)[2] = -1.0;
}
void A22_0_eval(jmi_real_t **jac) {
    (*jac)[0] = -2;
}

jacobian_t *jacobian_init_0() {
    jacobian_t *jc = (jacobian_t *) malloc(sizeof(jacobian_t));
    jc->A11.dim = &A11_0_dim;
    jc->A11.col = &A11_0_col;
    jc->A11.row = &A11_0_row;
    jc->A11.eval = &A11_0_eval;
    jc->A12.dim = &A12_0_dim;
    jc->A12.col = &A12_0_col;
    jc->A12.row = &A12_0_row;
    jc->A12.eval = &A12_0_eval;
    jc->A21.dim = &A21_0_dim;
    jc->A21.col = &A21_0_col;
    jc->A21.row = &A21_0_row;
    jc->A21.eval = &A21_0_eval;
    jc->A22.dim = &A22_0_dim;
    jc->A22.col = &A22_0_col;
    jc->A22.row = &A22_0_row;
    jc->A22.eval = &A22_0_eval;
    return jc;
}

static int jacobian_0(jmi_t *jmi, jmi_real_t *x, jmi_real_t **jac, int mode) {
    int ef = 0;
    jacobian_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A11) {
        jc->A11.eval(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A12) {
        jc->A12.eval(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A21) {
        jc->A21.eval(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A22) {
        jc->A22.eval(jac);
    }

    free(jc);
    JMI_DYNAMIC_FREE()
    return ef;
}

static int jacobian_struct_0(jmi_t *jmi, jmi_real_t *x, jmi_real_t **jac, int mode) {
    int ef = 0;
    jacobian_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A11_STRUCTURE_DIMENSION) {
        jc->A11.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A11_STRUCTURE_COLPTR) {
        jc->A11.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A11_STRUCTURE_ROWIND) {
        jc->A11.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A11_STRUCTURE_EVAL) {
        jc->A11.eval(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A12_STRUCTURE_DIMENSION) {
        jc->A12.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A12_STRUCTURE_COLPTR) {
        jc->A12.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A12_STRUCTURE_ROWIND) {
        jc->A12.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A12_STRUCTURE_EVAL) {
        jc->A12.eval(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A21_STRUCTURE_DIMENSION) {
        jc->A21.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A21_STRUCTURE_COLPTR) {
        jc->A21.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A21_STRUCTURE_ROWIND) {
        jc->A21.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A21_STRUCTURE_EVAL) {
        jc->A21.eval(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A22_STRUCTURE_DIMENSION) {
        jc->A22.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A22_STRUCTURE_COLPTR) {
        jc->A22.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A22_STRUCTURE_ROWIND) {
        jc->A22.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN_A22_STRUCTURE_EVAL) {
        jc->A22.eval(jac);
    }

    free(jc);
    JMI_DYNAMIC_FREE()
    return ef;
}


------
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, &jacobian_0, &jacobian_struct_0, 1, 2, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

")})));
end SparseJacobianLinearBlock1;


end CCodeGenJacobianTests;