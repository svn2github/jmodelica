# -*- coding: utf-8 -*-
"""Module containing the FMI interface Python wrappers.
"""
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


import sys
import jmodelica.jmi
from jmodelica import xmlparser
import os
import tempfile
import ctypes as C
import numpy as N
from ctypes.util import find_library
import platform as PL
import numpy.ctypeslib as Nct
from zipfile import ZipFile
from lxml import etree
from operator import itemgetter



class FMIException(Exception):
    """A JMI exception."""
    pass


    
def unzip_FMU(archive, path='.'):
    """
    Unzip the FMU.
    """

    try:
        archive = ZipFile(os.path.join(path,archive))
    except IOError:
        raise FMIException('Could not locate the FMU.')
    
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
        raise FMIException('Could not find modelDescription.xml in the FMU.')
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
        
        return [tempdllname.split(os.sep)[-1], tempxmlname.split(os.sep)[-1], modelname]

    else:
        raise FMIException('Could not find binaries for your platform.')
        return False

class FMIModel(object):
    """
    A JMI Model loaded from a DLL.
    """
    
    def __init__(self, fmu, path='.'):
        """
        Contructor.
        """
                
        #Detect Platform
        platform = ''
        
        if sys.platform == 'win32':
            suffix = '.dll'
        elif sys.platform == 'darwin':
            suffix = '.dylib'
        else:
            suffix = '.so'

            
        #Create temp binary
        self._tempnames = unzip_FMU(archive=fmu, path=path)
        self._tempdll = self._tempnames[0]
        self._tempxml = self._tempnames[1]
        self._modelname = self._tempnames[2]
        self._tempdir = tempfile.gettempdir()
        
        #Retrieve and load the binary
        self._dll = jmodelica.jmi.load_DLL(self._tempdll[:-len(suffix)],self._tempdir)
        
        #Set FMIModel Typedefs
        self._set_fmimodel_typedefs()
        
        #Load calloc and free
        self._load_c()
        
        #Load XML file
        self._load_xml()
        
        #Instantiate
        self.instantiate_model()
        
        #Default values
        self.__t = None
        
        #Internal values
        self._file_open = False
        self._npoints = 0
    
    def _load_c(self):
        """
        Loads the C-library and the C-functions 'free' and 'calloc' to
        
            model._free
            model._calloc
        """
        c_lib = C.CDLL(find_library('c'))
        
        self._calloc = c_lib.calloc
        self._calloc.restype = C.c_void_p
        self._calloc.argtypes = [C.c_size_t, C.c_size_t]
        
        self._free = c_lib.free
        self._free.restype = None
        self._free.argtypes = [C.c_void_p]
        
    def _load_xml(self):
        """
        Loads the XML information.
        """
        self._md = xmlparser.ModelDescription(self._tempdir+os.sep+self._tempxml) 
        self._nContinuousStates = self._md.get_number_of_continuous_states()
        self._nEventIndicators = self._md.get_number_of_event_indicators()
        self._GUID = self._md.get_guid()
        self._description = self._md.get_description()
        
        def_experiment = self._md.get_default_experiment()
        if def_experiment != None:
            self._XMLStartTime = self._md.get_default_experiment().get_start_time()
            self._XMLStopTime = self._md.get_default_experiment().get_stop_time()
            self._XMLTolerance = self._md.get_default_experiment().get_tolerance()
            self._tolControlled = True
            
        else:
            self._XMLStartTime = 0.0
            self._XMLTolerance = 1.e-4
            self._tolControlled = False
        
        reals = self._md.get_all_real_variables()
        real_start_values = []
        real_keys = []
        real_names = []
        for real in reals:
            start= real.get_fundamental_type().get_start()
            if start != None:
                real_start_values.append(real.get_fundamental_type().get_start())
                real_keys.append(real.get_value_reference())
                real_names.append(real.get_name())

        self._XMLStartRealValues = N.array(real_start_values,dtype=N.double)
        self._XMLStartRealKeys =   N.array(real_keys,dtype=N.uint32)
        self._XMLStartRealNames =  N.array(real_names)
        
        ints = self._md.get_all_integer_variables()
        int_start_values = []
        int_keys = []
        int_names = []
        for int in ints:
            start = int.get_fundamental_type().get_start()
            if start != None:
                int_start_values.append(int.get_fundamental_type().get_start())
                int_keys.append(int.get_value_reference())
                int_names.append(int.get_name())

        self._XMLStartIntegerValues = N.array(int_start_values,dtype=N.int32)
        self._XMLStartIntegerKeys   = N.array(int_keys,dtype=N.uint32)
        self._XMLStartIntegerNames  = N.array(int_names)
        
        bools = self._md.get_all_boolean_variables()
        bool_start_values = []
        bool_keys = []
        bool_names = []
        for bool in bools:
            start = bool.get_fundamental_type().get_start()
            if start != None:
                bool_start_values.append(bool.get_fundamental_type().get_start())
                bool_keys.append(bool.get_value_reference())
                bool_names.append(bool.get_name())

        self._XMLStartBooleanValues = N.array(bool_start_values)
        self._XMLStartBooleanKeys   = N.array(bool_keys,dtype=N.uint32)
        self._XMLStartBooleanNames  = N.array(bool_names)
        
        strs = self._md.get_all_string_variables()
        str_start_values = []
        str_keys = []
        str_names = []
        for str in strs:
            start = str.get_fundamental_type().get_start()
            if start != '':
                str_start_values.append(str.get_fundamental_type().get_start())
                str_keys.append(str.get_value_reference())
                str_names.append(str.get_name())

        self._XMLStartStringValues = N.array(str_start_values)
        self._XMLStartStringKeys   = N.array(str_keys,dtype=N.uint32)
        self._XMLStartStringNames  = N.array(str_names)

        for i in xrange(len(self._XMLStartBooleanValues)):
            if self._XMLStartBooleanValues[i] == True:
                if self._md.is_negated_alias(self._XMLStartBooleanNames[i]):
                    self._XMLStartBooleanValues[i] = '0'
                else:
                    self._XMLStartBooleanValues[i] = '1'
            else:
                if self._md.is_negated_alias(self._XMLStartBooleanNames[i]):
                    self._XMLStartBooleanValues[i] = '1'
                else:
                    self._XMLStartBooleanValues[i] = '0'
                
        for i in xrange(len(self._XMLStartRealValues)):
            self._XMLStartRealValues[i] = -1*self._XMLStartRealValues[i] if self._md.is_negated_alias(self._XMLStartRealNames[i]) else self._XMLStartRealValues[i]
        
        for i in xrange(len(self._XMLStartIntegerValues)):
            self._XMLStartIntegerValues[i] = -1*self._XMLStartIntegerValues[i] if self._md.is_negated_alias(self._XMLStartIntegerNames[i]) else self._XMLStartIntegerValues[i]
        
        
        cont_name = []
        cont_valueref = []
        disc_name_r = []
        disc_valueref_r = []
 
        for real in reals:
            if real.get_variability() == xmlparser.CONTINUOUS and \
                real.get_alias() == xmlparser.NO_ALIAS:
                    cont_name.append(real.get_name())
                    cont_valueref.append(real.get_value_reference())
                
            elif real.get_variability() == xmlparser.DISCRETE and \
                real.get_alias() == xmlparser.NO_ALIAS:
                    disc_name_r.append(real.get_name())
                    disc_valueref_r.append(real.get_value_reference())
        
        disc_name_i = []
        disc_valueref_i = []
        for int in ints:
            if int.get_variability() == xmlparser.DISCRETE and \
                int.get_alias() == xmlparser.NO_ALIAS:
                    disc_name_i.append(int.get_name())
                    disc_valueref_i.append(int.get_value_reference())
                    
        disc_name_b = []
        disc_valueref_b =[]
        for bool in bools:
            if bool.get_variability() == xmlparser.DISCRETE and \
                bool.get_alias() == xmlparser.NO_ALIAS:
                    disc_name_b.append(bool.get_name())
                    disc_valueref_b.append(bool.get_value_reference())

        self._save_cont_valueref = [N.array(cont_valueref+disc_valueref_r,dtype=N.uint), disc_valueref_i, disc_valueref_b]
        self._save_cont_name = [cont_name+disc_name_r, disc_name_i, disc_name_b]
        self._save_nbr_points = 0
        
    def _set_fmimodel_typedefs(self):
        """
        Connects the FMU to Python by retrieving the C-function by use of ctypes. 
        """
        self._validplatforms = self._dll.__getattr__(self._modelname+'_fmiGetModelTypesPlatform')
        self._validplatforms.restype = C.c_char_p
    
        self._version = self._dll.__getattr__(self._modelname+'_fmiGetVersion')
        self._version.restype = C.c_char_p
        
        #Typedefs
        (self._fmiOK,
         self._fmiWarning,
         self._fmiDiscard,
         self._fmiError,
         self._fmiFatal) = map(C.c_int, xrange(5))
        self._fmiStatus = C.c_int
        
        self._fmiComponent = C.c_void_p
        self._fmiValueReference = C.c_uint32
        
        self._fmiReal = C.c_double
        self._fmiInteger = C.c_int32
        self._fmiBoolean = C.c_char
        self._fmiString = C.c_char_p
        self._PfmiString = C.POINTER(self._fmiString)
        
        #Defines
        self._fmiTrue = '\x01'
        self._fmiFalse = '\x00'
        self._fmiUndefinedValueReference = self._fmiValueReference(-1).value
        
        #Struct
        self._fmiCallbackLogger = C.CFUNCTYPE(None, self._fmiComponent, self._fmiString, self._fmiStatus, self._fmiString, self._fmiString)
        self._fmiCallbackAllocateMemory = C.CFUNCTYPE(C.c_void_p, C.c_size_t, C.c_size_t)
        self._fmiCallbackFreeMemory = C.CFUNCTYPE(None, C.c_void_p) 
        
        
        class fmiCallbackFunctions(C.Structure):
            _fields_ = [('logger', self._fmiCallbackLogger),
                        ('allocateMemory', self._fmiCallbackAllocateMemory),
                        ('freeMemory', self._fmiCallbackFreeMemory)]
        
        self._fmiCallbackFunctions = fmiCallbackFunctions
        
        class fmiEventInfo(C.Structure):
            _fields_ = [('iterationConverged', self._fmiBoolean),
                        ('stateValueReferencesChanged', self._fmiBoolean),
                        ('stateValuesChanged', self._fmiBoolean),
                        ('terminateSimulation', self._fmiBoolean),
                        ('upcomingTimeEvent',self._fmiBoolean),
                        ('nextEventTime', self._fmiReal)]
                        
        class pyEventInfo():
            pass
                        
        self._fmiEventInfo = fmiEventInfo
        self._pyEventInfo = pyEventInfo()
        
        #Methods
        self._fmiInstantiateModel = self._dll.__getattr__(self._modelname+'_fmiInstantiateModel')
        self._fmiInstantiateModel.restype = self._fmiComponent
        self._fmiInstantiateModel.argtypes = [self._fmiString, self._fmiString, self._fmiCallbackFunctions, self._fmiBoolean]
        
        self._fmiFreeModelInstance = self._dll.__getattr__(self._modelname+'_fmiFreeModelInstance')
        self._fmiFreeModelInstance.restype = C.c_void_p
        self._fmiFreeModelInstance.argtypes = [self._fmiComponent]
        
        self._fmiSetDebugLogging = self._dll.__getattr__(self._modelname+'_fmiSetDebugLogging')
        self._fmiSetDebugLogging.restype = C.c_int
        self._fmiSetDebugLogging.argtypes = [self._fmiComponent, self._fmiBoolean]
        
        self._fmiSetTime = self._dll.__getattr__(self._modelname+'_fmiSetTime')
        self._fmiSetTime.restype = C.c_int
        self._fmiSetTime.argtypes = [self._fmiComponent, self._fmiReal]
        
        self._fmiCompletedIntegratorStep = self._dll.__getattr__(self._modelname+'_fmiCompletedIntegratorStep')
        self._fmiCompletedIntegratorStep.restype = self._fmiStatus
        self._fmiCompletedIntegratorStep.argtypes = [self._fmiComponent, C.POINTER(self._fmiBoolean)]
        
        self._fmiInitialize = self._dll.__getattr__(self._modelname+'_fmiInitialize')
        self._fmiInitialize.restype = self._fmiStatus
        self._fmiInitialize.argtypes = [self._fmiComponent, self._fmiBoolean, self._fmiReal, C.POINTER(self._fmiEventInfo)]
        
        self._fmiTerminate = self._dll.__getattr__(self._modelname+'_fmiTerminate')
        self._fmiTerminate.restype = self._fmiStatus
        self._fmiTerminate.argtypes = [self._fmiComponent]
        
        self._fmiEventUpdate = self._dll.__getattr__(self._modelname+'_fmiEventUpdate')
        self._fmiEventUpdate.restype = self._fmiStatus
        self._fmiEventUpdate.argtypes = [self._fmiComponent, self._fmiBoolean, C.POINTER(self._fmiEventInfo)]
        
        self._fmiSetContinuousStates = self._dll.__getattr__(self._modelname+'_fmiSetContinuousStates')
        self._fmiSetContinuousStates.restype = self._fmiStatus
        self._fmiSetContinuousStates.argtypes = [self._fmiComponent, Nct.ndpointer() ,C.c_size_t]
        self._fmiGetContinuousStates = self._dll.__getattr__(self._modelname+'_fmiGetContinuousStates')
        self._fmiGetContinuousStates.restype = self._fmiStatus
        self._fmiGetContinuousStates.argtypes = [self._fmiComponent, Nct.ndpointer() ,C.c_size_t]
        
        self._fmiGetReal = self._dll.__getattr__(self._modelname+'_fmiGetReal')
        self._fmiGetReal.restype = self._fmiStatus
        self._fmiGetReal.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t, Nct.ndpointer()]
        self._fmiGetInteger = self._dll.__getattr__(self._modelname+'_fmiGetInteger')
        self._fmiGetInteger.restype = self._fmiStatus
        self._fmiGetInteger.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t, Nct.ndpointer()]
        self._fmiGetBoolean = self._dll.__getattr__(self._modelname+'_fmiGetBoolean')
        self._fmiGetBoolean.restype = self._fmiStatus
        self._fmiGetBoolean.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t, Nct.ndpointer()]
        self._fmiGetString = self._dll.__getattr__(self._modelname+'_fmiGetString')
        self._fmiGetString.restype = self._fmiStatus
        #self._fmiGetString.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t, Nct.ndpointer()]
        self._fmiGetString.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t, self._PfmiString]
        
        self._fmiSetReal = self._dll.__getattr__(self._modelname+'_fmiSetReal')
        self._fmiSetReal.restype = self._fmiStatus
        self._fmiSetReal.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t,Nct.ndpointer()]
        self._fmiSetInteger = self._dll.__getattr__(self._modelname+'_fmiSetInteger')
        self._fmiSetInteger.restype = self._fmiStatus
        self._fmiSetInteger.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t,Nct.ndpointer()]
        self._fmiSetBoolean = self._dll.__getattr__(self._modelname+'_fmiSetBoolean')
        self._fmiSetBoolean.restype = self._fmiStatus
        self._fmiSetBoolean.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t,Nct.ndpointer()]
        self._fmiSetString = self._dll.__getattr__(self._modelname+'_fmiSetString')
        self._fmiSetString.restype = self._fmiStatus
        self._fmiSetString.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t,self._PfmiString]
        
        self._fmiGetDerivatives = self._dll.__getattr__(self._modelname+'_fmiGetDerivatives')
        self._fmiGetDerivatives.restype = self._fmiStatus
        self._fmiGetDerivatives.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t]
        
        self._fmiGetEventIndicators = self._dll.__getattr__(self._modelname+'_fmiGetEventIndicators')
        self._fmiGetEventIndicators.restype = self._fmiStatus
        self._fmiGetEventIndicators.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t]
        
        self._fmiGetNominalContinuousStates = self._dll.__getattr__(self._modelname+'_fmiGetNominalContinuousStates')
        self._fmiGetNominalContinuousStates.restype = self._fmiStatus
        self._fmiGetNominalContinuousStates.argtypes = [self._fmiComponent, Nct.ndpointer(), C.c_size_t]
        
        self._fmiGetStateValueReferences = self._dll.__getattr__(self._modelname+'_fmiGetStateValueReferences')
        self._fmiGetStateValueReferences.restype = self._fmiStatus
        self._fmiGetStateValueReferences.argtypes = [self._fmiComponent, Nct.ndpointer(), C.c_size_t]
       
    def _get_time(self):
        """
        Sets/Gets the current time of the simulation.
        
            Parameters::
            
                time
                        - Sets the time.
                        
            Returns::
            
                time
                        - The current time.
        
        Calls the low-level FMI function: fmiSetTime.
        """
        return self.__t
    
    def _set_time(self, t):
        """
        Sets/Gets the current time of the simulation.
        
            Parameters::
            
                time
                        - Sets the time.
                        
            Returns::
            
                time
                        - The current time.
        
        Calls the low-level FMI function: fmiSetTime.
        """
        t = N.array(t)
        if t.size > 1:
            raise FMIException('Failed to set the time. The size of "t" is greater than one.')
        self.__t = t
        temp = self._fmiReal(t)
        self._fmiSetTime(self._model,temp)
        
    time = property(_get_time,_set_time)
    
    def _get_continuous_states(self):
        """
        Gets/Sets the continuous state vector.
        
            Parameters::
            
                values
                        - The new values of the continuous states.
            
            Returns::
            
                The current values of the continuous states.
                
        Calls the low-level FMI function: fmiSetContinuousStates/fmiGetContinuousStates
        """
        values = N.array([0.0]*self._nContinuousStates, dtype=N.double)
        status = self._fmiGetContinuousStates(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to retrieve the continuous states.')
        
        return values
        
    def _set_continuous_states(self, values):
        """
        Gets/Sets the continuous state vector.
        
            Parameters::
            
                values
                        - The new values of the continuous states.
            
            Returns::
            
                The current values of the continuous states.
                
        Calls the low-level FMI function: fmiSetContinuousStates/fmiGetContinuousStates
        """
        values = N.array(values)
        if values.size != self._nContinuousStates:
            raise FMIException('Failed to set the new continuous states. The number of values are not consistent' \
                                ' with the number of continuous states.')
        
        status = self._fmiSetContinuousStates(self._model, values, self._nContinuousStates)
        
        if status >= 3:
            raise FMIException('Failed to set the new continuous states.')
    
    continuous_states = property(_get_continuous_states, _set_continuous_states)
    
    def _get_nominal_continuous_states(self):
        """
        Returns the nominal values of the continuous states.
        
            Parameters::
            
                None
                
            Return::
            
                nomial    - The nominal values as an array.
                
            Example::
            
                nominal = model.nominal_continuous_states
                
        Calls the low-level FMI function: fmiGetNominalContinuousStates
        """
        values = N.array([0.0]*self._nContinuousStates,dtype=N.double)
        status = self._fmiGetNominalContinuousStates(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to get the nominal values.')
            
        return values
    
    nominal_continuous_states = property(_get_nominal_continuous_states)
    
    def get_derivatives(self):
        """
        Returns the derivative of the continuous states.
        
            Parameters::
            
                None
                
            Return::
            
                dx    - The derivative as an array.
                
            Example::
            
                dx = model.get_derivatives()
                
        Calls the low-level FMI function: fmiGetDerivatives
        """
        values = N.array([0.0]*self._nContinuousStates,dtype=N.double)
        status = self._fmiGetDerivatives(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to get the derivative values.')
            
        return values
        
    def get_event_indicators(self):
        """
        Returns the event indicators at the current time-point.
        
            Parameters::
            
                None
                
            Return::
            
                evInd   - The event indicators as an array.
                
            Example::
            
                evInd = model.get_event_indicators()
                
        Calls the low-level FMI function: fmiGetEventIndicators
        """
        values = N.array([0.0]*self._nEventIndicators,dtype=N.double)
        status = self._fmiGetEventIndicators(self._model, values, self._nEventIndicators)
        
        if status != 0:
            raise FMIException('Failed to get the event indicators.')
            
        return values

    
    def get_tolerances(self):
        """
        Returns the relative and absolute tolerances. If the relative tolerance
        is defined in the XML-file it is used, otherwise a default of 1.e-4 is 
        used. The absolute tolerance is calculated and returned according to
        the FMI specification, atol = 0.01*rtol*(nominal values of the continuous states)
        
            Parameters::
            
                None
                
            Return::
            
                rtol    - The relative tolerance.
                
                atol    - The absolute tolerance.
                
            Example::
            
                [rtol, atol] = model.get_tolerances()
        """
        rtol = self._XMLTolerance
        atol = 0.01*rtol*self.nominal_continuous_states
        
        return [rtol, atol]
    
    def event_update(self, intermediateResult='0'):
        """
        Updates the event information at the current time-point. If intermediateResult is
        set to '1' the update_event will stop at each event iteration which would require
        to loop until event_info.iterationConverged == fmiTrue.
        
            Parameters::
            
                intermediateResult  - Default '0'.
                
            Return::
            
                None
                
            Example::
            
                model.event_update()
        
        Calls the low-level FMI function: fmiEventUpdate
        """
        status = self._fmiEventUpdate(self._model, intermediateResult, C.byref(self._eventInfo))
        
        if status != 0:
            raise FMIException('Failed to update the events.')
    
    def save_time_point(self):
        """
        Retrieves the data at the current time-point of the variables defined
        to be continuous and the variables defined to be discrete. The information
        about the variables are retrieved from the XML-file.
        
            Parameters::
            
                None
                
            Return::
            
                sol_real    - The Real-valued variables.
                
                sol_int     - The Integer-valued variables.
                
                sol_bool    - The Boolean-valued variables.
                
            Example::
            
                [r,i,b] = model.save_time_point()
        """
        sol_real = self.get_real(self._save_cont_valueref[0])
        sol_int  = self.get_integer(self._save_cont_valueref[1])
        sol_bool = self.get_boolean(self._save_cont_valueref[2])
        
        return sol_real, sol_int, sol_bool
    
    def get_event_info(self):
        """
        Returns the event information from the FMU. The event information
        is a struct which contains,
        
            iterationConverged          - Event iteration converged (if True).
            stateValueReferencesChanged - ValueReferences of states x changed (if True).
            stateValuesChanged          - Values of states x have changed (if True).
            terminateSimulation         - Error, terminate simulation (if True).
            upcomingTimeEvent           - if True, nextEventTime is the next time event.
            nextEventTime               - The next time event.
        
            Parameters::
            
                None
                
            Return::
            
                eventInfo   - The eventInfo struct.
                
            Example::
            
                event_info    = model.event_info
                nextEventTime = model.event_info.nextEventTime
        
        """
        
        self._pyEventInfo.iterationConverged          = self._eventInfo.iterationConverged == self._fmiTrue
        self._pyEventInfo.stateValueReferencesChanged = self._eventInfo.stateValueReferencesChanged == self._fmiTrue
        self._pyEventInfo.stateValuesChanged          = self._eventInfo.stateValuesChanged == self._fmiTrue
        self._pyEventInfo.terminateSimulation         = self._eventInfo.terminateSimulation == self._fmiTrue
        self._pyEventInfo.upcomingTimeEvent           = self._eventInfo.upcomingTimeEvent == self._fmiTrue
        self._pyEventInfo.nextEventTime               = self._eventInfo.nextEventTime
        
        return self._pyEventInfo
    
    def get_state_value_references(self):
        """
        Returns the continuous states valuereferences.
        
            Parameters::
            
                None
                
            Return::
            
                val     - The references to the continuous states.
                
            Example::
            
            val = model.get_continuous_value_reference()
            
        Calls the low-level FMI function: fmiGetStateValueReferences
        """
        values = N.array([0]*self._nContinuousStates,dtype=N.uint32)
        status = self._fmiGetStateValueReferences(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to get the continuous state reference values.')
            
        return values
    
    def _get_version(self):
        """
        Returns the FMI version of the Model which it was generated according.
            
            Parameters::
            
                None
                
            Return::
            
                version   - The version.
                
            Example::
            
                model.version
        
        """
        return self._version()
        
    version = property(fget=_get_version)
    
    def _get_model_types_platform(self):
        """
        Returns the set of valid compatible platforms for the Model, extracted
        from the XML.
        
            Parameters::
            
                None
                
            Return::
            
                model_types_platform   - The valid platforms.
                
            Example::
            
                model.model_types_platform
        """
        return self._validplatforms()
        
    model_types_platform = property(fget=_get_model_types_platform)
    
    def get_ode_sizes(self):
        """
        Returns the number of continuous states and the number of
        event indicators.
        
            Parameters::
            
                None
                
            Return::
            
                nbr_cont    - The number of continuous states.
                
                nbr_ind     - The number of event indicators.
                
            Example::
            
                [nCont, nEvent] = model.get_ode_sizes()
        """
        return self._nContinuousStates, self._nEventIndicators
    
    def get_real(self, valueref):
        """
        Returns the real-values from the valuereference(s).
        
            Parameters::
            
                valueref    - A list of valuereferences.
                
            Return::
            
                values      - The values retrieved from the FMU.
                
            Example::
            
                val = model.get_real([232])
                
        Calls the low-level FMI function: fmiGetReal/fmiSetReal
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = len(valueref)
        values = N.array([0.0]*nref)
        
        status = self._fmiGetReal(self._model, valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to get the Real values.')
            
        return values
        
    def set_real(self, valueref, values):
        """
        Sets the real-values in the FMU as defined by the valuereference(s).
        
            Parameters::
                
                valueref    - A list of valuereferences.
                
                values      - Values to be set.
                
            Return::
                
                None
        
            Example::
            
                model.set_real([234,235],[2.34,10.4])
        
        Calls the low-level FMI function: fmiGetReal/fmiSetReal
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = valueref.size
        values = N.array(values)

        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')

        status = self._fmiSetReal(self._model,valueref, nref, values)

        if status != 0:
            raise FMIException('Failed to set the Real values.')
        
        
    def get_integer(self, valueref):
        """
        Returns the integer-values from the valuereference(s).
        
            Parameters::
            
                valueref    - A list of valuereferences.
                
            Return::
            
                values      - The values retrieved from the FMU.
                
            Example::
            
                val = model.get_integer([232])
                
        Calls the low-level FMI function: fmiGetInteger/fmiSetInteger
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = len(valueref)
        values = N.array([0]*nref)
        
        status = self._fmiGetInteger(self._model, valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to get the Integer values.')
            
        return values
        
    def set_integer(self, valueref, values):
        """
        Sets the integer-values in the FMU as defined by the valuereference(s).
        
            Parameters::
                
                valueref    - A list of valuereferences.
                
                values      - Values to be set.
                
            Return::
                
                None
        
            Example::
            
                model.set_integer([234,235],[12,-3])
        
        Calls the low-level FMI function: fmiGetInteger/fmiSetInteger
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = valueref.size
        values = N.array(values)
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')
        
        status = self._fmiSetInteger(self._model,valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to set the Integer values.')
        
        
    def get_boolean(self, valueref):
        """
        Returns the boolean-values from the valuereference(s).
        
            Parameters::
            
                valueref    - A list of valuereferences.
                
            Return::
            
                values      - The values retrieved from the FMU.
                
            Example::
            
                val = model.get_boolean([232])
                
        Calls the low-level FMI function: fmiGetBoolean/fmiSetBoolean
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = len(valueref)
        values = N.array(['0']*nref)
        
        status = self._fmiGetBoolean(self._model, valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to get the Boolean values.')
        
        bol = []
        for i in values:
            if i == self._fmiTrue:
                bol.append(True)
            else:
                bol.append(False)
        
        #if nref==1:
        #    bol = bol[0]
        
        return bol
        
    def set_boolean(self, valueref, values):
        """
        Sets the boolean-values in the FMU as defined by the valuereference(s).
        
            Parameters::
                
                valueref    - A list of valuereferences.
                
                values      - Values to be set.
                
            Return::
                
                None
        
            Example::
            
                model.set_boolean([234,235],[True,False])
        
        Calls the low-level FMI function: fmiGetBoolean/fmiSetBoolean
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = valueref.size
        values = N.array(values)
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')
        
        status = self._fmiSetBoolean(self._model,valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to set the Boolean values.')
        
    def get_string(self, valueref):
        """
        Returns the string-values from the valuereference(s).
        
            Parameters::
            
                valueref    - A list of valuereferences.
                
            Return::
            
                values      - The values retrieved from the FMU.
                
            Example::
            
                val = model.get_string([232])
                
        Calls the low-level FMI function: fmiGetString/fmiSetString
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = len(valueref)
        values = N.ndarray([])
        
        temp = (self._fmiString*nref)()
        
        status = self._fmiGetString(self._model, valueref, nref, temp)

        if status != 0:
            raise FMIException('Failed to set the String values.')
        
        return N.array(temp)[:]
    
    def set_string(self, valueref, values):
        """
        Sets the string-values in the FMU as defined by the valuereference(s).
        
            Parameters::
                
                valueref    - A list of valuereferences.
                
                values      - Values to be set.
                
            Return::
                
                None
        
            Example::
            
                model.set_string([234,235],['text','text'])
        
        Calls the low-level FMI function: fmiGetString/fmiSetString
        """
        valueref = N.array(valueref, dtype=N.uint32)
        nref = valueref.size
        values = N.array(values)
        
        temp = (self._fmiString*nref)()
        for i in range(nref):
            temp[i] = values[i]
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')

        status = self._fmiSetString(self._model, valueref, nref, temp)
        
        if status != 0:
            raise FMIException('Failed to set the String values.')
        
    def get_nominal(self, valueref):
        """
        Returns the nominal value from valueref.
        """
        values = self._xmldoc._xpatheval('//ScalarVariable/Real/@nominal[../../@valueReference=\''+valueref+'\']')
        
        if len(values) == 0:
            return 1.0
        else:
            return float(values[0])
    
    def completed_integrator_step(self):
        """
        This method must be called by the environment after every completed step of the 
        integrator. If the return is True, then the environment must call event_update()
        otherwise, no action is needed.
        
            Returns::
            
                True  -> Call event_update().
                False -> Do nothing.
                
        Calls the low-level FMI function: fmiCompletedIntegratorStep.
        """
        callEventUpdate = self._fmiBoolean(self._fmiFalse)
        status = self._fmiCompletedIntegratorStep(self._model, C.byref(callEventUpdate))
        
        if status != 0:
            raise FMIException('Failed to call FMI Completed Step.')
            
        if callEventUpdate.value == self._fmiTrue:
            return True
        else:
            return False
    
    def initialize(self):
        """
        Initializes the model and computes initial values for all variables, including
        setting the start values of variables defined with a the start attribute in the
        XML-file. 
        
            Returns::
            
                None
                
        Calls the low-level FMI function: fmiInitialize.
        """
        
        #Set the start attributes
        if len(self._XMLStartRealValues) > 0:
            self.set_real(self._XMLStartRealKeys, self._XMLStartRealValues)

        if len(self._XMLStartIntegerValues) > 0:
            self.set_integer(self._XMLStartIntegerKeys, self._XMLStartIntegerValues)

        if len(self._XMLStartBooleanValues) > 0:
            self.set_boolean(self._XMLStartBooleanKeys, self._XMLStartBooleanValues)

        if len(self._XMLStartStringValues) > 0:
            self.set_string(self._XMLStartStringKeys, self._XMLStartStringValues)

        #Trying to set the initial time from the xml file, else 0.0
        if self.time == None:
            self.time = self._XMLStartTime
        
        
        if self._tolControlled:
            tolcontrolled = self._fmiBoolean('1')
            tol = self._XMLTolerance
        else:
            tolcontrolled = self._fmiBoolean('0')
            tol = self._fmiReal(0.0)
        
        self._eventInfo = self._fmiEventInfo('0','0','0','0','0',self._fmiReal(0.0))
        
        status = self._fmiInitialize(self._model, tolcontrolled, tol, C.byref(self._eventInfo))
        
        if status > 0:
            raise FMIException('Failed to Initialize the model.')
    
    
    def instantiate_model(self, name='Model', logging='0'):
        """
        Instantiate the model.
        
            Parameters::
            
                name    
                        - The name of the instance.
                        - Default 'Model'
                        
                logging
                        - Defines if the logging should be turned on or off.
                        - Default '0', no logging.
                        
            Returns::
            
                None
                
        Calls the low-level FMI function: fmiInstantiateModel.
        """
        instance = self._fmiString(name)
        guid = self._fmiString(self._GUID)
        if logging == '0':
            logging = self._fmiBoolean(self._fmiFalse)
        else:
            logging = self._fmiBoolean(self._fmiTrue)
        
        functions = self._fmiCallbackFunctions()#(self._fmiCallbackLogger(self.fmiCallbackLogger),self._fmiCallbackAllocateMemory(self.fmiCallbackAllocateMemory), self._fmiCallbackFreeMemory(self.fmiCallbackFreeMemory))
        
        
        functions.logger = self._fmiCallbackLogger(self.fmiCallbackLogger)
        functions.allocateMemory = self._fmiCallbackAllocateMemory(self.fmiCallbackAllocateMemory)
        functions.freeMemory = self._fmiCallbackFreeMemory(self.fmiCallbackFreeMemory)
        
        self._model = self._fmiInstantiateModel(instance,guid,functions,logging)
        
    def fmiCallbackLogger(self,*args):
        print 'Logger'
        pass
    def fmiCallbackAllocateMemory(self, nobj, size):
        """
        Callback function for the FMU which allocates memory needed by the model.
        """
        return self._calloc(nobj,size)

    def fmiCallbackFreeMemory(self, obj):
        """
        Callback function for the FMU which deallocates memory allocated by fmiCallbackAllocateMemory
        """
        print 'Free'
        self._free(obj)
    
    #XML PART
    def get_variable_descriptions(self, include_alias=True):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Dict with ValueReference as key and description as value.
        """
        return self._md.get_variable_descriptions(include_alias)
        
    def get_data_type(self, variablename):
        """ Get data type of variable. """
        return self._md.get_data_type(variablename)
        
    def get_valueref(self, variablename=None, type=None):
        """
        Extract the ValueReference given a variable name.
        
        Parameters:
            variablename -- the name of the variable
            
        Returns:
            The ValueReference for the variable passed as argument.
        """
        if variablename != None:
            return self._md.get_value_reference(variablename)
        else:
            valrefs = []
            allvariables = self._md.get_model_variables()
            for variable in allvariables:
                if variable.get_variability() == type:
                    valrefs.append(variable.get_value_reference())
                    
        return N.array(valrefs,dtype=N.int)
    
    def get_variable_names(self, type=None, include_alias=True):
        """
        Extract the names of the variables in a model.

        Returns:
            Dict with variable name as key and value reference as value.
        """
        
        if type != None:
            variables = self._md.get_model_variables()
            names = []
            valuerefs = []
            if include_alias:
                for var in variables:
                    if var.get_variability()==type:
                        names.append(var.get_name())
                        valuerefs.append(var.get_value_reference())
                return zip(tuple(vrefs), tuple(names))
            else:
                for var in variables: 
                    if var.get_variability()==type and \
                        var.get_alias() == xmlparser.NO_ALIAS:
                            names.append(var.get_name())
                            valuerefs.append(var.get_value_reference())
                return zip(tuple(vrefs), tuple(names))
        else:
            return self._md.get_variable_names(include_alias)
    
    def get_alias_for_variable(self, aliased_variable, ignore_cache=False):
        """ Return list of all alias variables belonging to the aliased 
            variable along with a list of booleans indicating whether the 
            alias variable should be negated or not.
            
            Raises exception if argument is not in model.

            Returns:
                A list consisting of the alias variable names and another
                list consisting of booleans indicating if the corresponding
                alias is negated.

        """
        return self._md.get_aliases_for_variable(aliased_variable)
    
    def get_variable_aliases(self):
        return self._md.get_variable_aliases()
    
    def get_name(self):
        """ Return the name of the model. """
        return self._modelname
    
    def __del__(self):
        """
        Destructor.
        """
        import os
        import sys
        
        #Deallocate the models allocation
        self._fmiTerminate(self._model)
        
        #--ERROR
        if sys.platform == 'win32':
            pass
            #try:
            #    self._fmiFreeModelInstance(self._model)
            #except WindowsError:
            #    print 'Failed to free model instance.'
        else:
            pass
            #self._fmiFreeModelInstance(self._model)
           
        #Remove the temporary xml
        os.remove(self._tempdir+os.sep+self._tempxml)
        #Remove the temporary binary
        try:
            os.remove(self._tempdir+os.sep+self._tempdll)
        except:
            print 'Failed to remove temporary dll ('+ self._tempdll+').'
