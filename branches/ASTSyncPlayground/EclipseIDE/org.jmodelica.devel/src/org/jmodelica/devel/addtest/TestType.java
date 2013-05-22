package org.jmodelica.devel.addtest;

public enum TestType {
	
	Regenerate                  (null, true, "%1$s -r -w -c=%3$s"),
    CADCodeGenTestCase          ("Code template"), 
    CCodeGenTestCase            ("Code template"), 
    ComplianceErrorTestCase,
    ErrorTestCase,
    FClassMethodTestCase        ("Method name"), 
    FlatteningTestCase,
    GenericCodeGenTestCase      ("Code template"), 
    TransformCanonicalTestCase,
    WarningTestCase,
    XMLCodeGenTestCase          ("Code template"), 
    XMLValueGenTestCase         ("Code template");
    
    private static final String FORMAT_WITH_DATA = "%s -w -t=%s -c=%s %s";
	private static final String FORMAT_NO_DATA = "%s -w -t=%s -c=%s";
	
	private String data;
    private String format;
    private boolean separator;
    
    private TestType(String d) {
    	this(d, false, FORMAT_WITH_DATA);
    }
    
    private TestType() {
    	this(null, false, FORMAT_NO_DATA);
    }
    
    private TestType(String d, boolean sep, String fmt) {
    	data = d;
    	separator = sep;
    	format = fmt;
    }
    
    public String menuName() {
    	if (hasData())
    		return toString() + "...";
    	else
    		return toString();
    }
    
    public String dataDesc() {
    	return data;
    }

	public boolean hasData() {
		return data != null;
	}
	
	public boolean useSeparator() {
		return separator;
	}
	
	public String args(String fileName, String name, String data) {
		return String.format(format, fileName, toString(), name, data);
	}
    
}
