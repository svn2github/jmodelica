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

flatRoot = org.jmodelica.ast.FlatRoot();
flatRoot.setFileName(mo_file);
flatModel = org.jmodelica.ast.FClass();
flatRoot.setFClass(flatModel);
ir = modelInstance.findFlattenInst('ConnectTests.CircuitTest1',flatModel);

flatString = flatModel.prettyPrint("")
print(flatString)