package org.jmodelica.junit;

public class Util {

    /**
     * Get the path to a file using the class loader for provided object, e.g.
     * JUnit test.
     */
    public static String resource(Object test, String name) {
        return resource(test.getClass(), name);
    }

    /**
     * Get the path to a file using the class loader for provided class object.
     */
    public static String resource(Class<?> clazz, String name) {
        return clazz.getResource(name).getPath();
    }

}
