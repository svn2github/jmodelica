package org.jmodelica.util;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MoveAnnot {
	public static void main(String[] args) throws IOException {
		String[] dirs = new String[] {
				"Compiler/ModelicaCBackEnd/src/test/modelica",
				"Compiler/ModelicaFrontEnd/src/test/modelica",
				"Compiler/ModelicaXMLBackEnd/src/test/modelica",
				"Compiler/OptimicaFrontEnd/src/test/modelica",
				"Compiler/OptimicaCBackEnd/src/test/modelica",
		};
		for (String dir : dirs)
			fixAll(dir);
	}
	
	private static void fixAll(String dir) throws IOException {
		for (File f : new File(dir).listFiles())
			if (f.isFile())
				fix(f.getPath());
	}

	private static void fix(String path) throws IOException {
		File temp = new File(path + ".temp");
		File org = new File(path);
		FileInputStream in = new FileInputStream(org);
		PrintStream out = new PrintStream(new FileOutputStream(temp));
		move(in, out);
		in.close();
		out.close();
		org.delete();
		temp.renameTo(org);
		System.out.println(path);
	}

	private final static Pattern CLASS    = Pattern.compile("(model|class|optimization)\\s+([A-Za-z0-9_]+)( .*)?");
	private final static Pattern ANNO     = Pattern.compile("annotation\\(__JModelica.*");
	private final static Pattern ANNO_END = Pattern.compile("\"?\\)\\}\\)\\)\\);");

	private static void move(InputStream rawin, PrintStream out) throws IOException {
		BufferedReader in = new BufferedReader(new InputStreamReader(rawin));
		ByteArrayOutputStream buf = new ByteArrayOutputStream(256);
		PrintStream temp = new PrintStream(buf);
		int state = 0;
		String line;
		String name = null;
		boolean print = true;
		while ((line = in.readLine()) != null) {
			String trimmed = line.trim();
			if (trimmed.isEmpty()) {
				if (state == 3) {
					state = 4;
					print = false;
				}
			} else {
				switch (state) {
				case 0:
					Matcher m = CLASS.matcher(trimmed);
					if (m.matches()) {
						state = 1;
						name = m.group(2);
					}
					break;
				case 1:
					if (ANNO.matcher(trimmed).matches()) {
						temp.println();
						state = 2;
					} else {
						state = 0;
					}
					break;
				case 2:
					if (ANNO_END.matcher(trimmed).matches()) 
						state = 3;
					break;
				case 3:
					state = 4;
					break;
				case 4:
					if (Pattern.matches("end " + name + ";", trimmed)) {
						out.print(buf.toString());
						buf.reset();
						state = 0;
					}
					break;
				}
			}
			if (print)
				((state <= 1 || state >= 4) ? out : temp).println(line);
			print = true;
		}
	}
}
