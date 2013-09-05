package org.jmodelica.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.Locale;

public class NotNullPrintStream extends PrintStream {

	public NotNullPrintStream(File file, String csn) throws FileNotFoundException,
			UnsupportedEncodingException {
		super(file, csn);
	}

	public NotNullPrintStream(File file) throws FileNotFoundException {
		super(file);
	}

	public NotNullPrintStream(OutputStream out, boolean autoFlush, String encoding)
			throws UnsupportedEncodingException {
		super(out, autoFlush, encoding);
	}

	public NotNullPrintStream(OutputStream out, boolean autoFlush) {
		super(out, autoFlush);
	}

	public NotNullPrintStream(OutputStream out) {
		super(out);
	}

	public NotNullPrintStream(String fileName, String csn) throws FileNotFoundException,
			UnsupportedEncodingException {
		super(fileName, csn);
	}

	public NotNullPrintStream(String fileName) throws FileNotFoundException {
		super(fileName);
	}

	public void print(String s) {
		if (s == null)
			throw new NullPointerException();
		super.print(s);
	}

	public void print(Object obj) {
		if (obj == null)
			throw new NullPointerException();
		super.print(obj);
	}

	public PrintStream format(String format, Object... args) {
		for (Object obj : args)
			if (obj == null)
				throw new NullPointerException();
		return super.format(format, args);
	}

	public PrintStream format(Locale l, String format, Object... args) {
		for (Object obj : args)
			if (obj == null)
				throw new NullPointerException();
		return super.format(l, format, args);
	}

	public PrintStream append(CharSequence csq) {
		if (csq == null)
			throw new NullPointerException();
		return super.append(csq);
	}

	public PrintStream append(CharSequence csq, int start, int end) {
		if (csq == null)
			throw new NullPointerException();
		return super.append(csq, start, end);
	}

}
