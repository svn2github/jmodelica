

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


def export_result_dymola(jmi_model, data, file_name='', format='txt'):
    """
    Export an optimization or simulation result to file in Dymolas
    result file format. The parameter values are read from the z
    vector of the jmi_model object and the time series are read from
    the data argument.

    Parameters:
        jmi_model --
            A JMIModel object.
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
            file_name=jmi_model.get_name() + '_result.txt'
        
        # Open file
        f = open(file_name,'w')
        
        # Write header
        f.write('#1\n')
        f.write('char Aclass(3,11)\n')
        f.write('Atrajectory\n')
        f.write('1.1\n')
        f.write('\n')

        # Write names
        names = jmi_model.get_variable_names()
        name_value_refs = names.keys()
        name_value_refs.sort(key=int)

        # Find the maximum name length
        max_name_length = len('Time')
        for ref in name_value_refs:
            if (len(names.get(ref))>max_name_length):
                max_name_length = len(names.get(ref))
                
        f.write('char name(%d,%d)\n' % (len(name_value_refs)+1, max_name_length))
        f.write('time\n')

        for ref in name_value_refs:
            f.write(names.get(ref)+'\n')

        f.write('\n')
        
        # Write descriptions
        descriptions = jmi_model.get_variable_descriptions()
        desc_value_refs = descriptions.keys()
        desc_value_refs.sort(key=int)

        # Find the maximum description length
        max_desc_length = len('Time in [s]');
        for ref in desc_value_refs:
            if (len(descriptions.get(ref))>max_desc_length):
                max_desc_length = len(descriptions.get(ref))
               
        f.write('char description(%d,%d)\n' % (len(name_value_refs)+1, max_desc_length))
        f.write('Time in [s]')
        
        # Loop over all variables, not only those with a description
        for ref in name_value_refs:
            if (desc_value_refs.count(ref)==0):
                f.write('\n')
            else:
                f.write(descriptions.get(ref)+'\n')

        f.write('\n')

        # Write data meta information
        offs = jmi_model.get_offsets()
        n_parameters = offs[4] # offs[4] = offs_dx
        f.write('int dataInfo(%d,%d)\n' % (len(name_value_refs)+1, 4))
        f.write('0 1 0 -1 # time\n')

        cnt_1 = 2
        cnt_2 = 2
        for ref in name_value_refs:
            if int(ref)<n_parameters: # Put parameters in data set
                f.write('1 %d 0 -1 # ' % cnt_1 + names.get(ref)+'\n')
                cnt_1 = cnt_1 + 1
            else:
                f.write('2 %d 0 -1 # ' % cnt_2 + names.get(ref)+'\n')
                cnt_2 = cnt_2 + 1

        f.write('\n')
        # Write data

        # Write data set 1
        f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
        f.write("%12.12f" % data[0,0])
        for ref in range(n_parameters):
            f.write(" %12.12f" % jmi_model.getZ()[ref])
        f.write('\n')
        f.write("%12.12f" % data[-1,0])
        for ref in range(n_parameters):
            f.write(" %12.12f" % jmi_model.getZ()[ref])
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
            
