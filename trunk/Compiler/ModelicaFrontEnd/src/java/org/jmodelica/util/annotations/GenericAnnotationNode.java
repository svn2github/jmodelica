/*
    Copyright (C) 2017 Modelon AB

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
package org.jmodelica.util.annotations;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmodelica.util.annotations.AnnotationProvider.SubNodePair;

/**
 * Generic class for handling traversal over different types of annotations.
 * Mainly in the source and flat tree.
 * 
 * In several places in the code we have to upcast a variable in order to
 * assign a field or call a method. This is due to the field or method being
 * private and the local variable of a subtype. See
 * http://stackoverflow.com/questions/20672840/has-private-access-error-with-generics
 * for a good explanation.
 * 
 * @param <T> The sub-type of AnnotationNode which we are operating on
 * @param <N> The base node type which we deal with
 * @param <V> The value that is returned by the nodes
 */
public abstract class GenericAnnotationNode<T extends GenericAnnotationNode<T, N, V>, N extends AnnotationProvider<N, V>, V> {
    
    private final String name;
    private N node;
    private final T parent;

    private volatile Collection<T> subNodes_cache;
    private volatile Map<String, T> subNodesNameMap_cache;

    /**
     * Constructor. <code>name</code> may be null, some nodes simply do not have a name.
     * <code>node</code> may only be null for the instances returned by
     * {@link #ambiguousNode()} and {@link #missingNode()}.
     * 
     * @param name Name of the node, optionally null.
     * @param node The node that this annotation node represent.
     */
    protected GenericAnnotationNode(String name, N node, T parent) {
        this.name = name;
        this.node = node;
        this.parent = parent;
    }

    private void computeSubNodesCache() {
        if (subNodes_cache != null) {
            return;
        }
        if (!exists() || isAmbiguous()) {
            subNodes_cache = Collections.emptyList();
            subNodesNameMap_cache = Collections.emptyMap();
            return;
        }
        List<T> subNodes = new ArrayList<T>();
        Map<String, T> subNodesNameMap = new HashMap<String, T>();
        for (SubNodePair<N> subNodePair : node.annotationSubNodes()) {
            T subNode = createNode(subNodePair.name, subNodePair.node);
            if (subNode == null) {
                continue;
            }
            subNodes.add(subNode);
            T previous = subNodesNameMap.put(subNode.name(), subNode);
            if (previous != null) {
                subNodesNameMap.put(subNode.name(), ambiguousNode());
            }
        }
        subNodes_cache = Collections.unmodifiableList(subNodes);
        subNodesNameMap_cache = Collections.unmodifiableMap(subNodesNameMap);
    }

    private void resetSubNodesCache() {
        subNodes_cache = null;
    }

    /**
     * Navigate downwards in the annotation tree. The first element in the path
     * list is resolved relative this node. Then the resolved node is used to
     * resolve the next one and so on.
     * @param path List of path elements to resolve
     * @return the resolved node
     */
    public T forPath(String ... path) {
        return forPath(path, 0);
    }

    private T forPath(String[] paths, int currentIndex) {
        if (isAmbiguous()) {
            return ambiguousNode();
        }
        if (currentIndex == paths.length) {
            return self();
        }
        computeSubNodesCache();
        GenericAnnotationNode<T, N, V> subNode = subNodesNameMap_cache.get(paths[currentIndex]);
        if (subNode == null) {
            return createNode(paths[currentIndex], null);
        }
        return subNode.forPath(paths, currentIndex + 1);
    }

    /**
     * Returns reference to it self, but with correct type! This pattern
     * ensures that all nodes have the same type as T.
     * All implementations of this method should simply return
     * <code>this</code>.
     * 
     * @return This node but with correct type
     */
    protected abstract T self();

    /**
     * Creates an annotation node representing the given name and node. One can
     * assume that it is a child of this node.
     * If null is returned, then the node will be filtered!
     * 
     * @param name Name of the new node
     * @param node The node which the annotation node is representing
     * @return An annotation node representing name and node
     */
    protected abstract T createNode(String name, N node);

    private N createChild(GenericAnnotationNode<T, N, V> child) throws AnnotationEditException {
        N res = node().addAnnotationSubNode(child.name());
        if (res == null) {
            throw new AnnotationEditException(child, "Unable to create sub node");
        }
        resetSubNodesCache();
        return res;
    }

    /**
     * Method for checking if this node has sub-nodes.
     * 
     * @return true if this node has sub nodes, otherwise false.
     */
    public boolean hasSubNodes() {
        computeSubNodesCache();
        return !subNodes_cache.isEmpty();
    }

    /**
     * Provides a list of sub nodes for this node.
     * 
     * @return a list with all sub-nodes
     */
    public Iterable<T> subNodes() {
        computeSubNodesCache();
        return subNodes_cache;
    }

    /**
     * @return the node that this annotation node represents
     * 
     * @throws AnnotationEditException may be thrown if the node doesn't exist
     *          and it wasn't possible to create.
     */
    public N node() throws AnnotationEditException {
        if (!exists()) {
            if (parent == null) {
                // This is an null pattern node without hope of creating
                return null;
            }
            node = ((GenericAnnotationNode<T, N, V>) parent).createChild(this);
            resetSubNodesCache();
        }
        return node;
    }

    /**
     * 
     * @return the name of this annotation node, can be null
     */
    public String name() {
        return name;
    }

    /**
     * 
     * @return true if this node has a value, otherwise false
     */
    public boolean hasValue() {
        return value() != null;
    }

    /**
     * 
     * @return the value of this node, if it has one, otherwise null
     */
    public V value() {
        if (!exists() || isAmbiguous()) {
            return null;
        }
        return node.annotationValue();
    }

    /**
     * Assigns a new value to this annotation and the actual node that this
     * annotation represents.
     * 
     * @param newValue The new value
     * @throws AnnotationEditException if it either wasn't possible to create
     *          the node or set the value of the node.
     */
    public void setValue(V newValue) throws AnnotationEditException {
        try {
            node().setAnnotationValue(newValue);
        } catch (FailedToSetAnnotationValueException e) {
            throw new AnnotationEditException(this, e);
        }
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        try {
            toString(sb);
        } catch (IOException e) {
            // Not possible, sb.append() does not throw IOException...
        }
        return sb.toString();
    }

    public void toString(Appendable out) throws IOException {
        if (name() != null) {
            out.append(name());
        }
        if (hasSubNodes()) {
            out.append('(');
            boolean first = true;
            for (T subNode : subNodes()) {
                if (!first) {
                    out.append(", ");
                }
                first = false;
                subNode.toString(out);
            }
            out.append(')');
        }
        if (hasValue()) {
            out.append('=');
            out.append(value().toString());
        }
    }

    /**
     * 
     * @return true if this node is ambiguous, otherwise false
     */
    public boolean isAmbiguous() {
        return this == ambiguousNode();
    }

    /**
     * 
     * @return true if this node does exist.
     */
    public boolean exists() {
        return node != null || isAmbiguous();
    }

    /**
     * Should return a singleton object which represent an ambiguous node.
     * It is crucial that this is the same object each time!
     * 
     * @return a node representing an ambiguous node
     */
    protected abstract T ambiguousNode();

    /**
     * Returns true if the each keyword is set
     * 
     * @return true if each is set
     */
    public boolean isEach() {
        return node().isEach();
    }

    /**
     * Returns true if the final keyword is set
     * 
     * @return true if final is set
     */
    public boolean isFinal() {
        return node().isFinal();
    }
    
    /**
     * Returns the parent node.
     * 
     * @return the parent node.
     */
    protected T parent() {
        return parent;
    }

}
