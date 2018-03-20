package org.jmodelica.common;

import java.io.File;
import java.net.URI;

public class URIResolverMock extends URIResolver {
    @Override
    boolean exists(File f) {
        return true;
    }

    @Override
    char separatorChar() {
        return '/';
    }

    @Override
    String scheme(URI uri) {
        return null;
    }
}
