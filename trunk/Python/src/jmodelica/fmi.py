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
import jmodelica.xmlparser
import os
import tempfile
import ctypes as C
import numpy as N
from ctypes.util import find_library
import numpy.ctypeslib as Nct
from zipfile import ZipFile
from lxml import etree
from operator import itemgetter



class FMIException(Exception):
    """A JMI exception."""
    pass


    
def unzip_FMU(archive, platform='win32', path='.'):
    """
    Unzip the FMU.
    """
    
    try:
        archive = ZipFile(path+os.sep+archive)
    except IOError:
        raise FMIException('Could not locate the FMU.')
    
    dir = ['binaries','sources']
    
    if platform == 'win32' or platform == 'win64':
        suffix = '.dll'
    elif platform == 'linux32' or platform == 'linux64':
        suffix = '.so'
    else: 
        suffix = '.dylib'
    
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
            platform = 'win32'
        else:
            raise FMIException('Unsupported platform.')
            
        #Create temp binary
        self._tempnames = unzip_FMU(archive=fmu, path=path, platform=platform)
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
        self.instantiate()
        
        #Default values
        self.__t = None
        
        self._res_t = N.array([])
        self._res_r = N.array([])
        self._res_i = N.array([])
        self._res_b = []
    
    def _load_c(self):
        """
        Loads the c library.
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
        self._xmldoc = jmodelica.xmlparser.XMLDoc(self._tempdir+os.sep+self._tempxml)
        
        self._nContinuousStates = int(self._xmldoc._xpatheval('//fmiModelDescription/@numberOfContinuousStates')[0])
        self._nEventIndicators = int(self._xmldoc._xpatheval('//fmiModelDescription/@numberOfEventIndicators')[0])
        self._GUID = self._xmldoc._xpatheval('//fmiModelDescription/@guid')[0]
        try:
            self._description = self._xmldoc._xpatheval('//fmiModelDescription/@description')[0]
        except IndexError:
            self._description = ''
        
        self._XMLStartTime = N.array(self._xmldoc._xpatheval('//DefaultExperiment/@startTime'),dtype=N.double)
        self._XMLStopTime = N.array(self._xmldoc._xpatheval('//DefaultExperiment/@stopTime'),dtype=N.double)
        self._XMLTolerance = N.array(self._xmldoc._xpatheval('//DefaultExperiment/@tolerance'),dtype=N.double)
        
        #if self._XMLStartTime.size > 0:
        #    self._XMLStartTime = self._XMLStartTime[0]
        if self._XMLStopTime.size > 0:
            self._XMLStopTime = self._XMLStopTime[0]
        
        self._XMLStartRealValues = N.array(self._xmldoc._xpatheval('//ScalarVariable/Real/@start'),dtype=N.double)
        self._XMLStartRealKeys = N.array(self._xmldoc._xpatheval('//ScalarVariable/@valueReference[../Real/@start]'),dtype=N.uint)
        self._XMLStartIntegerValues = N.array(self._xmldoc._xpatheval('//ScalarVariable/Integer/@start'),dtype=N.int)
        self._XMLStartIntegerKeys = N.array(self._xmldoc._xpatheval('//ScalarVariable/@valueReference[../Integer/@start]'),dtype=N.uint)
        self._XMLStartBooleanValues = N.array(self._xmldoc._xpatheval('//ScalarVariable/Boolean/@start'))
        self._XMLStartBooleanKeys = N.array(self._xmldoc._xpatheval('//ScalarVariable/@valueReference[../Boolean/@start]'),dtype=N.uint)
        self._XMLStartStringValues = N.array(self._xmldoc._xpatheval('//ScalarVariable/String/@start'))
        self._XMLStartStringKeys = N.array(self._xmldoc._xpatheval('//ScalarVariable/@valueReference[../String/@start]'),dtype=N.uint)
        
        for i in xrange(len(self._XMLStartBooleanValues)):
            if self._XMLStartBooleanValues[i] == 'true':
                self._XMLStartBooleanValues[i] = '1'
            else:
                self._XMLStartBooleanValues[i] = '0'
                
        cont_name = self._xmldoc._xpatheval("//ScalarVariable/@name[../Real][not(../@variability='constant')][not(../@variability='parameter')][not(../@variability='discrete')][not(../@alias)]")
        cont_valueref = self._xmldoc._xpatheval("//ScalarVariable/@valueReference[../Real][not(../@variability='constant')][not(../@variability='parameter')][not(../@variability='discrete')][not(../@alias)]")
        
        disc_name_r = self._xmldoc._xpatheval("//ScalarVariable/@name[../@variability='discrete'][not(../@alias)][../Real]")
        disc_valueref_r = self._xmldoc._xpatheval("//ScalarVariable/@valueReference[../@variability='discrete'][not(../@alias)][../Real]")
        disc_name_i = self._xmldoc._xpatheval("//ScalarVariable/@name[../@variability='discrete'][not(../@alias)][../Integer]")
        disc_valueref_i = N.array(self._xmldoc._xpatheval("//ScalarVariable/@valueReference[../@variability='discrete'][not(../@alias)][../Integer]"),dtype=N.uint)
        disc_name_b = self._xmldoc._xpatheval("//ScalarVariable/@name[../@variability='discrete'][not(../@alias)][../Boolean]")
        disc_valueref_b = N.array(self._xmldoc._xpatheval("//ScalarVariable/@valueReference[../@variability='discrete'][not(../@alias)][../Boolean]"),dtype=N.uint)

        self._save_cont_valueref = [N.array(cont_valueref+disc_valueref_r,dtype=N.uint), disc_valueref_i, disc_valueref_b]
        self._save_cont_name = [cont_name+disc_name_r, disc_name_i, disc_name_b]
        self._save_nbr_points = 0
        
    def _set_fmimodel_typedefs(self):
        """ 
        Type c-functions from FMI used by FMIModel.
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
        self._fmiValueReference = C.c_uint
        
        self._fmiReal = C.c_double
        self._fmiInteger = C.c_int
        self._fmiBoolean = C.c_char
        self._fmiString = C.c_char_p
        
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
                        
        self._fmiEventInfo = fmiEventInfo
        
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
        self._fmiGetString.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t, Nct.ndpointer()]
        
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
        self._fmiSetString.argtypes = [self._fmiComponent, Nct.ndpointer(),C.c_size_t,Nct.ndpointer()]
        
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
       
    def get_t(self):
        """
        Returns the time.
        """
        return self.__t
    
    def set_t(self, t):
        """
        Sets the time.
        """
        self.__t = t
        temp = self._fmiReal(t)
        self._fmiSetTime(self._model,temp)
        
    t = property(get_t,set_t)
    
    def get_cont_state(self):
        """
        Returns the continuous state.
        """
        values = N.array([0.0]*self._nContinuousStates, dtype=N.double)
        status = self._fmiGetContinuousStates(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to retrieve the continuous states.')
        
        return values
        
    def set_cont_state(self, values):
        """
        Sets the continuous state.
        """
        status = self._fmiSetContinuousStates(self._model, values, self._nContinuousStates)
        
        if status >= 3:
            raise FMIException('Failed to set the new continuous states.')
    
    real_x = property(get_cont_state, set_cont_state)
    
    def get_nominal(self):
        """
        Returns the nominal values.
        """
        values = N.array([0.0]*self._nContinuousStates,dtype=N.double)
        status = self._fmiGetNominalContinuousStates(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to get the nominal values.')
            
        return values
    
    real_x_nominal = property(get_nominal)
    
    def get_dx(self):
        """
        Returns the derivative.
        """
        values = N.array([0.0]*self._nContinuousStates,dtype=N.double)
        status = self._fmiGetDerivatives(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to get the derivative values.')
            
        return values
        
    real_dx = property(get_dx)
        
    def get_event_indicators(self):
        """
        Returns the event indicators.
        """
        values = N.array([0.0]*self._nEventIndicators,dtype=N.double)
        status = self._fmiGetEventIndicators(self._model, values, self._nEventIndicators)
        
        if status != 0:
            raise FMIException('Failed to get the event indicators.')
            
        return values
        
    event_ind = property(get_event_indicators)
    
    def get_tolerances(self):
        """
        Returns the tolerances.
        """
        if len(self._XMLTolerance) == 0:
            rtol = 1.e-4 #Default tolerance 10^-4
        else:
            rtol = self._XMLTolerance[0]
        atol = 0.01*rtol*self.real_x_nominal
        
        return [rtol, atol]
    
    def update_event(self, intermediateResult='1'):
        """
        Updates the event information.
        """
        status = self._fmiEventUpdate(self._model, intermediateResult, C.byref(self._eventInfo))
        
        if status != 0:
            raise FMIException('Failed to update the events.')
    
    def save_time_point(self):
        """
        Saves data for the specific time point.
        """
        sol_real = self.get_fmiReal(self._save_cont_valueref[0])
        sol_int  = self.get_fmiInteger(self._save_cont_valueref[1])
        sol_bool = self.get_fmiBoolean(self._save_cont_valueref[2])
        
        return sol_real, sol_int, sol_bool
    
    def get_event_info(self):
        """
        Returns the event info.
        """
        return self._eventInfo
    
    event_info = property(get_event_info)
    
    def get_continuous_value_reference(self):
        """
        Returns the continuous states value reference.
        """
        values = N.array([0]*self._nContinuousStates,dtype=N.uint)
        status = self._fmiGetStateValueReferences(self._model, values, self._nContinuousStates)
        
        if status != 0:
            raise FMIException('Failed to get the continuous state reference values.')
            
        return values
    
    def get_version(self):
        """
        Returns the FMI version of the Model.
        """
        return self._version()
        
    version = property(fget=get_version)
    
    def get_validplatforms(self):
        """
        Returns the set of valid compatible platforms for the Model.
        """
        return self._validplatforms()
        
    valid_platforms = property(fget=get_validplatforms)
    
    def get_ode_sizes(self):
        """
        Returns the number of continuous states and the number of
        event indicators.
        """
        return self._nContinuousStates, self._nEventIndicators
    
    def get_fmiReal(self, valueref):
        """
        Returns the fmiReal values from the value reference
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = len(valueref)
        values = N.array([0.0]*nref)
        
        status = self._fmiGetReal(self._model, valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to get the Real values.')
            
        return values
        
    def set_fmiReal(self, valueref, values):
        """
        Sets the values of parameters identified by valueref with the 'values'.
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = valueref.size
        values = N.array(values)
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')
        
        status = self._fmiSetReal(self._model,valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to set the Real values.')
        
        
        
    def get_fmiInteger(self, valueref):
        """
        Returns the fmiInteger values from the value reference
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = len(valueref)
        values = N.array([0]*nref)
        
        status = self._fmiGetInteger(self._model, valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to get the Integer values.')
            
        return values
        
    def set_fmiInteger(self, valueref, values):
        """
        Sets the values of parameters identified by valueref with the 'values'.
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = valueref.size
        values = N.array(values)
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')
        
        status = self._fmiSetInteger(self._model,valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to set the Integer values.')
        
        
    def get_fmiBoolean(self, valueref):
        """
        Returns the fmiBoolean values from the value reference
        """
        valueref = N.array(valueref, dtype=N.uint)
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
        
        if nref==1:
            bol = bol[0]
        
        return bol
        
    def set_fmiBoolean(self, valueref, values):
        """
        Sets the values of parameters identified by valueref with the 'values'.
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = valueref.size
        values = N.array(values)
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')
        
        status = self._fmiSetBoolean(self._model,valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to set the Boolean values.')
        
    def get_fmiString(self, valueref):
        """
        Returns the fmiString values from the value reference
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = len(valueref)
        values = N.array(['str']*nref)
        
        status = self._fmiGetString(self._model, valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to get the String values.')
            
        return values
    
    def set_fmiString(self, valueref, values):
        """
        Sets the values of parameters identified by valueref with the 'values'.
        """
        valueref = N.array(valueref, dtype=N.uint)
        nref = valueref.size
        values = N.array(values)
        
        if valueref.size != values.size:
            raise FMIException('The length of valueref and values are inconsistent.')
        
        status = self._fmiSetString(self._model,valueref, nref, values)
        
        if status != 0:
            raise FMIException('Failed to set the String values.')
        
    def get_fmiNominal(self, valueref):
        """
        Returns the nominal value from valueref.
        """
        values = self._xmldoc._xpatheval('//ScalarVariable/Real/@nominal[../../@valueReference=\''+valueref+'\']')
        
        if len(values) == 0:
            return 1.0
        else:
            return float(values[0])
    
    def fmiCompletedIntegratorStep(self):
        """
        Call the internal FMI function: fmiCompletedIntegratorStep.
        """
        callEventUpdate = self._fmiBoolean('0')
        status = self._fmiCompletedIntegratorStep(self._model, C.byref(callEventUpdate))
        
        if status != 0:
            raise FMIException('Failed to call FMI Completed Step.')
            
        if callEventUpdate.value == self._fmiTrue:
            return True
        else:
            return False
    
    def initialize(self):
        """
        Initialize the model.
        """
        #Set the start attributes
        if len(self._XMLStartRealValues) > 0:
            self.set_fmiReal(self._XMLStartRealKeys, self._XMLStartRealValues)

        if len(self._XMLStartIntegerValues) > 0:
            self.set_fmiInteger(self._XMLStartIntegerKeys, self._XMLStartIntegerValues)

        if len(self._XMLStartBooleanValues) > 0:
            self.set_fmiBoolean(self._XMLStartBooleanKeys, self._XMLStartBooleanValues)

        if len(self._XMLStartStringValues) > 0:
            self.set_fmiString(self._XMLStartStringKeys, self._XMLStartStringValues)

        #Trying to set the initial time from the xml file, else 0.0
        if self.t == None:
            try:
                self.t = self._XMLStartTime[0]
            except IndexError:
                self.t = 0.0
        
        
        if len(self._XMLTolerance) == 0:
            tolcontrolled = self._fmiBoolean('0')
            tol = self._fmiReal(0.0)
        else:
            tolcontrolled = self._fmiBoolean('1')
            tol = self._XMLTolerance[0]
        
        self._eventInfo = self._fmiEventInfo('0','0','0','0','0',self._fmiReal(0.0))
        
        status = self._fmiInitialize(self._model, tolcontrolled, tol, C.byref(self._eventInfo))
        
        if status > 0:
            raise FMIException('Failed to Initialize the model.')
    
    
    def instantiate(self, name='Model', logging='0'):
        """
        Instantiate the model.
        """
        instance = self._fmiString(name)
        guid = self._fmiString(self._GUID)
        logging = self._fmiBoolean(logging)
        
        functions = self._fmiCallbackFunctions#(self._fmiCallbackLogger(self.fmiCallbackLogger),self._fmiCallbackAllocateMemory(self.fmiCallbackAllocateMemory), self._fmiCallbackFreeMemory(self.fmiCallbackFreeMemory))
        
        
        functions.logger = self.fmiCallbackLogger
        functions.allocateMemory = self.fmiCallbackAllocateMemory
        functions.freeMemory = self.fmiCallbackFreeMemory
        
        
        self._model = self._fmiInstantiateModel(instance,guid,functions,logging)
        
    def fmiCallbackLogger(self,*args):
        print 'Logger'
        pass
    def fmiCallbackAllocateMemory(self, nobj, size):
        return self._calloc(nobj,size)

    def fmiCallbackFreeMemory(self, obj):
        print 'Free'
        self._free(obj)
        
    
    #XML PART
    def get_variable_descriptions(self, include_alias=True):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Dict with ValueReference as key and description as value.
        """
        return self._xmldoc.get_variable_descriptions(include_alias)
        
    def get_data_type(self, variablename):
        """ Get data type of variable. """
        return self._xmldoc.get_data_type(variablename)
        
    def get_valueref(self, variablename=None, type=None):
        """
        Extract the ValueReference given a variable name.
        
        Parameters:
            variablename -- the name of the variable
            
        Returns:
            The ValueReference for the variable passed as argument.
        """
        if variablename:
            return self._xmldoc.get_valueref(variablename)
        else:
            return N.array(self._xmldoc._xpatheval("//ScalarVariable/@valueReference[../@variability='"+type+"']"),dtype=N.int)
    
    def get_variable_type_names(self, type):
        """
        Extract the names of the variables in a model depending on the type.
        """
        keys = []
        vals = []
        for i in type:
            keys=keys+self._xmldoc._xpatheval("//ScalarVariable/@name[not(../@alias)][not(../Enumeration)][not(../String)][../@variability='"+i+"']")
            vals=vals+self._xmldoc._xpatheval("//ScalarVariable/@valueReference[not(../@alias)][not(../Enumeration)][not(../String)][../@variability='"+i+"']")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))           
        
        d={}
        for index, key in enumerate(keys):
            d[str(key)]=int(vals[index])
        return d
        
    
    def get_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the variables in a model.

        Returns:
            Dict with variable name as key and value reference as value.
        """
        if not ignore_cache:
            return self._xmldoc.function_cache.get(self,'get_variable_names',include_alias)
        
        if include_alias:
            keys = self._xmldoc._xpatheval("//ScalarVariable/@name[not(../Enumeration)][not(../String)]")
            vals = self._xmldoc._xpatheval("//ScalarVariable/@valueReference[not(../Enumeration)][not(../String)]")
        else:
            keys = self._xmldoc._xpatheval("//ScalarVariable/@name[not(../@alias)][not(../Enumeration)][not(../String)]")
            vals = self._xmldoc._xpatheval("//ScalarVariable/@valueReference[not(../@alias)][not(../Enumeration)][not(../String)]")        

   
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))           
        
        d={}
        for index, key in enumerate(keys):
            d[str(key)]=int(vals[index])
        return d
    
    def get_aliases(self, aliased_variable):
        """ Return list of all alias variables belonging to the aliased 
            variable along with a list of booleans indicating whether the 
            alias variable should be negated or not.
            
            Raises exception if argument is not in model.

            Returns:
                A list consisting of the alias variable names and another
                list consisting of booleans indicating if the corresponding
                alias is negated.

        """
        # get value reference of aliased variable
        val_ref = self.get_valueref(aliased_variable)
        if val_ref!=None:
            aliases = self._xmldoc._xpatheval("//ScalarVariable/@name[../@alias]\
                [../@valueReference=\""+str(val_ref)+"\"]")
            aliasnames=[]
            isnegated=[]
            for index, alias in enumerate(aliases):
                if str(aliased_variable)!=str(alias):
                    aliasnames.append(str(alias))
                    aliasvalue = self._xmldoc._xpatheval("//ScalarVariable/@alias[../@name=\""+str(alias)+"\"]")
                    isnegated.append(str(aliasvalue[0])=="negatedAlias")
            return aliasnames, isnegated
        else:
            raise Exception("The variable: "+str(aliased_variable)+" can not be found in model.")
    
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
        #if sys.platform == 'win32':
        #    try:
        #        self._fmiFreeModelInstance(self._model)
        #    except WindowsError:
        #        print 'Failed to free model instance.'
        #else:
        #    self._fmiFreeModelInstance(self._model)
            
        #Remove the temporary xml
        os.remove(self._tempdir+os.sep+self._tempxml)
        #Remove the temporary binary
        try:
            os.remove(self._tempdir+os.sep+self._tempdll)
        except:
            print 'Failed to remove temporary dll ('+ self._tempdll+').'


def export_result_dymola(model, data, file_name='', format='txt'):
    """
    Export an optimization or simulation result to file in Dymolas
    result file format. The parameter values are read from the z
    vector of the model object and the time series are read from
    the data argument.

    Parameters:
        model --
            A Model object.
        data --
            A two dimensional array of variable trajectory data. The
            first column represents the time vector. The following
            colums contain, in order, the derivatives, the states,
            the inputs and the algebraic variables. The ordering is
            according to increasing value references.
        file_name --
            If no file name is given, the name of the model (as defined
            by JMIModel.get_name()) concatenated with the string
            '_result' is used. A file suffix equal to the format
            argument is then appended to the file name.
        format --
            A text string equal either to 'txt' for textual format or
            'mat' for binary Matlab format.

    Limitations:
        Currently only textual format is supported.

    """

    if (format=='txt'):

        if file_name=='':
            file_name=model.get_name() + '_result.txt'

        # Open file
        f = open(file_name,'w')

        # Write header
        f.write('#1\n')
        f.write('char Aclass(3,11)\n')
        f.write('Atrajectory\n')
        f.write('1.1\n')
        f.write('\n')

        # Write names and create dicts that will be used later
        # dicts:
        # names_without_alias: dict with {variablename:valueref}
        # alias_names_ref: dict with {aliasname:valueref}
        # alias_names_sign: dict with {aliasname:sign}
        
        names_without_alias = model.get_variable_names(include_alias=False)
        alias_names_ref = {}
        alias_names_sign = {}
        # sort in value reference order
        sorted_names = sorted(names_without_alias.items(),key=itemgetter(1))
        all_names=[]
        all_names_without_alias = []
        for n in sorted_names:
            # add variable name to list
            all_names.append(n[0])
            all_names_without_alias.append(n[0])
            # add alias variables
            alias_names, alias_sign = model.get_aliases(n[0])
            for i, an in enumerate(alias_names):
                alias_names_ref[an] = n[1]
                alias_names_sign[an] = alias_sign[i]
                all_names.append(an)
                
        num_vars = 0

        # Find the maximum name length
        max_name_length = len('Time')
        for name in all_names:
            if (len(name)>max_name_length):
                max_name_length = len(name)
            num_vars = num_vars + 1

        f.write('char name(%d,%d)\n' % (num_vars+1, max_name_length))
        f.write('time\n')

        for name in all_names:
            f.write(name +'\n')

        f.write('\n')

        # Write descriptions       
        descriptions = model.get_variable_descriptions()
        desc_names = descriptions.keys()

        # Find the maximum description length
        max_desc_length = len('Time in [s]');
        for name in desc_names:
            desc = descriptions.get(name)
            if desc != None:
                if (len(desc)>max_desc_length):
                    max_desc_length = len(desc)

        f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
        f.write('Time in [s]\n')

        # Loop over all variables, not only those with a description
        for name in all_names:
            desc = descriptions.get(name)
            if desc != None:
                f.write(desc)
            f.write('\n')            
        f.write('\n')

        # Write data meta information
        
        f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
        f.write('0 1 0 -1 # time\n')
        
        
        #Get Parameters and Constants
        params_without_alias = model.get_variable_type_names(['constant','parameter'])
        params_names_ref = {}
        params_names_sign = {}
        # sort in value reference order
        params_sorted_names = sorted(params_without_alias.items(),key=itemgetter(1))
        params_names=[]
        params_names_without_alias = []
        for n in params_sorted_names:
            # add variable name to list
            params_names.append(n[0])
            params_names_without_alias.append(n[0])
            """
            # add alias variables
            alias_names, alias_sign = model.get_aliases(n[0])
            for i, an in enumerate(alias_names):
                params_names_ref[an] = n[1]
                params_names_sign[an] = alias_sign[i]
                params_names.append(an)
            """

        n_parameters = len(params_names_without_alias)
        
        list_of_continuous_states = N.append(model._save_cont_valueref[0],model._save_cont_valueref[1])
        list_of_continuous_states = N.append(list_of_continuous_states, model._save_cont_valueref[2]).tolist()
        valueref_of_continuous_states = []
        
        cnt_1 = 2
        cnt_2 = 2
        for name in all_names_without_alias:
            ref = N.uint(model.get_valueref(name))
            if name in params_names_without_alias: # Put parameters in data set
                f.write('1 %d 0 -1 # ' % cnt_1 + name+'\n')                
                # find out if variable has aliases
                aliases = [item[0] for item in alias_names_ref.items() if item[1] == ref]
                # loop through aliases and set sign
                for alias in aliases:
                    if alias_names_sign.get(alias):
                        f.write('1 -%d 0 -1 # ' % cnt_1 + alias +'\n')
                    else:
                        f.write('1 %d 0 -1 # ' % cnt_1 + alias +'\n')               
                cnt_1 = cnt_1 + 1
            else:
                valueref_of_continuous_states.append(list_of_continuous_states.index(ref))
                f.write('2 %d 0 -1 # ' % cnt_2 + name +'\n')
                # find out if variable has aliases
                aliases = [item[0] for item in alias_names_ref.items() if item[1] == ref]
                # loop through aliases and set sign
                for alias in aliases:
                    if alias_names_sign.get(alias):
                        f.write('2 -%d 0 -1 # ' % cnt_2 + alias +'\n')
                    else:
                        f.write('2 %d 0 -1 # ' % cnt_2 + alias +'\n')
                cnt_2 = cnt_2 + 1
        f.write('\n')

        # Write data
        # Write data set 1
        f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
        f.write("%12.12f" % data[0,0])
        str_text = ''
        for name in all_names_without_alias:
            ref = model.get_valueref(name)
            if name in params_names_without_alias: # Put parameters in data set
                datatype = model.get_data_type(name)
                if datatype == 'Real':
                    str_text = str_text + (" %12.12f" % (model.get_fmiReal([ref])))
                if datatype == 'Integer':
                    str_text = str_text + (" %12.12f" % (model.get_fmiInteger([ref])))
                if datatype == 'Boolean':
                    str_text = str_text + (" %12.12f" % (float(model.get_fmiBoolean([ref]))))
        f.write(str_text)
        f.write('\n')
        f.write("%12.12f" % data[-1,0])
        f.write(str_text)
        """
        for name in all_names_without_alias:
            ref = model.get_valueref(name)
            if name in params_names_without_alias: # Put parameters in data set
                datatype = model.get_data_type(name)
                if datatype == 'Real':
                    f.write(" %12.12f" % (model.get_fmiReal([ref])*model.get_fmiNominal(str(ref))))
                if datatype == 'Integer':
                    f.write(" %12.12f" % (model.get_fmiInteger([ref])))
                if datatype == 'Boolean':
                    f.write(" %12.12f" % (float(model.get_fmiBoolean([ref]))))
        """
        f.write('\n\n')
        
        n_vars = len(data[0,:])
        n_points = len(data[:,0])
        f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
       
        for i in range(n_points):
            str_text = (" %12.12f" % data[i,0])
            for j in range(n_vars-1):
                str_text = str_text + (" %12.12f" % (data[i,1+valueref_of_continuous_states[j]]))#*model.get_fmiNominal(str(list_of_continuous_states[valueref_of_continuous_states[j]]))))
            f.write(str_text+'\n')
        f.write('\n')
        f.close()

    else:
        raise Error('Export on binary Dymola result files not yet supported.')
