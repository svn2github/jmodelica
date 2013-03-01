package org.jmodelica.ide.documentation.commands;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.ui.AbstractSourceProvider;
import org.eclipse.ui.ISources;

public class NavigationProvider extends AbstractSourceProvider {

	public final static String NAVIGATION_BACK = "org.jmodelica.ide.documentation.commands.navigationback";
	public final static String NAVIGATION_FORWARD = "org.jmodelica.ide.documentation.commands.navigationforward";
	private final static String BACK_ENABLED = "backEnabled";
    private final static String BACK_DISABLED = "backDisabled";
    private final static String FORWARD_ENABLED = "forwardEnabled"; 
    private final static String FORWARD_DISABLED = "forwardDisabled";
    boolean backEnabled = false;
    boolean forwardEnabled = false;
    
    @Override
	public String[] getProvidedSourceNames() {
		return new String[] {NAVIGATION_BACK, NAVIGATION_FORWARD}; 
	}

	  @Override 
	    public Map<String, String> getCurrentState() { 
	        Map<String, String> currentState = new HashMap<String, String>(2);
	        String backState =  backEnabled ? BACK_ENABLED : BACK_DISABLED; 
	        currentState.put(NAVIGATION_BACK, backState); 
	        String forwardState = forwardEnabled ? FORWARD_ENABLED : FORWARD_DISABLED;
	        currentState.put(NAVIGATION_FORWARD, forwardState);
	        return currentState; 
	    }
	  
	  @Override
		public void dispose() {
			// TODO Auto-generated method stub
		}

	public void setForwardEnabled(boolean isEnabled) {
		forwardEnabled = isEnabled;
		fireSourceChanged(ISources.WORKBENCH, NAVIGATION_FORWARD, forwardEnabled ? FORWARD_ENABLED : FORWARD_DISABLED);
		
	}
	public void setBackEnabled(boolean isEnabled){
		backEnabled = isEnabled;
		fireSourceChanged(ISources.WORKBENCH, NAVIGATION_BACK, backEnabled ? BACK_ENABLED : BACK_DISABLED);
	}

}
