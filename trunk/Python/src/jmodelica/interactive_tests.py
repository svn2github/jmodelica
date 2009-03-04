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


import jmodelica.interactive 
import jpype

jmodelica_jar = """C:\\Documents and Settings\\johan_013\\My Documents\\projects\\JModelica\\trunk\\JModelica\\bin"""

def test_startSession():
    jmodelica.interactive.initSession(jmodelica_jar)
    print("""Session started...""")
        
mo_file =  """C:\\Documents and Settings\\johan_013\\My Documents\\projects\\JModelica\\trunk\\JModelica\\src\\test\\modelica\\ConnectTests.mo"""

def test_loadFile():
    sourceRoot = jmodelica.interactive.loadFile(mo_file)    
    return sourceRoot

org = jpype.JPackage('org')

test_startSession()
sourceRoot = test_loadFile()

# Get the root node in the instance tree
modelInstance = sourceRoot.getProgram().getInstProgramRoot();
modelInstance.dumpTree("")

# Create a flat class to use in the flattening algorithm
flatRoot = org.jmodelica.ast.FlatRoot();
flatRoot.setFileName(mo_file);
flatModel = org.jmodelica.ast.FClass();
flatRoot.setFClass(flatModel);
# Flatten the model
ir = modelInstance.findFlattenInst('ConnectTests.CircuitTest1',flatModel);

# Pretty print the flat model
flatString = flatModel.prettyPrint("")
print(flatString)
