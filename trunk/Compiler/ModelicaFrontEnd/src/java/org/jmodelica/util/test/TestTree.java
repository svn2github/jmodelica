package org.jmodelica.util.test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class TestTree implements GenericTestTreeNode, Iterable<GenericTestTreeNode> {
    private String name;
    private ArrayList<GenericTestTreeNode> children;
    private TestTree parent;
    private int parentIndex;

    public TestTree(String name) {
        this.name = name;
        parent = null;
        parentIndex = -1;
        children = new ArrayList<GenericTestTreeNode>();
    }

    public TestTree enter(String childName) {
        TestTree child = new TestTree(childName);
        child.parent = this;
        child.parentIndex = children.size();
        children.add(child);
        return child;
    }

    public TestTree exit() {
        if (children.isEmpty() && parent != null) 
            parent.children.remove(parentIndex);
        return parent;
    }

    public void add(GenericTestCase tc) {
        children.add(tc);
    }

    public String getName() {
        return name;
    }

    public int numChildren() {
        return children.size();
    }

    public Iterator<GenericTestTreeNode> iterator() {
        return children.iterator();
    }
}
