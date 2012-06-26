package testcases;

import org.jmodelica.ide.namecomplete.CompletionFilter;

import junit.framework.TestCase;

public class TestCompletionFilter extends TestCase {

    public CompletionFilter ncfs;

    public void testBasic() {
        
        ncfs = new CompletionFilter("rea");
        
        assertTrue(ncfs.matches("real"));
        
        assertFalse(ncfs.matches("rael"));
        
    }
    
    public void testCamel() {
        
        ncfs = new CompletionFilter("ConInt");
        
        assertTrue(ncfs.matches("ContinuousIntegrator"));
        
        assertFalse(ncfs.matches("Continuousintegrator"));
        
        assertTrue(ncfs.matches("ContinuousIntegratorSecondOrder"));
        
        assertTrue(ncfs.matches("ConInt"));
        
        assertFalse(ncfs.matches(""));
        
        assertFalse(ncfs.matches("ConIn"));
        
    }
    
    public void testEmpty() {
        
        ncfs = new CompletionFilter("");
        
        assertTrue(ncfs.matches("real"));

        assertTrue(ncfs.matches("Real"));

        assertTrue(ncfs.matches(""));
        
        assertTrue(ncfs.matches("@#!@!"));
        
    }
    
    public void testLeadingLowerCase() {
        
        ncfs = new CompletionFilter("conInt");
        
        assertTrue(ncfs.matches("ContinuousIntegrator"));
        
        assertFalse(ncfs.matches("Continuousintegrator"));
        
        assertTrue(ncfs.matches("ContinuousIntegratorSecondOrder"));
        
        assertTrue(ncfs.matches("ConInt"));
        
        assertFalse(ncfs.matches(""));
        
        assertFalse(ncfs.matches("ConIn"));        
    }
    
    public void testUnderScores() {
        
        ncfs = new CompletionFilter("AB_CcDd");
        
        assertTrue(ncfs.matches("AaaBbbb_CccDddd"));
        
        assertTrue(ncfs.matches("AaaBbbb_CccDdddEeee_Ffff"));

        ncfs = new CompletionFilter("_Cc_Ff");
        
        assertTrue(ncfs.matches("AaaBbbb_CccDdddEeee_Ffff"));
        
    }
}
