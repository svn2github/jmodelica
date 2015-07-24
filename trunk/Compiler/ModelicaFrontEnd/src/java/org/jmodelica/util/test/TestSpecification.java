package org.jmodelica.util.test;

import java.io.File;

import org.junit.runner.RunWith;

@RunWith(org.jmodelica.junit.TreeJModelicaRunner.class)
public abstract class TestSpecification {

    private File[] dirs;
    private Assert asserter;

    protected TestSpecification(File... dirs) {
        this.dirs = dirs;
    }

    protected TestSpecification(String... dirs) {
        this.dirs = new File[dirs.length];
        for (int i = 0; i < dirs.length; i++)
            this.dirs[i] = new File(dirs[i]);
    }

    public File[] getModuleDirs() {
        return dirs;
    }

    public Assert asserter() {
        if (asserter == null)
            asserter = createAssert();
        return asserter;
    }

    public abstract GenericTestSuite createTestSuite(File testFile);

    protected abstract Assert createAssert();

}
