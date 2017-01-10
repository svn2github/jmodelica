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
 * @param <T> The sub-type of AnnotationNode which we are operating on
 * @param <N> The base node type which we deal with
 * @param <V> The value that is returned by the nodes
 */
public abstract class GenericAnnotationNode<T extends GenericAnnotationNode<T, N, V>, N extends AnnotationProvider<N, V>, V> {
    
    private final String name;
    private final N node;

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
    protected GenericAnnotationNode(String name, N node) {
        this.name = name;
        this.node = node;
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

    protected T forPath(String[] paths, int currentIndex) {
        if (!exists()) {
            return missingNode();
        }
        if (isAmbiguous()) {
            return ambiguousNode();
        }
        if (currentIndex == paths.length) {
            return self();
        }
        computeSubNodesCache();
        T subNode = subNodesNameMap_cache.get(paths[currentIndex]);
        if (subNode == null) {
            return missingNode();
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
     * 
     * @return the node that this annotation node represents
     */
    public N getNode() {
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
     * @return true if this node doesn't exist.
     */
    public boolean exists() {
        return this != missingNode();
    }

    /**
     * Should return a singleton object which represent an ambiguous node.
     * It is crucial that this is the same object each time!
     * 
     * @return a node representing an ambiguous node
     */
    protected abstract T ambiguousNode();

    /**
     * Should return a singleton object which represent an missing node.
     * It is crucial that this is the same object each time!
     * 
     * @return a node representing a missing node
     */
    protected abstract T missingNode();

}
