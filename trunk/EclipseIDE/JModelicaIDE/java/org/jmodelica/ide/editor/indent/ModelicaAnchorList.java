package org.jmodelica.ide.editor.indent;

import java.util.LinkedList;
import java.util.Stack;

import org.jmodelica.ide.indent.Anchor;
import org.jmodelica.ide.indent.AnchorList;


/**
 * Used by IndentationHintScanner to create a list of anchors annotating the
 * scanned modelica source code with indentation hints. The class maintains a
 * stack of current active anchors, while adding all seen anchors to a list used
 * later for lookup when indenting text.
 * 
 * @author philip
 */
public class ModelicaAnchorList implements AnchorList {

private Stack<Anchor> stack;
private LinkedList<Anchor> anchors, sinks;

private boolean partial_newline;

public ModelicaAnchorList() {
    super();
    partial_newline = false;
    stack = new Stack<Anchor>();
    anchors = new LinkedList<Anchor>();
    sinks = new LinkedList<Anchor>();
    push(Anchor.BOTTOM);
}

protected Anchor find(Iterable<Anchor> anchors, int offset) {
    Anchor result = Anchor.BOTTOM;
    for (Anchor a : anchors)
        if (a.offset < offset)
            result = a;
    return result;
}

/**
 * Returns the anchor in scanned text closest past offset <code>offset</code>.
 * 
 * @param offset
 *            offset of anchor
 * @return
 */
public Anchor anchorAt(int offset) {
    return find(anchors, offset);
}

/**
 * Returns the sink in scanned text closest past offset <code>offset</code>.
 * 
 * @param offset
 *            offset of anchor
 * @return
 */
public Anchor sinkAt(int offset) {
    return find(sinks, offset);
}

protected void push(Anchor a) {
    anchors.addLast(a);
    stack.push(a);
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
 * @param offset
 *            offset to put anchor at
 * @param reference
 *            reference indentation
 * @param indent
 *            indent modification
 * @param id
 *            anchor id
 */
public void beginSection(int offset, int reference, Indent indent, String id) {
    push(new Anchor(offset, reference, indent, id));
}

/**
 * Add anchor at <code>offset</code>.
 * 
 * @param offset
 *            offset to put anchor at
 * @param reference
 *            reference indentation
 * @param indent
 *            indent modification
 */
public void addAnchor(int offset, int reference, Indent indent) {
    beginSection(offset, reference, indent, "#");
}

/**
 * Called when scanner encounters the beginning of a line.
 * 
 * @param offset
 *            offset of inserted anchor.
 */
public void beginLine(int offset) {
    beginSection(offset + 1, offset,
            partial_newline ? Indent.SAME : Indent.INDENT, 
            partial_newline ? "#" : "newline");
    partial_newline = true;
}

/**
 * Called when scanner encounters the end of a statement.
 * 
 * @param offset
 *            offset of inserted anchor.
 */
public void completeStatement(int offset) {
    while (stack.peek() != Anchor.BOTTOM
            && !stack.peek().id.matches("newline|class"))
        pop();
    pushTop(offset);
    if (anchors.getLast().id.equals("newline"))
        anchors.getLast().indent = Indent.SAME;
    stack.push(anchors.getLast());
    partial_newline = false;
}

/**
 * Pop internal stack past the next named section with id <code>id</code>.
 * Duplicate the resulting stack top to <code>offset</code>.
 * 
 * @param id
 *            id of anchor to pop past
 * @param offset
 *            offset of inserted anchor
 */
public void popPast(String id, int offset) {
    while (stack.peek() != Anchor.BOTTOM && !stack.peek().id.matches(id))
        pop();
    pop();
    pushTop(offset);
}

/**
 * Add an anchor that "sinks" the current line to last class defn.
 * 
 * @param offset
 *            offset of inserted anchor 
 */
public void addSink(int offset) {
    int ref = 0;
    for (Anchor a : stack)
        if ("class".equals(a.id))
            ref = a.reference;
    sinks.addLast(new Anchor(offset, ref, Indent.SAME, "#"));
}

/**
 * Duplicate top element of internal stack to offset.
 * 
 * @param offset
 *            offset of inserted anchor.
 */
public void pushTop(int offset) {
    anchors.add(new Anchor(offset, stack.peek().reference,
            stack.peek().indent, stack.peek().id));
}
}