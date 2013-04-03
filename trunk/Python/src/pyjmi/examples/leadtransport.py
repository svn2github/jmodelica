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
    Demonstrate how to solve and calculate sensitivity for initial conditions.
    See "http://sundials.2283335.n4.nabble.com/Forward-sensitivities-for-  \
               initial-conditions-td3239724.html"
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    jmu_name = compile_jmu("LeadTransport", curr_dir+"/files/leadtransport.mop")
    model = JMUModel(jmu_name)
    
    opts = model.simulate_options()
    opts["IDA_options"]["sensitivity"] = True
    opts["IDA_options"]["rtol"] = 1e-7
    opts["IDA_options"]["suppress_sens"] = False #Use the sensitivity variablers
                                                 #in the error test.
    
    res = model.simulate(final_time=400, options=opts)

    # Extract variable profiles
    y1,y2,y3 = res['y1'], res["y2"], res["y3"]
    dy1p1,dy2p1,dy3p1 = res['dy1/dp1'], res['dy2/dp1'], res['dy3/dp1']
    dy1p2,dy2p2,dy3p2 = res['dy1/dp2'], res['dy2/dp2'], res['dy3/dp2']
    dy1p3,dy2p3,dy3p3 = res['dy1/dp3'], res['dy2/dp3'], res['dy3/dp3']
    t=res['time']
    
    assert N.abs(res.initial('dy1/dp1') - 1.000) < 1e-3
    assert N.abs(res.initial('dy1/dp2') - 1.000) < 1e-3
    assert N.abs(res.initial('dy2/dp2') - 1.000) < 1e-3 

    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(221)
        plt.plot(t,y1,t,y2,t,y3)
        plt.grid()
        plt.legend(("y1","y2","y3"))
        
        plt.subplot(222)
        plt.plot(t,dy1p1,t,dy2p1,t,dy3p1)
        plt.grid()
        plt.legend(("dy1/dp1","dy2/dp1","dy3/dp1"))
        
        plt.subplot(223)
        plt.plot(t,dy1p2,t,dy2p2,t,dy3p2)
        plt.grid()
        plt.legend(("dy1/dp2","dy2/dp2","dy3/dp2"))
        
        plt.subplot(224)
        plt.plot(t,dy1p3,t,dy2p3,t,dy3p3)
        plt.grid()
        plt.legend(("dy1/dp3","dy2/dp3","dy3/dp3"))
        plt.suptitle("Lead transport through the body")
        plt.show()

if __name__ == "__main__":
    run_demo()
