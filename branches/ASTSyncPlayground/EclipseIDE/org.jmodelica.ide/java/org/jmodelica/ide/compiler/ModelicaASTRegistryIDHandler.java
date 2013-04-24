package org.jmodelica.ide.compiler;

public class ModelicaASTRegistryIDHandler {
	private static ModelicaASTRegistryIDHandler instance;
	private int graphicalEditorID = 0;
	private int outlineID = 0;
	private int changeSetID = 0;

	private ModelicaASTRegistryIDHandler() {
	}

	public static synchronized ModelicaASTRegistryIDHandler getInstance() {
		if (instance == null)
			instance = new ModelicaASTRegistryIDHandler();
		return instance;
	}

	public synchronized int getOutlineID() {
		outlineID++;
		return outlineID;
	}

	public synchronized int getGraphicalEditorID() {
		graphicalEditorID++;
		return graphicalEditorID;
	}
	
	public synchronized int getChangeSetID(){
		changeSetID++;
		return changeSetID;
	}
}
