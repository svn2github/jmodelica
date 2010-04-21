package testcases;

import org.jmodelica.ide.editor.actions.ToggleComment;

import junit.framework.TestCase;


public class ToggleCommentTest extends TestCase {
    
    public void testCommentLine() {
        
        ToggleComment cour = new ToggleComment(null);
        
        assertEquals("// bla;", cour.toggleComment(" bla;", 
                !ToggleComment.isCommented(" bla;")));
        
        assertEquals(" bla;", cour.toggleComment("// bla;", 
                !ToggleComment.isCommented("// bla;")));
        
        assertEquals(" bla;", cour.toggleComment(" //bla;", 
                !ToggleComment.isCommented(" //bla;")));
        
        assertEquals("   \t\tbla;", cour.toggleComment("  // \t\tbla;", 
                !ToggleComment.isCommented("  // \t\tbla;")));
        
        assertEquals("  ////bla;", cour.toggleComment("  //bla;", true));
        
        assertEquals("  bla;", cour.toggleComment("  bla;", false));
        
        assertEquals("  bla;//test", cour.toggleComment("  bla;//test", false));
    }

}
