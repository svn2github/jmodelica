package org.jmodelica.separateProcess;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.jmodelica.util.Criteria;
import org.jmodelica.util.FilteredIterator;
import org.jmodelica.util.Problem;

public final class Compilation {
    
    private final Process process;
    private final LogReceiver receiver;
    private final Collection<Problem> problems = new ConcurrentLinkedQueue<Problem>();
    private Throwable exception = null;
    
    protected Compilation(List<String> args, String jmodelicaHome) throws IOException {
        ProcessBuilder builder = new ProcessBuilder(args);
        builder.environment().put("JMODELICA_HOME", jmodelicaHome);
        builder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
        
        process = builder.start();
        
        receiver = new LogReceiver();
        receiver.start();
    }
    
    public boolean join() throws Throwable, InterruptedException {
        process.waitFor();
        if (exception != null)
            throw exception;
        
        return true;
    }
    
    public Iterator<Problem> getProblems() {
        return problems.iterator();
    }
    
    public Iterator<Problem> getErrors() {
        return new FilteredIterator<Problem>(getProblems(), new Criteria<Problem>() {
            @Override
            public boolean test(Problem elem) {
                return elem.severity() == Problem.Severity.ERROR;
            }});
    }
    
    public Iterator<Problem> getWarnings() {
        return new FilteredIterator<Problem>(getProblems(), new Criteria<Problem>() {
            @Override
            public boolean test(Problem elem) {
                return elem.severity() == Problem.Severity.WARNING;
            }});
    }
    
    private class LogReceiver extends Thread {
        @Override
        public void run() {
            try {
                ObjectInputStream stream = new ObjectInputStream(process.getErrorStream());
                Object o;
                while ((o = stream.readObject()) != null) {
                    if (o instanceof String) {
                        // Ignore
                    } else if (o instanceof Problem) {
                        problems.add((Problem) o);
                    } else if (o instanceof Throwable) {
                        if (exception == null)
                            exception = (Throwable) o;
                    } else {
                        // TODO, exception?!
                    }
                }
            } catch (EOFException e) {
                // OK
            } catch (IOException e) {
                if (exception == null)
                    exception = e;
            } catch (ClassNotFoundException e) {
                if (exception == null)
                    exception = e;
            }
            readAndThrow(process.getErrorStream());
        }
        
        private void readAndThrow(InputStream stream) {
            try {
                byte[] buffer = new byte[2048];
                while (stream.read(buffer) != -1);
            } catch (IOException e) {
                // Not much to do here, we are in serious problems if we get here!
                e.printStackTrace();
            }
        }
    }
    
}
