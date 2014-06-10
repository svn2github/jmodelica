package org.jmodelica.util.logging;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

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
        write_raw(String.format(
                "<Exception>\n" +
                "    <value name=\"kind\">%s</value>\n" +
                "    <value name=\"message\">%s</value>\n" +
                "    <value name=\"stacktrace\">\n%s</value>\n" +
                "</Exception>",
                XMLUtil.escape(throwable.getClass().getName()),
                XMLUtil.escape(throwable.getMessage() == null ? "" : throwable.getMessage()),
                XMLUtil.escape(str.toString())
        ));
    }

    @Override
    protected void do_write(Problem problem) throws IOException {
        write_raw(String.format(
                "<%s>\n" +
                "    <value name=\"kind\">%s</value>\n" +
                "    <value name=\"file\">%s</value>\n" +
                "    <value name=\"line\">%d</value>\n" +
                "    <value name=\"column\">%d</value>\n" +
                "    <value name=\"message\">%s</value>\n" +
                "</%1$s>",
                XMLUtil.escape(Problem.capitalize(problem.severity())),
                XMLUtil.escape(problem.kind().toString().toLowerCase()),
                XMLUtil.escape(problem.fileName()), problem.beginLine(),
                problem.beginColumn(), XMLUtil.escape(problem.message())
        ));
    }
    
    protected void write_raw(String logMessage) throws IOException {
        if (!started) {
            started = true;
            write_raw("<compilation>\n");
        }
        super.write_raw(logMessage);
    }

}
