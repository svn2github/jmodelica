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
import org.jmodelica.util.values.ConstValue;
import org.jmodelica.util.values.ConstantEvaluationException;
import org.jmodelica.util.values.Evaluable;

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
public abstract class GenericAnnotationNode<T extends GenericAnnotationNode<T, N, V>,
        N extends AnnotationProvider<N, V>, V extends Evaluable> {

    /**
     * Vendor name.
     */
    public static final String VENDOR_NAME = "__Modelon";

    private final String name;
    private N node;
    private final T parent;

    private volatile Collection<T> subNodes_cache;
    private volatile Map<String, T> subNodesNameMap_cache;
    private volatile T valueAnnotation_cache;
    private volatile boolean valueAnnotation_cacheComputed = false;

    /**
     * Constructor. <code>name</code> may be null, some nodes simply do not have a name.
     * <code>node</code> may only be null for the instances returned by
     * {@link #ambiguousNode()} and nodes which doesn't exist yet.
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
            subNode = createNode(paths[currentIndex], null);
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
        if (child == valueAnnotation_cache) {
            // Trying to set the value annotation child
            throw new AnnotationEditException(this, "Not possible to set assign annotation value as annotation yet");
        }
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
     * Return the node that this annotation represents without creating if it
     * doesn't exist. I.e.: simply return what we know without creating
     * anything.
     * 
     * @return The underlying node if available
     */
    protected N peekNode() {
        return node;
    }

    /**
     * Tries to resolve the provided string as and URI.
     * 
     * @param str String to resolve as URI
     * @return canonical file:// URI or null on failure
     */
    public String resolveURI(String str) {
        if (node == null) {
            if (parent == null) {
                return null; // We did our best, we cant do more
            }
            return parent.resolveURI(str);
        }
        return node.resolveURI(str);
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

    /**
     * Interprets the value of this annotation as a sub annotation which can
     * be traversed and explored further.
     * 
     * @return An annotation representing the value of this annotation or null
     *          if it wasn't possible to interpret the value as an annotation.
     */
    public T valueAsAnnotation() {
        if (!valueAnnotation_cacheComputed) {
            valueAnnotation_cacheComputed = true;
            N annotationNode = valueAsProvider();
            if (hasValue() && annotationNode == null) {
                valueAnnotation_cache = null;
            } else {
                valueAnnotation_cache = createNode(null, annotationNode);
            }
        }
        return valueAnnotation_cache;
    }

    /**
     * If the provided value can be interpreted as an annotation node, then
     * this method should return the provider that reflects the value as an
     * annotation node.
     * 
     * @param value Value which can be an annotation node
     * @return Provider which reflects the value as annotation node
     */
    protected abstract N valueAsProvider();

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

    /**********************************
     *  Value checkers and retrieves
     *********************************/

    /**
     * Check if the value of this annotation entry represents a scalar boolean.
     * 
     * @return true if the value represent scalar boolean
     */
    public boolean isValueBoolean() {
        return getAndCheckConstValue(ValueType.BOOLEAN, ValueSize.SCALAR) != null;
    }

    /**
     * Interpret the value of this annotation entry as a scalar boolean.
     * 
     * @return boolean value of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as scalar boolean
     */
    public boolean valueAsBoolean() throws ConstantEvaluationException{
        return getAndCheckConstValue(ValueType.BOOLEAN, ValueSize.SCALAR, true).booleanValue();
    }

    /**
     * Check if the value of this annotation entry represents a scalar integer.
     * 
     * @return true if the value represent scalar integer
     */
    public boolean isValueInteger() {
        return getAndCheckConstValue(ValueType.INTEGER, ValueSize.SCALAR) != null;
    }

    /**
     * Interpret the value of this annotation entry as a scalar integer.
     * 
     * @return integer value of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as scalar integer
     */
    public int valueAsInteger() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.INTEGER, ValueSize.SCALAR, true).intValue();
    }

    /**
     * Check if the value of this annotation entry represents a integer vector.
     * 
     * @return true if the value represent integer vector
     */
    public boolean isValueIntegerVector() {
        return getAndCheckConstValue(ValueType.INTEGER, ValueSize.VECTOR) != null;
    }
    
    /**
     * Interpret the value of this annotation entry as a integer vector.
     * 
     * @return integer value of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as integer vector
     */
    public int[] valueAsIntegerVector() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.INTEGER, ValueSize.VECTOR, true).intVector();
    }
    
    /**
     * Check if the value of this annotation entry represents a scalar real.
     * 
     * @return true if the value represent scalar real
     */
    public boolean isValueReal() {
        return getAndCheckConstValue(ValueType.REAL, ValueSize.SCALAR) != null;
    }

    /**
     * Interpret the value of this annotation entry as a scalar real.
     * 
     * @return real value of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as scalar real
     */
    public double valueAsReal() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.REAL, ValueSize.SCALAR, true).realValue();
    }

    /**
     * Check if the value of this annotation entry represents a real vector.
     * 
     * @return true if the value represent real vector
     */
    public boolean isValueRealVector() {
        return getAndCheckConstValue(ValueType.REAL, ValueSize.VECTOR) != null;
    }

    /**
     * Interpret the value of this annotation entry as a real vector.
     * 
     * @return real vector of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as real vector
     */
    public double[] valueAsRealVector() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.REAL, ValueSize.VECTOR, true).realVector();
    }

    /**
     * Check if the value of this annotation entry represents a real matrix.
     * 
     * @return true if the value represent real matrix
     */
    public boolean isValueRealMatrix() {
        return getAndCheckConstValue(ValueType.REAL, ValueSize.MATRIX) != null;
    }

    /**
     * Interpret the value of this annotation entry as a real matrix.
     * 
     * @return real matrix of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as real matrix
     */
    public double[][] valueAsRealMatrix() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.REAL, ValueSize.MATRIX, true).realMatrix();
    }

    /**
     * Check if the value of this annotation entry represents a scalar string.
     * 
     * @return true if the value represent scalar string
     */
    public boolean isValueString() {
        return getAndCheckConstValue(ValueType.STRING, ValueSize.SCALAR) != null;
    }

    /**
     * Interpret the value of this annotation entry as a scalar string.
     * 
     * @return string value of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as scalar string
     */
    public String valueAsString() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.STRING, ValueSize.SCALAR, true).stringValue();
    }

    /**
     * Check if the value of this annotation entry represents a string vector.
     * 
     * @return true if the value represent string vector
     */
    public boolean isValueStringVector() {
        return getAndCheckConstValue(ValueType.STRING, ValueSize.VECTOR) != null;
    }

    /**
     * Interpret the value of this annotation entry as a string vector.
     * 
     * @return string vector of the entry value
     * @throws ConstantEvaluationException
     *      if there is no value or it can't be interpreted as string vector
     */
    public String[] valueAsStringVector() throws ConstantEvaluationException {
        return getAndCheckConstValue(ValueType.STRING, ValueSize.VECTOR, true).stringVector();
    }

    /*****************************************
     *  Value checkers and retrieves helpers
     ****************************************/
    private static enum ValueType {
        BOOLEAN {
            @Override
            public boolean check(ConstValue value) {
                return value.isBoolean();
            }
        },
        INTEGER {
            @Override
            public boolean check(ConstValue value) {
                return value.isInteger();
            }
        },
        STRING {
            @Override
            public boolean check(ConstValue value) {
                return value.isString() || value.isEnum();
            }
        },
        REAL {
            @Override
            public boolean check(ConstValue value) {
                return value.isReal();
            }
        };

        public abstract boolean check(ConstValue value);
    }

    private static enum ValueSize {
        SCALAR {
            @Override
            public boolean check(ConstValue value) {
                return value.isScalar();
            }
        },
        VECTOR {
            @Override
            public boolean check(ConstValue value) {
                return value.isVector();
            }
        },
        MATRIX {
            @Override
            public boolean check(ConstValue value) {
                return value.isMatrix();
            }
        };

        public abstract boolean check(ConstValue value);
    }

    /**
     * Helper which checks that the value of this annotation entry is set and
     * of specified size and type. If the size and type match, then the value
     * is returned, otherwise null is returned.
     * 
     * @param type Type which the value should have
     * @param size Size which the value should have
     * @return Value if it matches the size and type, otherwise null
     */
    private ConstValue getAndCheckConstValue(ValueType type, ValueSize size) {
        return getAndCheckConstValue(type, size, false);
    }

    /**
     * Helper which checks that the value of this annotation entry is set and
     * of specified size and type. If the size and type match, then the value
     * is returned, otherwise, depending on throwOnIncorrect and exception is 
     * thrown or null is returned.
     * 
     * @param type Type which the value should have
     * @param size Size which the value should have
     * @param throwOnIncorrect Whether the method should throw and exception
     *      or return null
     * @return Value if it matches the size and type, null if throwOnIncorrect
     *      is false
     * @throws ConstantEvaluationException if throwOnIncorrect is true and the
     *      value isn't set or doesn't match the size or type.
     */
    private ConstValue getAndCheckConstValue(ValueType type, ValueSize size, boolean throwOnIncorrect)
            throws ConstantEvaluationException {
        if (!hasValue()) {
            if (throwOnIncorrect) {
                throw new ConstantEvaluationException();
            } else {
                return null;
            }
        }
        ConstValue value = evaluatedValue();
        if (type.check(value) && size.check(value)) {
            return value;
        } else if (throwOnIncorrect) {
            throw new ConstantEvaluationException(value, "Cannot convert to " + size + " " + type);
        } else {
            return null;
        }
    }

    protected ConstValue evaluatedValue() {
        return value().evaluateValue();
    }

}
