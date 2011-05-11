package org.jmodelica.icons.test;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;

public abstract class ModelicaFileFinder {
	public ModelicaFileFinder() {
		
	}
	
	private static final FileFilter MODELICA_FILE_FILTER = new ModelicaFileFilter(); 
	
	public static String[] getFiles(String rootStr) {
		ArrayList<File> files = getFiles(new File(rootStr));
		String[] fileStrs = new String[files.size()];
		for (int i = 0; i < files.size(); i++) {
			fileStrs[i] = files.get(i).toString();
		}
		return fileStrs;
	}
	
	private static ArrayList<File> getFiles(File dir) {
		ArrayList<File> files = new ArrayList<File>();
		
		for (File f : dir.listFiles(MODELICA_FILE_FILTER)) {
			files.add(f);
		}
		
		for (File f : dir.listFiles()) {
			if (f.isDirectory()) {
				files.addAll(getFiles(f));
			}
		}
		
		return files;
	}
}