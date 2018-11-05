package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertFalse;

import org.jmodelica.common.GUIDManager;
import org.junit.Before;
import org.junit.Test;

public class GUIDManagerTest {
    
    private GUIDManager guidManager;
    
    @Before
    public void setup() {
        guidManager = new GUIDManager("1.0");
    }
    
    private void test(String source, String[] dependent, String[] expected) {
        guidManager.setSourceString(source);
        StringBuilder[] output = new StringBuilder[dependent.length];
        for (int i = 0; i < dependent.length; i++) {
            output[i] = new StringBuilder();
            guidManager.addDependentString(dependent[i], output[i]);
        }
        guidManager.processDependentFiles();
        for (int i = 0; i < expected.length; i++) {
            assertEquals(ignoreWhitespace(expected[i]), ignoreWhitespace(output[i].toString()));
        }
    }
    
    private String ignoreWhitespace(String string) {
        return string.trim().replaceAll("\\s", " ");
    }
    
    @Test
    public void testGuid() {
        String[] dependent = {"guid=" + guidManager.getGuidToken()};
        String[] expected = {"guid=fd3dbec9730101bff92acc820befc34"};
        test("Test string", dependent, expected);
    }
    
    @Test
    public void testDate() {
        String input = "guid=" + guidManager.getGuidToken() + ", date=" + guidManager.getDateToken();
        String expected = "guid=dd4396b82020aef1ea5c015eb67ce94";
        guidManager.setSourceString(input);
        StringBuilder output = new StringBuilder();
        guidManager.addDependentString(input, output);
        guidManager.processDependentFiles();
        String actual = output.toString();
        assertEquals(expected, actual.substring(0, expected.length()));
        assertFalse(input.equals(actual));
        actual = actual.substring(expected.length() + 2);
        assertTrue(actual + " does not match date pattern", actual.trim().matches("date=[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}"));
    }
    
    @Test
    public void testCompilerVersion() {
        String[] dependent = {"guid=" + guidManager.getGuidToken() + ", cv=" + guidManager.getCompilerVersionToken()};
        String[] expected = {"guid=7215ee9c7d9dc229d2921a40e899ec5f, cv=1.0"};
        test(guidManager.getGuidToken() + " " + guidManager.getCompilerVersionToken(),
                dependent, expected);
    }
    
    @Test
    public void twoGuidSameLine() {
        test(guidManager.getGuidToken() + " " + guidManager.getGuidToken(),
                new String[]{guidManager.getGuidToken() + " " + guidManager.getGuidToken()},
                new String[]{"e177d94705dcb794cd9aa8c0ffdbbd99" + " " + guidManager.getGuidToken()});
    }
    
    @Test
    public void twoGuidDifferentLines() {
        test(guidManager.getGuidToken() + "\n" + guidManager.getGuidToken(),
                new String[]{guidManager.getGuidToken() + "\n" + guidManager.getGuidToken()},
                new String[]{"c3436849d689f4c7c964c3893f62315b" + "\n" + guidManager.getGuidToken()});
    }
    
    @Test
    public void guidTwoDependentFiles() {
        test("Test string",
                new String[]{guidManager.getGuidToken(), "guid: " + guidManager.getGuidToken()},
                new String[]{"fd3dbec9730101bff92acc820befc34", "guid: fd3dbec9730101bff92acc820befc34"});
    }

}
