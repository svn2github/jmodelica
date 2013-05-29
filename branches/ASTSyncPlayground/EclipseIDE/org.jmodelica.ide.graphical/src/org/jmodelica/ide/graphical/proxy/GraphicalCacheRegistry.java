package org.jmodelica.ide.graphical.proxy;

import java.io.ByteArrayInputStream;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.graphical.GraphicalEditorInput;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ChangePropagationController;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ListenerObject;
import org.jmodelica.ide.sync.LocalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.UniqueIDGenerator;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class GraphicalCacheRegistry implements IASTChangeListener {
	private GraphicalEditorInput input;
	private ClassDiagramProxy dp;
	private IASTChangeListener myGraphicalEditorListener;
	private IFile theFile;
	private int myListenerId;
	private Stack<ASTPathPart> myListenPath = new Stack<ASTPathPart>();
	private StoredDefinition def;

	public GraphicalCacheRegistry() {
	}

	private void refreshClassDiagramProxyCache() {
		createClassDiagramProxyCache(theFile, input.getClassName());
	}

	public ClassDiagramProxy getClassDiagramProxy() {
		return dp;
	}

	public void removeAsListener() {
		ChangePropagationController.getInstance().removeListener(this, theFile,
				myListenPath);
	}

	public void setInput(GraphicalEditorInput input) {
		myListenerId = UniqueIDGenerator.getInstance().getListenerID();
		if (this.input != null)
			removeAsListener();
		this.input = input;
		GlobalRootNode gRoot = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(input.getProject());
		LocalRootNode lroot = (LocalRootNode) gRoot.lookupFileNode(input
				.getSourceFileName());
		theFile = lroot.getFile();
		createClassDiagramProxyCache(theFile, input.getClassName());
		registerAsListener();
	}

	private void registerAsListener() {
		ListenerObject listObj = new ListenerObject(this,
				IASTChangeListener.GRAPHICAL_LISTENER, myListenerId);
		ChangePropagationController.getInstance().addListener(listObj, theFile,
				myListenPath);
	}

	private void createClassDiagramProxyCache(IFile theFile, String className) {
		GlobalRootNode gRoot = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(input.getProject());
		SourceRoot root = gRoot.getSourceRoot();
		def = ModelicaASTRegistry.getInstance().getLatestDef(theFile);
		synchronized (root.state()) {
			InstClassDecl icd = root.getProgram().getInstProgramRoot()
					.syncSimpleLookupInstClassDecl(input.getClassName());
			if (icd == null)
				System.err
						.println("Graphical Editor could not find input class\n");
			dp = new ClassDiagramProxy(theFile, icd);
			myListenPath = ModelicaASTRegistry.getInstance().createDefPath(
					icd.getClassDecl());
		}
		dp.setClassASTPath(myListenPath);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if ((e == null) || (e.getType() != IASTChangeEvent.FILE_RECOMPILED)) {
			refreshClassDiagramProxyCache();
			createNewGraphicalUpdaterThread();
		} else if (e.getType() == IASTChangeEvent.FILE_RECOMPILED) {
			createNewAskToRebuildThread();
		}
	}

	private void createNewGraphicalUpdaterThread() {
		// We need the GUI thread when updating editor content.
		Display.getDefault().syncExec(new Runnable() {
			public void run() {
				myGraphicalEditorListener.astChanged(null);
			}
		});
	}

	private void createNewAskToRebuildThread() {
		// We need the GUI thread when updating editor content.
		Display.getDefault().syncExec(new Runnable() {
			public void run() {
				ASTChangeEvent event = new ASTChangeEvent(
						IASTChangeEvent.FILE_RECOMPILED,
						IASTChangeEvent.FILE_LEVEL);
				myGraphicalEditorListener.astChanged(event);
			}
		});
	}

	public void addGraphEditorListener(IASTChangeListener listener) {
		myGraphicalEditorListener = listener;
	}

	public void saveModelicaFile(IProgressMonitor monitor) {
		GlobalRootNode root = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(theFile.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			try {
				theFile.setContents(new ByteArrayInputStream(
						def.prettyPrintFormatted().getBytes()), false,
						true, monitor);
				UniqueIDGenerator.getInstance().setLastSaveGraphical();
			} catch (CoreException e) {
				System.err
						.println("GraphicalCacheRegistry failed to save StoredDefinition to file...\n");
				e.printStackTrace();
			}
		}
	}
}