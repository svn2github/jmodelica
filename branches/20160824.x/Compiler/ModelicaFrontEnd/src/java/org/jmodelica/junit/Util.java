package org.jmodelica.junit;

public class Util {

    /**
     * Get the path to a file placed in the same directory as a JUnit test.
     */
    public static String resource(Object test, String name) {
        return test.getClass().getResource(name).getPath();
    }

}
