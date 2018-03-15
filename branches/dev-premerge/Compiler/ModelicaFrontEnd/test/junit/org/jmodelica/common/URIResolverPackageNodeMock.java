package org.jmodelica.common;

import org.jmodelica.common.URIResolver.PackageNode;

public class URIResolverPackageNodeMock implements PackageNode {
    private boolean hasError = false;

    public boolean hasError() {
        return hasError;
    }

    @Override
    public String fileName() {
        return "fileName";
    }

    @Override
    public String packagePath(String authority) {
        return authority.equals("pack") ? "C:/packpath" : null;
    }

    @Override
    public String topPackagePath() {
        return "C:/toppath";
    }

    @Override
    public void error(String format, Object... args) {
        hasError = true;
    }
}