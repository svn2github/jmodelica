package org.jmodelica.ant;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.util.Scanner;

public class ExtractPluginVersion {
	public static final String VERSION_FILE = "plugin.versions";
	public static final String PROPERTY_FILE = "plugin.properties";
	private String plugin;
	private String dataDir;
	private String path;

	public void setPlugin(String plug) {
		plugin = plug;
	}

	public void setDatadir(String path) {
		dataDir = path;
	}

	public void setPath(String path) {
		this.path = path;
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
					// TODO: Add some kind of qualifier to the version string
					// and patch manifest file
					out.println(plugin + ".version = " + version);
				} else if (str.equals("Bundle-SymbolicName") && scan.hasNext()) {
					name = scan.next().split(";")[0];
					out.println(plugin + ".id = " + name);
				}
			}
			if (name != null && version != null) {
				out.println(plugin + ".jar = " + String.format("%s_%s.jar", name, version));
				addVersion(name, version);
			}
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
