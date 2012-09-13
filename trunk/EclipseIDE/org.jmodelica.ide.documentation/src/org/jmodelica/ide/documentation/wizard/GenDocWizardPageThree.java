//package org.jmodelica.ide.documentation.wizard;
//
//import java.lang.reflect.InvocationTargetException;
//import java.util.HashMap;
//
//import org.eclipse.core.runtime.IProgressMonitor;
//import org.eclipse.jface.dialogs.ProgressMonitorDialog;
//import org.eclipse.jface.operation.IRunnableWithProgress;
//import org.eclipse.jface.wizard.WizardPage;
//import org.eclipse.swt.SWT;
//import org.eclipse.swt.widgets.Composite;
//import org.eclipse.ui.PlatformUI;
//
//public class GenDocWizardPageThree extends WizardPage{
//	protected GenDocWizardPageThree(String pageName) {
//		super(pageName);
//		setTitle("Generating");
//		setDescription("Generating Documentation");
//	}
//
//	@Override
//	public void createControl(Composite parent) {
//		Composite composite = new Composite(parent, SWT.NONE);
//		setControl(composite);
//		setPageComplete(false);
//		String path = ((GenDocWizardPageTwo)getWizard().getPage(GenDocWizard.PAGE_TWO)).getPath();
//		HashMap<String, Boolean> checkBoxes = ((GenDocWizardPageOne)getWizard().getPage(GenDocWizard.PAGE_ONE)).getCheckBoxes();
//		//do a bunch of generation stuff
//		
//		ProgressMonitorDialog dialog = new ProgressMonitorDialog(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell()); 
//		try {
//			dialog.run(true, true, new IRunnableWithProgress(){ 
//			    public void run(IProgressMonitor monitor) { 
//			        monitor.beginTask("Some nice progress message here ...", 100); 
//			        // execute the task ... 
//			        wasteTime(monitor);
//			        monitor.done(); 
//			    } 
//			});
//		} catch (InvocationTargetException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} catch (InterruptedException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//		
//		//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//		setPageComplete(true);
//	}
//	
//	public void wasteTime(IProgressMonitor monitor){
//		 int i = 0;
//	        while (i < 100){
//	        	 // execute the task ... 
//	        	for (int j = 0; j < 100000; j++){
//	        		double p = Math.sqrt(Math.sin(j));
//	        	}
//		        try {
//					Thread.sleep(100);
//				} catch (InterruptedException e) {
//					// TODO Auto-generated catch block
//					e.printStackTrace();
//				}
//		        monitor.worked(1);
//		        i++;
//	        }
//	}
//}
