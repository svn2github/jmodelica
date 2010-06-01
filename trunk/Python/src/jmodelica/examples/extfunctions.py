import jmodelica
import pylab as p
import numpy as N
import os


def run_demo(with_plots=True):
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    model_name = 'ExtFunctions.addTwo'
    mofile = curr_dir+'/files/ExtFunctions.mo'

    #simulate
    (model, res) = jmodelica.simulate(model_name, mofile, compiler_target='model_noad')

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

