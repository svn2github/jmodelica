""" 
Test module for testing the JMI Model Interface wrappers.
(Low-level jmodelica interfaces.)

The correctness of the methods are not really tested here, only that they can
be called without crashing and in some cases that return value has at least the
correct type.
"""

import os

import ctypes as ct
import numpy as n
import nose
import nose.tools

from jmodelica.compiler import OptimicaCompiler
import jmodelica as jm
import jmodelica.jmi as jmi

from jmodelica.tests import load_example_standard_model
from jmodelica.simulation.sundials import solve_using_sundials


class ModelContainer(object):
    def __init__(self, filename, filepath):
        self.filename = filename
        self.filepath = filepath
        self.model = None
        
    def initmodel(self):
        self.model = jmi.Model(self.filename, self.filepath)
    
    def getjmimodel(self):
        return self.model.jmimodel
    
    def delmodel(self):
        if model:
            del(self.model)


jm_home = jm.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python','jmodelica','examples')

model = os.path.join('files','VDP.mo')
fpath = os.path.join(jm_home, path_to_examples, model)
cpath = "VDP_pack.VDP_Opt"

fname = cpath.replace('.','_')

mc = ModelContainer(fname, '.')

# constants used in all tests that have them
eval_alg = jmi.JMI_DER_CPPAD
sparsity = jmi.JMI_DER_SPARSE
indep_vars = jmi.JMI_DER_ALL


def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
    oc = OptimicaCompiler()
    oc.compile_model(fpath, cpath, 'ipopt')
    mc.initmodel()
    

def teardown():
    """ Teardown test run. Delete test model. """
    mc.delmodel()


def test_initAD():
    """ Test JMIModel.initAD method. """
    model = mc.getjmimodel()
    model.initAD()


def test_get_sizes():
    """ Test JMIModel.get_sizes method. """
    #model = jmi.JMIModel(fname, '.')
    model = mc.getjmimodel()
    n_ci = ct.c_int()
    n_cd = ct.c_int()
    n_pi = ct.c_int()
    n_pd = ct.c_int()
    n_dx = ct.c_int()
    n_x  = ct.c_int()
    n_u  = ct.c_int()
    n_w  = ct.c_int()
    n_tp = ct.c_int()
    n_z  = ct.c_int()
    model.get_sizes(n_ci, n_cd, n_pi, n_pd, n_dx, n_x, n_u, n_w, n_tp, n_z)
    

def test_get_offsets():
    """ Test JMIModel.get_offsets method. """
    model = mc.getjmimodel()
    offs_ci = ct.c_int()
    offs_cd = ct.c_int()
    offs_pi = ct.c_int()
    offs_pd = ct.c_int()
    offs_dx = ct.c_int()
    offs_x = ct.c_int()
    offs_u = ct.c_int()
    offs_w = ct.c_int()
    offs_t = ct.c_int()
    offs_dx_p = ct.c_int()
    offs_x_p = ct.c_int()
    offs_u_p = ct.c_int()
    offs_w_p = ct.c_int()   
    model.get_offsets(offs_ci, offs_cd, offs_pi, offs_pd, offs_dx, offs_x, offs_u, 
                      offs_w, offs_t, offs_dx_p, offs_x_p, offs_u_p, offs_w_p)


def test_get_n_tp():
    """ Test JMIModel.get_n_tp method. """
    model = mc.getjmimodel()
    n_tp = ct.c_int()
    model.get_n_tp(n_tp)


def test_getset_tp():
    """ Test JMIModel.get_tp and JMIModel.set_tp method. """
    model = mc.getjmimodel()
    n_tp = ct.c_int()
    model.get_n_tp(n_tp)
    #set tp
    set_tp = n.zeros(n_tp.value)
    for i in range(n_tp.value):
        set_tp[i]=i+1
    model.set_tp(set_tp) 
    #get tp
    get_tp = n.zeros(n_tp.value)
    model.get_tp(get_tp)
    for j in range(n_tp.value):
        if set_tp[j] != get_tp[j]:
            assert False, "value set with set_tp was not the same as returned by get_tp"   
    

def test_get_z():
    """ Test JMIModel.get_z method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_z(), n.ndarray),\
        "JMIModel.get_z did not return numpy.ndarray."
    

def test_get_ci():
    """ Test JMIModel.get_ci method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_ci(), n.ndarray),\
        "JMIModel.get_ci did not return numpy.ndarray."
    

def test_get_cd():
    """ Test JMIModel.get_cd method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_cd(), n.ndarray),\
        "JMIModel.get_cd did not return numpy.ndarray."
    

def test_get_pi():
    """ Test JMIModel.get_pi method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_pi(), n.ndarray),\
        "JMIModel.get_pi did not return numpy.ndarray."
        

def test_get_pd():
    """ Test JMIModel.get_pd method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_pd(), n.ndarray),\
        "JMIModel.get_pd did not return numpy.ndarray."


def test_get_dx():
    """ Test JMIModel.get_dx method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_dx(), n.ndarray),\
        "JMIModel.get_dx did not return numpy.ndarray."
    

def test_get_x():
    """ Test JMIModel.get_x method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_x(), n.ndarray),\
        "JMIModel.get_x did not return numpy.ndarray."
    

def test_get_u():
    """ Test JMIModel.get_u method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_u(), n.ndarray),\
        "JMIModel.get_u did not return numpy.ndarray."
    

def test_get_w():
    """ Test JMIModel.get_w method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_w(), n.ndarray),\
        "JMIModel.get_w did not return numpy.ndarray. "


def test_get_t():
    """ Test JMIModel.get_t method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_t(), n.ndarray),\
        "JMIModel.get_t did not return numpy.ndarray. "


def test_get_dx_p():
    """ Test JMIModel.get_dx_p method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_dx_p(0), n.ndarray), \
        "JMIModel.get_dx_p(i) for i=0 did not return numpy.ndarray. "


def test_get_x_p():
    """ Test JMIModel.get_x_p method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_x_p(0), n.ndarray), \
        "JMIModel.get_x_p(i) for i=0 did not return numpy.ndarray. "


def test_get_u_p():
    """ Test JMIModel.get_u_p method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_u_p(0), n.ndarray), \
        "JMIModel.get_u_p(i) for i=0 did not return numpy.ndarray. " 


def test_get_w_p():
    """ Test JMIModel.get_w_p method. """
    model = mc.getjmimodel()
    assert isinstance(model.get_w_p(0), n.ndarray), \
        "JMIModel.get_w_p(i) for i=0 did not return numpy.ndarray. "


#def test_ode_f():
#    """ Test JMIModel.ode_f method. """
#    model = jmi.JMIModel(fname, '.')
#    model.ode_f()
#    
#
#def test_ode_df():
#    """ Test JMIModel.ode_f method. """
#    model = jmi.JMIModel(fname, '.')
#
#
#def test_ode_df_n_nz():
#    """ Test JMIModel.ode_df_n_nz method. """
#    model = jmi.JMIModel(fname, '.')
# 
#
#def test_ode_df_nz_indices():
#    """ Test JMIModel.ode_df_nz_indices method. """
#    model = jmi.JMIModel(fname, '.')
#
#
#def test_ode_df_dim():
#    """ Test JMIModel.ode_df_dim method. """
#    model = jmi.JMIModel('.')


def test_dae_get_sizes():
    """ Test JMIModel.dae_get_sizes method. """
    model = mc.getjmimodel()
    model.dae_get_sizes()
      
  
def test_dae_F():
    """ Test JMIModel.dae_F method. """
    model = mc.getjmimodel()
    size = model.dae_get_sizes()
    res = n.zeros(size)
    model.dae_F(res)
    

def test_dae_dF():
    """ Test JMIModel.dae_dF method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    jac = n.zeros(model.get_z().size)
    model.dae_dF(eval_alg,sparsity,indep_vars,mask,jac)
    

def test_dae_dF_n_nz():
    """ Test JMIModel.dae_dF_n_nz method. """
    model = mc.getjmimodel()
    model.dae_dF_n_nz(eval_alg)
    

def test_dae_dF_nz_indices():
    """ Test JMIModel.dae_dF_nz_indices method. """ 
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    nnz = model.dae_dF_n_nz(eval_alg)
    row = n.ndarray(nnz, dtype=int)
    col = n.ndarray(nnz, dtype=int)
    model.dae_dF_nz_indices(eval_alg, indep_vars, mask, row, col)
    

def test_dae_dF_dim():
    """ Test JMIModel.dae_dF_dim method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    n_cols, n_n_nz = model.dae_dF_dim(eval_alg, sparsity, indep_vars, mask)
    

def test_init_get_sizes():
    """ Test JMIModel.init_get_sizes method. """
    model = mc.getjmimodel()
    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    

def test_init_F0():
    """ Test JMIModel.init_FO method. """
    model = mc.getjmimodel()
    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    res = n.zeros(n_eq_f0)
    model.init_F0(res)
    

def test_init_dF0():
    """ Test JMIModel.init_dF0 method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    jac = n.zeros(model.get_z().size)
    model.init_dF0(eval_alg, sparsity, indep_vars, mask, jac)
    

def test_init_dF0_n_nz():
    """ Test JMIModel.init_dF0_n_nz method. """
    model = mc.getjmimodel()
    n_nz = model.init_dF0_n_nz(eval_alg)
    

def test_init_dF0_nz_indices():
    """ Test JMIModel.init_dF0_nz_indices method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    nnz = model.init_dF0_n_nz(eval_alg)
    row = n.ndarray(nnz, dtype=int)
    col = n.ndarray(nnz, dtype=int)
    model.init_dF0_nz_indices(eval_alg, indep_vars, mask, row, col)
    

def test_init_dF0_dim():
    """ Test JMIModel.init_dF0_dim method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    dF_n_cols, dF_n_nz = model.init_dF0_dim(eval_alg, sparsity, indep_vars,
                                            mask)
 

def test_init_F1():
    """ Test JMIModel.init_F1 method. """
    model = mc.getjmimodel()
    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    res = n.zeros(n_eq_f1)
    model.init_F1(res)
    

def test_init_dF1():
    """ Test JMIModel.init_dF1 method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    jac = n.zeros(model.get_z().size)
    model.init_dF1(eval_alg, sparsity, indep_vars, mask, jac)
    

def test_init_dF1_n_nz():
    """ Test JMIModel.init_dF1_n_nz method. """
    model = mc.getjmimodel()
    n_nz = model.init_dF1_n_nz(eval_alg)
    

def test_init_dF1_nz_indices():
    """ Test JMIModel.init_dF1_nz_indices method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    nnz = model.init_dF1_n_nz(eval_alg)
    row = n.ndarray(nnz, dtype=int)
    col = n.ndarray(nnz, dtype=int)
    model.init_dF1_nz_indices(eval_alg, indep_vars, mask, row, col)
    

def test_init_dF1_dim():
    """ Test JMIModel.init_dF1_dim method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    dF_n_cols, dF_n_nz = model.init_dF1_dim(eval_alg, sparsity, indep_vars,
                                            mask) 


#def test_init_Fp():
#    """ Test JMIModel.init_Fp method. """
#    model = mc.getjmimodel()
#    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
#    res = n.zeros(n_eq_fp)
#    model.init_Fp(res)
#    
#
#def test_init_dFp():
#    """ Test JMIModel.init_dFp method. """
#    model = mc.getjmimodel()
#    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
#    if n_eq_fp > 0:
#        mask = n.ones(model.get_z().size, dtype=int)
#        jac = n.zeros(model.get_z().size)
#        model.init_dFp(eval_alg, sparsity, indep_vars, mask, jac)
#    else:
#        assert False, "Cannot perform test, size of Fp is 0. "
#    
#
#def test_init_dFp_n_nz():
#    """ Test JMIModel.init_dFp_n_nz method. """
#    model = mc.getjmimodel()
#    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
#    if n_eq_fp > 0:
#        n_nz = model.init_dFp_n_nz(eval_alg)
#    else:
#        assert False, "Cannot perform test, size of Fp is 0. "
#    
#
#def test_init_dFp_nz_indices():
#    """ Test JMIModel.init_dFp_nz_indices method. """
#    model = mc.getjmimodel()
#    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
#    if n_eq_fp > 0:
#        mask = n.ones(model.get_z().size, dtype=int)
#        nnz = model.init_dFp_n_nz(eval_alg)
#        row = n.ndarray(nnz, dtype=int)
#        col = n.ndarray(nnz, dtype=int)
#        model.init_dFp_nz_indices(eval_alg, indep_vars, mask, row, col)
#    else:
#       assert False, "Cannot perform test, size of Fp is 0. " 
#    
#
#def test_init_dFp_dim():
#    """ Test JMIModel.init_dFp_dim method. """
#    model = mc.getjmimodel()
#    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
#    if n_eq_fp > 0:
#        mask = n.ones(model.get_z().size, dtype=int)
#        dF_n_cols, dF_n_nz = model.init_dFp_dim(eval_alg, sparsity,
#                                                 indep_vars, mask) 
#    else:
#        assert False, "Cannot perform test, size of Fp is 0. "


def test_opt_getset_optimization_interval():
    """Test JMIModel.opt_[set|get]_optimization_interval methods."""
    st_set = ct.c_double(5)
    # 0 = fixed, 1 = free (free NOT YET SUPPORTED)
    stf_set = ct.c_int(0)
    ft_set = ct.c_double(20)
    # 0 = fixed, 1 = free (free NOT YET SUPPORTED)
    ftf_set = ct.c_int(0)
    model = mc.getjmimodel()
    model.opt_set_optimization_interval(st_set, stf_set, ft_set, ftf_set)
    st_get, stf_get, ft_get, ftf_get = model.opt_get_optimization_interval()
    
    nose.tools.assert_equal(st_set.value, st_get)
    nose.tools.assert_equal(stf_set.value, stf_get)
    nose.tools.assert_equal(ft_set.value, ft_get)
    nose.tools.assert_equal(ftf_set.value, ftf_get)
    

def test_opt_get_n_p_opt():
    """ Test opt_get_n_p_opt method. """
    model = mc.getjmimodel()
    assert isinstance(model.opt_get_n_p_opt(), int),\
        "Method does not return int."
    

def test_opt_getset_p_opt_indices():
    """ Test JMIModel.opt_set_p_opt_indices method. """
    model = mc.getjmimodel()
    n_pi = model.get_pi().size
    if n_pi > 0:
        # test set
        set_indices = n.zeros(1, dtype=int)
        set_indices[0]=0
        model.opt_set_p_opt_indices(1, set_indices)
        #test get
        get_indices = n.ones(1, dtype=int)
        model.opt_get_p_opt_indices(get_indices)
        nose.tools.assert_equal(model.opt_get_n_p_opt(), 1)
        nose.tools.assert_equal(set_indices[0], get_indices[0])
    else:
        assert False, "pi vector is empty"


def test_opt_get_sizes():
    """ Test opt_get_sizes method. """
    model = mc.getjmimodel()
    n_eq_ceq, n_eq_cineq, n_eq_heq, n_eq_hineq = model.opt_get_sizes()
    

def test_opt_J():
    """ Test opt_J method. """
    model = mc.getjmimodel()
    model.opt_J()
    

def test_opt_dJ():
    """ Test opt_dJ method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    jac = n.zeros(model.get_z().size)
    model.opt_dJ(eval_alg, sparsity, indep_vars, mask, jac)


def test_opt_dJ_n_nz():
    """ Test opt_dJ_n_nz method. """
    model = mc.getjmimodel()
    assert isinstance(model.opt_dJ_n_nz(eval_alg), int),\
        "Method does not return int."
    

def test_opt_dJ_nz_indices():
    """ Test opt_dJ_nz_indices method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    nnz = model.opt_dJ_n_nz(eval_alg)
    row = n.ndarray(nnz, dtype=int)
    col = n.ndarray(nnz, dtype=int)
    model.opt_dJ_nz_indices(eval_alg, indep_vars, mask, row, col)
    

def test_opt_dJ_dim():
    """ Test opt_dJ_dim method. """
    model = mc.getjmimodel()
    mask = n.ones(model.get_z().size, dtype=int)
    dJ_n_cols, dJ_n_nz = model.init_dF0_dim(eval_alg, sparsity, indep_vars,
                                            mask)    
    
    
class TestModelSimulation:
    """Test the JMIModel instance of the Van der Pol oscillator."""
    
    def setUp(self):
        """Test setUp. Load the test model."""
        self.m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo', 
                                              'VDP_pack.VDP_Opt')
        
    def test_opt_jac_non_zeros(self):
        """Testing the number of non-zero elements in VDP after simulation.
        
        Note:
        This test is model specific and not generic as most other
        tests in this class.
        """
        solve_using_sundials(self.m, self.m.opt_interval_get_final_time(),
                             self.m.opt_interval_get_start_time())
        assert self.m._n_z > 0, "Length of z should be greater than zero."
        print 'n_z.value:', self.m._n_z.value
        n_cols, n_nz = self.m.jmimodel.opt_dJ_dim(jmi.JMI_DER_CPPAD,
                                                  jmi.JMI_DER_SPARSE,
                                                  jmi.JMI_DER_X_P,
                                                  n.ones(self.m._n_z.value,
                                                         dtype=int))
        
        print 'n_nz:', n_nz
        
        assert n_cols > 0, "The resulting should at least of one column."
        assert n_nz > 0, "The resulting jacobian should at least have" \
                         " one element (structurally) non-zero."
