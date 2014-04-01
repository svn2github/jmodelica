package org.jmodelica.util;

import java.io.OutputStream;
import java.io.PrintStream;

public class NotNullCodeStream extends CodeStream {

	public NotNullCodeStream(PrintStream out) {
		super(out);
	}
	
    public NotNullCodeStream(OutputStream out) {
        super(out);
    }

	public void print(String s) {
		if (s == null)
			throw new NullPointerException();
		super.print(s);
	}
	
	public void print(Object o) {
        if (o == null)
            throw new NullPointerException();
        super.print(o);
	}

	public void format(String format, Object... args) {
		for (Object obj : args)
			if (obj == null)
				throw new NullPointerException();
		super.format(format, args);
	}
}
