package org.jmodelica.ide.graphical.proxy.cache;

import org.eclipse.core.resources.IFile;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ChangePropagationController;
import org.jmodelica.ide.compiler.GlobalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.graphical.GraphicalEditorInput;
import org.jmodelica.ide.graphical.proxy.ClassDiagramProxy;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;

public class GraphicalCacheRegistry implements IASTChangeListener {
	private GraphicalEditorInput input;
	private ClassDiagramProxy dp;
	private InstClassDecl icd;
	private CachedInstClassDecl icdc;
	private IASTChangeListener myGraphicalEditorListener;
	private InstProgramRoot root;

	public GraphicalCacheRegistry() {
	}

	private void refreshClassDiagramProxyCache() {
		long time = System.currentTimeMillis();
		synchronized (icd.state()) {
			icd = root.syncSimpleLookupInstClassDecl(input.getClassName());
			icdc = new CachedInstClassDecl(icd);
		}
		time = System.currentTimeMillis() - time;
		System.out.println("Rebuilt graphical cache, took " + time + "ms");
	}

	public ClassDiagramProxy getClassDiagramProxy() {
		return dp;
	}

	private void removeAsListener() {
		ModelicaASTRegistry.getASTRegistry().removeListener(this);
	}

	public void setInput(GraphicalEditorInput input) {
		if (this.input != null)
			removeAsListener();
		this.input = input;
		IFile theFile = ModelicaASTRegistry.getASTRegistry()
				.doLookup(input.getProject()).lookupAllFileNodes()[0].getFile();
		// TODO hardcoded only works if one file in project, fixxx
		SourceRoot sroot = ((GlobalRootNode) ModelicaASTRegistry
				.getASTRegistry().doLookup(input.getProject())).getSourceRoot();
		ASTNode<?> classDecl;
		synchronized (sroot.state()) {
			root = sroot.getProgram().getInstProgramRoot();
			icd = root.syncSimpleLookupInstClassDecl(input.getClassName());
			createClassDiagramProxyCache(theFile, icd);
			classDecl = icd.getClassDecl();
		}
		if (classDecl == null) {
			System.err
					.println("GraphicalCacheregistry: could not find classdecl of input: "
							+ input.getName());
		} else {
			registerAsListener(theFile, classDecl);
		}
	}

	private void registerAsListener(IFile theFile, ASTNode<?> classDecl) {
		ChangePropagationController.getInstance().addListener(theFile,
				classDecl, this, IASTChangeListener.GRAPHICAL_LISTENER);
	}

	private void createClassDiagramProxyCache(IFile theFile, InstClassDecl icd) {
		dp = new ClassDiagramProxy(theFile, icd);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		refreshClassDiagramProxyCache();
		createNewGraphicalUpdaterThread();
	}

	private void createNewGraphicalUpdaterThread() {
		// We need the GUI thread when updating editor content.
		Display.getDefault().syncExec(new Runnable() {
			public void run() {
				myGraphicalEditorListener.astChanged(null);
			}
		});
	}

	public CachedInstClassDecl getCache() {
		return icdc;
	}

	public void addGraphEditorListener(IASTChangeListener listener) {
		myGraphicalEditorListener = listener;
	}
}
