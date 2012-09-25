package org.jmodelica.ide.documentation;

public class Scripts {
	private static final String N3 = "\n\t\t\t";
	private static final String N4 = "\n\t\t\t\t";
	private static final String N5 = "\n\t\t\t\t\t";
	private static final String N6 = "\n\t\t\t\t\t\t";

	public static final String SUPPRESS_NAVIGATION_WARNING =
			N3 + "window.onunload = function() {"+
					N3 + "var x = confirm('Are you sure you want to navigate away from this page?');"+
					N3 + "if (x == true) return true;"+
					N3 + "else window.location.reload();" +
					N3 + "}";

	public static final String SUPPRESS_NAVIGATION_WARNING2 =
			N3 + "(function(b){" +
					N3 + "var f = function() { return confirm('Are you sure you wish to leave?'); };" +
					N3 + "if(b.attachEvent) {"+
					N3 + "b.attachEvent('window.onunload', f);" +
					N3 + "b.attachEvent('window.onbeforeunload', f);" +
					N3 + "}"+
					N3 + "else {"+
					N3 + "b.addEventListener('unload', f, false);"+
					N3 + "}"+
					N3 + "})(document.body);";

	public static final String SUPPRESS_NAVIGATION_WARNING3 =
			N3 + "$(window).bind('beforeunload', function(e) {" +
					N3 + "e.preventDefault();"+
					N3 + "});";

	public static final String SUPPRESS_NAVIGATION_WARNING4 =
			N3 + "window.onunload = null;" +
					N3 + "window.onbeforeunload = null;";

	public static final String SUPPRESS_NAVIGATION_WARNING5 =
			N3 + "window.onbeforeunload = function() {"+
					N3 + "return false;" +
					N3 + "}";

	public static final String SUPPRESS_NAVIGATION_WARNING6 = 

			N3 + "OnloadEvent={"+
					N4 +  "ONLOAD:'onload/onload',ONBEFOREUNLOAD:'onload/beforeunload',ONUNLOAD:'onload/unload'" +
					N3 +  "};" +
					N3 + "function _include_quickling_events_default(){" +
					N4 + "return!window.loading_page_chrome;" +
					N3 + "}" +
					N3 + "function onbeforeunloadRegister(handler,include_quickling_events){" +
					N4 + "if(include_quickling_events===undefined){" +
					N5 + "include_quickling_events=_include_quickling_events_default();" +
					N4 + "}" + 
					N4 + "if(include_quickling_events){" + 
					N5 + "_addHook('onbeforeleavehooks',handler);"+
					N4 + "}" + 
					N4 + "else{" +
					N5 + "_addHook('onbeforeunloadhooks',handler);" +
					N4 + "}" + 
					N3 + "}" + 
					N3 + "function onunloadRegister(handler,include_quickling_events){" +
					N4 + "if(include_quickling_events===undefined){" + 
					N5 + "include_quickling_events=_include_quickling_events_default();" +
					N4 + "}" + 
					N4 + "if(include_quickling_events){" +
					N5 + "_addHook('onleavehooks',handler);" +
					N4 + "}" +
					N4 + "else{" +
					N5 + "_addHook('onunloadhooks',handler);}" + 
					N3 + "}" + 
					N3 + "function _addHook(hooks,handler){" + 
					N4 + "(window[hooks]?window[hooks]:(window[hooks]=[])).push(handler);" +
					N3 + "}";
	
	public static String UNDO_ALL =
			"while (tinyMCE.activeEditor.undoManager.hasUndo()){" +
			"tinyMCE.activeEditor.undoManager.undo();}";

	public static final String confirm(String message){
		return "return confirm(" + "\"" + message + "\");";
	}
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
			N3 + "function cancelInfo() {" +
					N4 + "if (tinyMCE.activeEditor.undoManager.hasUndo()){" +
					N5 + "if (confirm(\"Are you sure you want to leave edit mode? All unsaved changed will be lost!\")){" +
					N5 + "while (tinyMCE.activeEditor.undoManager.hasUndo()){" +
					N5 + "tinyMCE.activeEditor.undoManager.undo();" +
					N5 + "}" +
					N5 + "document.title = \"cancelInfo\";"+
					N5 + "}else{" +	//if 'cancel' on popup																							//(\2)
					N6 + "tinyMCE.activeEditor.focus();" +
					N5 + "}" +
					N4 + "}else{" + //if we dont have undo's
					N5 + "document.title = \"cancelInfo\";"+
					N4 + "}" +
					N3 + "}";
	public static final String CANCEL_INFO2 = 
			N3 +"function cancelInfo() {"+
					N4 + "if (confirm(\"Are you sure you want to leave edit mode? All unsaved changed will be lost!\")){" +
					N5 + "while (tinyMCE.activeEditor.undoManager.hasUndo()){" +
					N5 + "tinyMCE.activeEditor.undoManager.undo();" +
					N5 + "}" + 
					N5 + "document.title = \"cancelInfo\";"+
					N4 + "}else{" +
					N4 + "tinyMCE.activeEditor.focus();" +
					N4 + "}" +
					N3 + "}";

	public static final String CANCEL_REV =
			N3 + "function cancelRev() {" +
					N4 + "if (tinyMCE.activeEditor.undoManager.hasUndo()){" +
					N5 + "if (confirm(\"Are you sure you want to leave edit mode? All unsaved changed will be lost!\")){" +
					N5 + "while (tinyMCE.activeEditor.undoManager.hasUndo()){" +
					N5 + "tinyMCE.activeEditor.undoManager.undo();" +
					N5 + "}" +
					N5 + "document.title = \"cancelRev\";"+
					N5 + "}else{" +	//if 'cancel' on popup																							//(\2)
					N6 + "tinyMCE.activeEditor.focus();" +
					N5 + "}" +
					N4 + "}else{" + //if we dont have undo's
					N5 + "document.title = \"cancelRev\";"+
					N4 + "}" +
					N3 + "}";
	public static final String CANCEL_REV2 = 
			N3 +"function cancelRev() {"+
					N4 + "if (confirm(\"Are you sure you want to leave edit mode? All unsaved changed will be lost!\")){" +
					N5 + "while (tinyMCE.activeEditor.undoManager.hasUndo()){" +
					N5 + "tinyMCE.activeEditor.undoManager.undo();" +
					N5 + "}" + 
					N5 + "document.title = \"cancelRev\";"+
					N4 + "}else{" +
					N4 + "tinyMCE.activeEditor.focus();" +
					N4 + "}" +
					N3 + "}";

	public static String setRevDivContent(String content) {
		return "var eDiv = document.getElementById('revDiv').innerHTML = " + content;

	}
	public static String setInfoDivContent(String content) {
		return "var eDiv = document.getElementById('infoDiv').innerHTML = " + content;
	}

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

	public static final String HIDE_INFO_DIV =
			"document.getElementById(\"infoDiv\").style.visibility = \"hidden\"";

	public static final String HIDE_REV_DIV =
			"document.getElementById(\"revDiv\").style.visibility = \"hidden\"";

	protected static final String SCRIPT_INIT_TINY_MCE =
			"tinyMCE.init({"+
					"mode : \"textareas\","+
					"theme : \"advanced\","+
					"skin : \"o2k7\","+
					"plugins : \"autolink,lists,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups,autosave\","+
					"theme_advanced_resizing : true," +
					"theme_advanced_path : false," +
					"theme_advanced_buttons1 : \"bold,italic,underline,strikethrough,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect\","+
					"theme_advanced_buttons2 : \"link,unlink,anchor,image,cleanup,code,|,insertdate,|,forecolor,backcolor,|,tablecontrols,|,hr,removeformat,|,sub,sup,charmap\"," +
					"});";

	public static final String CONFIRM_POPUP = 
			"return confirm(\"Would you like to leave edit mode? All unsaved changed will be lost!\");";

	public static final String ALERT_UNSAVED_CHANGES = 
			"alert(\"You have unsaved changes\");";
}
