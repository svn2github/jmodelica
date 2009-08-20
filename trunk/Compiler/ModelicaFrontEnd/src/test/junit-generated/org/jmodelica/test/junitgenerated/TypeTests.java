package org.jmodelica.test.junitgenerated;

import org.junit.*;
import static org.junit.Assert.*;
import org.jmodelica.modelica.compiler.*;

public class TypeTests {

  static TestSuite ts;

  @BeforeClass public static void setUp() {
    ts = new TestSuite("src/test/modelica/TypeTests.mo","TypeTests");
  }

  @Test public void TypeTest1() {
    assertTrue(ts.get(0).testMe());
  }

  @Test public void TypeTest2() {
    assertTrue(ts.get(1).testMe());
  }

  @Test public void TypeTest3() {
    assertTrue(ts.get(2).testMe());
  }

  @Test public void TypeTest4() {
    assertTrue(ts.get(3).testMe());
  }

  @Test public void TypeTest5() {
    assertTrue(ts.get(4).testMe());
  }

  @AfterClass public static void tearDown() {
    ts = null;
  }

}

