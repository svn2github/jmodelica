package org.jmodelica.util.logging;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;

import org.jmodelica.util.logging.units.LoggingUnit;

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
    protected void do_write(LoggingUnit logMessage) throws IOException {
        write_raw(logMessage.print(getLevel()));
        write_raw("\n");
    }

}
