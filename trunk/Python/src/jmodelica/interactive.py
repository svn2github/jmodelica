import jpype
    
def initSession(path_to_jmodelica_jar):
    vm_arg = '-Djava.ext.dirs=%s' % path_to_jmodelica_jar
    jpype.startJVM(jpype.getDefaultJVMPath(),vm_arg)
    
def loadFile(fileName):
    org = jpype.JPackage('org')
    sourceRoot = org.jmodelica.interactive.Interactive.loadFile(fileName)
    return sourceRoot
 

    

