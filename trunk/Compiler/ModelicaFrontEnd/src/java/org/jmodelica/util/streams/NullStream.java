package org.jmodelica.util.streams;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;

public class NullStream {
	
	public static final OutputStream OUPUT = new OutputStream() {
		public void write(int b) throws IOException {}

		public void write(byte[] b) throws IOException {}

		public void write(byte[] b, int off, int len) throws IOException {}
	};

	public static final PrintStream PRINT = new PrintStream(OUPUT);
	
	public static final InputStream INPUT = new InputStream() {
		public int read() throws IOException {
			return -1;
		}
	};

}
