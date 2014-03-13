import os.path

import pymodelica
from pymodelica.compiler_wrappers import ModelicaCompiler

import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt

import jpype

org = jpype.JPackage('org')

mc = ModelicaCompiler()

try:
	source_root.getProgramRoot()
except:
	source_root = mc.parse_model("C:\\JModelica.org-SDK-1.9\\src\\Python\\src\\tests_jmodelica\\files\\Modelica\\TestModelicaModels.mo")
	#source_root = mc.parse_model("C:\\JModelica.org-SDK-1.8.1\\src\\ThirdParty\\MSL\\Modelica\\Mechanics\\MultiBody\\Examples\\Systems\\RobotR3.mo")
	
target = mc.create_target_object("xml", "1.0")

try:
	filter_instance.components()
except:
	#filter_instance = mc.instantiate_model(source_root, "Modelica.Mechanics.MultiBody.Examples.Systems.RobotR3.fullRobot", target)
	filter_instance = mc.instantiate_model(source_root, "AtomicModelDerivedBooleanTypeIsDone", target)
try:
	filter_flat_model.name()
except:
	filter_flat_model = mc.flatten_model(filter_instance, target)
	
mc.generate_code(filter_flat_model, target)
