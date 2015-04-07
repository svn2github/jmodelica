package org.jmodelica.junit;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmodelica.util.test.GenericTestCase;
import org.jmodelica.util.test.GenericTestSuite;
import org.jmodelica.util.test.TestSpecification;
import org.junit.runner.Description;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class ModelicaFileRunner extends ParentRunner<GenericTestCase> {

    private GenericTestSuite suite;
    private Description desc;
    private TestSpecification spec;
    private Map<String,Description> childDesc;

    public ModelicaFileRunner(TestSpecification spec, File testFile) throws InitializationError {
        super(spec.getClass());
        suite = spec.createTestSuite(testFile);
        desc = Description.createSuiteDescription(testFile.getName());
        this.spec = spec;
        childDesc = new HashMap<String,Description>();
        for (GenericTestCase test : suite.getAll()) {
            String descStr = String.format("%s(%s)", test.getName(), testFile);
            Description chDesc = Description.createSuiteDescription(descStr);
            childDesc.put(test.getName(), chDesc);
            desc.addChild(chDesc);
        }
    }

    public Description describeChild(GenericTestCase test) {
        return childDesc.get(test.getName());
    }

    public List<GenericTestCase> getChildren() {
        return (List<GenericTestCase>) suite.getAll();
    }

    public void runChild(GenericTestCase test, RunNotifier note) {
        Description d = describeChild(test);
        note.fireTestStarted(d);
        try {
            test.testMe(spec.asserter());
        } catch (Throwable e) {
            note.fireTestFailure(new Failure(d, e));
        }
        note.fireTestFinished(d);
    }

    public Description getDescription() {
        return desc;
    }

}
