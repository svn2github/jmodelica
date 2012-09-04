package org.jmodelica.ide.documentation.wizard;

import org.eclipse.jface.wizard.Wizard;
public class GenDocWizard extends Wizard {
	GenDocWizardPageOne personalInfoPage;
	GenDocWizardPageTwo addressInfoPage;

     public void addPages() {
              personalInfoPage = new GenDocWizardPageOne("Personal Information Page");
              addPage(personalInfoPage);
              addressInfoPage = new GenDocWizardPageTwo("Address Information");
              addPage(addressInfoPage);
     }
     public boolean performFinish() {
              return false;
     }
}
