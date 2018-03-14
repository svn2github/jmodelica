package org.jmodelica.common;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

public class URIResolver {

    public interface PackageNode {
        String fileName();

        String packagePath(String authority);

        String topPackagePath();

        void error(String format, Object... args);
    }

    public class URIException extends Exception {
        private static final long serialVersionUID = -2945381968691052204L;

    }

    public static final URIResolver DEFAULT = new URIResolver();

    URIResolver() {

    }

    /**
     * Convert file to a canonical path, if possible.
     * 
     * On Windows, backslash is converted to forward slash, to make testing
     * easier.
     */
    public String canonicalPath(File path) {
        String res;
        try {
            res = path.getCanonicalPath();
        } catch (IOException e) {
            res = path.getAbsolutePath();
        }
        if (separatorChar() == '\\') {
            res = res.replace('\\', '/');
        }
        return res;
    }

    /**
     * Resolves <code>str</code> to an absolute file path.
     * 
     * Supports file URI and modelica URI only. Returns null for unsupported
     * schemes and malformed URIs.
     */
    public String resolveURI(PackageNode n, String str) {
        return resolveURI(n, str, false);
    }

    /**
     * Resolves <code>str</code> to an absolute file path.
     * 
     * Supports file URI and modelica URI only. Returns null for unsupported
     * schemes and malformed URIs. If error is true, also generate an error for
     * unsupported schemes.
     */
    public String resolveURI(PackageNode n, String str, boolean error) {
        try {
            URI uri = new URI(str);
            String scheme = scheme(uri);
            if (scheme != null) {
                if (scheme.equalsIgnoreCase("file")) {
                    return uri.getPath();
                } else if (scheme.equalsIgnoreCase("modelica")) {
                    String pack = n.packagePath(uri.getAuthority());
                    if (pack != null) {
                        return canonicalPath(new File(pack + uri.getPath()));
                    }
                } else if (error) {
                    n.error("Unsupported URI scheme '%s'.", scheme.toLowerCase());
                }
            }
        } catch (URISyntaxException e) {
        }
        return null;
    }

    /**
     * Resolves <code>str</code> to an absolute file path. Supports file URI,
     * modelica URI, absolute file path and relative file path (w.r.t. current
     * working directory)
     */
    public String resolve(PackageNode n, String str) {
        String path = resolveURI(n, str, true);
        if (path != null) {
            return path;
        } else {
            return canonicalPath(new File(str));
        }
    }

    /**
     * Converts an URI to a file-system path.
     * 
     * Only modelica:// and file:// URIs are supported. If the string is a
     * simple path, then it is interpreted as relative to the top level package
     * this node is in, or if that path does not exist, relative to the parent
     * directory the file this node is in.
     * 
     * @param str
     *            the string to interpret as an URI
     */
    public String resolveInPackage(PackageNode n, String str) {
        String path = resolveURI(n, str, true);
        if (path != null) {
            return path;
        } else {
            String pack = n.topPackagePath();
            if (pack != null) {
                File f = new File(pack, str);
                if (exists(f)) {
                    return canonicalPath(f);
                }
                File dir = new File(n.fileName()).getParentFile();
                return canonicalPath(new File(dir, str));
            }
        }
        return null;
    }

    public String resolveURIChecked(PackageNode n, String str) throws URIException {
        String res = resolveURI(n, str, false);
        if (res == null) {
            throw new URIException();
        }
        return res;
    }

    /*
     * Utils to improve testability
     */

    boolean exists(File f) {
        return f.exists();
    }

    char separatorChar() {
        return File.separatorChar;
    }

    String scheme(URI uri) {
        return uri.getScheme();
    }
}
