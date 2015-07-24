package org.jmodelica.junit;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmodelica.util.test.GenericTestCase;
import org.jmodelica.util.test.GenericTestTreeNode;
import org.jmodelica.util.test.TestSpecification;
import org.jmodelica.util.test.TestTree;
import org.junit.runner.Description;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class TestTreeRunner extends ParentRunner<GenericTestTreeNode> {

    private List<GenericTestTreeNode> nodes;
    private Map<String,Description> caseDesc;
    private Map<String,TestTreeRunner> runners;
    private List<GenericTestTreeNode> children;
    private Description desc;
    private TestSpecification spec;
    private File testFile;

    public TestTreeRunner(TestSpecification spec, File testFile) throws InitializationError {
        this(spec, null, testFile);
    }

    public TestTreeRunner(TestSpecification spec, TestTree tree, File testFile) throws InitializationError {
        super(spec.getClass());
        String name; 
        if (tree == null) {
            name = testFile.getName();
            tree = spec.createTestSuite(testFile).getTree();
        } else {
            name = tree.getName();
        }
        desc = Description.createSuiteDescription(name);
        this.spec = spec;
        this.testFile = testFile;
        caseDesc = new HashMap<String,Description>();
        runners = new HashMap<String,TestTreeRunner>();
        children = new ArrayList<GenericTestTreeNode>();
        for (GenericTestTreeNode test : tree) {
            Description chDesc = null;
            GenericTestTreeNode subTest = null;
            String testName = test.getName();
            if (test instanceof TestTree) {
                TestTree subTree = (TestTree) test;
                if (subTree.numChildren() == 1) {
                    subTest = subTree.iterator().next();
                }
                if (subTest != null && !(subTest instanceof TestTree)) {
                    test = subTest;
                } else {
                    TestTreeRunner runner = new TestTreeRunner(spec, subTree, testFile);
                    runners.put(subTree.getName(), runner);
                    chDesc = runner.getDescription();
                }
            } 
            if (!(test instanceof TestTree)) {
                // TODO: Upgrade JUnit version, then use createTestDescription(String, String) instead
                String descStr = String.format("%s(%s)", testName, testFile);
                chDesc = Description.createSuiteDescription(descStr);
                caseDesc.put(test.getName(), chDesc);
            }
            desc.addChild(chDesc);
            children.add(test);
        }
    }

    protected Description describeChild(GenericTestTreeNode test) {
        if (test instanceof TestTree) {
            return runners.get(test.getName()).getDescription();
        } else {
            return caseDesc.get(test.getName());
        }
    }

    protected List<GenericTestTreeNode> getChildren() {
        return children;
    }

    protected void runChild(GenericTestTreeNode test, RunNotifier note) {
        if (test instanceof TestTree) {
            runners.get(test.getName()).run(note);
        } else {
            Description d = caseDesc.get(test.getName());
            note.fireTestStarted(d);
            try {
                ((GenericTestCase) test).testMe(spec.asserter());
            } catch (Throwable e) {
                note.fireTestFailure(new Failure(d, e));
            }
            note.fireTestFinished(d);
        }
    }

    public Description getDescription() {
        return desc;
    }

}
