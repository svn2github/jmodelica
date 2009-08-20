package org.jmodelica.test.junitgenerated;

import org.junit.*;
import static org.junit.Assert.*;
import org.jmodelica.modelica.compiler.*;

public class ModificationTests {

  static TestSuite ts;

  @BeforeClass public static void setUp() {
    ts = new TestSuite("src/test/modelica/ModificationTests.mo","ModificationTests");
  }

  @Test public void ModTest1() {
    assertTrue(ts.get(0).testMe());
  }

  @Test public void ModTest2() {
    assertTrue(ts.get(1).testMe());
  }

  @Test public void ModTest3() {
    assertTrue(ts.get(2).testMe());
  }

  @Test public void ModTest5() {
    assertTrue(ts.get(3).testMe());
  }

  @Test public void ModTest6() {
    assertTrue(ts.get(4).testMe());
  }

  @Test public void ModTest7() {
    assertTrue(ts.get(5).testMe());
  }

  @Test public void ModTest8() {
    assertTrue(ts.get(6).testMe());
  }

  @Test public void ModTest9() {
    assertTrue(ts.get(7).testMe());
  }

  @Test public void ModTest10() {
    assertTrue(ts.get(8).testMe());
  }

  @Test public void ModTest11() {
    assertTrue(ts.get(9).testMe());
  }

  @Test public void ModTest12() {
    assertTrue(ts.get(10).testMe());
  }

  @Test public void ModTest13_Err() {
    assertTrue(ts.get(11).testMe());
  }

  @Test public void ModTest14_Err() {
    assertTrue(ts.get(12).testMe());
  }

  @Test public void ModTest15_Err() {
    assertTrue(ts.get(13).testMe());
  }

  @Test public void ShortClassDeclModTest1() {
    assertTrue(ts.get(14).testMe());
  }

  @Test public void ShortClassDeclModTest2() {
    assertTrue(ts.get(15).testMe());
  }

  @Test public void ShortClassDeclModTest3() {
    assertTrue(ts.get(16).testMe());
  }

  @AfterClass public static void tearDown() {
    ts = null;
  }

}

