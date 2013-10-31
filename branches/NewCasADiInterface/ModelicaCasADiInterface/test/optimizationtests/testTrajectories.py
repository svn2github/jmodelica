#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

from numpy import mean, sqrt, double, array
from  matplotlib.pyplot import *
import unittest

"""
Compares trajectories from modeltransfer and JModelica optimizer
"""
class Tester(unittest.TestCase):

    def test_traj_vdp(self):
        fileName = 'vdp_jmi_traj.txt'
        generateVdpTrajectories(fileName)
        traj_jmi = self.__get_traj(fileName)
        traj_mc = self.__get_traj('mc_transfer_vdp_traj.txt')
        diff = abs(traj_jmi-traj_mc)
        rms = sqrt(mean(diff**2))
        print "Test failed, root mean square error: ",rms
        print "abs(diff) vector:\n",diff
        assert rms<1e-4 
        
    def test_traj_opt_one(self):
        fileName = "optOne_jmi_traj.txt"
        generateOptimizationOneTrajectories(fileName)
        traj_jmi = self.__get_traj(fileName)
        traj_mc = self.__get_traj('mc_transfer_optOne_traj.txt')
        diff = abs(traj_jmi-traj_mc)
        rms = sqrt(mean(diff**2))
        print "Test failed, root mean square error: ",rms
        print "abs(diff) vector:\n",diff
        assert rms<1e-4 
    
    """
    Read trajectories from file
    """
    def __get_traj(self, f_name):
        arr = []
        split_line = open(f_name,'r').readline().strip().split(',')
        for x in split_line:
            arr.append(double(x))
        return array(arr)


def generateVdpTrajectories(fileName):
    import numpy as np
    from pymodelica import compile_jmu
    from pyjmi import JMUModel
    
    modName = compile_jmu("vdp","../common/optimizationProblems.mop")
    model = JMUModel(modName)
    opts = model.optimize_options()
    opts['n_cp'] = 1
    opts['n_e'] = 100
    res = model.optimize(options=opts)
    
    outData = res['x1']
    outData = np.concatenate((outData,res['x2']))
    outData = np.concatenate((outData,res['cost']))
    outData = np.concatenate((outData,res['der(x1)']))
    outData = np.concatenate((outData,res['der(x2)']))
    outData = np.concatenate((outData,res['der(cost)']))
    outData = np.concatenate((outData,res['u']))
    createTrajectoryFile(outData, fileName)
    
def generateOptimizationOneTrajectories(fileName):
    import numpy as np
    from pymodelica import compile_jmu
    from pyjmi import JMUModel
    
    modName = compile_jmu("optimizationOne","../common/optimizationProblems.mop")
    model = JMUModel(modName)
    opts = model.optimize_options()
    opts['n_cp'] = 1
    opts['n_e'] = 100
    res = model.optimize(options=opts)
    
    outData = res['a']
    outData = np.concatenate((outData,res['der(a)']))
    outData = np.concatenate((outData,res['b']))
    outData = np.concatenate((outData,res['u']))
    createTrajectoryFile(outData, fileName)
    
    
def createTrajectoryFile(trajectoryData, fileName):
    f = open(fileName,'w+')
    out = ""
    sep = ""
    for x in trajectoryData:
        out = out + sep + str(x)
        sep = ", "
    print>>f, out   
    f.close()
