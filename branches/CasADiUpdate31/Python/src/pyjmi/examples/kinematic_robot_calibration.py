#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2016 Modelon AB
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

# Import stuff
import os
from pyjmi import transfer_optimization_problem, get_files_path
from pyjmi.optimization.static_optimization import StaticExternalData
from collections import OrderedDict
import numpy as np
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi.symbolic_elimination import BLTOptimizationProblem, EliminationOptions
import scipy

def run_demo(with_plots=True):
    """
    Uses StaticOptimizationAlg to perform kinematic calibration of a simple robot.

    The robot consists of three revolute joints with associated links, where the lengths of links two and three as well
    as the angle between the rotation axis of the first and the second links are to be estimated based on artificial
    experimental data. The robot is parameterized using the Denavit-Hartenberg convention. The identification is
    performed based on measurements (x,y,z) of the end-effector position of the robot and measurement of the joint
    angles theta. The measurements are subject to noise drawn from a Gaussian distribution. In the parameter estimation,
    a cost function composed of the sum of the squared residuals between the predicted robot positions and the
    corresponding measurements is employed.
    """
    # Compilation
    file_path = os.path.join(get_files_path(), "robot_arm.mop")
    fmu = load_fmu(compile_fmu('RobotArm', file_path))
    op = transfer_optimization_problem('RobotArmEst', file_path)

    # Load data
    data = scipy.io.loadmat(os.path.join(get_files_path(), 'robot_data.mat'))
    N = data['joint_pos'].shape[1] # Numer of measurements

    # Joint data
    eliminated = OrderedDict()
    theta = data['joint_pos'][:, :N]
    eliminated['theta[1]'] = theta[0, :]
    eliminated['theta[2]'] = theta[1, :]
    eliminated['theta[3]'] = theta[2, :]

    # Tool data
    quad_pen = OrderedDict()
    xyz = data['tool_pos'][:, :N]
    quad_pen['x'] = xyz[0, :]
    quad_pen['y'] = xyz[1, :]
    quad_pen['z'] = xyz[2, :]

    # Unitary weights for each variable and data point
    Q = N * [np.eye(3)]

    # Compose data
    sed = StaticExternalData(Q=Q, eliminated=eliminated, quad_pen=quad_pen)

    # Generates initial guess by initializing FMU for each data point
    init_guess = op.generate_static_guess(fmu, sed)

    # Set solver options
    algorithm = 'StaticOptimizationAlg'
    opts = op.optimize_options(algorithm=algorithm)
    opts['external_data'] = sed
    opts['init_guess'] = init_guess

    # Eliminate variables
    elim_opts = EliminationOptions()
    elim_opts['ineliminable'] = ['x', 'y', 'z']
    op = BLTOptimizationProblem(op, elim_opts)

    # Solve
    res = op.optimize(options=opts, algorithm=algorithm)

    # Print result
    print('alpha1:\n\tTrue value %.4e\n\tEstimated value %.4e\n' % (np.pi/2, res['l1.alpha'][0]))
    print('a2:\n\tTrue value %.4e\n\tEstimated value %.4e\n' % (1.0, res['l2.a'][0]))
    print('a3:\n\tTrue value %.4e\n\tEstimated value %.4e\n' % (2.0, res['l3.a'][0]))
