/**
* Request controller base component. Routed controllers extend this to give all the FireBolt helper methods and the request context.
*/
component transient{
	
	
	variables.FireBolt = "";
	variables.requestHandler = "";
	variables.templateRootDir = "";
	variables.viewRootDir = "";
	variables.templateService = "";
	
	/**
	* @hint constructor
	*/
	public controller function init(requestHandler req, framework FireBolt inject){
		variables.requestHandler = arguments.req;
		variables.FireBolt = arguments.FireBolt;
		setTemplateProxyMethods();
		return this;
	}

	// can be overwritten by controllers
	public void function before(struct routeData, requestHandler req){}

	// can be overwritten by controllers
	public void function after(struct routeData, requestHandler req){}

	// ===================================
	// SHORTCUTS & HELPERS
	
	
	/**
	* @hint framework shortcut
	*/
	public framework function FB(){
		return variables.FireBolt;
	}

	/**
	* @hint request hander shortcut
	*/
	public struct function req(){
		return variables.requestHandler;
	}

	/**
	* @hint request context shortcut
	*/
	public struct function rc(){
		return req().getContext();
	}


	/**
	* @hint write a var dump out as a string
	*/
	public string function stringDump(any var){
		savecontent variable="local.content"{
			writeDump(arguments.var);
		}
		return local.content;
	}

	/**
	* @hint helper to call dynamic functions
	*/
	public function callFunction(required string fnc, args={}){
		//return this[arguments.fnc](argumentCollection=arguments.args);
		var callMe = this[arguments.fnc];
		return callMe(argumentCollection=arguments.args);
	}

	// ===================================
	// REQUEST
	/**
	* @hint set request data variable shortcut
	*/
	public void function setData(string key, any data){
		req().setData(arguments.key, arguments.data);
	}

	/**
	* @hint get request data variable shortcut
	*/
	public any function getData(string key){
		return req().getData(arguments.key);
	}


	// ===================================
	// RESPONSE HANDLING
	/**
	* @hint helper for our request response
	*/
	public function response(){
		return req().getResponse();
	}

	/**
	* @hint helper for setting our request response body
	*/
	public function respondWith(any body){
		return response().setBody(arguments.body);
	}

	/**
	* @hint call our response for our request handler
	*/
	public function respond(){
		return req().respond();
	}



	

	// ===================================
	// TEMPLATES
	/**
	* @hint returns a template path
	*/
	public string function templateRoot(string templateRootDir=""){
		if(len(arguments.templateRootDir)){
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
	*/
	public string function templatePath(string template="default", string root=templateRoot()){
		return "#arguments.root##replaceNoCase(arguments.template, '.', '/', 'ALL')#.cfm";
	}


	/**
	* @hint render a given template
	*/
	public any function layout(string templateName="default"){
		local.pathToTemplate = templatePath(arguments.templateName);
		savecontent variable="local.output" {include local.pathToTemplate;};
		response().setBody(local.output);
		return local.output;
	}

	/**
	* @hint performs a template include
	*/
	public string function templateInclude(required string templateName){
		savecontent variable="local.output" {include templatePath("includes." & arguments.templateName);};
		return local.output;
	}


	// ===================================
	// VIEWS
	public string function viewRoot(string viewRootDir=""){
		if(len(arguments.viewRootDir)){
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
	*/
	public string function viewPath(string viewFile="default", string root=viewRoot()){
		return "#arguments.root##replaceNoCase(arguments.viewFile, '.', '/', 'ALL')#.cfm";
	}

	/**
	* @hint render a view
	*/
	public any function view(string viewFile, any viewData={}, string contentRegion="", string root=viewRoot()){
		var data = arguments.viewData;
		savecontent variable="local.ret"{include "#viewPath(arguments.viewFile, arguments.root)#";}
		if(len(arguments.contentRegion)){
			variables.templateService.addContent(local.ret, arguments.contentRegion);
		}
		return local.ret;
	}

	/**
	* @hint render a view and add it by default to the default content region
	*/
	public any function addView(string viewFile, any viewData={}, string contentRegion="default", string root=viewRoot()){
		return view(argumentCollection:arguments);
	}


	/**
	* @hint render a module view
	*/
	public any function moduleView(string moduleRoot, string viewFile, any viewData={}, string contentRegion="", string viewPath="views"){
		local.pathToView = "/#arguments.moduleRoot#/#arguments.viewPath#/";
		return view(arguments.viewFile, arguments.viewData, arguments.contentRegion,  local.pathToView);
	}

	/**
	* @hint render a view and add it by default to the default content region
	*/
	public any function addModuleView(string moduleRoot, string viewFile, any viewData={}, string contentRegion="default", string viewPath="views"){
		return moduleView(argumentCollection:arguments);

	}



	// ===================================
	// TEMPLATE SERVICE PROXY
	

	/**
	* @hint creates proxy methods to our response output service methods
	*/
	public void function setTemplateProxyMethods(){
		variables.templateService = new templateService(this);
		for(local.key in variables.templateService){
			//FB().inject(this, local.key, local.templateService[local.key], true);
			
			if(!structKeyExists(this, local.key)){
				this[local.key] = this.templateProxyMethod;
				if(!structKeyExists(variables, local.key)){
					variables[local.key] = this.templateProxyMethod;
				}
			}
		}
	}

	/**
	* @hint this gets called by our proxied response output service methods and makes the call back to itself
	*/
	public any function templateProxyMethod(){
		return invoke(variables.templateService, getFunctionCalledName(), arguments);
	}

	
}