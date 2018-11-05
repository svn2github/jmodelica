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

import org.jmodelica.common.URIResolver.URIException;
import org.jmodelica.util.values.Evaluable;

/**
 * Generic interface which all nodes that are supposed to be navigable by
 * {@code GenericAnnotationNode}. This include modifications and annotations.
 * Provides methods for traversing the tree structure and manipulate the data.
 * 
 * @param <N> The base node type which we deal with
 * @param <V> The value that is returned by the nodes
 */
public interface AnnotationProvider<N extends AnnotationProvider<N, V>, V extends Evaluable> {
    public Iterable<SubNodePair<N>> annotationSubNodes();
    public V annotationValue();

    /**
     * Change the value of this Annotation/modification if possible.
     * @param newValue The new value
     * @throws FailedToSetAnnotationValueException If the value cannot be changed.
     */
    public void setAnnotationValue(V newValue) throws FailedToSetAnnotationValueException;
    
    /**
     * Create a new subannotation for the given name
     * @param name The name to create a subannotation for.
     * @return The annotationProvider for the new subannotation.
     * @throws AnnotationEditException If the subannotation cannot be created.
     */
    public N addAnnotationSubNode(String name) throws AnnotationEditException;
    
    public boolean isEach();
    public boolean isFinal();
    public String resolveURI(String str) throws URIException;

    public class SubNodePair<N> {
        public String name;
        public final N node;
        public SubNodePair(String name, N node) {
            this.name = name;
            this.node = node;
        }
    }
    
}
