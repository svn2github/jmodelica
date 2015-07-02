package org.jmodelica.util.logging.units;

import org.jmodelica.util.XMLUtil;
import org.jmodelica.util.logging.Level;

public class StringLoggingUnit implements LoggingUnit {

    private static final long serialVersionUID = 7260935338610275821L;

    private String string;
    private Object[] args;

    public StringLoggingUnit(String string, Object ... args) {
        this.string = string;
        this.args = args;
    }
    
    /**
     * This method should be called before each print. It ensures that
     * expensive operation such as String.format() only is done once.
     */
    private void computeString() {
        if (args != null) {
            string = String.format(string, args);
            args = null;
        }
    }

    @Override
    public String print(Level level) {
        computeString();
        return string;
    }

    @Override
    public String printXML(Level level) {
        computeString();
        return XMLUtil.escape(string);
    }

    /**
     * This must be done since there might be objects in the args field that
     * can't be serialized! An empty Object[] is serializable though.
     */
    @Override
    public void prepareForSerialization() {
        computeString();
    }

}
