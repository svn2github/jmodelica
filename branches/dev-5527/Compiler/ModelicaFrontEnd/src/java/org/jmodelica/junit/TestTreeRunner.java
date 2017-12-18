/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
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

    public TestTreeRunner(TestSpecification spec, File testFile, String parentName) throws InitializationError {
        this(spec, null, parentName, testFile);
    }

    public TestTreeRunner(TestSpecification spec, TestTree tree, String parentName, File testFile) throws InitializationError {
        super(spec.getClass());
        String name;
        char sep;
        if (tree == null) {
            name = testFile.getName();
            tree = spec.createTestSuite(testFile).getTree();
        } else {
            name = tree.getName();
        }
        String fullName = String.format("%s.%s", parentName, name);
        desc = Description.createSuiteDescription(name);
        this.spec = spec;
        this.testFile = testFile;
        caseDesc = new HashMap<String,Description>();
        runners = new HashMap<String,TestTreeRunner>();
        children = new ArrayList<GenericTestTreeNode>();
        int i = 0;
        for (GenericTestTreeNode test : tree) {
            i++;
            Description chDesc = null;
            GenericTestTreeNode subTest = null;
            String testName = test.getName();
            if (testName == null) {
                testName = String.format("[%d]", i);
            }
            if (test instanceof TestTree) {
                TestTree subTree = (TestTree) test;
                if (subTree.numChildren() == 1) {
                    subTest = subTree.iterator().next();
                }
                if (subTest != null && !(subTest instanceof TestTree)) {
                    test = subTest;
                } else {
                    TestTreeRunner runner = new TestTreeRunner(spec, subTree, fullName, testFile);
                    runners.put(subTree.getName(), runner);
                    chDesc = runner.getDescription();
                }
            } 
            if (!(test instanceof TestTree)) {
                // TODO: Upgrade JUnit version, then use createTestDescription(String, String) instead
                String descStr = String.format("%s(%s)", testName, fullName);
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
