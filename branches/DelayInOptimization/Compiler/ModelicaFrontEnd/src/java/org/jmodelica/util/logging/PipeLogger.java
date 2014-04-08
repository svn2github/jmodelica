package org.jmodelica.util.logging;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.jmodelica.util.Problem;

public abstract class PipeLogger extends ModelicaLogger {

    private State state = State.ACTIVE;
    private final OutputStream stream;
    private final boolean thisCreatedStream;

    public PipeLogger(Level level, String fileName) throws IOException {
        this(level, new File(fileName));
    }

    public PipeLogger(Level level, File file) throws IOException {
        super(level);
        this.stream = createStream(file);
        thisCreatedStream = true;
    }

    public PipeLogger(Level level, OutputStream stream) {
        super(level);
        this.stream = stream;
        thisCreatedStream = false;
    }
    
    protected OutputStream getStream() {
        return stream;
    }
    
    protected OutputStream createStream(File file) throws IOException {
        return new FileOutputStream(file);
    }

    @Override
    public final void close() {
        if (state == State.CLOSED)
            return;
        state = State.CLOSED;
        try {
            do_close();
        } catch (IOException e) {}
    }
    
    protected void do_close() throws IOException {
        if (thisCreatedStream) {
            stream.close();
        }
    }

    @Override
    protected void finalize() throws Throwable {
        close();
        super.finalize();
    }

    @Override
    protected final void write(Level level, String logMessage) {
        if (!getLevel().shouldLog(level))
            return;
        if (state == State.EXCEPTION)
            return;
        if (state == State.CLOSED) {
            System.err.println("Compiler is writing to closed logger!");
            state = State.EXCEPTION;
            return;
        }
        try {
            do_write(logMessage);
        } catch (IOException e) {
            state = State.EXCEPTION;
            System.err.println("Compiler logger failed to write." + e.getMessage() != null ? " " + e.getMessage() : "");
        }
    }

    protected abstract void do_write(String logMessage) throws IOException;;

    @Override
    protected final void write(Level level, Throwable throwable) {
        if (!getLevel().shouldLog(level))
            return;
        if (state == State.EXCEPTION)
            return;
        if (state == State.CLOSED) {
            System.err.println("Compiler is writing to closed logger!");
            state = State.EXCEPTION;
            return;
        }
        try {
            do_write(throwable);
        } catch (IOException e) {
            state = State.EXCEPTION;
            System.err.println("Compiler logger failed to write." + e.getMessage() != null ? " " + e.getMessage() : "");
        }
    }

    protected abstract void do_write(Throwable throwable) throws IOException;;

    @Override
    protected final void write(Level level, Problem problem) {
        if (!getLevel().shouldLog(level))
            return;
        if (state == State.EXCEPTION)
            return;
        if (state == State.CLOSED) {
            System.err.println("Compiler is writing to closed logger!");
            state = State.EXCEPTION;
            return;
        }
        try {
            do_write(problem);
        } catch (IOException e) {
            state = State.EXCEPTION;
            System.err.println("Compiler logger failed to write." + e.getMessage() != null ? " " + e.getMessage() : "");
        }
    }

    protected abstract void do_write(Problem problem) throws IOException;;

    private static enum State {
        ACTIVE, CLOSED, EXCEPTION,
    }
    
    protected void write_raw(String logMessage) throws IOException {
        stream.write(logMessage.getBytes());
    }

}
