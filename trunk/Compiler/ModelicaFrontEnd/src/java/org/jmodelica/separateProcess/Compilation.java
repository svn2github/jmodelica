package org.jmodelica.separateProcess;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.jmodelica.util.Criteria;
import org.jmodelica.util.FilteredIterator;
import org.jmodelica.util.Problem;
import org.jmodelica.util.logging.ObjectStreamLogger;

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
                readStartBytes(process.getErrorStream());
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
                        throw new SeparateProcessException("Unknown object type '" + o.getClass().getName() + "' received on compiler log");
                    }
                }
            } catch (EOFException e) {
                // OK
                return;
            } catch (IOException e) {
                if (exception == null)
                    exception = new SeparateProcessException("Exception while parsing compiler log", e);
            } catch (ClassNotFoundException e) {
                if (exception == null)
                    exception = new SeparateProcessException("Unable to reconstruct compiler log object", e);
            } catch (SeparateProcessException e) {
                if (exception == null)
                    exception = e;
            }
            readAndThrow(process.getErrorStream());
        }
        
        private void readStartBytes(InputStream stream) throws IOException {
            byte[] readStartBytes = new byte[ObjectStreamLogger.START_BYTES.length];
            int read = 0;
            while (read < readStartBytes.length) {
                int len = stream.read(readStartBytes, read, readStartBytes.length - read);
                if (len == -1)
                    break;
                read += len;
            }
            if (!Arrays.equals(readStartBytes, ObjectStreamLogger.START_BYTES)) {
                StringBuilder sb = new StringBuilder(new String(readStartBytes, 0, read));
                byte[] buffer = new byte[2048];
                int len;
                while ((len = stream.read(buffer)) != -1)
                    sb.append(new String(buffer, 0, len));
                throw new InvalidLogStartException(sb.toString());
            }
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
