package org.jmodelica.junit;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.List;

import org.jmodelica.util.test.TestSpecification;
import org.junit.runner.Description;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class TreeModuleRunner extends ParentRunner<TestTreeRunner> {

    private static final FilenameFilter MODELICA_FILES = new FilenameFilter() {
        public boolean accept(File dir, String name) {
            return name.endsWith(".mo");
        }
    };

    private List<TestTreeRunner> children;
    private Description desc;

    public TreeModuleRunner(TestSpecification spec, File path) throws InitializationError {
        super(spec.getClass());
        children = new ArrayList<TestTreeRunner>();
        desc = Description.createSuiteDescription(path.getName());
        File testDir = new File(path, "src/test");
        for (File f : testDir.listFiles(MODELICA_FILES)) {
            TestTreeRunner mod = new TestTreeRunner(spec, f);
            children.add(mod);
            desc.addChild(mod.getDescription());
        }
    }

    public Description describeChild(TestTreeRunner mod) {
        return mod.getDescription();
    }

    public List<TestTreeRunner> getChildren() {
        return children;
    }

    public void runChild(TestTreeRunner mod, RunNotifier note) {
        mod.run(note);
    }

    public Description getDescription() {
        return desc;
    }

}
