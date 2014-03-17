package org.jmodelica.util.logging;

import java.io.File;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.OutputStream;

import org.jmodelica.util.Problem;

public class ObjectStreamLogger extends PipeLogger {
    
    public ObjectStreamLogger(Level level, String filename) throws IOException {
        super(level, filename);
    }
    
    public ObjectStreamLogger(Level level, File file) throws IOException {
        super(level, file);
    }
    
    public ObjectStreamLogger(Level level, OutputStream stream) throws IOException {
        super(level, new ObjectOutputStream(stream));
    }
    
    @Override
    public void do_close() throws IOException {
        getStream().writeObject(null);
        super.do_close();
    }

    @Override
    protected OutputStream createStream(File file) throws IOException {
        return new ObjectOutputStream(super.createStream(file));
    }
    
    @Override
    protected ObjectOutputStream getStream() {
        return (ObjectOutputStream) super.getStream();
    }
    
    @Override
    protected void do_write(String logMessage) throws IOException {
        getStream().writeObject(logMessage);
    }

    @Override
    protected void do_write(Throwable throwable) throws IOException {
        getStream().writeObject(throwable);
    }

    @Override
    protected void do_write(Problem problem) throws IOException {
        getStream().writeObject(problem);
    }

}
