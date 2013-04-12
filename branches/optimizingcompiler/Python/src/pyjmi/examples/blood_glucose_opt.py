#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the JModelica.org Python packages
from pymodelica import compile_jmu
from pyjmi import JMUModel

def run_demo(with_plots=True):
    """
    Optimization of a model that predicts the blood glucose levels of a 
    type-I diabetic. The objective is to predict the relationship between 
    insulin injection and blood glucose levels.
    
    Reference:
    S. M. Lynch and B. W. Bequette, Estimation based Model Predictive Control of Blood Glucose in 
    Type I Diabetes: A Simulation Study, Proc. 27th IEEE Northeast Bioengineering Conference, IEEE, 2001.
    
    S. M. Lynch and B. W. Bequette, Model Predictive Control of Blood Glucose in type I Diabetics 
    using Subcutaneous Glucose Measurements, Proc. ACC, Anchorage, AK, 2002.
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu = compile_jmu("JMExamples_opt.BloodGlucose_opt", 
        (os.path.join(curr_dir, 'files', 'JMExamples_opt.mop'), os.path.join(curr_dir, 'files', 'JMExamples.mo')))
    bg = JMUModel(jmu)
    res = bg.optimize()
    
    jmu_final = compile_jmu("JMExamples_opt.BloodGlucose_opt_final", 
        (os.path.join(curr_dir, 'files', 'JMExamples_opt.mop'), os.path.join(curr_dir, 'files', 'JMExamples.mo')))
    bg_final = JMUModel(jmu_final)
    res_final = bg_final.optimize()

    # Extract variable profiles
    G = res['bc.G']
    X = res['bc.X']
    I = res['bc.I']
    D = res['bc.D']
    t = res['time']
    
    # Extract variable profiles of final result
    G_final = res_final['bc.G']
    X_final = res_final['bc.X']
    I_final = res_final['bc.I']
    D_final = res_final['bc.D']

    assert N.abs(res.final('bc.G') - 5.60798)        < 1e-4
    assert N.abs(res.final('bc.D') - 13.00005)       < 1e-4
    assert N.abs(res_final.final('bc.G') - 4.99974)  < 1e-4
    assert N.abs(res_final.final('bc.D') - 14.88007) < 1e-4
    
    if with_plots:
        plt.figure()
        
        plt.subplot(2,2,1)
        plt.plot(t, G)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('Plasma Glucose Conc. (mmol/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,2)
        plt.plot(t, X)
        plt.title('Plasma Insulin Conc.')
        plt.grid(True)
        plt.ylabel('Plasma Insulin Conc. (mu/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,3)
        plt.plot(t, I)
        plt.title('Plasma Insulin Conc.')
        plt.grid(True)
        plt.ylabel('Plasma Insulin Conc. (mu/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,4)
        plt.plot(t, D)
        plt.title('Insulin Infusion')
        plt.grid(True)
        plt.ylabel('Insulin Infusion')
        plt.xlabel('time')
        
        plt.show()
        
        plt.figure()
        
        plt.subplot(2,2,1)
        plt.plot(t, G_final)
        plt.title('Plasma Glucose Conc. final')
        plt.grid(True)
        plt.ylabel('Plasma Glucose Conc. (mmol/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,2)
        plt.plot(t,X_final)
        plt.title('Plasma Insulin Conc. final')
        plt.grid(True)
        plt.ylabel('Plasma Insulin Conc. (mu/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,3)
        plt.plot(t,I_final)
        plt.title('Plasma Insulin Conc. final')
        plt.grid(True)
        plt.ylabel('Plasma Insulin Conc. (mu/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,4)
        plt.plot(t,D_final)
        plt.title('Insulin Infusion final')
        plt.grid(True)
        plt.ylabel('Insulin Infusion')
        plt.xlabel('time')
        
        plt.show()

if __name__ == "__main__":
    run_demo()
