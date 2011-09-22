package org.jmodelica.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class StreamGobbler extends Thread {
	private InputStream is;
    private OutputStream os;
    
    public StreamGobbler(InputStream is) {
        this(is, new DummyOutputStream());
    }
    
    public StreamGobbler(InputStream is, OutputStream redirect) {
        this.is = is;
        this.os = redirect;
    }
    
    public void run() {
        try {
        	try {
				byte[] b = new byte[64];
				int n;
				while ((n = is.read(b)) > 0)
					os.write(b, 0, n);
				os.flush();
	        } finally {
	        	is.close();
	        }
        } catch (IOException ioe) {
        }
    }
}
