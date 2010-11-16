package org.jmodelica.ide.preferences;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.core.runtime.preferences.DefaultScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.IPreferencesService;
import org.eclipse.core.runtime.preferences.IScopeContext;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Display;
import org.jmodelica.ide.Activator;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.scanners.HilightScanner;

public class Preferences extends AbstractPreferenceInitializer {

	private static final int BUF_SIZE = 2048;
	private byte buf[] = new byte[BUF_SIZE];

	public Preferences() {
	}
	
	public static String get(String key) {
		IPreferencesService service = Platform.getPreferencesService();
		return service.getString(IDEConstants.PLUGIN_ID, key, null, null);
	}
	
	public static Token getColorToken(String key) {
		return SyntaxColorPref.getPref(key).getToken();
	}
	
	public static Color getColor(String key) {
		return readColor(get(key));
	}

	public static void set(String key, String value) {
		new InstanceScope().getNode(IDEConstants.PLUGIN_ID).put(key, value);
	}

	public static void setColor(String key, Color value) {
		set(key, writeColor(value));
	}

	public static void update(String key, String value) {
		if (value != null && !value.isEmpty())
			set(key, value);
		else
			clear(key);
	}

	public static void clear(String key) {
		new InstanceScope().getNode(IDEConstants.PLUGIN_ID).remove(key);
	}
	
	public static String get(IProject proj, String key) {
		IPreferencesService service = Platform.getPreferencesService();
		IScopeContext[] contexts = new IScopeContext[] { new ProjectScope(proj) };
		return service.getString(IDEConstants.PLUGIN_ID, key, null, contexts);
	}
	
	public static void set(IProject proj, String key, String value) {
		new ProjectScope(proj).getNode(IDEConstants.PLUGIN_ID).put(key, value);
	}

	public static void update(IProject proj, String key, String value) {
		if (value != null && !value.isEmpty())
			set(key, value);
		else
			clear(key);
	}

	public static void clear(IProject proj, String key) {
		new ProjectScope(proj).getNode(IDEConstants.PLUGIN_ID).remove(key);
	}

	@Override
	public void initializeDefaultPreferences() {
		Activator plugin = Activator.getDefault();
		
		// Read default values from environment vars
		String jmodelicaHome = System.getenv("JMODELICA_HOME");
		String modelicaPath = System.getenv("MODELICAPATH");

		// Calculate proper defaults from environment vars
		if (modelicaPath == null && jmodelicaHome != null) {
			modelicaPath = jmodelicaHome
					+ "/ThirdParty/MSL".replace('/', File.separatorChar);
		}
		String optionsPath = (jmodelicaHome != null) ? 
				(jmodelicaHome + File.separator + "Options") : "";
		
		// If no MODELICAPATH can be calculated, try to extract MSL from plugin
		if (modelicaPath == null) 
			modelicaPath = getExtractedMSLPath();
		if (modelicaPath == null) 
			modelicaPath = "";

		// Store calculated values
		IEclipsePreferences node = new DefaultScope().getNode(IDEConstants.PLUGIN_ID);
		node.put(IDEConstants.PREFERENCE_LIBRARIES_ID, modelicaPath);
		node.put(IDEConstants.PREFERENCE_OPTIONS_PATH_ID, optionsPath);
		
		// Store default colors
		for (SyntaxColorPref pref : HilightScanner.COLOR_DEFS)
			node.put(pref.getPrefId(), pref.toString());
		Color annoBG = new Color(Display.getCurrent(), HilightScanner.DEFAULT_ANNO_BG);
		node.put(IDEConstants.PREFERENCE_ANNO_BG, writeColor(annoBG));
		HilightScanner.readColors();
	}

	protected String getExtractedMSLPath() {
		String dir = Activator.getDefault().getStateLocation().toOSString();
		File mslDirPath = new File(dir, "MSL");
		if (!mslDirPath.isDirectory()) {
			try {
				extractMSL(mslDirPath);
			} catch (SecurityException e) {
				return null;
			} catch (IOException e) {
				return null;
			}
		}
		return mslDirPath.getAbsolutePath();
	}

	protected void extractMSL(File mslDirPath) throws IOException, SecurityException {
		// TODO: this takes a little while - show progress bar?
		if (mslDirPath.isFile())
			mslDirPath.delete();
		mslDirPath.mkdir();
		ZipInputStream zis = new ZipInputStream(openResource(IDEConstants.MSL_ZIP_URL));
		ZipEntry entry;
		while ((entry = zis.getNextEntry()) != null) {
			File path = new File(mslDirPath, entry.getName());
			if (entry.isDirectory())
				path.mkdir();
			else
				saveFile(zis, path);
		}
		zis.close();
	}

	protected InputStream openResource(String url) throws IOException {
		return new URL(url).openConnection().getInputStream();
	}

	protected void saveFile(InputStream is, File path) throws IOException {
		int count;
		FileOutputStream fos = new FileOutputStream(path);
		BufferedOutputStream dest = new BufferedOutputStream(fos, BUF_SIZE);
		while ((count = is.read(buf, 0, BUF_SIZE)) != -1)
			dest.write(buf, 0, count);
		dest.close();
	}
	
	protected static Color readColor(String str) {
		if (str.equals("-"))
			return null;
		String[] parts = str.split(":");
		int r = Integer.parseInt(parts[0]), g = Integer.parseInt(parts[1]), b = Integer.parseInt(parts[2]);
		return new Color(Display.getCurrent(), r, g, b);
	}

	protected static String writeColor(Color col) {
		if (col == null) {
			return "-";
		} else {
			StringBuilder buf = new StringBuilder();
			buf.append(col.getRed());
			buf.append(':');
			buf.append(col.getGreen());
			buf.append(':');
			buf.append(col.getBlue());
			return buf.toString();
		}
	}

	// TODO: Add support for handling annotations separately (they should have option "use standard annotation background")
	// TODO: Add a map of colors to reuse the for references - this requires it to be updated when prefs change - listener?
	// TODO: will probably need to merge in ref into base class
	public abstract static class SyntaxColorPref {
		protected static final int TYPE_NORM = 1;
		protected static final int TYPE_REF  = 2;
		protected static final int TYPE_DIS  = 3;
		protected static final int TYPE_ANNO = 4;
		protected static final int TYPE_MASK = 3;
		
		protected static final int FLAG_ENABLED = 1;
		protected static final int FLAG_ANNO_BG = 2;
		protected static final int FLAG_USE_ANNO_BG = 3;

		public String key;
		protected int flags;
		protected int type;
		
		public SyntaxColorPref(String key, boolean enabled) {
			this.key = key;
			flags = enabled ? FLAG_ENABLED : 0;
			type = 0;
		}
		
		public SyntaxColorPref(String key, boolean enabled, boolean annoBG) {
			this.key = key;
			flags = (enabled ? FLAG_ENABLED : 0) + (annoBG ? FLAG_ANNO_BG : 0);
			type = TYPE_ANNO;
		}

		protected SyntaxColorPref(String key, String[] parts) {
			this.key = key;
			type = Integer.parseInt(parts[0]);
			flags = Integer.parseInt(parts[1]);
		}

		public Token getToken() {
			TextAttribute attr = isEnabled() ? getTextAttr(0) : new TextAttribute(null);
			if ((flags & FLAG_USE_ANNO_BG) == FLAG_USE_ANNO_BG) {
				Color bg = getColor(IDEConstants.PREFERENCE_ANNO_BG);
				attr = new TextAttribute(attr.getForeground(), bg, attr.getStyle());
			}
			return new Token(attr);
		}
		
		public boolean isEnabled() {
			return (flags & FLAG_ENABLED) != 0;
		}
		
		public boolean isAnnotationBG() {
			return (flags & FLAG_ANNO_BG) != 0;
		}

		public String getPrefId() {
			return getPrefId(key);
		}
		
		public static String getPrefId(String key) {
			return IDEConstants.PREFERENCE_COLOR_PREFIX + key;
		}

		protected abstract TextAttribute getTextAttr(int depth);

		public static SyntaxColorPref getPref(String key) {
			String[] parts = Preferences.get(getPrefId(key)).split(",");
			int type = Integer.parseInt(parts[0]);
			switch (type & TYPE_MASK) {
			case TYPE_NORM:
				return new NormalSyntaxColorPref(key, parts);
			case TYPE_REF:
				return new ReferenceSyntaxColorPref(key, parts);
			case TYPE_DIS:
				return new DisabledSyntaxColorPref(key, parts);
			default:
				return null;
			}
		}
		
		public void setPref() {
			Preferences.set(getPrefId(), toString());
		}
		
		public void clearPref() {
			Preferences.clear(getPrefId());
		}

		public String toString() {
			StringBuilder buf = new StringBuilder();
			buf.append(type);
			buf.append(',');
			buf.append(flags);
			completeString(buf);
			return buf.toString();
		}

		protected abstract void completeString(StringBuilder buf);
	}
	
	public static class NormalSyntaxColorPref extends SyntaxColorPref {
		public Color fg;
		public Color bg;
		public int style;
		
		public NormalSyntaxColorPref(String key, boolean enabled, Color fg, Color bg, int style) {
			super(key, enabled);
			this.fg = fg;
			this.bg = bg;
			this.style = style;
			type += TYPE_NORM;
		}
		
		public NormalSyntaxColorPref(String key, boolean enabled, Color fg, Color bg, int style, boolean annoBG) {
			super(key, enabled, annoBG);
			this.fg = fg;
			this.bg = bg;
			this.style = style;
			type += TYPE_NORM;
		}
		
		public NormalSyntaxColorPref(String key, RGB fg, RGB bg, int style) {
			this(key, true, rgbToColor(fg), rgbToColor(bg), style);
		}
		
		public NormalSyntaxColorPref(String key, RGB fg, RGB bg, int style, boolean annoBG) {
			this(key, true, rgbToColor(fg), rgbToColor(bg), style, annoBG);
		}
		
		protected static Color rgbToColor(RGB rgb) {
			return rgb == null ? null : new Color(Display.getCurrent(), rgb);
		}

		protected NormalSyntaxColorPref(String key, String[] parts) {
			super(key, parts);
			fg = readColor(parts[2]);
			bg = readColor(parts[3]);
			style = Integer.parseInt(parts[4]);
		}

		protected TextAttribute getTextAttr(int depth) {
			return new TextAttribute(fg, bg, style);
		}

		protected void completeString(StringBuilder buf) {
			buf.append(',');
			buf.append(writeColor(fg));
			buf.append(',');
			buf.append(writeColor(bg));
			buf.append(',');
			buf.append(style);
		}
	}

	public static class ReferenceSyntaxColorPref extends SyntaxColorPref {
		public String ref;

		public ReferenceSyntaxColorPref(String key, boolean enabled, String ref) {
			super(key, enabled);
			this.ref = ref;
			type += TYPE_REF;
		}

		public ReferenceSyntaxColorPref(String key, boolean enabled, String ref, boolean annoBG) {
			super(key, enabled, annoBG);
			this.ref = ref;
			type += TYPE_REF;
		}

		public ReferenceSyntaxColorPref(String key, String ref) {
			this(key, true, ref);
		}

		public ReferenceSyntaxColorPref(String key, String ref, boolean annoBG) {
			this(key, true, ref, annoBG);
		}

		protected ReferenceSyntaxColorPref(String key, String[] parts) {
			super(key, parts);
			ref = parts[2];
		}

		protected TextAttribute getTextAttr(int depth) {
			if (depth > HilightScanner.COLOR_DEFS.length)
				return new TextAttribute(null);
			return getPref(ref).getTextAttr(depth + 1);
		}

		protected void completeString(StringBuilder buf) {
			buf.append(',');
			buf.append(ref);
		}
	}
	
	public static class DisabledSyntaxColorPref extends SyntaxColorPref {

		public DisabledSyntaxColorPref(String key, boolean isAnno) {
			super(key, false);
			type = TYPE_DIS | (isAnno ? TYPE_ANNO : 0);
		}

		public DisabledSyntaxColorPref(String key) {
			this(key, false);
		}

		protected DisabledSyntaxColorPref(String key, String[] parts) {
			super(key, parts);
		}

		protected TextAttribute getTextAttr(int depth) {
			return null;
		}

		protected void completeString(StringBuilder buf) {}
		
	}

}
