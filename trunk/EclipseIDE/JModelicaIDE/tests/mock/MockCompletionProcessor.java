package mock;


import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.namecomplete.CompletionProcessor;
import org.jmodelica.modelica.compiler.SourceRoot;

public class MockCompletionProcessor extends CompletionProcessor {

IProject proj;
ASTRegistry reg;

public MockCompletionProcessor(IProject proj, ASTRegistry reg) {
    super(null);
    this.proj = proj;
    this.reg = reg;
}

@Override
protected IFile getFile() {
    return new MockFile(proj);
}
@Override
protected SourceRoot projectRoot() {
    return (SourceRoot) reg.lookupAST(null, proj);
}
}
