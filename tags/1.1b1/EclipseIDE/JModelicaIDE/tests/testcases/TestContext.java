package testcases;

import junit.framework.TestCase;

import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.namecomplete.Context;

public class TestContext extends TestCase {


public void makeTest(
        String context, 
        String expectedQpart,
        String expectedFilter) 
{
    Context c =
        new Context(new OffsetDocument(context + '^'));
    
    assertEquals(
        c.qualifiedPart(), 
        expectedQpart);
    assertEquals(
        c.filter().filter, 
        expectedFilter);
    
}

public void testContext() {

    makeTest(""                     , ""              , ""        );
    makeTest("."                    , ""              , ""        );
    makeTest("@#@"                  , ""              , ""        );
    makeTest("testing"              , ""              , "testing" );
    makeTest("test.ing"             , "test"          , "ing"     );
    makeTest("qualified.part.filter", "qualified.part", "filter"  );
    makeTest("test."                , "test"          , ""        );
    makeTest(".test"                , ""              , "test"    );

}

}
