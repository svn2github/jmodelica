package org.jmodelica.util.streams;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class StreamGobbler extends Thread {
	private InputStream is;
    private OutputStream os;
    
    public StreamGobbler(InputStream is) {
        this(is, NullStream.OUPUT);
    }
    
    public StreamGobbler(InputStream is, OutputStream redirect) {
        this.is = is;
        this.os = redirect;
    }
    
    public void run() {
        try {
        	try {
        		// Write to output as soon as data is available.
				byte[] b = new byte[128];
				int n;
				while ((n = is.read(b, 0, 1)) > 0) {
					int m = is.available();
					if (m > b.length - 1)
						m = b.length - 1;
					n += is.read(b, 1, m);
					os.write(b, 0, n);
				}
				os.flush();
	        } finally {
	        	is.close();
	        }
        } catch (IOException ioe) {
        }
    }
}
