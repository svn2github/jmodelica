package org.jmodelica.ant;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ExtractPluginVersion {
	public static final String VERSION_FILE = "plugin.versions";
	public static final String PROPERTY_FILE = "plugin.properties";
	private String plugin;
	private String dataDir;
	private String path;
	private String rev = ".";

	public void setPlugin(String plug) {
		plugin = plug;
	}

	public void setDatadir(String path) {
		dataDir = path;
	}

	public void setPath(String path) {
		this.path = path;
	}
	
	public void setRevision(String revision) {
		int i = revision.lastIndexOf(':') + 1;
		rev = ".r" + revision.substring(i).replaceAll("[^0-9]*", "");
	}

	public void execute() {
		try {
			Scanner scan = new Scanner(new File(path));
			scan.useDelimiter(":\\s*|\n|\r|\r\n");
			String name = null;
			String version = null;
			PrintStream out = new PrintStream(dataDir + File.separator + PROPERTY_FILE);
			while (scan.hasNext()) {
				String str = scan.next();
				if (str.equals("Bundle-Version") && scan.hasNext()) {
					version = scan.next();
					if (rev.length() > 2)
						version += rev;
					out.println(plugin + ".version = " + version);
				} else if (str.equals("Bundle-SymbolicName") && scan.hasNext()) {
					name = scan.next().split(";")[0];
					out.println(plugin + ".id = " + name);
				}
			}
			scan.close();
			if (name != null && version != null) {
				out.println(plugin + ".jar = " + String.format("%s_%s.jar", name, version));
				addVersion(name, version);
				if (rev.length() > 2) 
					patchVersion(version);
			}
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private void patchVersion(String version) {
		try {
			ArrayList<String> lines = new ArrayList<String>();
			
			BufferedReader in = new BufferedReader(new FileReader(path));
			Pattern pat = Pattern.compile("(Bundle-Version: )([.0-9]*)");
			String repl = "$1" + version;
			String line = in.readLine();
			while (line != null) {
				Matcher m = pat.matcher(line);
				line = m.replaceAll(repl);
				lines.add(line);
				line = in.readLine();
			}
			in.close();
			
			PrintStream out = new PrintStream(path);
			for (String l : lines)
				out.println(l);
			out.close();
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}

	private void addVersion(String name, String version) {
		try {
			File f = new File(dataDir + File.separator + VERSION_FILE);
			String str = String.format("%s=%s", name, version);
			if (f.exists())
				str = ";" + str;
			FileWriter out = new FileWriter(f, true);
			out.write(str);
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
