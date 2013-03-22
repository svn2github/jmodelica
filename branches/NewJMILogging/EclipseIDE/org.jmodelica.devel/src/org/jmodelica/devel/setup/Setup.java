package org.jmodelica.devel.setup;

import org.eclipse.core.resources.IFile;
import org.jmodelica.devel.launch.AntFile;

public class Setup {

	private static final String REPO_JM_ORG = "https://svn.jmodelica.org";
	
	private static final String MODELICA = "Modelica";
	private static final String OPTIMICA = "Optimica";

	private static final String TYPE_GEN = "java";
	private static final String TYPE_TEST = "test/junit";

	private static final String PATTERN_GEN_DIR = "Compiler/%sCompiler/src/%s-generated";
	private static final String PATTERN_GEN_CHECK = PATTERN_GEN_DIR + "/org/jmodelica/%s/compiler/ASTNode.java";	
	private static final String PATTERN_TEST_DIR = "Compiler/%sCompiler/src/%s-generated";
	private static final String PATTERN_TEST_CHECK = PATTERN_GEN_DIR + "/org/jmodelica/test/%s/junitgenerated/NameTests.java";	
	private static final String PATTERN_ANT_FILE = "Compiler/%sCompiler/build.xml";
	
	private static final String MODELICA_GENERATED_DIR = String.format(PATTERN_GEN_DIR, MODELICA, TYPE_GEN);
	private static final String MODELICA_TEST_DIR = String.format(PATTERN_GEN_DIR, MODELICA, TYPE_TEST);
	private static final String MODELICA_GEN_CHECK = String.format(PATTERN_GEN_CHECK, MODELICA, TYPE_GEN, MODELICA.toLowerCase());
	private static final String MODELICA_TEST_CHECK = String.format(PATTERN_TEST_CHECK, MODELICA, TYPE_TEST, MODELICA.toLowerCase());
	private static final AntFile MODELICA_GEN_ANT = new AntFile(String.format(PATTERN_ANT_FILE, MODELICA), MODELICA);
	
	private static final String OPTIMICA_GENERATED_DIR = String.format(PATTERN_GEN_DIR, OPTIMICA, TYPE_GEN);
	private static final String OPTIMICA_TEST_DIR = String.format(PATTERN_GEN_DIR, OPTIMICA, TYPE_TEST);
	private static final String OPTIMICA_GEN_CHECK = String.format(PATTERN_GEN_CHECK, OPTIMICA, TYPE_GEN, OPTIMICA.toLowerCase());
	private static final String OPTIMICA_TEST_CHECK = String.format(PATTERN_TEST_CHECK, OPTIMICA, TYPE_TEST, OPTIMICA.toLowerCase());
	private static final AntFile OPTIMICA_GEN_ANT = new AntFile(String.format(PATTERN_ANT_FILE, OPTIMICA), OPTIMICA);

	private static final FileDef MODELICA_COMPILER = 
			new FileDef(MODELICA_GEN_CHECK, new AntRunner(MODELICA_GEN_ANT, "gen", MODELICA_GENERATED_DIR, true));
	private static final FileDef MODELICA_TESTS = 
			new FileDef(MODELICA_TEST_CHECK, new AntRunner(MODELICA_GEN_ANT, "gen-test", MODELICA_TEST_DIR, true));
	private static final FileDef OPTIMICA_COMPILER = 
			new FileDef(OPTIMICA_GEN_CHECK, new AntRunner(OPTIMICA_GEN_ANT, "gen", OPTIMICA_GENERATED_DIR, true));
	private static final FileDef OPTIMICA_TESTS = 
			new FileDef(OPTIMICA_TEST_CHECK, new AntRunner(OPTIMICA_GEN_ANT, "gen-test", OPTIMICA_TEST_DIR, true));

	public static final ProjectDef JMODELICA_PROJ = new ProjectDef("JModelica", REPO_JM_ORG, "trunk", new FileDef[] {
		MODELICA_COMPILER, OPTIMICA_COMPILER, MODELICA_TESTS, OPTIMICA_TESTS
	});
	
	public static ProjectSet COMPILER = new ProjectSet(new ProjectDef[] { JMODELICA_PROJ });
	
}
