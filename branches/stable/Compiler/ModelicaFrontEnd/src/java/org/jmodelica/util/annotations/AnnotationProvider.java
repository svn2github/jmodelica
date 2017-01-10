package org.jmodelica.util.annotations;

/**
 * Generic interface which all nodes that are supposed to be navigable by
 * {@code GenericAnnotationNode}.
 * 
 * @param <N> The base node type which we deal with
 * @param <V> The value that is returned by the nodes
 */
public interface AnnotationProvider<N, V> {
    public Iterable<SubNodePair<N>> annotationSubNodes();
    public V annotationValue();

    public class SubNodePair<N> {
        public final String name;
        public final N node;
        public SubNodePair(String name, N node) {
            this.name = name;
            this.node = node;
        }
    }
}
