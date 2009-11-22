#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Contains code used for simulation of models.

This currently only includes an interface to SUNDIALS.
"""
__all__ = ['sundials']

import jmodelica.io as io
import numpy as np

class SimulationException(Exception):
    """ A simulation exception. """
    pass

class Simulator(object):
    """An object oriented interface for simulating JModelica.org models."""
    
    def __init__(self, model=None, start_time=None, final_time=None,
                 abstol=1.0e-6, reltol=1.0e-6, time_step=0.2, return_last=False, 
                 verbosity=0):
        
        # Setting members
        self._model = model
        
        # Setting defaults
        self.set_return_last(return_last)
        self.set_time_step(time_step)
        self.set_verbosity(verbosity)
        self.set_absolute_tolerance(abstol)
        self.set_relative_tolerance(reltol)
        self._set_solution(None, None)
        
        if start_time is not None:
            self._start_time = start_time
        else:
            self._start_time = None
        if final_time is not None:
            self._final_time = final_time
        else:
            self._final_time = None
            
        if self._final_time is not None and self._start_time is not None and \
            self._start_time > self._final_time:
                raise SimulationException('Start time must be before '
                                                 'end time.')
        
                
                     
    def set_time_step(self, time_step):
        """Sets the time step returned by self.get_solution()."""
        if time_step <= 0:
            raise SimulationException("Time step size must be "
                                              "positive.")
        self._time_step = time_step
        
    def get_time_step(self):
        """Returns the time step returned by self.get_solution()."""
        return self._time_step
        
    time_step = property(get_time_step, set_time_step, 
                         doc="The time step size when SUNDIALS should return.")
    
    
    def set_model(self, model):
        """Set the model on which the simulation should be done on.
        
        The model needs to be of type jmodelica.jmi.Model.
        """
        if model is None:
            raise SimulationException("model must not be none")
            
        if self.get_sensitivity_analysis():
            # A new model will require a new sensivity indices class will have
            # to be reinitialized.
            self._set_sensitivity_indices(_SensivityIndices(model))
            
        self._model = model
        
    def get_model(self):
        """Returns the model on which the simulation is being done."""
        return self._model
        
    model = property(get_model, set_model, doc="The model to simulate.")
    
    def set_return_last(self, return_last):
        """Set this to True if only the last time point should be returned
           after simulation by self.get_solution(). False otherwise.
        """
        if return_last==1 or return_last==True:
            self._return_last = True
        elif return_last==0 or return_last==False:
            self._return_last = False
        else:
            raise SimulationException("return_last must be either "
                                              "True, False, 1 or 0.")
                                              
    def get_return_last(self):
        """Returns True if only the last time point should be returned
           after simulation by self.get_solution(), False otherwise.
        """
        return self._return_last
        
    return_last = property(get_return_last, set_return_last,
                           doc="True if only the last time point should be "
                               "returned after simulation by "
                               "self.get_solution(). False otherwise.")
     
    def get_start_time(self):
        """Returns the simulation start time"""
        return self._start_time
        
    def get_final_time(self):
        """Returns the simulation end time"""
        return self._final_time
        
    def get_solution(self):
        """Return the solution calculated by run().
        
        The solution consists of a tuple (T, Y) where T are the time samples
        and Y contains all the equivalent state samples, one per row.
        """
        return self._T, self._Y
        
    def _set_solution(self, T, Y):
        """Internal function used by run().
        
        Setter for self.get_solution().
        """
        self._T = T
        self._Y = Y
    
    def set_relative_tolerance(self, reltol):
        """Set the positive relative tolerance for simulation.
        
        Currently only a single scalar used for all states is supported. 
        
        This function will raise an exception if the tolerance is not positive.
        
        See the SUNDIALS documentation for more information.
        """
        if reltol <= 0:
            raise SimulationException("Relative tolerance must be "
                                      "positive.")
        self._reltol = reltol
        
    def get_relative_tolerance(self):
        """Return the relative tolerance set for this simulator.
        
        See the SUNDIALS documentation for more information.
        """
        return self._reltol
        
    reltol = property(get_relative_tolerance, set_relative_tolerance,
                      doc="The relative tolerance.")
        
        
    
    
    def set_absolute_tolerance(self, abstol):
        """Set the positive absolute tolerance for simulation.
        
        Currently only a single scalar used for all states is supported.
        
        This function will raise an exception if the tolerance is not positive. 
        
        See the SUNDIALS documentation for more information.
        """
        if abstol <= 0:
            raise SimulationException("Absolute tolerance must be "
                                      "positive.")
        self._abstol = abstol
        
    def get_absolute_tolerance(self):
        """Return the absolute tolerance set for this simulator.
        
        See the SUNDIALS documentation for more information.
        """
        return self._abstol
        
    abstol = property(get_absolute_tolerance, set_absolute_tolerance,
                      doc="The absolute tolerance.")
     
    def set_simulation_interval(self, start_time, final_time):
        """Set the interval through the simulation will be made."""
        if start_time >= final_time:
            raise SimulationException("Start time must be earlier "
                                              "than the final time.")
        self._start_time = start_time
        self._final_time = final_time
        
    def get_simulation_interval(self):
        """Return the simulation interval.
        
        The simulation interval consists of a tuple: (start_time, final_time).
        """
        return self._start_time, self._final_time
     
    # Verbosity levels
    QUIET = 0
    WHISPER = 1
    NORMAL = 2
    LOUD = 3
    SCREAM = 4
    VERBOSE_VALUES = [QUIET, WHISPER, NORMAL, LOUD, SCREAM]
    def get_verbosity(self):
        """Return the verbosity of the simulator."""
        return self._verbosity
        
    def set_verbosity(self, verbosity):
        """Specify how much output should be given: 0 <= verbosity <= 4.
        
        The verbosity levels can also be specified using the constants:
         * Simulator.QUIET
         * Simulator.WHISPER
         * Simulator.NORMAL
         * Simulator.LOUD
         * Simulator.SCREAM
         
        If the verbosity level is set to something not within the interval, an
        error is raised.
        """
        if verbosity not in self.VERBOSE_VALUES:
            raise SimulationException("invalid verbosity value")
        self._verbosity = verbosity
        
    verbosity = property(get_verbosity, set_verbosity,
                         doc="How explicit the output should be")
    
        
    def write_data(self):
        
        t, y = self.get_solution()
        # extends the time array with the states columnwise
        data = np.c_[t,y]
        io.export_result_dymola(self.get_model(),data)
        
        

class ODESimulator(Simulator):
    
    def __init__(self, model=None, start_time=None,final_time=None,
                    abstol=1.0e-6, reltol=1.0e-6, time_step=0.2, return_last=False, 
                    verbosity=0):
        
        Simulator.__init__(self, model, start_time, final_time,
                           abstol, reltol, time_step, return_last, 
                           verbosity)
    
class DAESimulator(Simulator):
    
    def __init__(self, model=None, start_time=None,final_time=None,
                    abstol=1.0e-6, reltol=1.0e-6, time_step=0.2, return_last=False, 
                    verbosity=0):
    
        Simulator.__init__(self, model, start_time, final_time,
                           abstol, reltol, time_step, return_last, 
                           verbosity)
                           
