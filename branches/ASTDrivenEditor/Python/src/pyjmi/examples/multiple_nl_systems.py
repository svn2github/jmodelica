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
from jmodelica import compile_fmu
from pyfmi import FMUModel

import pyfmi.examples.log_analysis as la

curr_dir = os.path.dirname(os.path.abspath(__file__));
    
def run_demo(with_plots=True,with_loganalysis=True,nb_blocks=10):
	options = {'generate_html_diagnostics':True}
	# Compile the stationary initialization model into a DLL
	fmu_name = compile_fmu("NonLinear.MultiSystems", curr_dir+"/files/NonLinear.mo")

	# Load a JMU model instance
	init_model = FMUModel(fmu_name)
	init_model.set_debug_logging(True)
	init_model.set('n',nb_blocks)
	# Initialize
	init_model.initialize()
	# Simulate
	#grab.grab("res_out.txt", init_model.simulate(0.0,1000.0))
	res = init_model.simulate(0.0,60.0)

	vin = res['V.p.v']
	vout = res['R1.p.v']
	t = res['time']

	fig1 = plt.figure()
	plt.plot(t,vin)

	fig2 = plt.figure()
	plt.plot(t,vout)
	plt.show()

	log =init_model.get_log()
	if with_loganalysis:
		logger = la.Analyze(log)

		njevals = logger.get_debug(["Block","njevals:","nbcalls:"])


		for entry in njevals:
			print " ", entry[0], "Block: ",entry[1], "with", entry[2],"jevals called", entry[3], "times"
