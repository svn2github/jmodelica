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

public class AnnotationEditException extends RuntimeException {
    
    private static final long serialVersionUID = 3169144097373344835L;

    public AnnotationEditException(GenericAnnotationNode<?, ?, ?> node, String reason) {
        super(reason + constructAnnotationStack(node));
    }

    public AnnotationEditException(GenericAnnotationNode<?, ?, ?> node, Exception e) {
        super(e.getMessage() + constructAnnotationStack(node), e);
    }

    private static String constructAnnotationStack(GenericAnnotationNode<?, ?, ?> node) {
        StringBuilder sb = new StringBuilder();
        sb.append(" for annotation path /");
        boolean first = true;
        while (node != null && node.name() != null) {
            if (!first) {
                sb.append('/');
            }
            first = false;
            sb.append(node.name());
        }
        return sb.toString();
    }
}
