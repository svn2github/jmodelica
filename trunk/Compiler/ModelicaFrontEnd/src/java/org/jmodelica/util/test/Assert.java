package org.jmodelica.util.test;

/**
 * Interface for proxy class used to remove dependency on junit from generated files.
 */
public interface Assert {
    public void fail(String msg);
    
    public void assertEquals(String msg, String expected, String actual);
}
