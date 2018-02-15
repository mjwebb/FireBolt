component{

	variables.startTime = getTickCount();
	variables.rootPath = "";
	variables.configService;
	variables.routeService;
	variables.eventService;
	variables.factoryService;
	variables.startup = now();
	variables.registeredMethods = {};

	/**
	* @hint constructor
	* **/
	public framework function init(string rootPath){
		variables.rootPath = rootPath;
		loadFramework();
		return this;
	}

	/**
	* @hint loads our FireBolt framework
	* **/
	public void function loadFramework(){
		variables.configService = new configService("FireBolt", this);
		variables.routeService = new routeService(this);
		variables.eventService = new eventService(this);
		variables.factoryService = new factoryService(this);
		getEventService().trigger("FireBolt.loaded");
	}

	
	/**
	* @hint registers a FireBolt method from within another object
	* **/
	public void function registerMethods(string methods, any object){
		// we make sure that the object in question is part of our FireBolt namespace
		if(listFirst(getMetaData(arguments.object).name, ".") IS "FireBolt"){
			// now we can register our events
			local.methodArray = listToArray(arguments.methods);
			for(local.method in local.methodArray){
				variables.registeredMethods[local.method] = arguments.object;	
			}
		}
	}

	/**
	* @hint write a var dump out as a string
	* **/
	public string function stringDump(any var){
		savecontent variable="local.content"{
			writeDump(arguments.var);
		}
		return local.content;
	}

	/**
	* @hint adds a mapping to our application
	* **/
	public string function addMapping(required string name, required string path){
		local.appMD = getApplicationMetadata();
		local.appMD.mappings[arguments.name] = arguments.path;
		try{
			application action="update" mappings="#local.appMD.mappings#";
		}catch(e){
			// no matching application update method
		}
	}

	/*
	request handler entry point
	===================================== */

	/**
	* @hint create a new request
	* **/
	public requestHandler function FireBoltRequest(
		string pathInfo=cgi.path_info,
		string scriptName=cgi.script_name,
		struct formScope=form,
		struct urlScope=url){
		structAppend(arguments, {
			FireBolt:this
		});
		return new requestHandler(argumentCollection:arguments);
	}


	/*
	getters for our framework services
	===================================== */

	/**
	* @hint returns our event service
	* **/
	public routeService function getRouteService(){
		return variables.routeService;
	}

	/**
	* @hint returns our event service
	* **/
	public eventService function getEventService(){
		return variables.eventService;
	}

	/**
	* @hint returns our factory service
	* **/
	public factoryService function getFactoryService(){
		return variables.factoryService;
	}

	/**
	* @hint returns our factory service
	* **/
	public aopService function getAOPService(){
		return getFactoryService().getAOPService();
	}

	
	
	/*
	missing method handler
	===================================== */

	/**
	* @hint used to proxy service methods within the framework
	* **/
	public any function onMissingMethod(string missingMethodName, struct missingMethodArguments){
		local.proxy = "";
		// find method names that we can proxy within our framework services
		switch(arguments.missingMethodName){
			// config
			case "__getSetting":
				local.proxy = "configService";
			break;
			default:
				if(structKeyExists(variables.registeredMethods, arguments.missingMethodName)){
					local.proxy = variables.registeredMethods[arguments.missingMethodName];
				}
		}
		// perform our proxy
		if(isObject(local.proxy)){
			return local.proxy[arguments.missingMethodName](argumentCollection:arguments.missingMethodArguments);
		}else if(len(local.proxy)){
			return variables[local.proxy][arguments.missingMethodName](argumentCollection:arguments.missingMethodArguments);
		}
		// not found..
		throw("Method '#encodeForHTML(arguments.missingMethodName)#' is not part of FireBolt");
	}


	/*
	application events
	===================================== */

	/**
	* @hint called when our application ends
	* **/
	public void function onApplicationEnd(struct appScope){
		
	}

	/**
	* @hint called when a request starts
	* **/
	public function onRequestStart(string targetPage) output="true"{
		getFactoryService().addModuleMappings(); // mappings need to be added on every request
		getEventService().trigger("req.start", arguments);
		local.targetPage = arguments.targetPage;
		local.req = FireBoltRequest(arguments.targetPage);
		writeOutput(local.req.process());
		return true;
	}

	/**
	* @hint called when a sesison starts
	* **/
	public void function onSessionStart(){
		getEventService().trigger("session.start");
	}

	/**
	* @hint called when a session ends
	* **/
	public void function onSessionEnd(struct sessionScope, struct appScope){
		getEventService().trigger("session.end", arguments);
	}

	/**
	* @hint called when a template can not be found
	* **/
	public boolean function onMissingTemplate(template){
		
	}

	/**
	* @hint erorr handler
	* **/
	public string function onError(any exception, string eventName=""){
		savecontent variable="local.err"{
			writeOutput('<div style="background: ##fff; color: ##000; padding: 10px;">');
			writeDump(var:arguments, label:"Error", format:"text");
			writeDump(var:url, label:"URL", format:"text");
			if(isDefined("form")){
				writeDump(var:form, label:"Form", format:"text");
			}
			writeDump(var:cgi, label:"CGI", format:"text");	
			writeOutput('</div>');
		}
		return local.err;
	}

}