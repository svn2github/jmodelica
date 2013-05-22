package org.jmodelica.devel;

public class Constants {

	public static final String PLUGIN_ID = "org.jmodelica.devel";
	
	private static final String MENU_ID = PLUGIN_ID + ".menu";
	private static final String COMMAND_ID = PLUGIN_ID + ".command";
	private static final String PARAMETER_ID = PLUGIN_ID + ".parameter";
	
	private static final String ADD_TEST_SUB_ID = ".addtest";
	public static final String ADD_TEST_MENU_ID = MENU_ID + ADD_TEST_SUB_ID;
	public static final String ADD_TEST_COMMAND_ID = COMMAND_ID + ADD_TEST_SUB_ID;
	private static final String ADD_TEST_PARAM_ID = PARAMETER_ID + ADD_TEST_SUB_ID;
	public static final String ADD_TEST_TYPE_PARAM_ID = ADD_TEST_PARAM_ID + ".type";
	public static final String ADD_TEST_OFFSET_PARAM_ID = ADD_TEST_PARAM_ID + ".offset";

}
