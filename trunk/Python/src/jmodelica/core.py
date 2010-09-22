#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""Module containing base classes."""

from zipfile import ZipFile
import tempfile
import platform as PL
import os
import sys

class BaseModel(object):
    """ Abstract base class for JMUModel and FMUModel."""
    
    def __init__(self):
        raise Exception("This is an abstract class it can not be instantiated.")
    
    def optimize(self):
        raise NotImplementedError('This method is currently not supported.')
                               
    def simulate(self):
        raise NotImplementedError('This method is currently not supported.')
    
    def initialize(self):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_real(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_real(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_integer(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_integer(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_boolean(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_boolean(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_string(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_string(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set(self, variable_name, value):
        """
        Sets the given value(s) to the specified variable name(s)
        into the model. The method both accept a single variable 
        and a list of variables.
        
        Parameters::
            
            variable_name  - The name of the variable(s) as string/list
            value          - The value(s) to set.
            
        Example::
        
            (FMU/JMU)Model.set('damper.d', 1.1)
            (FMU/JMU)Model.set(['damper.d','gear.a'], [1.1, 10])
        """
        if isinstance(variable_name, str):
            self._set(variable_name, value) #Scalar case
        else:
            for i in xrange(len(variable_name)): #A list of variables
                self._set(variable_name[i], value[i])
    
    def get(self, variable_name):
        """
        Returns the value(s) of the specified variable(s). The
        method both accept a single variable and a list of variables.
        
            Parameters::
                
                variable_name - The name of the variable(s) as string/list.
                
            Returns::
            
                The value(s).
                
            Example::
            
                (FMU/JMU)Model.get('damper.d') #Returns the variable d
                (FMU/JMU)Model.get(['damper.d','gear.a']) #Returns a list of the variables
        """
        if isinstance(variable_name, str):
            return self._get(variable_name) #Scalar case
        else:
            ret = []
            for i in xrange(len(variable_name)): #A list of variables
                ret += [self._get(variable_name[i])]
            return ret
    
    def _exec_algorithm(self,
                 algorithm, 
                 alg_args, 
                 solver_args):
        """ Helper function which performs all steps of an algorithm run 
        which are common to all algortihms.
        
        Throws exception if algorithm is not a subclass of 
        algorithm_drivers.AlgorithmBase.
        """
        base_path = 'jmodelica.algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'algorithm_drivers')
        AlgorithmBase = getattr(algdrive, 'AlgorithmBase')
        
        if isinstance(algorithm, str):
            algorithm = getattr(algdrive, algorithm)
        
        if not issubclass(algorithm, AlgorithmBase):
            raise Exception(str(algorithm)+
            " must be a subclass of jmodelica.algorithm_drivers.AlgorithmBase")

        # initialize algorithm
        alg = algorithm(self, alg_args)
        # set arguments to solver, if any
        alg.set_solver_options(solver_args)
        # solve optimization problem/simulate
        alg.solve()
        # get and return result
        return alg.get_result()
        
    def initialize_options(self, algorithm='IpoptInitializationAlg'):
        """ Get an instance of the initialize options class, prefilled 
        with default values. If called without argument then the options 
        class for the default initialization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be 
                fetched. Possible values are: 'IpoptInitializationAlg', 
                'KInitSolveAlg'.
                Default: 'IpoptInitializationAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
        
    def simulate_options(self, algorithm='AssimuloAlg'):
        """ Get an instance of the simulate options class, prefilled 
        with default values. If called without argument then the options 
        class for the default simulation algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be 
                fetched. Possible values are: 'AssimuloAlg', 
                'AssimuloFMIAlg'.
                Default: 'AssimuloAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
        
    def optimize_options(self, algorithm='CollocationLagrangePolynomialsAlg'):
        """ Get an instance of the optimize options class, prefilled 
        with default values. If called without argument then the options 
        class for the default optimization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be 
                fetched. Possible values are: 
                'CollocationLagrangePolynomialsAlg'.
                Default: 'CollocationLagrangePolynomialsAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
        
    def _default_options(self, algorithm):
        """ Help method. Gets the options class for the algorithm 
        specified in 'algorithm'.
        """
        base_path = 'jmodelica.algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'algorithm_drivers')
        algorithm = getattr(algdrive, algorithm)
        return algorithm.get_default_options()
    
    
def unzip_unit(archive, path='.'):
    """
    Unzip the FMU/JMU.
    """

    try:
        archive = ZipFile(os.path.join(path,archive))
    except IOError:
        raise IOError('Could not locate the FMU/JMU.')
    
    dir = ['binaries','sources']
    
    if sys.platform == 'win32':
        platform = 'win'
        suffix = '.dll'
    elif sys.platform == 'darwin':
        platform = 'darwin'
        suffix = '.dylib'
    else:
        platform = 'linux'
        suffix = '.so'
    
    if PL.architecture()[0].startswith('32'):
        platform += '32'
    else:
        platform += '64'
    
    #if platform == 'win32' or platform == 'win64':
    #    suffix = '.dll'
    #elif platform == 'linux32' or platform == 'linux64':
    #    suffix = '.so'
    #else: 
    #    suffix = '.dylib'
    
    #Extracting the XML
    for file in archive.filelist:
        if 'modelDescription.xml' in file.filename:
            
            data = archive.read(file) #Reading the file

            fhandle, tempxmlname = tempfile.mkstemp(suffix='.xml') #Creating temp file
            os.close(fhandle)
            fout = open(tempxmlname, 'w') #Writing to the temp file
            fout.write(data)
            fout.close()
            break
    else:
        raise IOError('Could not find modelDescription.xml in the FMU.')
        
    #Extracting the XML values (if any)
    is_jmu = False
    for file in archive.filelist:
        if file.filename.endswith('values.xml'):
            
            data = archive.read(file) #Reading the file

            fhandle, tempxmlvaluesname = tempfile.mkstemp(suffix='.xml') #Creating temp file
            os.close(fhandle)
            fout = open(tempxmlvaluesname, 'w') #Writing to the temp file
            fout.write(data)
            fout.close()
            is_jmu = True
            break
    # --
    
    #Extrating the binary
    
    found_files = [] #Found files
    
    for file in archive.filelist: #Looping over the archive to find correct binary
        if dir[0] in file.filename and platform in file.filename and file.filename.endswith(suffix): #Binary directory found
            found_files.append(file)
    
    if found_files:
        #Unzip
        data = archive.read(found_files[0]) #Reading the first found dll
        
        modelname = found_files[0].filename.split('/')[-1][:-len(suffix)]
        
        fhandle, tempdllname = tempfile.mkstemp(suffix=suffix)
        os.close(fhandle)
        fout = open(tempdllname, 'w+b')
        fout.write(data)
        fout.close()
        
        if is_jmu:
            return [tempdllname.split(os.sep)[-1], tempxmlname.split(os.sep)[-1], modelname, tempxmlvaluesname.split(os.sep)[-1]]
        else:
            return [tempdllname.split(os.sep)[-1], tempxmlname.split(os.sep)[-1], modelname]

    else:
        raise IOError('Could not find binaries for your platform.')

