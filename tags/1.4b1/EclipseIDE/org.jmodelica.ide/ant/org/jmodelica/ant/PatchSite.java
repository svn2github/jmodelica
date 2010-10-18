package org.jmodelica.ant;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PatchSite {
	public static final String VERSION_FILE = ExtractPluginVersion.VERSION_FILE;
	private String dataDir;
	private String path;

	public void setDatadir(String path) {
		dataDir = path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public void execute() {
		try {
			BufferedReader r = new BufferedReader(new FileReader(dataDir + File.separator + VERSION_FILE));
			HashMap<String, String> versions = new HashMap<String, String>();
			for (String str : r.readLine().split(";")) {
				String[] parts = str.split("=");
				versions.put(parts[0], parts[1]);
			}
			r.close();
			
			// TODO: this assumes that id or url is always before version - that should probably be fixed...
			// TODO: Update download-size and install-size as well?
			r = new BufferedReader(new FileReader(path));
			ArrayList<String> lines = new ArrayList<String>();
			String id = null;
			Pattern all = Pattern.compile("^(id|url|version)=\"([^\"]*)\".*");
			Pattern url = Pattern.compile("^features/(.[^_]+)_([^_]+)\\.jar");
			String line = r.readLine();
			while (line != null) {
				for (String word : line.split("\\s+")) {
					Matcher m = all.matcher(word);
					if (m.matches()) {
						String attr = m.group(1);
						String val = m.group(2);
						
						if (attr.equals("id")) {
							id = val;
						} else if (attr.equals("url")) {
							Matcher m2 = url.matcher(val);
							if (m2.matches()) {
								id = m2.group(1);
								String version = versions.get(id);
								if (version != null) {
									String repl = String.format("features/%s_%s.jar", id, version);
									line = line.replaceFirst(Pattern.quote(m2.group()), repl);
								}
							}
						} else if (attr.equals("version") && id != null) {
							String version = versions.get(id);
							if (version != null) {
								String pat = "(^|\\s)(version=\")" + Pattern.quote(val) + "\"";
								String repl = "$1$2" + version + "\"";
								line = line.replaceFirst(pat, repl);
							}
							id = null;
						}
					}
				}
				lines.add(line);
				line = r.readLine();
			}
			r.close();
			
			PrintStream out = new PrintStream(path);
			for (String l : lines)
				out.println(l);
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
