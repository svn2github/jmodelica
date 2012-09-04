package org.jmodelica.ide.documentation;

public class Scripts {
	private static final String N3 = "\n\t\t\t";
	private static final String N4 = "\n\t\t\t\t";	
	
	public static final String PRE_INFO_EDIT =
			N3 + "function preInfoEdit(){"+
			N4 + "document.title = \"preInfoEdit\";"+
			N3 + "}";
	
	public static final String PRE_REV_EDIT =
			N3 + "function preRevEdit(){"+
			N4 + "document.title = \"preRevEdit\";"+
			N3 + "}";
	
	public static final String POST_INFO_EDIT =
			N3 + "function postInfoEdit(){"+
			N4 + "document.title = \"postInfoEdit\";"+
			N3 + "}";
	
	public static final String POST_REV_EDIT =
			N3 + "function postRevEdit(){"+
			N4 + "document.title = \"postRevEdit\";"+
			N3 + "}";
	
	public static final String CANCEL_INFO = 
			N3 +"function cancelInfo() {"+
			N4 + "document.title = \"cancelInfo\";"+
			N3 + "}";
	
	public static final String CANCEL_REV = 
			N3 +"function cancelRev() {"+
			N4 + "document.title = \"cancelRev\";"+
			N3 + "}";
	
	public static final String FETCH_INFO_DIV_CONTENT =
			N4 + "var eDiv = document.getElementById('infoDiv');"+
			N4 + "var content = eDiv.innerHTML;" +
			N4 + "return content";
	
	public static final String FETCH_REV_DIV_CONTENT =
			N4 + "var eDiv = document.getElementById('revDiv');"+
			N4 + "var content = eDiv.innerHTML;" +
			N4 + "return content";
	
	public static final String FETCH_INFO_TEXTAREA_CONTENT =
			N4 + "return tinyMCE.get('infoTextArea').getContent();";
	
	public static final String FETCH_REV_TEXTAREA_CONTENT =
			N4 + "return tinyMCE.get('revTextArea').getContent();";
	
	protected static final String SCRIPT_INIT_TINY_MCE =
				"tinyMCE.init({"+
					"mode : \"textareas\","+
					"theme : \"advanced\","+
					"skin : \"o2k7\","+
					"plugins : \"autolink,lists,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups,autosave\","+
					"theme_advanced_resizing : true," +
					"theme_advanced_buttons1 : \"bold,italic,underline,strikethrough,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect\","+
					"theme_advanced_buttons2 : \"link,unlink,anchor,image,cleanup,code,|,insertdate,|,forecolor,backcolor,|,tablecontrols,|,hr,removeformat,|,sub,sup,charmap\"," +
					"document_base_url : \"C:/workspace/org.jmodelica.ide.documentation/resources/\""+
			"});";
	
	public static final String CONFIRM_POPUP = 
			"return confirm(\"Would you like to leave edit mode? All unsaved changed will be lost!\");";
	
	public static final String ALERT_UNSAVED_CHANGES = 
			"alert(\"You have unsaved changes\");";
}
