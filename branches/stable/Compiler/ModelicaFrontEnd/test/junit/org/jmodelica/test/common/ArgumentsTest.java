package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;

import org.jmodelica.util.Arguments;
import org.jmodelica.util.Arguments.InvalidArgumentException;
import org.junit.Test;

public class ArgumentsTest {

    @Test(expected = InvalidArgumentException.class)
    public void onlyOptionArguments() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-modelicapath=X", "-log=w|os|stderr"
        });
    }

    @Test()
    public void parseOneNoOptionArgument() throws InvalidArgumentException {
        Arguments args = new Arguments("ModelicaCompiler", new String[] {
            "-target=parse", "-modelicapath=X", "-log=w|os|stderr", "libraryPath"
        });
        assertEquals("libraryPath", args.libraryPath());
    }

    @Test
    public void classNameOneNoOptionArgument() throws InvalidArgumentException {
        Arguments args = new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test"
        });
        assertEquals("test", args.className());
    }

    @Test
    public void libraryPathOneNoOptionArgument() throws InvalidArgumentException {
        Arguments args = new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test"
        });
        assertEquals("test", args.className());
        assertEquals("", args.libraryPath());
    }

    @Test
    public void twoNonOptionArguments() throws InvalidArgumentException {
        Arguments args = new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-modelicapath=X", "-log=w|os|stderr", "libraryPath", "test"
        });
        assertEquals("test", args.className());
        assertEquals("libraryPath", args.libraryPath());
    }

    /*
     * Test the arguments' check.
     */

    @Test
    public void oneArgumentModelicaPathAndParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=parse", "-modelicapath=X", "-log=w|os|stderr", "test"
        });
    }

    @Test
    public void oneArgumentModelicaPathNoParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test"
        });
    }

    @Test
    public void oneArgumentNoModelicaPathAndParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=parse", "-log=w|os|stderr", "test"
        });
    }

    @Test(expected = InvalidArgumentException.class)
    public void oneArgumentNoModelicaPathNoParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-log=w|os|stderr", "test"
        });
    }

    @Test(expected = InvalidArgumentException.class)
    public void twoArgumentsModelicaPathAndParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=parse", "-modelicapath=X", "-log=w|os|stderr", "test", "libPath"
        });
    }

    @Test
    public void twoArgumentsModelicaPathNoParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test", "libPath"
        });
    }

    @Test(expected = InvalidArgumentException.class)
    public void twoArgumentsNoModelicaPathAndParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=parse", "-log=w|os|stderr", "test", "libPath"
        });
    }

    @Test
    public void twoArgumentsNoModelicaPathNoParse() throws InvalidArgumentException {
        new Arguments("ModelicaCompiler", new String[] {
            "-target=cs", "-log=w|os|stderr", "test", "libPath"
        });
    }
}
