/**
* @FB:transient true
* **/
component{ // transient request output service

	variables.req;
	
	variables.content = {};
	variables.breadcrumbs = [];
	variables.title = "";
	variables.metaData = [];
	variables.templateRootDir = "";
	variables.viewRootDir = "";

	/**
	* @hint constructor
	* **/
	public requestOutputService function init(requestHandler req, string templateRootDir="", string viewRootDir=""){
		variables.req = arguments.req;
		variables.templateRootDir = arguments.templateRootDir;
		variables.viewRootDir = arguments.viewRootDir;
		return this;
	}

	
	/**
	* @hint returns our request data struct
	* **/
	public struct function requestHandler(){
		return variables.req;
	}

	/**
	* @hint framework shortcut
	* **/
	public framework function FB(){
		return requestHandler().FB();
	}

	// ===================================
	// CONTENT 
	/**
	* @hint get our content
	* **/
	public any function getContent(string contentRegion="", boolean returnArray=false){
		if(len(arguments.contentRegion)){
			if(structKeyExists(variables.content, arguments.contentRegion)){
				var c = variables.content[arguments.contentRegion];
				if(arguments.returnArray){
					return c;
				}else{
					var str = [];
					for(var i in c){
						arrayAppend(str, i.content);
					}
					return arrayToList(str, "");
				}
			}
			return "";
		}else{
			return variables.content;
		}
	}

	/**
	* @hint add content to a content region
	* **/
	public void function addContent(required string content, string contentRegion="default", struct info={}, numeric position=-1){
		var item = {};
		item.content = arguments.content;
		item.info = arguments.info;
		
		if(! structKeyExists(variables.content, arguments.contentRegion)){
			variables.content[arguments.contentRegion] = [];
		}

		if((arguments.position < 1) || (arguments.position > arrayLen(variables.content[arguments.contentRegion])+1)){
			arrayAppend(variables.content[arguments.contentRegion], item);
		}else{
			arrayInsertAt(variables.content[arguments.contentRegion], arguments.position, item);
		}
	}

	/**
	* @hint clears content for a given content region
	* **/
	public any function purgeContent(string contentRegion=""){
		if(len(arguments.contentRegion)){
			variables.content[arguments.contentRegion] = [];
		}else{
			variables.content = {};
		}
	}

	// ===================================
	// TEMPLATES
	/**
	* @hint returns a template path
	* **/
	public string function templateRoot(string templateRootDir){
		if(isSimpleValue(arguments.templateRootDir)){
			variables.templateRootDir = arguments.templateRootDir;
		}
		if(len(variables.templateRootDir)){
			return variables.templateRootDir;
		}else{
			return FB().getSetting('paths.templates');
		}
	}

	/**
	* @hint returns a template path
	* **/
	public string function templatePath(string template="default", string root=templateRoot()){
		return "#arguments.root##replaceNoCase(arguments.template, '.', '/', 'ALL')#.cfm";
	}

	

	/**
	* @hint render a given template
	* **/
	public any function layout(string templateName="default"){
		local.pathToTemplate = templatePath(arguments.templateName);
		savecontent variable="local.output" {include local.pathToTemplate;};
		return local.output;
	}

	/**
	* @hint clears content for a given content region
	* **/
	public string function templateInclude(required string templateName){
		savecontent variable="local.output" {include templatePath("includes." & arguments.templateName);};
		return local.output;
	}


	// ===================================
	// VIEWS
	public string function viewRoot(string viewRootDir){
		if(isSimpleValue(arguments.viewRootDir)){
			variables.viewRootDir = arguments.viewRootDir;
		}
		if(len(variables.viewRootDir)){
			return variables.viewRootDir;
		}else{
			return FB().getSetting('paths.views');
		}
	}

	/**
	* @hint returns a view path
	* **/
	public string function viewPath(string viewFile="default", string root=viewRoot()){
		return "#arguments.root##replaceNoCase(arguments.viewFile, '.', '/', 'ALL')#.cfm";
	}

	/**
	* @hint render a view
	* **/
	public any function view(string viewFile, any data={}, string contentRegion="", string root=viewRoot()){
		var data = arguments.data;
		savecontent variable="local.ret"{include "#viewPath(arguments.viewFile, arguments.root)#";}
		if(len(arguments.contentRegion)){
			addContent(local.ret, arguments.contentRegion);
		}
		return local.ret;
	}

	/**
	* @hint render a view and add it by default to the default content region
	* **/
	public any function addView(string viewFile, any data={}, string contentRegion="default", string root=viewRoot()){
		return view(argumentCollection:arguments);
	}

	// ===================================
	// TITLE
	/**
	* @hint set our title
	* **/
	public void function setTitle(string title){
		variables.title = arguments.title;
	}

	/**
	* @hint get our title
	* **/
	public string function getTitle(){
		return variables.title
	}

	// ===================================
	// META DATA
	/**
	* @hint adds meta data 
	* **/
	public void function addMetaData(string name, string value, string scheme="", boolean append=true){
		local.doAdd = true;
		for(local.meta in variables.metaData){
			if(local.meta.name IS arguments.name AND local.meta.scheme IS arguments.scheme){
				if(arguments.append){
					local.meta.value = listAppend(local.meta.value, arguments.value);
				}else{
					local.meta.value =arguments.value;
				}
				local.doAdd = false;
			}
		}

		if(local.doAdd){
			arrayAppend(variables.metaData, {
				"name": arguments.name,
				"scheme": arguments.scheme,
				"value": arguments.value
			});
		}
	}
	
	/**
	* @hint returns our meta data
	* **/
	public array function getTemplateMetaData(){
		return variables.metaData;
	}
	
	// ===================================
	// BREAD CRUMBS
	/**
	* @hint adds a breead crumb
	* **/
	public void function addBreadCrumb(string crumbTitle, string crumbURL, numeric position=0, boolean overwrite=false){
		local.crumb = {
			"title": arguments.crumbTitle,
			"url": arguments.crumbURL
		}

		if(arguments.position LTE 0
			OR arguments.position GT arraylen(variables.breadcrumbs)){
			arrayAppend(variables.breadcrumbs, local.crumb);
		}else if(arguments.overwrite AND (arguments.position LTE arraylen(variables.breadcrumbs))){
			variables.breadcrumbs[arguments.position] = local.crumb;
		}else if(arguments.position LTE arrayLen(variables.breadcrumbs)){
			arrayInsertAt(variables.breadcrumbs, arguments.position, local.crumb);
		}
	}


	/**
	* @hint clears current breadcrumb array
	* **/
	public void function purgeBreadCrumbs(){
		variables.breadcrumbs = [];
	}
	
	/**
	* @hint returns our breadcrumb array
	* **/
	public array function getBreadCrumbs(){
		return variables.breadcrumbs;
	}
	
	/**
	* @hint sets the page title using reverse breadcrumbs
	* **/
	public void function setTitleFromBreadCrumbs(numeric crumbEnd=2, string delimiter=" - ", string base=FB().getSetting('siteName')){
		//local.t = duplicate(getBreadCrumbs());
		//createObject("java", "java.util.Collections").reverse(local.t);
		local.t = [];
		for(local.i=arrayLen(variables.breadCrumbs); local.i GTE arguments.crumbEnd; local.i = local.i-1){
			arrayAppend(local.t, variables.breadCrumbs[local.i].title);
		}
		
		if(len(arguments.base)){
			arrayAppend(local.t, arguments.base);
		}

		setTitle(arrayToList(local.t, arguments.delimiter));
	}
	

}