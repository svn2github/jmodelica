package LibraryTests

model LibraryTest1
        extends TestLib.M;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="LibraryTest1",
            description="Test compiling with a custom library",
            modelicaLibraries="TestLib",
            flatModel="
fclass LibraryTests.LibraryTest1
 Real x;
equation
 x = time;
end LibraryTests.LibraryTest1;
")})));
end LibraryTest1;

model LibraryTest2
        extends TestLib.Sub.M;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="LibraryTest2",
            description="Test compiling with a custom library",
            modelicaLibraries="TestLib",
            flatModel="
fclass LibraryTests.LibraryTest2
 Real x;
equation
 x = time;
end LibraryTests.LibraryTest2;
")})));
end LibraryTest2;

end LibraryTests;