package org.jmodelica.ide.compiler;

import java.io.File;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.preferences.Preferences;
import org.jmodelica.modelica.compiler.LibraryList;
import org.jmodelica.modelica.compiler.LibraryList.LibraryDef;
import org.jmodelica.util.ModelicaLogger;
import org.jmodelica.util.OptionRegistry;

public class IDELibraryList extends LibraryList {

	private Set<LibraryDef> loadedSet;
	private boolean loadAll;
	private IProject project;

	public IDELibraryList(OptionRegistry options, IProject project) {
		super(options);
		loadedSet = new HashSet<LibraryDef>();
		this.project = project;
	}

//	public Set<LibraryDef> loadedLibraries() {
//		search();
//		return loadedSet;
//	}
	
	public void load(LibraryDef def) {
		loadedSet.add(def);
	}
	
	public void unload(LibraryDef def) {
		loadedSet.remove(def);
	}

	public void reset() {
		super.reset();
		loadedSet.clear();
	}

	protected void search() {
		if (set.isEmpty()) {
			super.search();
			loadAll = true;
			addFromOption("PACKAGEPATHS", false);
			loadAll = false;
			String toLoadString = Preferences.get(project, IDEConstants.PREFERENCE_LIBRARIES_ID);
			String[] toLoad = toLoadString.split(File.pathSeparator);
			// TODO: Load all in toLoad
		}
	}

	protected void add(LibraryDef def) {
		super.add(def);
		if (def != null && loadAll)
			loadedSet.add(def);
	}

}
