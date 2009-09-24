/*
    Copyright (C) 2009 Modelon AB

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
package org.jmodelica.ide;

import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.jface.text.IDocument;
import org.eclipse.swt.graphics.RGB;
import org.jmodelica.generated.scanners.Modelica22PartitionScanner;

public class IDEConstants {

	public static final String PLUGIN_ID = "org.jmodelica.ide";
	public static final String NATURE_ID = PLUGIN_ID + ".nature";
	public static final String EDITOR_ID = PLUGIN_ID + ".editor";
	public static final String CONTENT_TYPE_ID = PLUGIN_ID + ".content";
	public static final String PERSPECTIVE_ID = PLUGIN_ID + ".perspective";

	public static final String ERROR_MARKER_ID = PLUGIN_ID + ".marker.error";

	public static final String FILE_EXT = "mo";
	public static final String[] ALL_FILE_EXTENSIONS = { FILE_EXT };
	
	public static final String ACTION_ID = PLUGIN_ID + ".action";
	public static final String ACTION_EXPAND_ALL_ID = ACTION_ID + ".expand-all";
	public static final String ACTION_COLLAPSE_ALL_ID = ACTION_ID + ".collapse-all";
	public static final String ACTION_ERROR_CHECK_ID = ACTION_ID + ".error.check";
	public static final String ACTION_ERROR_CHECK_TEXT = "Check for &errors";
	public static final String ACTION_TOGGLE_ANNOTATIONS_ID = ACTION_ID + ".annotation";
	public static final String ACTION_TOGGLE_ANNOTATIONS_TEXT = "Show &annotations";
	public static final String ACTION_FORMAT_REGION_ID = ACTION_ID + ".format-region";
    public static final String ACTION_FORMAT_REGION_TEXT = "&Format region";
    public static final String ACTION_TOGGLE_COMMENT_ID = ACTION_ID + ".toggle-comment";
    public static final String ACTION_TOGGLE_COMMENT_TEXT = "Toggle &Comment";
    public static final String ACTION_FOLLOW_REFERENCE_ID = ACTION_ID + ".gotodecl";
    public static final String ACTION_FOLLOW_REFERENCE_TEXT = "&Go to declaration";
    public static final String GROUP_ID = ACTION_ID + ".group";
	public static final String GROUP_MODELICA_ID = GROUP_ID + ".modelica";
	public static final String GROUP_ERROR_ID = GROUP_ID + ".error";
	
	public static final String PREFERENCE_ID = PLUGIN_ID + ".preference";
	public static final String KEY_BRACE_MATCHING = PREFERENCE_ID + ".brace-match";
	public static final String KEY_BRACE_MATCHING_COLOR = KEY_BRACE_MATCHING + ".color";

	public static final RGB BRACE_MATCHING_COLOR = new RGB(128, 128, 128);
	
	public static final QualifiedName PROPERTY_LIBRARIES_ID = new QualifiedName(PLUGIN_ID, "libraries");
	public static final QualifiedName PROPERTY_DEFAULT_MSL_ID = new QualifiedName(PLUGIN_ID, "default_msl");

	public static final String WIZARD_ID = PLUGIN_ID + ".wizard";
	public static final String WIZARD_FILE_ID = WIZARD_ID + ".file";
	public static final String WIZARD_PROJECT_ID = WIZARD_ID + ".project";
	
	public static final String VIEW_ID = PLUGIN_ID + ".view";
	public static final String INSTANCE_OUTLINE_VIEW_ID = VIEW_ID + ".outline.instance";

	public static final String[] CONFIGURED_CONTENT_TYPES;
	
	static {
		String[] a = Modelica22PartitionScanner.LEGAL_PARTITIONS;
		String[] b = new String[] { IDocument.DEFAULT_CONTENT_TYPE, CONTENT_TYPE_ID };
		CONFIGURED_CONTENT_TYPES = new String[a.length + b.length];
		System.arraycopy(a, 0, CONFIGURED_CONTENT_TYPES, 0, a.length);
		System.arraycopy(b, 0, CONFIGURED_CONTENT_TYPES, a.length, b.length);
	}

	public static final String PACKAGE_FILE = "package.mo";
}
