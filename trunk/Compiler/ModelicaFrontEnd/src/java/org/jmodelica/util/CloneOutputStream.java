package org.jmodelica.util;

import java.io.IOException;
import java.io.OutputStream;

public class CloneOutputStream extends OutputStream {

    private OutputStream[] out;
    private boolean[] close;

    /**
     * Creates a stream that writes to all the given streams.
     */
    public CloneOutputStream(OutputStream... out) {
        this.out = out;
        close = new boolean[out.length];
        for (int i = 0; i < out.length; i++)
            close[i] = true;
    }

    public void write(int b) throws IOException {
        for (OutputStream o : out)
            o.write(b);
    }

    public void write(byte[] b) throws IOException {
        for (OutputStream o : out)
            o.write(b);
    }

    public void write(byte[] b, int off, int len) throws IOException {
        for (OutputStream o : out)
            o.write(b, off, len);
    }

    public void flush() throws IOException {
        for (OutputStream o : out)
            o.flush();
    }

    /**
     * Closes all the child streams set to be closed.
     * 
     * Default is that all child streams are set to be closed.
     */
    public void close() throws IOException {
        for (int i = 0; i < out.length; i++)
            if (close[i])
                out[i].close();
    }

    /**
     * Set what child streams should be closed when closing this stream.
     * 
     * Default is that all child streams are set to be closed.
     * 
     * @return <code>this</code>, for convenience
     */
    public CloneOutputStream setClose(boolean... close) {
        System.arraycopy(close, 0, this.close, 0, Math.min(close.length, this.close.length));
        return this;
    }

}
