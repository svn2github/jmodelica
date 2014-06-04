package org.jmodelica.util.logging;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

import org.jmodelica.util.CompiledUnit;
import org.jmodelica.util.Problem;
import org.jmodelica.util.XMLUtil;

/**
 * XMLLogger converts the log into XML and output it to another logger.
 */
public final class XMLLogger extends PipeLogger {
    
    private boolean started = false;

    public XMLLogger(Level level, String fileName) throws IOException {
        super(level, fileName);
    }
    
    public XMLLogger(Level level, File file) throws IOException {
        super(level, file);
    }
    
    /**
     * Constructs a XMLLogger with the sub logger <code>logger</code>
     * 
     * @param logger sub logger
     */
    public XMLLogger(Level level, OutputStream stream) throws IOException {
        super(level, stream);
    }

    @Override
    public void do_close() throws IOException {
        write_raw("</compilation>");
        super.do_close();
    }

    @Override
    protected void do_write(String logMessage) throws IOException {
        write_raw(XMLUtil.escape(logMessage));
    }

    @Override
    protected void do_write(Throwable throwable) throws IOException {
        StringWriter str = new StringWriter();
        PrintWriter print = new PrintWriter(str);
        throwable.printStackTrace(print);
        write_node("Exception", 
                   "kind",       throwable.getClass().getName(),
                   "message",    throwable.getMessage() == null ? "" : throwable.getMessage(), 
                   "stacktrace", str.toString());
    }

    @Override
    protected void do_write(Problem problem) throws IOException {
        write_node(Problem.capitalize(problem.severity()), 
                   "kind",    problem.kind().toString().toLowerCase(),
                   "file",    problem.fileName(),
                   "line",    problem.beginLine(),
                   "column",  problem.beginColumn(),
                   "message", problem.message());
    }

    protected void do_write(CompiledUnit unit) throws IOException {
        write_node("CompilationUnit", 
                   "file", unit.toString());
    }

    private void write_node(String name, Object... values) throws IOException {
        StringBuffer buf = new StringBuffer();
        buf.append('<');
        buf.append(name);
        buf.append(">\n");
        for (int i = 0; i < values.length; i += 2) {
            buf.append("    <value name=\"");
            buf.append(values[i]);
            buf.append("\">");
            if (values[i + 1] instanceof String)
                buf.append(XMLUtil.escape((String) values[i + 1]));
            else
                buf.append(values[i + 1]);
            buf.append("</value>\n");
        }
        buf.append("</");
        buf.append(name);
        buf.append(">\n");
        write_raw(buf.toString());
    }

    protected void write_raw(String logMessage) throws IOException {
        if (!started) {
            started = true;
            write_raw("<compilation>\n");
        }
        super.write_raw(logMessage);
    }

}
