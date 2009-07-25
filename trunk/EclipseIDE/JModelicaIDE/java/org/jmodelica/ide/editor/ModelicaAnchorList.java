package org.jmodelica.ide.editor;

import java.util.LinkedList;
import java.util.Stack;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.jmodelica.ide.indent.Anchor;
import org.jmodelica.ide.indent.AnchorList;
import org.jmodelica.ide.indent.IndentedSection;
import org.jmodelica.ide.indent.IndentingAutoEditStrategy;


/**
 * Used by IndentationHintScanner to create a list of anchors annotating the
 * scanned modelica source code with indentation hints. The class maintains a
 * stack of current active anchors, while adding all seen anchors to a list used
 * later for lookup when indenting text.
 * 
 * @author philip
 */
public class ModelicaAnchorList implements AnchorList<Indent> {

protected Stack<Anchor<Indent>> stack;
protected LinkedList<Anchor<Indent>> anchors, sinks;

protected boolean partial_newline;

public final static Anchor<Indent> BOTTOM = new Anchor<Indent>(0, 0,
        Indent.SAME, "#BOTTOM#");

public ModelicaAnchorList() {
    super();
    partial_newline = false;
    stack = new Stack<Anchor<Indent>>();
    anchors = new LinkedList<Anchor<Indent>>();
    sinks = new LinkedList<Anchor<Indent>>();
    push(BOTTOM);
}

protected Anchor<Indent> find(Iterable<Anchor<Indent>> anchors, int offset,
        Anchor<Indent> def) {
    Anchor<Indent> result = def;
    for (Anchor<Indent> a : anchors)
        if (a.offset < offset)
            result = a;
    return result;
}

/**
 * Returns the anchor in scanned text closest past offset <code>offset</code>.
 * 
 * @param offset offset of anchor
 * @return
 */
public Anchor<Indent> anchorAt(int offset) {
    return find(anchors, offset, BOTTOM);
}

/**
 * Returns the sink in scanned text closest past offset <code>offset</code>.
 * 
 * @param offset offset of anchor
 * @return
 */
public Anchor<Indent> sinkAt(int offset) {
    return find(sinks, offset, null);
}

protected void push(Anchor<Indent> a) {
    anchors.addLast(a);
    stack.push(a);
}

/**
 * Create an anchor that leaves the indentation unchanged when formatting region.
 * 
 * @param offset
 */
public void pushUnchanged(int offset) {
    pushTop(offset);
    anchors.getLast().reference = offset + 1;
    stack.peek().reference = offset + 1;
}

/** 
 * Add an anchor for a paren in annotation 
 * @param offset
 * @param level
 */
public void annotationParen(int offset, int level) {
    popTo("paren");
    
    pushTop(offset);
    
    anchors.getLast().id = "#";

    Indent indent = new Indent.AnnotationParen(level);
    anchors.getLast().indent = indent;
}

/**
 * Pop an element from the stack if possible. O.w. keep bottom element in stack
 */
protected void pop() {
    if (stack.size() > 1)
        stack.pop();
}

/**
 * Add anchor at <code>offset</code>, beginning a new named section.
 * 
 * @param offset offset to put anchor at
 * @param reference reference indentation
 * @param indent indent modification
 * @param id anchor id
 */
public void beginSection(int offset, int reference, Indent indent, String id) {
    push(new Anchor<Indent>(offset, reference, indent, id));
}

/**
 * Add anchor at <code>offset</code>.
 * 
 * @param offset offset to put anchor at
 * @param reference reference indentation
 * @param indent indent modification
 */
public void addAnchor(int offset, int reference, Indent indent) {
    beginSection(offset, reference, indent, "#");
}

/**
 * Called when scanner encounters the beginning of a line.
 * 
 * @param offset offset of inserted anchor.
 */
public void beginLine(int offset) {
    beginSection(offset + 1, offset, partial_newline ? Indent.SAME
            : Indent.INDENT, partial_newline ? "#" : "newline");
    partial_newline = true;
}

/**
 * Called when scanner encounters the end of a statement.
 * 
 * @param offset offset of inserted anchor.
 */
public void completeStatement(int offset) {
    while (stack.peek() != BOTTOM && !stack.peek().id.matches("newline|class"))
        pop();
    pushTop(offset);
    if (anchors.getLast().id.equals("newline"))
        anchors.getLast().indent = Indent.SAME;
    stack.push(anchors.getLast());
    anchors.getLast().id = "#";
    partial_newline = false;
}

private void popTo(String id) {
    while (stack.peek() != BOTTOM && !stack.peek().id.matches(id))
        pop();
}

/**
 * Pop internal stack past the next named section with id <code>id</code>.
 * Duplicate the resulting stack top to <code>offset</code>.
 * 
 * @param id id of anchor to pop past
 * @param offset offset of inserted anchor
 */
public void popPast(String id, int offset) {
    popTo(id);
    pop();
    pushTop(offset);
}

/**
 * Add an anchor that "sinks" the current line to last class defn.
 * 
 * @param offset offset of inserted anchor
 */
public void addSink(int offset, String id, Indent indent) {
    int ref = 0;
    for (Anchor<Indent> a : stack)
        if (id.equals(a.id))
            ref = a.reference;
    sinks.addLast(new Anchor<Indent>(offset, ref, indent, "#"));
}

/**
 * Duplicate top element of internal stack to offset.
 * 
 * @param offset offset of inserted anchor.
 */
public void pushTop(int offset) {
    anchors.add(new Anchor<Indent>(offset, stack.peek().reference,
            stack.peek().indent, stack.peek().id));
}

/**
 * Bind the current tab width to transform list to AnchorList&lt;Integer&gt;.
 * @param tabWidth tabWidth to use
 */
public AnchorList<Integer> bindEnv(final IDocument doc, final int tabWidth) {
    return new AnchorList<Integer>() {

        private IDocument d = doc;

        private Anchor<Integer> bind(Anchor<Indent> a, int offset) {

            int indent = IndentingAutoEditStrategy.countTokens(d, a.reference);
            indent = a.indent.modify(indent, tabWidth);

            if (a.indent == Indent.UNCHANGED) {
                try {
                    IRegion line = d.getLineInformationOfOffset(offset);
                    indent = IndentedSection.countIndent(d.get(
                            line.getOffset(), line.getLength()));
                } catch (BadLocationException e) { 
                    e.printStackTrace();
                }
            }

            return new Anchor<Integer>(a.offset, a.reference, indent, a.id);
        }

        public Anchor<Integer> anchorAt(int offset) {
            Anchor<Indent> a = ModelicaAnchorList.this.anchorAt(offset);
            return bind(a, offset);
        }

        public Anchor<Integer> sinkAt(int offset) {
            Anchor<Indent> a = ModelicaAnchorList.this.sinkAt(offset);
            return a == null ? null : bind(a, offset);
        }

    };
}
}