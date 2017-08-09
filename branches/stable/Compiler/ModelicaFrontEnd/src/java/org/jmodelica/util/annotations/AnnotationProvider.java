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

import org.jmodelica.util.values.Evaluable;

/**
 * Generic interface which all nodes that are supposed to be navigable by
 * {@code GenericAnnotationNode}.
 * 
 * @param <N> The base node type which we deal with
 * @param <V> The value that is returned by the nodes
 */
public interface AnnotationProvider<N extends AnnotationProvider<N, V>, V extends Evaluable> {
    public Iterable<SubNodePair<N>> annotationSubNodes();
    public V annotationValue();
    public void setAnnotationValue(V newValue) throws FailedToSetAnnotationValueException;
    public N addAnnotationSubNode(String name) throws AnnotationEditException;
    public boolean isEach();
    public boolean isFinal();
    public String resolveURI(String str);

    public class SubNodePair<N> {
        public final String name;
        public final N node;
        public SubNodePair(String name, N node) {
            this.name = name;
            this.node = node;
        }
    }
}
