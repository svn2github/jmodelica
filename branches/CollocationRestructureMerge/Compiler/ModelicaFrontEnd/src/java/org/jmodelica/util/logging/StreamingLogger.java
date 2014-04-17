package org.jmodelica.util.logging;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

import org.jmodelica.util.Problem;
import org.jmodelica.util.exceptions.ModelicaException;

public class StreamingLogger extends PipeLogger {

    /**
     * Constructs a logger with log level <code>level</code> and
     * writes to the file with the name <code>fileName</code>.
     * 
     * @param level log level of this logger
     * @param fileName Name of file that should be written
     * @throws FileNotFoundException thrown when invalid file name is supplied
     */
    public StreamingLogger(Level level, String fileName) throws IOException {
        super(level, fileName);
    }

    /**
     * Constructs a logger with log level <code>level</code> and
     * writes to the file <code>file</code>.
     * 
     * @param level log level of this logger
     * @param file File that should be written
     * @throws FileNotFoundException thrown when invalid file is supplied
     */
    public StreamingLogger(Level level, File file) throws IOException {
        super(level, file);
    }

    /**
     * Constructs a logger with log level <code>level</code> and
     * writes log output to OutputStream <code>stream</code>
     * 
     * @param level log level of this logger
     * @param stream OutputStream that the log is written to
     */
    public StreamingLogger(Level level, OutputStream stream) {
        super(level, stream);
    }

    @Override
    protected void do_write(String logMessage) throws IOException {
        write_raw(logMessage);
        write_raw("\n");
    }

    @Override
    protected void do_write(Throwable throwable) throws IOException {
        if (throwable instanceof ModelicaException) {
            do_write(throwable.getMessage());
        } else if (throwable instanceof FileNotFoundException) {
            do_write("Could not find file: " + throwable.getMessage());
        } else if (throwable instanceof OutOfMemoryError) {
            do_write("Out of memory. Please set the memory limit of the JVM higher.");
        } else {
            StringBuilder sb = new StringBuilder();
            sb.append("Unknown program error, " + throwable.getClass().getName());
            if (throwable.getMessage() != null)
                sb.append(": " + throwable.getMessage());
            do_write(sb.toString());
        }
        if (getLevel().shouldLog(Level.DEBUG)) {
            StringWriter str = new StringWriter();
            PrintWriter print = new PrintWriter(str);
            throwable.printStackTrace(print);
            do_write(str.toString());
        }
    }

    @Override
    protected void do_write(Problem problem) throws IOException {
        do_write(problem.toString());
    }

}
