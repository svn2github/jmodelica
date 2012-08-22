package org.jmodelica.ide.documentation;

public class Scripts {
	private static final String N2 = "\n\t\t";
	private static final String N3 = "\n\t\t\t";
	private static final String N4 = "\n\t\t\t\t";
	private static final String N5 = "\n\t\t\t\t\t";		
	
	public static final String PRE_INFO_EDIT =
			N2 + "function preInfoEdit(){"+
			N3 + "document.title = \"preInfoEdit\";"+
			N2 + "}";
	
	public static final String PRE_REV_EDIT =
			N2 + "function preRevEdit(){"+
			N3 + "document.title = \"preRevEdit\";"+
			N2 + "}";
	
	public static final String POST_INFO_EDIT =
			N2 + "function postInfoEdit(){"+
			N3 + "document.title = \"postInfoEdit\";"+
			N2 + "}";
	
	public static final String POST_REV_EDIT =
			N2 + "function postRevEdit(){"+
			N3 + "document.title = \"postRevEdit\";"+
			N2 + "}";
	
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
	
	public static final String CANCEL_INFO = 
			N2 +"function cancelInfo() {"+
			N3 + "document.title = \"cancelInfo\";"+
			N2 + "}";
	
	public static final String CANCEL_REV = 
			N2 +"function cancelRev() {"+
			N3 + "document.title = \"cancelRev\";"+
			N2 + "}";
	
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

//	protected static final String SCRIPT_PRE_SAVE =
//	N3 + "if (document.getElementById && document.createElement) {" +
//		N4 + "var saveBtn = document.createElement('BUTTON');" +
//		N4 + "saveBtn.id = 'saveButton';" +
//		N4 + "saveBtn.appendChild(document.createTextNode('Save'));" +
//		N4 + "saveBtn.onclick = preSaveChanges;" +
//	N3 + "}"+
//
//	N3 + "function editDocumentationAction(){"+
//		N4 + "if (!document.getElementById || !document.createElement) return;"+
//		N4 + "var eDiv = document.getElementById('docDiv');"+
//		N4 + "var content = eDiv.innerHTML;"+
//		N4 + "var textArea = document.createElement('TEXTAREA');"+
//		N4 + "textArea.cols = 97;"+
//		N4 + "textArea.rows = content.length/97 + 5;"+
//		N4 + "textArea.className = 'textAreaIndent';"+
//		N4 + "textArea.id = 'textAreaID';"+
//		N4 + "var parent = eDiv.parentNode;"+
//		N4 + "var btnDiv = document.createElement('DIV');"+
//		N4 + "btnDiv.id = 'buttonDiv';"+
//		N4 + "btnDiv.appendChild(saveBtn);"+
//		N4 + "parent.insertBefore(textArea,eDiv);"+
//		N4 + "parent.insertBefore(btnDiv, eDiv);"+
//		N4 + "parent.removeChild(eDiv);"+
//		N4 + "textArea.value = content;"+
//		N4 + "textArea.focus();"+
//		N4 + "var txt = textArea.value;"+
//		N4 + "if (txt.toLowerCase() == \"<i>No HTML documentation available</i>\".toLowerCase()){"+
//		N4 + "textArea.select();"+
//		N4 + "textArea.value = \"\";"+
//		N4 + "}"+
//		N4 + "document.getElementById('editButton').disabled=true;"+
//	N3 + "}"+
//
//	N3 + "function preSaveChanges() {"+
//		N4 + "document.title = 'save';"+
//	N3 + "}";
	
//	protected static final String SCRIPT_FORM = 
//	"<form name=\"frm1\" onsubmit=\"greeting()\">" +
//		"<textarea id=\"elm1\" name=\"elm1\" rows=\"15\" cols=\"80\" style=\"width: 80%\">"+
//			"&lt;p&gt;This is the first paragraph.&lt;/p&gt;"+
//		"</textarea>"+
//	
//		"<br />"+
//		"<input type=\"submit\" name=\"save\" value=\"Submit\" />"+
//		"<input type=\"reset\" name=\"reset\" value=\"Reset\" />"+
//	"</form>";
			
//	protected static final String SCRIPT_FORM_2 = 
//			"<form>"+ 
//    "<textarea name=\"content\" cols=\"50\" rows=\"15\" > "+
//    "This is some content that will be editable with TinyMCE."+
//    "</textarea>"+
//    "</form>";
	
//	protected static final String SCRIPT_PRE_SAVE_2 =
//			N3 + "function greeting(){"+
//				N4 + "alert(\"Welcome \" + document.forms[\"frm1\"][\"elm1\"].value + \"!\")"+
//			N3 + "}";
	
//	protected static final String SCRIPT_INIT_TINY_MCE =
//	N3 + "tinyMCE.init({" +
//		// hard coded URL: file:/C:/workspace/org.jmodelica.ide.documentation//resources/tinymce/
//		N4 + "document_base_url : \"C:/workspace/org.jmodelica.ide.documentation/resources/tinymce/jscripts/tiny_mce/tiny_mce.js\""+
//		// General options
//		N4 + "mode : \"textareas\"," +
//		N4 + "theme : \"advanced\"," +
//		N4 + "skin : \"o2k7\"," +
//		N4 + "plugins : \"autolink,lists,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups,autosave\"," +
//
//		// Theme options
//		N4 + "theme_advanced_buttons1 : \"bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect\"," +
//		N4 + "theme_advanced_buttons2 : \"bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,|,forecolor,backcolor\"," +
//		N4 + "theme_advanced_buttons3 : \"tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,advhr,|,ltr,rtl\"," +
//		N4 + "theme_advanced_buttons4 : \"insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak,restoredraft\"," +
//		N4 + "theme_advanced_toolbar_location : \"top\"," +
//		N4 + "theme_advanced_toolbar_align : \"left\"," +
//		N4 + "theme_advanced_statusbar_location : \"bottom\"," +
//		N4 + "theme_advanced_resizing : true," +
//
//		// Example word content CSS (should be your site CSS) this one removes paragraph margins
//		N4 + "content_css : \"css/word.css\"," +
//
//		// Drop lists for link/image/media/template dialogs
//		N4 + "template_external_list_url : \"lists/template_list.js\"," +
//		N4 + "external_link_list_url : \"lists/link_list.js\"," +
//		N4 + "external_image_list_url : \"lists/image_list.js\"," +
//		N4 + "media_external_list_url : \"lists/media_list.js\"," +
//
//		// Replace values for the template plugin
//		N4 + "template_replace_values : {" +
//			N5 + "username : \"Some User\"," +
//			N5 + "staffid : \"991234\"" +
//		N4 + "}" +
//
//		N3 + "});";
			
//	protected static final String SCRIPT_NO_DOC_AVAILABLE =
//			"var eDiv = document.getElementById('docDiv');" +
//					"eDiv.innerHTML = '<i>No HTML documentation available</i>';";
	
//	protected static final String SCRIPT_SAVE =
//			"var area = document.getElementsByTagName('TEXTAREA')[0];"+
//					"var eDiv = document.createElement('div');" +
//					"eDiv.id = \"docDiv\";" +	
//					"var z = area.parentNode;"+
//					"var tmp = area.value;"+
//					"eDiv.innerHTML = area.value;"+
//					"z.insertBefore(eDiv,area);"+
//					"z.removeChild(area);"+
//					"z.removeChild(document.getElementById('buttonDiv'));"+
//					"document.getElementById('editDocumentationButton').disabled=false;" +
//					"document.title = \"\";"+
//					"return tmp;";
	
//	protected static final String FULL_FILE = 
//	"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n"+
//	"<html xmlns=\"http://www.w3.org/1999/xhtml\" dir=\"ltr\">\n\n"+
//	"<head>\n"+
//	"<meta http-equiv=\"X-UA-Compatible\" content=\"IE=8\" />\n"+
//	"<script type=\"text/javascript\" src=\"C:/workspace/org.jmodelica.ide.documentation/resources/tinymce/jscripts/tiny_mce/tiny_mce.js\" ></script >\n"+
//	"<script type=\"text/javascript\" >\n"+
//	"tinyMCE.init({\n"+
//	        "\t\tmode : \"textareas\",\n"+
//	        "\t\ttheme : \"simple\",   //(n.b. no trailing comma, this will be critical as you experiment later)\n"+
//	        "\t\tdocument_base_url : \"C:/workspace/org.jmodelica.ide.documentation/resources/\"\n"+
//	"});\n"+
//	"</script >\n"+
//	"</head>\n"+
//	"<body>\n"+
//	        "\t\t<form>\n"+  
//	        "\t\t<textarea name=\"content\" cols=\"50\" rows=\"15\" >\n"+ 
//	        "\t\tThis is some content that will be editable with TinyMCE.\n"+
//	        "\t\t</textarea>\n"+
//	        "\t\t</form>\n"+
//	"</body>\n"+
//	"</html>";
}
