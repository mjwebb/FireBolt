component accessors="true" transient{ // transient template output service

	
	variables.content = {};
	variables.breadcrumbs = [];
	variables.title = "";
	variables.metaData = [];

	variables.owner = "";
	
	/**
	* @hint constructor
	*/
	public templateService function init(controller owner){
		variables.owner = arguments.owner;
		return this;
	}


	// ===================================
	// CONTENT 
	/**
	* @hint get our content
	*/
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
	*/
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
	*/
	public any function purgeContent(string contentRegion=""){
		if(len(arguments.contentRegion)){
			variables.content[arguments.contentRegion] = [];
		}else{
			variables.content = {};
		}
	}

	

	// ===================================
	// TITLE
	/**
	* @hint set our title
	*/
	public void function setTitle(string title){
		variables.title = arguments.title;
	}

	/**
	* @hint get our title
	*/
	public string function getTitle(){
		return variables.title;
	}

	// ===================================
	// META DATA
	/**
	* @hint adds meta data 
	*/
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
	*/
	public array function getTemplateMetaData(){
		return variables.metaData;
	}
	
	// ===================================
	// BREAD CRUMBS
	/**
	* @hint adds a breead crumb
	*/
	public void function addBreadCrumb(string crumbTitle, string crumbURL, numeric position=0, boolean overwrite=false){
		local.crumb = {
			"title": arguments.crumbTitle,
			"url": arguments.crumbURL
		};

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
	*/
	public void function purgeBreadCrumbs(){
		variables.breadcrumbs = [];
	}
	
	/**
	* @hint returns our breadcrumb array
	*/
	public array function getBreadCrumbs(){
		return variables.breadcrumbs;
	}
	
	/**
	* @hint sets the page title using reverse breadcrumbs
	*/
	public void function setTitleFromBreadCrumbs(numeric crumbEnd=2, string delimiter=" - ", string base=variables.owner.FB().getSetting('siteName')){
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