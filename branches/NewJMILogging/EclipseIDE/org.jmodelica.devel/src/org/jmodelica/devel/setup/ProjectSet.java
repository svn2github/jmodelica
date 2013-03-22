package org.jmodelica.devel.setup;

public class ProjectSet {
	
	private ProjectDef[] proj;
	
	public ProjectSet(ProjectDef[] projects) {
		proj = projects;
	}
	
	public boolean checkSetup() {
		for (ProjectDef p : proj)
			if (!p.checkSetup())
				return false;
		return true;
	}
	
	public void ensureSetup() {
		for (ProjectDef p : proj)
			p.ensureSetup();
	}

}
