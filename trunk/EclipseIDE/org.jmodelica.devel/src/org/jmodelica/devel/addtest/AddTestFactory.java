package org.jmodelica.devel.addtest;
import java.util.Collections;
import java.util.HashMap;

import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.menus.CommandContributionItem;
import org.eclipse.ui.menus.CommandContributionItemParameter;
import org.eclipse.ui.menus.ExtensionContributionFactory;
import org.eclipse.ui.menus.IContributionRoot;
import org.eclipse.ui.menus.IMenuService;
import org.eclipse.ui.services.IServiceLocator;
import org.jmodelica.devel.Constants;
import org.jmodelica.ide.helpers.hooks.IASTEditor;
import org.jmodelica.modelica.compiler.ClassDecl;


public class AddTestFactory extends ExtensionContributionFactory {

	public AddTestFactory() {
		System.out.println("=================== factory created");
	}

	public void createContributionItems(IServiceLocator serviceLocator, IContributionRoot additions) {
		System.out.println("=================== factory called");
		ClassDecl cl = findClass();
		if (cl != null) {
			MenuManager sub = new MenuManager("Add Test Annotation");
			additions.addContributionItem(sub, null);
			CommandContributionItemParameter param = new CommandContributionItemParameter(
					serviceLocator, Constants.ADD_TEST_MENU_ID, Constants.ADD_TEST_COMMAND_ID, 0);
//			sub.add(new CommandContributionItem(param));
			for (TestType t : TestType.values()) {
				param.parameters = new HashMap<String,String>();
				param.parameters.put(Constants.ADD_TEST_OFFSET_PARAM_ID, Integer.toString(cl.getBeginOffset()));
				param.parameters.put(Constants.ADD_TEST_TYPE_PARAM_ID, t.toString());
				param.label = t.menuName();
				sub.add(new CommandContributionItem(param));
				if (t.useSeparator())
					sub.add(new Separator());
			}
		}
	}

	private ClassDecl findClass() {
		ClassDecl cl = null;
		IWorkbenchPart part = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActivePart();
		if (part instanceof IASTEditor) {
			IASTEditor editor = (IASTEditor) part;
			cl = editor.getClassContainingMouse();
		}
		return cl;
	}

}
