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

public class ModuleRunner extends ParentRunner<ModelicaFileRunner> {

    private static final FilenameFilter MODELICA_FILES = new FilenameFilter() {
        public boolean accept(File dir, String name) {
            return name.endsWith(".mo");
        }
    };

    private List<ModelicaFileRunner> children;
    private Description desc;

    public ModuleRunner(TestSpecification spec, File path) throws InitializationError {
        super(spec.getClass());
        children = new ArrayList<ModelicaFileRunner>();
        desc = Description.createSuiteDescription(path.getName());
        File testDir = new File(path, "src/test");
        for (File f : testDir.listFiles(MODELICA_FILES)) {
            ModelicaFileRunner mod = new ModelicaFileRunner(spec, f);
            children.add(mod);
            desc.addChild(mod.getDescription());
        }
    }

    public Description describeChild(ModelicaFileRunner mod) {
        return mod.getDescription();
    }

    public List<ModelicaFileRunner> getChildren() {
        return children;
    }

    public void runChild(ModelicaFileRunner mod, RunNotifier note) {
        mod.run(note);
    }

    public Description getDescription() {
        return desc;
    }

}
