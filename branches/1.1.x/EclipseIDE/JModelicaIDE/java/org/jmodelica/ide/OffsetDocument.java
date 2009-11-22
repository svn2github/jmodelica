package org.jmodelica.ide;

import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;

public class OffsetDocument extends Document {
    
    public int offset;

    public OffsetDocument(String s) {
        this(
            s.replaceFirst("\\^", ""),
            Math.max(0, s.indexOf("^")));
    }

    public OffsetDocument(String s, int offset) {
        super(s);
        this.offset = offset;
    }
    
    public OffsetDocument(IDocument doc, int offset) {
        this(doc.get(), offset);
    }
    
}
