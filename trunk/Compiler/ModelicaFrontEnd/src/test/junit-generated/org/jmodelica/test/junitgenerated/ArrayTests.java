package org.jmodelica.test.junitgenerated;

import org.junit.*;
import static org.junit.Assert.*;
import org.jmodelica.modelica.compiler.*;

public class ArrayTests {

  static TestSuite ts;

  @BeforeClass public static void setUp() {
    ts = new TestSuite("src/test/modelica/ArrayTests.mo","ArrayTests");
  }

  @Test public void ArrayTest1() {
    assertTrue(ts.get(0).testMe());
  }

  @Test public void ArrayTest1b() {
    assertTrue(ts.get(1).testMe());
  }

  @Test public void ArrayTest2() {
    assertTrue(ts.get(2).testMe());
  }

  @AfterClass public static void tearDown() {
    ts = null;
  }

}

