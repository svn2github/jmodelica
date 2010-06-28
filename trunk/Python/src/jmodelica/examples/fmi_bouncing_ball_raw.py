import pylab as P
import numpy as N
import os as O
from jmodelica.fmi import FMIModel

curr_dir = O.path.dirname(O.path.abspath(__file__));
path_to_fmus = O.path.join(curr_dir, 'files', 'FMUs')

def run_demo(with_plots=True):
    """
    This example shows how to use the raw (JModelica.org) FMI interface for
    simulation of an FMU.
    
    FMU = bouncingBall.fmu (Generated using Qtronic FMU SDK (http://www.qtronic.de/en/fmusdk.html) )
    
    This example is written similair to the example in the documentation of the 'Functional Mock-up Interface
    for Model Exchange' version 1.0 (http://www.functional-mockup-interface.org/) 
    """
    
    #Load the FMU by specifying the fmu and the directory
    bouncing_fmu = FMIModel('bouncingBall.fmu',path_to_fmus)

    Tstart = 0.5 #The start time.
    Tend   = 3.0 #The final simulation time.
    
    bouncing_fmu.t = Tstart #Set the start time before the initialization.
    
    bouncing_fmu.initialize() #Initialize the model. Also sets all the start attributes
                              #defined in the XML file.
                              
    #Get Continuous States
    x = bouncing_fmu.real_x
    #Get the Nominal Values
    x_nominal = bouncing_fmu.real_x_nominal
    #Get the Event Indicators
    event_ind = bouncing_fmu.event_ind
    
    #For retrieving the solutions use,
    #bouncing_fmu.get_fmiReal,get_fmiInteger,get_fmiBoolean,get_fmiString (valueref)
    
    #Values for the solution
    t_sol = [Tstart]
    h_sol = [bouncing_fmu.get_fmiReal([0])]
    
    #Main integration loop.
    time = Tstart
    Tnext = Tend #Used for time events
    dt = 0.01 #Step-size
    
    while time < Tend and not bouncing_fmu.event_info.terminateSimulation:
        
        #Compute the derivative
        dx = bouncing_fmu.real_dx
        
        #Advance
        h = min(dt, Tnext-time)
        time = time + h
        
        #Set the time
        bouncing_fmu.t = time
        
        #Set the inputs at the current time (if any)
        #bouncing_fmu.set_fmiReal,set_fmiInteger,set_fmiBoolean,set_fmiString (valueref, values)
        
        #Set the states at t = time (Perform the step)
        x = x + h*dx
        bouncing_fmu.real_x = x
        
        #Get the event indicators at t = time
        event_ind_new = bouncing_fmu.event_ind
        
        #Inform the model about an accepted step
        EventUpdate = bouncing_fmu.fmiCompletedIntegratorStep()
        
        #Check for time and state events
        time_event  = abs(time-Tnext) <= 1.e-10
        state_event = True if event_ind_new[0]*event_ind <= 0.0 else False 
        
        #Event handling
        if EventUpdate or time_event or state_event:
            
            eInfo = bouncing_fmu.event_info
            eInfo.iterationConverged = False
            
            #Event iteration
            while eInfo.iterationConverged == False:
                bouncing_fmu.update_event()
                eInfo = bouncing_fmu.event_info

                #Retrieve solutions (if needed)
                if eInfo.iterationConverged == False:
                    #bouncing_fmu.get_fmiReal,get_fmiInteger,get_fmiBoolean,get_fmiString (valueref)
                    pass
            
            #Check if the event affected the state values and if so sets them
            if eInfo.stateValuesChanged:
                x = bouncing_fmu.real_x
        
            #Get new nominal values.
            if eInfo.stateValueReferencesChanged:
                #atol = 0.01*rtol*bouncing_fmu.real_x_nominal
                pass
                
            #Check for new time event
            if eInfo.upcomingTimeEvent:
                Tnext = min(eInfo.nextEventTime, Tend)
            else:
                Tnext = Tend
        
        event_ind = event_ind_new
        
        #Retrieve solutions at t=time for outputs
        #bouncing_fmu.get_fmiReal,get_fmiInteger,get_fmiBoolean,get_fmiString (valueref)
        
        t_sol += [time]
        h_sol += [bouncing_fmu.get_fmiReal([0])]
    
    
    #Plot the solution
    P.plot(t_sol,h_sol)
    P.title(bouncing_fmu.get_name())
    P.xlabel('Height (m)')
    P.ylabel('Time (s)')
    P.show()

if __name__ == "__main__":
    run_demo()
