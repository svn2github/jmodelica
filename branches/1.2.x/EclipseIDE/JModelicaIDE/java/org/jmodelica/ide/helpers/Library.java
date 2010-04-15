/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.helpers;

import java.io.File;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.jmodelica.ide.IDEConstants;

public class Library {

    public static final String PART_SEPARATOR = File.pathSeparator;
	public static final String LIBRARY_SEPARATOR = "|";
	
	public String name;
	public Version version;
	public String path;

	public Library(String str) {
		String[] arr = Util.explode(PART_SEPARATOR, str);
		name = arr[0];
		version = new Version(arr[1]);
		path = arr[2];
	}

	public Library() {
	}

	public String toString() {
		return 
		    Util.implode(
		        PART_SEPARATOR, 
		        new String[] { name, version.toString(), path });
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Library) {
			Library lib = (Library) obj;
			return name.equals(lib.name) && version.equals(lib.version);
		}
		return false;
	}
	
	public boolean isOK() {
		return !name.equals("");
	}

	public static String toString(List<Library> libs) {
		
	    if (libs == null)
			return "";
		
		return Util.implode(
		    LIBRARY_SEPARATOR,
		    libs);
	}
	
	public static List<Library> fromString(String str) {
		if (str == null) 
			return new ArrayList<Library>();
		String[] arr = Util.explode(LIBRARY_SEPARATOR, str);
		ArrayList<Library> res = new ArrayList<Library>(arr.length);
		try {
			for (int i = 0; i < arr.length; i++) {
				res.add(new Library(arr[i]));
			}
		} catch (ArrayIndexOutOfBoundsException e) {
			return new ArrayList<Library>();
		}
		return res;
	}
	
	public static class Version implements Comparable<Version> {
		private int[] num;
		private String sub;
		private String str;
		
		public Version(String string) {
			char first = string.length() > 0 ? string.charAt(0) : ' ';
			if (first >= '0' && first <= '9') {
				String[] arr = string.split(" ", 2);
				if (arr.length > 1)
					sub = arr[1];
				arr = arr[0].split("\\.");
				num = new int[arr.length];
				for (int i = 0; i < arr.length; i++)
					num[i] = Integer.parseInt(arr[i]);
			} else {
				num = new int[0];
				sub = string;
			}
			str = string;
		}
		
		@Override
		public String toString() {
			return str;
		}

		public int compareTo(Version v) {
			int res = 0, n = Math.max(num.length, v.num.length);
			for (int i = 0; res == 0 && i < n; i++) {
				int v1 = i < num.length ? num[i] : 0;
				int v2 = i < v.num.length ? v.num[i] : 0;
				res = v1 - v2;
			}
			if (res == 0) {
				if (sub != null) {
					if (v.sub == null)
						res = -1;
					else
						res = sub.compareTo(v.sub);
				} else if (v.sub != null) {
					res = 1;
				}
			}
			return res;
		}
	}

	public static String makeModelicaPath(String str) {
	    
	    List<Library> libs =
	        Library.fromString(str);
	    
	    List<String> paths =
	        new LinkedList<String>();
	        
	    for (Library lib : libs)
	        paths.add(lib.path);
	    
	    String path = System.getenv("MODELICAPATH");
	    if (path != null)
	        paths.add(path);
	    
	    return 
	        Util.implode(IDEConstants.PATH_SEP, paths); 
	}
	
}
