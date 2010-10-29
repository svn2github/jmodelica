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
"""
Module containing base classes.
"""

import zipfile
import tempfile
import platform as PL
import os
import sys
import numpy as N

class BaseModel(object):
    """ 
    Abstract base class for JMUModel and FMUModel.
    """
    
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
        Sets the given value(s) to the specified variable name(s) into the 
        model. The method both accept a single variable and a list of variables.
        
        Parameters::
            
            variable_name -- 
                The name of the variable(s) as string/list.
                
            value -- 
                The value(s) to set.
            
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
        Returns the value(s) of the specified variable(s). The method both 
        accept a single variable and a list of variables.
        
        Parameters::
        
            variable_name -- 
                The name of the variable(s) as string/list.
                
        Returns::
        
            The value(s).
                
        Example::
            
            # Returns the variable d
            (FMU/JMU)Model.get('damper.d') 
            # Returns a list of the variables
            (FMU/JMU)Model.get(['damper.d','gear.a'])
        """
        if isinstance(variable_name, str):
            return self._get(variable_name) #Scalar case
        else:
            ret = []
            for i in xrange(len(variable_name)): #A list of variables
                ret += [self._get(variable_name[i])]
            return ret
    
    def _exec_algorithm(self, algorithm, options):
        """ 
        Helper function which performs all steps of an algorithm run which are 
        common to all initialize and optimize algortihms.
        
        Raises:: 
        
            Exception if algorithm is not a subclass of 
            jmodelica.algorithm_drivers.AlgorithmBase.
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
        alg = algorithm(self, options)
        # solve optimization problem/initialize
        alg.solve()
        # get and return result
        return alg.get_result()

    def _exec_simulate_algorithm(self,
                                 start_time,
                                 final_time,
                                 input,
                                 algorithm, 
                                 options):
        """ 
        Helper function which performs all steps of an algorithm run which are 
        common to all simulate algortihms.
        
        Raises:: 
        
            Exception if algorithm is not a subclass of 
            jmodelica.algorithm_drivers.AlgorithmBase.
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
        alg = algorithm(start_time, final_time, input, self, 
            options)
        # simulate
        alg.solve()
        # get and return result
        return alg.get_result()
        
    def initialize_options(self, algorithm='IpoptInitializationAlg'):
        """ 
        Get an instance of the initialize options class, prefilled with default 
        values. If called without argument then the options class for the 
        default initialization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be fetched. 
                Possible values are: 'IpoptInitializationAlg', 'KInitSolveAlg'.
                Default: 'IpoptInitializationAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
        
    def simulate_options(self, algorithm='AssimuloAlg'):
        """ 
        Get an instance of the simulate options class, prefilled with default 
        values. If called without argument then the options class for the 
        default simulation algorithm will be returned.

        Parameters::
        
            algorithm --
                The algorithm for which the options class should be fetched. 
                Possible values are: 'AssimuloAlg', 'AssimuloFMIAlg'.
                Default: 'AssimuloAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
        
    def optimize_options(self, algorithm='CollocationLagrangePolynomialsAlg'):
        """
        Returns an instance of the optimize options class containing options 
        default values. If called without argument then the options class for 
        the default optimization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be returned. 
                Possible values are: 'CollocationLagrangePolynomialsAlg'.
                Default: 'CollocationLagrangePolynomialsAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
        
    def _default_options(self, algorithm):
        """ 
        Help method. Gets the options class for the algorithm specified in 
        'algorithm'.
        """
        base_path = 'jmodelica.algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'algorithm_drivers')
        algorithm = getattr(algdrive, algorithm)
        return algorithm.get_default_options()
        
def package_unit(class_name, path='.', unit_type='JMU'):
    """
    Method that takes as input a class name and package all model related files 
    into a JMU or FMU depending on the parameter 'unit_type'.
    
    Parameters::
    
        class_name --
            The name of the model.
            
        path --
            The directory to compile to. Created if does not exist.
            Default: '.'
            
        unit_type --
            To package a JMU or FMU, set this parameter to 'JMU' or 'FMU' 
            respectively.
            Default: 'JMU'
    """
    if not os.path.isdir(path):
        os.mkdir(path)
        
    mName = class_name
    mMangledName = class_name.replace('.','_')
    
    #Look for operating system and architecture
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
    
    #Create the new archive
    if unit_type == 'JMU':
        file = zipfile.ZipFile(os.path.join(path, mMangledName+'.jmu'), 'w') 
    elif unit_type == 'FMU':
        file = zipfile.ZipFile(os.path.join(path, mMangledName+'.fmu'), 'w')
    else:
        raise Exception("The unit type %s is unknown" %unit_type)
        
    try:
        #Write the xml file
        file.write(mMangledName+'.xml', 'modelDescription.xml', 
            zipfile.ZIP_DEFLATED)
        #Write the .c file
        file.write(mMangledName+'.c','sources'+os.sep+mMangledName+'.c',
            zipfile.ZIP_DEFLATED)
        #Write the .mof file
        file.write(mName+'.mof','resources'+os.sep+mName+'.mof',
            zipfile.ZIP_DEFLATED)
        #Write the transformed .mof file
        file.write(
            mName+'_transformed.mof','resources'+os.sep+mName+'_transformed.mof',
            zipfile.ZIP_DEFLATED)
        #Write the parameter file
        file.write(
            mMangledName+'_values.xml','resources'+os.sep+mMangledName+'_values.xml',
            zipfile.ZIP_DEFLATED)
        #Write the binary
        file.write(
            mMangledName+suffix,'binaries'+os.sep+platform+os.sep+mMangledName+suffix, 
            zipfile.ZIP_DEFLATED)
    except OSError:
        raise JMIException('No such file or directory')
    finally:
        file.close()
    
    #Remove files
    try:
        os.remove(mMangledName+'.xml')        #XML
        os.remove(mMangledName+'.c')          #Source file
        os.remove(mName+'.mof')               #Mof file
        os.remove(mName+'_transformed.mof')   #Transformed mof file
        os.remove(mMangledName+'_values.xml') #XML
        os.remove(mMangledName+suffix)        #Binary
    except OSError, msg:
        logging.warning(msg)
    
def unzip_unit(archive, path='.'):
    """
    Unzip the FMU/JMU.
    """

    try:
        archive = zipfile.ZipFile(os.path.join(path,archive))
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
            
            # Creating temp file
            fhandle, tempxmlname = tempfile.mkstemp(suffix='.xml') 
            os.close(fhandle)
            # Writing to the temp file
            fout = open(tempxmlname, 'w') 
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
            
            # Creating temp file
            fhandle, tempxmlvaluesname = tempfile.mkstemp(suffix='.xml') 
            os.close(fhandle)
            # Writing to the temp file
            fout = open(tempxmlvaluesname, 'w') 
            fout.write(data)
            fout.close()
            is_jmu = True
            break
    # --
    
    #Extrating the binary
    
    found_files = [] #Found files

    # Looping over the archive to find correct binary
    for file in archive.filelist: 
        if dir[0] in file.filename and platform in file.filename and \
            file.filename.endswith(suffix): 
            # Binary directory found
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
            return [tempdllname.split(os.sep)[-1], \
                tempxmlname.split(os.sep)[-1], \
                modelname, tempxmlvaluesname.split(os.sep)[-1]]
        else:
            return [tempdllname.split(os.sep)[-1], \
                tempxmlname.split(os.sep)[-1], modelname]

    else:
        raise IOError('Could not find binaries for your platform.')
        
def get_unit_name(class_name, unit_type='JMU'):
    """
    Computes the unit name from a class name.
    
    Parameters::
        
        class_name -- 
            The name of the model.
            
        unit_type --
            The unit type, JMU or FMU.
            Default: 'JMU'
        
    Returns::
    
        The unit name (replaced dots with underscores).
    """
    if unit_type == 'JMU':
        return class_name.replace('.','_')+'.jmu' 
    elif unit_type == 'FMU':
        return class_name.replace('.','_')+'.fmu' 
    else:
        raise Exception("The unit type %s is unknown" %unit_type)

class Trajectory:
    """
    Base class for representation of trajectories.
    """
    
    def __init__(self, abscissa, ordinate):
        """
        Default constructor for creating a tracjectory object.

        Parameters::
        
            abscissa -- 
                One dimensional numpy array containing the n abscissa 
                (independent) values.
                
            ordinate -- 
                Two dimensional n x m numpy matrix containing the ordiate 
                values. The matrix has the same number of rows as the abscissa 
                has elements. The number of columns is equal to the number of
                output variables.
        """
        self._abscissa = abscissa
        self._ordinate = ordinate
        self._n = N.size(abscissa)
        self._x0 = abscissa[0]
        self._xf = abscissa[-1]

        if not N.all(N.diff(self.abscissa)>=0):
            raise Exception("The abscissa must be increasing.")

        small = 1e-8
        double_point_indices = N.nonzero(N.abs(N.diff(self.abscissa))<=small)
        for i in double_point_indices:
            self.abscissa[i+1] = self.abscissa[i+1] + small

    def eval(self,x):
        """
        Evaluate the trajectory at a specifed abscissa.

        Parameters::
        
            x -- 
                One dimensional numpy array, or scalar number, containing n 
                abscissa value(s).

        Returns::
        
            Two dimensional n x m matrix containing the ordinate values 
            corresponding to the argument x.
        """
        pass

    def _set_abscissa(self, absscissa):
        self._abscissa[:] = abscissa

    def _get_abscissa(self):
        return self._abscissa

    abscissa = property(_get_abscissa, _set_abscissa, doc=
    """
    Property for accessing the abscissa of the trajectory.
    """)

    def _set_ordinate(self, absscissa):
        self._ordinate[:] = ordinate

    def _get_ordinate(self):
        return self._ordinate

    ordinate = property(_get_ordinate, _set_ordinate, doc=
    """
    Property for accessing the ordinate of the trajectory.
    """)

class TrajectoryLinearInterpolation(Trajectory):

    def eval(self,x):
        """
        Evaluate the trajectory at a specifed abscissa.

        Parameters::
        
            x -- 
                One dimensional numpy array, or scalar number, containing n 
                abscissa value(s).

        Returns::
        
            Two dimensional n x m matrix containing the ordinate values 
            corresponding to the argument x.
        """        
        y = N.zeros([N.size(x),N.size(self.ordinate,1)])
        for i in range(N.size(y,1)):
            y[:,i] = N.interp(x,self.abscissa,self.ordinate[:,i])
        return y
