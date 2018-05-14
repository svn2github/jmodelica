package annotationMock;

/**
 * Convenient constructors for DummyAnnotProvider
 */
public class Builder {

    public static DummyAnnotProvider newProvider(String name) {
        return new DummyAnnotProvider(name);
    }
    
    public static DummyAnnotProvider newProvider(String name, int value) {
        return new DummyAnnotProvider(name, value);
    }
    
    public static DummyAnnotProvider newProvider(String name, String value) {
        return new DummyAnnotProvider(name, value);
    }

}
