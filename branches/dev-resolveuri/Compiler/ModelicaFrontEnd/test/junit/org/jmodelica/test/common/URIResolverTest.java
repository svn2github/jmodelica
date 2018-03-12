package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.IOException;

import org.jmodelica.common.URIResolver;
import org.jmodelica.common.URIResolver.PackageNode;
import org.jmodelica.common.URIResolverMock;
import org.jmodelica.common.URIResolverPackageNodeMock;
import org.junit.Test;

public class URIResolverTest {

    /*
     * Test canonicalPath()
     */

    @Test
    public void testCanonicalPath() {
        String res = URIResolver.DEFAULT.canonicalPath(new File("C:/test.txt"));
        assertEquals("C:/test.txt", res);
    }

    @Test
    public void testCanonicalPathNoIO() {
        @SuppressWarnings("serial")
        String res = URIResolver.DEFAULT.canonicalPath(new File("C:/test.txt") {
            @Override
            public String getCanonicalPath() throws IOException {
                throw new IOException();
            }
        });
        assertEquals("C:/test.txt", res);
    }

    /*
     * Test resolveURI()
     */

    @Test
    public void testResolveURIPath() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "C:/pack/subpath");
        assertNull(res);
    }

    @Test
    public void testResolveURIModelicaCorrect() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "modelica://pack/subpath");
        assertEquals("C:/packpath/subpath", res);
    }

    @Test
    public void testResolveURIModelicaMissing() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "modelica://pack/subpath/missing");
        assertEquals("C:/packpath/subpath/missing", res);
    }

    @Test
    public void testResolveURIModelicaMissingPack() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "modelica://missing/subpath");
        assertNull(res);
    }

    @Test
    public void testResolveURIFileCorrect() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "file:///pack/subpath");
        assertEquals("/pack/subpath", res);
    }

    @Test
    public void testResolveURIFileIncorrect() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "file://pack/subpath");
        assertEquals("/subpath", res);
    }

    @Test
    public void testResolveURIFileMissing() {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURI(n, "file:///pack/subpath/missing");
        assertEquals("/pack/subpath/missing", res);
    }

    /*
     * Test resolve()
     */

    @Test
    public void testResolvePathCorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolve(n, "C:/pack/subpath");
        assertTrue(n.hasError());
        assertEquals("C:/pack/subpath", res);
    }

    @Test
    public void testResolvePathMissing() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolve(n, "C:/pack/subpath/missing");
        assertTrue(n.hasError());
        assertEquals("C:/pack/subpath/missing", res);
    }

    @Test
    public void testResolveModelicaCorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolve(n, "modelica://pack/subpath");
        assertEquals("C:/packpath/subpath", res);
    }

    /*
     * Test resolveInPackage()
     */

    @Test
    public void testResolveInPackageModelicaCorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveInPackage(n, "modelica://pack/subpath");
        assertEquals("C:/packpath/subpath", res);
    }

    @Test
    public void testResolveInPackageModelicaIncorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveInPackage(n, "modelica://pack2/subpath");
        String expected = System.getProperty("user.dir").replaceAll("\\\\", "/") + "/modelica:/pack2/subpath";
        assertEquals(expected, res);
    }

    @Test
    public void testResolveInPackageModelicaIncorrect2() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock() {
            @Override
            public String topPackagePath() {
                return null;
            }
        };
        String res = URIResolver.DEFAULT.resolveInPackage(n, "modelica://pack2/subpath");
        assertNull(res);
    }

    @Test
    public void testResolveInPackageModelicaIncorrect3() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = new URIResolverMock().resolveInPackage(n, "modelica://pack2/subpath");
        assertEquals("C:\\toppath\\modelica:\\pack2\\subpath", res);
    }
}
