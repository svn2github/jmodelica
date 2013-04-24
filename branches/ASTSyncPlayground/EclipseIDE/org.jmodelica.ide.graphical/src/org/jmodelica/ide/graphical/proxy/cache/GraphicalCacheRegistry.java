package org.jmodelica.ide.graphical.proxy.cache;

import java.io.ByteArrayInputStream;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.GlobalRootNode;
import org.jmodelica.ide.compiler.ListenerObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.compiler.ModelicaASTRegistryIDHandler;
import org.jmodelica.ide.graphical.GraphicalEditorInput;
import org.jmodelica.ide.graphical.proxy.ClassDiagramProxy;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class GraphicalCacheRegistry implements IASTChangeListener {
	private GraphicalEditorInput input;
	private ClassDiagramProxy dp;
	private CachedInstClassDecl icdc;
	private IASTChangeListener myGraphicalEditorListener;
	private IFile theFile;

	public GraphicalCacheRegistry() {
	}

	private void refreshClassDiagramProxyCache() {
		long time = System.currentTimeMillis();
		SourceRoot root = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(theFile.getProject())).getSourceRoot();
		synchronized (root.state()) {
			InstClassDecl icd = root.getProgram().getInstProgramRoot()
					.syncSimpleLookupInstClassDecl(input.getClassName());
			Stack<String> astPath = ModelicaASTRegistry.getInstance()
					.createPath(icd.getClassDecl());
			icdc = new CachedInstClassDecl(icd);
			icdc.setClassASTPath(astPath);
		}
		time = System.currentTimeMillis() - time;
		System.out.println("Rebuilt graphical cache, took " + time + "ms");
	}

	public ClassDiagramProxy getClassDiagramProxy() {
		return dp;
	}

	private void removeAsListener() {
		ModelicaASTRegistry.getInstance().removeListener(this);
	}

	public void setInput(GraphicalEditorInput input) {
		if (this.input != null)
			removeAsListener();
		this.input = input;
		GlobalRootNode gRoot = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(input.getProject());
		theFile = gRoot.lookupFileNode(input.getSourceFileName());
		SourceRoot root = gRoot.getSourceRoot();
		ASTNode<?> classDecl;
		synchronized (root.state()) {
			InstClassDecl icd = root.getProgram().getInstProgramRoot()
					.syncSimpleLookupInstClassDecl(input.getClassName());
			if (icd == null)
				System.err
						.println("Graphical Editor could not find input class\n");
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
		ListenerObject listObj = new ListenerObject(this,
				IASTChangeListener.GRAPHICAL_LISTENER,
				ModelicaASTRegistryIDHandler.getInstance()
						.getGraphicalEditorID());
		ModelicaASTRegistry.getInstance().addListener(theFile, classDecl,
				listObj);
	}

	private void createClassDiagramProxyCache(IFile theFile, InstClassDecl icd) {
		CachedInstClassDecl instClassDecl = new CachedInstClassDecl(icd);
		Stack<String> astPath = ModelicaASTRegistry.getInstance().createPath(
				icd.getClassDecl());
		instClassDecl.setClassASTPath(astPath);
		dp = new ClassDiagramProxy(theFile, instClassDecl);
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

	public void saveModelicaFile(IProgressMonitor monitor) {
		SourceRoot root = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(theFile.getProject())).getSourceRoot();
		synchronized (root.state()) {
			InstClassDecl icd = root.getProgram().getInstProgramRoot()
					.syncSimpleLookupInstClassDecl(input.getClassName());
			StoredDefinition def = icd.getDefinition();
			try {
				def.getFile().setContents(
						new ByteArrayInputStream(def.prettyPrintFormatted()
								.getBytes()), false, true, monitor);
			} catch (CoreException e) {
				System.err
						.println("GraphicalCacheRegistry failed to save StoredDefinition to file...\n");
				e.printStackTrace();
			}
		}
	}
}
