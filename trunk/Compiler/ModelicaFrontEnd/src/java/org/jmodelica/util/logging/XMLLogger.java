package org.jmodelica.util.logging;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import org.jmodelica.util.XMLUtil;
import org.jmodelica.util.logging.units.LoggingUnit;

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

    public XMLLogger(Level level, OutputStream stream) throws IOException {
        super(level, stream);
    }

    @Override
    public void do_close() throws IOException {
        write_raw("</compilation>");
        super.do_close();
    }

    protected void write_raw(String logMessage) throws IOException {
        if (!started) {
            started = true;
            write_raw("<compilation>\n");
        }
        super.write_raw(logMessage);
    }

    @Override
    protected void do_write(LoggingUnit logMessage) throws IOException {
        write_raw(logMessage.printXML(getLevel()));
    }

    public static String write_node(String name, Object ... values) {
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
        return buf.toString();
    }

}
