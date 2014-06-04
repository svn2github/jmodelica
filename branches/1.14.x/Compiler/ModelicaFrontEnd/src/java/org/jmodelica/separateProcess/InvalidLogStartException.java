package org.jmodelica.separateProcess;

public class InvalidLogStartException extends SeparateProcessException {
    private static final long serialVersionUID = 1;
    private final String completeLog;
    public InvalidLogStartException(String log) {
        super(createLogMessage(log));
        completeLog = log;
    }
    
    public String getCompleteLog() {
        return completeLog;
    }
    
    private static String createLogMessage(String log) {
        int pos = log.indexOf('\n');
        if (pos != -1) {
            pos = log.indexOf('\n', pos + 1);
            if (pos != -1) {
                log = log.substring(0, pos + 1) + "...";
            }
        }
        
        return "Unexpected start of output stream from compiler:\n" + log;
    }
}
