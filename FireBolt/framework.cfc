component{

	variables.startTime = getTickCount();
	variables.rootPath = "";
	variables.flavour = "";
	variables.configService = "";
	variables.routeService = "";
	variables.eventService = "";
	variables.factoryService = "";
	variables.startup = now();
	variables.registeredMethods = {};
	variables.isLoaded = false;

	/**
	* @hint constructor
	*/
	public framework function init(string rootPath){
		variables.rootPath = rootPath;
		loadFramework();
		return this;
	}

	/**
	* @hint loads our FireBolt framework
	*/
	public void function loadFramework(){
		variables.flavour = new flavour.engine();
		variables.configService = new configService("FireBolt", this);
		variables.routeService = new routeService(this);
		variables.eventService = new eventService(this);
		variables.factoryService = new factoryService(this);
		getEventService().trigger("FireBolt.loaded");
		variables.isLoaded = true;
	}

	
	/**
	* @hint registers a FireBolt method from within another object
	*/
	public void function registerMethods(string methods, any object){
		// we make sure that the object in question is part of our FireBolt namespace
		if(listFirst(getMetaData(arguments.object).name, ".") IS "FireBolt"){
			// now we can register our methods
			local.methodArray = listToArray(arguments.methods);
			for(local.method in local.methodArray){
				variables.registeredMethods[local.method] = arguments.object;	
			}
		}
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
	* @hint adds a mapping to our application
	*/
	public string function addMapping(required string name, required string path){
		variables.flavour.addMapping(arguments.name, arguments.path);
	}

	/*
	request handler entry point
	===================================== */

	/**
	* @hint create a new request
	*/
	public requestHandler function FireBoltRequest(
		string path=cgi.path_info,
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
	*/
	public routeService function getRouteService(){
		return variables.routeService;
	}

	/**
	* @hint returns our event service
	*/
	public eventService function getEventService(){
		return variables.eventService;
	}

	/**
	* @hint returns our factory service
	*/
	public factoryService function getFactoryService(){
		return variables.factoryService;
	}

	/**
	* @hint returns our factory service
	*/
	public aopService function getAOPService(){
		return getFactoryService().getAOPService();
	}

	
	
	/*
	missing method handler
	===================================== */

	/**
	* @hint used to proxy service methods within the framework
	*/
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
			//return local.proxy[arguments.missingMethodName](argumentCollection:arguments.missingMethodArguments);
			return invoke(local.proxy, arguments.missingMethodName, arguments.missingMethodArguments);
		}else if(len(local.proxy)){
			//return variables[local.proxy][arguments.missingMethodName](argumentCollection:arguments.missingMethodArguments);
			return invoke(variables[local.proxy], arguments.missingMethodName, arguments.missingMethodArguments);
		}
		// not found..
		throw("Method '#encodeForHTML(arguments.missingMethodName)#' is not part of FireBolt");
	}


	/*
	application events
	===================================== */

	/**
	* @hint called when our application ends
	*/
	public void function onApplicationEnd(struct appScope){
		
	}

	/**
	* @hint called when a request starts
	* @output true
	*/
	public function onRequestStart(string targetPage){
		getFactoryService().addModuleMappings(); // mappings need to be added on every request
		getEventService().trigger("req.start", arguments);
		local.req = FireBoltRequest();
		writeOutput(local.req.process());
	}

	/**
	* @hint called when a sesison starts
	*/
	public void function onSessionStart(){
		getEventService().trigger("session.start");
	}

	/**
	* @hint called when a session ends
	*/
	public void function onSessionEnd(struct sessionScope, struct appScope){
		getEventService().trigger("session.end", arguments);
	}

	/**
	* @hint called when a template can not be found
	*/
	public boolean function onMissingTemplate(template){
		
	}

	/**
	* @hint erorr handler
	*/
	public string function onError(any exception, string eventName=""){
		local.err = {
			exception: arguments.exception,
			eventName: arguments.eventName
		};

		if(variables.isLoaded){

			// trigger an error event
			try{
				getEventService().trigger("FireBolt.error", local.err);
			}catch(any e){
				// error within our event - skip this and continue to output our original error
			}


			// attempt to process an error controller
			try{
				getFactoryService().addModuleMappings(); // mappings need to be added on every request
				local.errReq = FireBoltRequest("onError");
				local.errReq.setRequestData(local.err);
				// set an error status code
				local.errReq.getResponse().setStatus(local.errReq.getResponse().codes.ERROR);
				// call our error route
				local.errReq.processRoute("index", "onError", local.err, true, false);
				//if(local.errReq.getResponse().getStatus() EQ local.errReq.getResponse().codes.OK){
					return local.errReq.getResponse().getBody();
				//}
			}catch(any e){
				// problem in our error render
			}

		}

		// if we get here, we output our defaut error
		savecontent variable="local.err"{
			writeOutput('<div style="background: ##fff !important; color: ##000 !important; padding: 10px;">');
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