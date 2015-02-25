package org.jmodelica.junit;

import org.jmodelica.util.test.Assert;

public class JUnitAssert implements Assert {
    public void fail(String msg) {
        org.junit.Assert.fail(msg);
    }

    public void assertEquals(String msg, String expected, String actual) {
        org.junit.Assert.assertEquals(msg, expected, actual);
    }
}
