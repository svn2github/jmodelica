package org.jmodelica.util;

import java.io.OutputStream;

public class DummyOutputStream extends OutputStream {
	public void write(int b) {}
	public void write(byte[] b, int off, int len) {}
}