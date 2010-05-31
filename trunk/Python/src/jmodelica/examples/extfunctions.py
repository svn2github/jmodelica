from jmodelica.compiler import ModelicaCompiler
import jmodelica
import pylab as p
import numpy as N
import os
from jmodelica.simulation.assimulo import JMIDAE, write_data
from Assimulo.Implicit_ODE import IDA
from Assimulo import Implicit_ODE as impl_ode

def run_demo(with_plots=True):
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    model_name = 'ExtFunctionsTest.ExtFunctionTest1'
    mofile = curr_dir+'/files/ExtFunctionsTests.mo'

    mc = ModelicaCompiler()
    model=mc.compile_model(model_name,mofile,target='model_noad')

    #simulate
    probl = JMIDAE(model)
    simulator = impl_ode.IDA(probl)
    simulator.simulate(10.0)
    write_data(simulator)
    result_file_name=model.get_name()+'_result.txt'
    res = jmodelica.io.ResultDymolaTextual(result_file_name)

    sim_a = res.get_variable_data('a')
    sim_b = res.get_variable_data('b')
    sim_c = res.get_variable_data('c')

    assert N.abs(sim_a.x[-1] - 1) < 1e-6, \
           "Wrong value in simulation result in extfunctions.py" 
    assert N.abs(sim_b.x[-1] - 2) < 1e-6, \
           "Wrong value in simulation result in extfunctions.py"
    assert N.abs(sim_c.x[-1] - 3) < 1e-6, \
           "Wrong value in simulation result in extfunctions.py"

    if with_plots:
        fig = p.figure()
        p.clf()
        p.subplot(3,1,1)
        p.plot(sim_a.t, sim_a.x)
        p.subplot(3,1,2) 
        p.plot(sim_b.t, sim_b.x) 
        p.subplot(3,1,3)
        p.plot(sim_c.t, sim_c.x)
        p.show()

if __name__=="__main__":
    run_demo()

