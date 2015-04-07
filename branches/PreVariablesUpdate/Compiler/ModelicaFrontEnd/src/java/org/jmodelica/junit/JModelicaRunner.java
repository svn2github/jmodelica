package org.jmodelica.junit;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.jmodelica.util.test.TestSpecification;
import org.junit.runner.Description;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class JModelicaRunner extends ParentRunner<ModuleRunner> {

    private List<ModuleRunner> children;

    public JModelicaRunner(Class testClass) throws InitializationError {
        super(testClass);
        if (TestSpecification.class.isAssignableFrom(testClass)) {
            try {
                TestSpecification spec = (TestSpecification) testClass.newInstance();
                children = new ArrayList<ModuleRunner>();
                for (File f : spec.getModuleDirs()) {
                    File testDir = new File(f, "src/test");
                    if (testDir.isDirectory() && testDir.listFiles().length > 0) 
                        children.add(new ModuleRunner(spec, f));
                }
            } catch (Exception e) {
                throw new InitializationError(Collections.<Throwable>singletonList(e));
            }
        } else {
            throw new InitializationError("Test class must inherit org.jmodelica.ModelicaTestSpecification.");
        }
    }

    public Description describeChild(ModuleRunner mod) {
        return mod.getDescription();
    }

    public List<ModuleRunner> getChildren() {
        return children;
    }

    public void runChild(ModuleRunner mod, RunNotifier note) {
        mod.run(note);
    }

}
