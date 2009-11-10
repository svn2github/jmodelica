

"""
Module for writing optimization and simulation results to file.
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


import numpy
import array
import scipy.io

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

        # Write names
        names = model.get_variable_names()
        name_value_refs = names.keys()
        name_value_refs.sort(key=int)

        num_vars = 0

        # Find the maximum name length
        max_name_length = len('Time')
        for ref in name_value_refs:
            if (len(names.get(ref))>max_name_length):
                max_name_length = len(names.get(ref))
            num_vars = num_vars + 1
            # Loop over the alias variables
            alias_names, alias_sign = model.get_aliases(names.get(ref))
            for n in alias_names:
                if (len(n)>max_name_length):
                    max_name_length = len(n)
                num_vars = num_vars + 1

        f.write('char name(%d,%d)\n' % (num_vars+1, max_name_length))
        f.write('time\n')

        for ref in name_value_refs:
            f.write(names.get(ref)+'\n')
            # Loop over the alias variables
            alias_names, alias_sign = model.get_aliases(names.get(ref))
            for n in alias_names:
                f.write(n+'\n')

        f.write('\n')

        # Write descriptions
        descriptions = model.get_variable_descriptions()
        desc_value_refs = descriptions.keys()
        desc_value_refs.sort(key=int)

        # Find the maximum description length
        max_desc_length = len('Time in [s]');
        for ref in name_value_refs:
            desc = model.get_variable_description(names.get(ref))
            if desc != None:
                if (len(desc)>max_desc_length):
                    max_desc_length = len(desc)
            # Loop over the alias variables
            alias_names, alias_sign = model.get_aliases(names.get(ref))
            for n in alias_names:
                desc = model.get_variable_description(n)
                if (desc!=None):
                    if (len(desc)>max_desc_length):
                        max_desc_length = len(desc)

        f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
        f.write('Time in [s]\n')

        # Loop over all variables, not only those with a description
        for ref in name_value_refs:
            desc = model.get_variable_description(names.get(ref))
            if desc != None:
                f.write(desc)
            f.write('\n')
            # Loop over the alias variables
            alias_names, alias_sign = model.get_aliases(names.get(ref))
            for n in alias_names:
                desc = model.get_variable_description(n)
                if desc != None:
                    f.write(desc)
                f.write('\n')
            
        f.write('\n')

        # Write data meta information
        offs = model.get_offsets()
        n_parameters = offs[4] # offs[4] = offs_dx
        f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
        f.write('0 1 0 -1 # time\n')

        cnt_1 = 2
        cnt_2 = 2
        for ref in name_value_refs:
            if int(ref)<n_parameters: # Put parameters in data set
                f.write('1 %d 0 -1 # ' % cnt_1 + names.get(ref)+'\n')
                cnt_1 = cnt_1 + 1
            else:
                f.write('2 %d 0 -1 # ' % cnt_2 + names.get(ref)+'\n')
                # Loop over the alias variables
                alias_names, alias_sign = model.get_aliases(names.get(ref))
                i = 0
                for n in alias_names:
                    if alias_sign[i]:
                        f.write('2 -%d 0 -1 # ' % cnt_2 + n +'\n')
                    else:
                        f.write('2 %d 0 -1 # ' % cnt_2 + n +'\n')
                    i = i + 1
                cnt_2 = cnt_2 + 1

        f.write('\n')
        # Write data

        # Write data set 1
        f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
        f.write("%12.12f" % data[0,0])
        for ref in range(n_parameters):
            f.write(" %12.12f" % model.get_z()[ref])
        f.write('\n')
        f.write("%12.12f" % data[-1,0])
        for ref in range(n_parameters):
            f.write(" %12.12f" % model.get_z()[ref])
        f.write('\n\n')

        # Write data set 2
        n_vars = len(data[0,:])
        n_points = len(data[:,0])
        f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
        for i in range(n_points):
            for ref in range(n_vars):
                f.write(" %12.12f" % data[i,ref])
            f.write('\n')

        f.write('\n')

        f.close()

    else:
        raise Error('Export on binary Dymola result files not yet supported.')


class Trajectory:
    """
    Class for storing a time series.
    """
    
    def __init__(self,t,x):
        """
        Constructor for the Trajectory class.

        Parameters:
            t --
                Abscissa of the trajectory.
            x --
                The ordinate of the trajectory.

        """
        self.t = t
        self.x = x

        
class ResultDymolaTextual:
    """ Class representing a simulation or optimization result loaded from a
    Dymola binary file.
    """

    def __init__(self,fname):
        """
        Load a result file written on Dymola textual format.

        Parameters:
            fname --
                Name of file.
        """
        fid = open(fname,'r')
        
        result  = [];
     
        # Read Aclass section
        l = fid.readline()
        tmp = l.partition('(')
        while tmp[0]!='char Aclass':
            l = fid.readline()
            tmp = l. partition('(')
        nLines = tmp[2].partition(',')
        nLines = int(nLines[0])
        Aclass = []
        for i in range(0,nLines):
            Aclass.append(fid.readline().strip())
        self.Aclass = Aclass

        # Read name section
        l = fid.readline()
        tmp = l.partition('(')
        while tmp[0]!='char name':
            l = fid.readline()
            tmp = l. partition('(')
        nLines = tmp[2].partition(',')
        nLines = int(nLines[0])
        name = []
        for i in range(0,nLines):
            name.append(fid.readline().strip())
        self.name = name
     
        # Read description section   
        l = fid.readline()
        tmp = l.partition('(')
        while tmp[0]!='char description':
            l = fid.readline()
            tmp = l. partition('(')
        nLines = tmp[2].partition(',')
        nLines = int(nLines[0])
        description = []
        for i in range(0,nLines):
            description.append(fid.readline().strip())
        self.description = description

        # Read dataInfo section
        l = fid.readline()
        tmp = l.partition('(')
        while tmp[0]!='int dataInfo':
            l = fid.readline()
            tmp = l. partition('(')
        nLines = tmp[2].partition(',')
        nCols = nLines[2].partition(')')
        nLines = int(nLines[0])
        nCols = int(nCols[0])
        dataInfo = []
        for i in range(0,nLines):
            info = fid.readline().split()
            dataInfo.append(map(int,info[0:nCols]))
        self.dataInfo = numpy.array(dataInfo)

        # Find out how many data matrices there are
        nData = 0
        for i in range(0,nLines):
            if dataInfo[i][0] > nData:
                nData = dataInfo[i][0]
                
        self.data = []
        for i in range(0,nData): 
            l = fid.readline()
            tmp = l.partition(' ')
            while tmp[0]!='float' and tmp[0]!='double':
                l = fid.readline()
                tmp = l. partition(' ')
            tmp = tmp[2].partition('(')
            nLines = tmp[2].partition(',')
            nCols = nLines[2].partition(')')
            nLines = int(nLines[0])
            nCols = int(nCols[0])
            data = []
            for i in range(0,nLines):
                info = []
                while len(info) < nCols:
                    l = fid.readline()
                    info.extend(l.split())
                data.append(map(float,info[0:nCols]))
                del(info)
            self.data.append(numpy.array(data))

    def get_variable_index(self,name): 
        """
        Retrieve the index in the name vector of a given variable.
        
        Parameters:
            name --
                Name of variable.
        
        Returns:
            In integer index.
        """
        try:
            return self.name.index(name)
        except ValueError, ex:
            raise VariableNotFoundError("Cannot find variable " +
                                        name + " in data file.")
            
    def get_variable_data(self,name):
        """
        Retrieve the data sequence for a variable with a given name.
        
        Parameters:
            name --
                Name of the variable.

        Returns:
            A Trajectory object containing the time vector and the data vector
            of the variable.
        """
        varInd  = self.get_variable_index(name)
        dataInd = self.dataInfo[varInd][1]
        factor = 1
        if dataInd<0:
            factor = -1
            dataInd = -dataInd -1
        else:
            dataInd = dataInd - 1
        dataMat = self.dataInfo[varInd][0]-1
        # Take into account that the 'Time' variable has data matrix index 0,
        # which means that it is
        if dataMat<0:
            dataMat = 0
        return Trajectory(self.data[dataMat][:,0],factor*self.data[dataMat][:,dataInd])
	
	
class ResultDymolaBinary:
    """ Class representing a simulation or optimization result loaded from a
    Dymola binary file.
    """

    def __init__(self,fname):
        """
        Load a result file written on Dymola binary format.

        Parameters:
            fname --
                Name of file.
        """
        self.raw = scipy.io.loadmat(fname,chars_as_strings=False)
        name = self.raw['name']
        self.name = [array.array('u',name[:,i].tolist()).tounicode().rstrip() for i in range(0,name[0,:].size)]
        description = self.raw['description']
        self.description = [array.array('u',description[:,i].tolist()).tounicode().rstrip() for i in range(0,description[0,:].size)]
	
    def get_variable_index(self,name): 
        """
        Retrieve the index in the name vector of a given variable.
        
        Parameters:
            name --
                Name of variable.

        Returns:
            In integer index.
        """
        try:
            return self.name.index(name)
        except ValueError, ex:
            raise VariableNotFoundError("Cannot find variable " +
                                        name + " in data file.")
       
	
    def get_variable_data(self,name):
        """
        Retrieve the data sequence for a variable with a given name.
        
        Parameters:
            name --
                Name of the variable.

        Returns:
            A Trajectory object containing the time vector and the data vector
            of the variable.
        """
        varInd  = self.get_variable_index(name)
        dataInd = self.raw['dataInfo'][1][varInd]
        dataMat = self.raw['dataInfo'][0][varInd]
        factor = 1
        if dataInd<0:
            factor = -1
            dataInd = -dataInd -1
        else:
            dataInd = dataInd - 1
        
        # Take into account that the 'Time' variable has data matrix index 0
            
        if dataMat<1:
            dataMat = 1
        return Trajectory(self.raw['data_%d'%dataMat][0,:],factor*self.raw['data_%d'%dataMat][dataInd,:])


class JIOError(Exception):
    
    """ Base class for exceptions specific to this module."""
    
    def __init__(self, message):
        """ Create new error with a specific message. """
        self.message = message
        
    def __str__(self):
        """ 
        Print error message when class instance is printed.
         
        Overrides the general-purpose special method such that a string 
        representation of an instance of this class will be the error message.
        
        """
        return self.message


class VariableNotFoundError(JIOError):
    """ Exception that is thrown when a variable is not found in a
    data file.
    """

    pass
