component{

	variables.FireBolt;
	variables.routes = {};	
	variables.controllerPath = "/controllers/";

	/**
	* @hint constructor
	* **/
	public routeService function init(framework FireBolt=application.FireBolt){
		variables.FireBolt = arguments.FireBolt;
		//variables.FireBolt.registerMethods("getObject,getModule,getService,getGateway,getBean", this);
		return this;
	}

	/**
	* @hint attempt to find and run a route for a given request
	* **/
	public any function runRoute(requestHandler req){
		local.c = arguments.req.getRoute();

		if(!isStruct(local.c)){
			local.c = getRoute(arguments.req);
		}
		
		if(local.c.isValid){
			//return local.c.cfc[local.c.method](argumentCollection:local.c.args);
			arguments.req.setRoute(local.c);
			return local.c.cfc.callFunction(local.c.method, local.c.args);
		}else{
			//return local.c;
			arguments.req.getResponse().setStatus(arguments.req.getResponse().codes.NOTFOUND);
			return "";
		}
	}

	/**
	* @hint attempt to find and run a route for a given request
	* **/
	public struct function getRoute(requestHandler req){
		local.path = listToArray(arguments.req.getRequest().path, "/");
		return walkPath(path: local.path, requestHandler: arguments.req);
	}

	/**
	* @hint attempt to find a route for a given path
	* **/
	public struct function walkPath(
		array path, 
		string method="index", 
		array args=[], 
		array history=[],
		requestHandler requestHandler){

		if(arguments.method IS "index") arguments.method = arguments.requestHandler.requestMethod();

		arrayAppend(arguments.history, arguments);

		local.cfcPath = variables.controllerPath & arrayTolist(arguments.path, "/");

		local.ret = {
			cfc: "",
			isValid: false,
			method: arguments.method,
			args: arguments.args,
			path: arguments.path,
			history: arguments.history
		};

		local.cfc = "";
		
		// check for cfc named as part of our path
		if(fileExists(expandPath(local.cfcPath) & ".cfc")){
			local.cfcDotPath = replaceNoCase(local.cfcPath, "/", ".");
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.requestHandler, variables.FireBolt);
			if(containsFunction(local.cfc, arguments.method, arrayLen(arguments.args))){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
			}
		}

		// check for our index cfc
		if(!local.ret.isValid AND fileExists(expandPath(local.cfcPath) & "/index.cfc")){
			local.cfcDotPath = replaceNoCase(local.cfcPath, "/", ".") & ".index";
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.requestHandler, variables.FireBolt);
			if(containsFunction(local.cfc, arguments.method, arrayLen(arguments.args))){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
			}
		}

		// return from here if we have found a route
		if(local.ret.isValid) return local.ret;

		// if we get here, we check for making a recursive call
		if(arrayLen(arguments.path)){
			if(arguments.method != "index"
				AND arguments.method != arguments.requestHandler.requestMethod()){
				// try our index method
				//arrayAppend(arguments.args, arguments.path[arrayLen(arguments.path)]);
				arrayPrepend(arguments.args, arguments.method);
				//arrayDeleteAt(arguments.path, arrayLen(arguments.path));
				return walkPath(arguments.path, "index", arguments.args, arguments.history, arguments.requestHandler);
			}else{
				// check for a 404 method - if found, this stops our walk...
				if(containsFunction(local.cfc, "get404", 0, false)){
					local.ret.cfc = local.cfc;
					local.ret.isValid = true;
					local.ret.method = "get404";
					arguments.requestHandler.getResponse().setStatus(arguments.requestHandler.getResponse().codes.NOTFOUND);
					return local.ret;
				}
				// move up our path
				local.nextMethod = arguments.path[arrayLen(arguments.path)];
				arrayDeleteAt(arguments.path, arrayLen(arguments.path));
				return walkPath(arguments.path, local.nextMethod, arguments.args, arguments.history, arguments.requestHandler);
			}

		}else if(arguments.method != "index"
			AND arguments.method != arguments.requestHandler.requestMethod()){
			arrayPrepend(arguments.args, arguments.method);
			return walkPath(arguments.path, "index", arguments.args, arguments.history, arguments.requestHandler);
		}

		// if we get here and have not found a valid route, look for a 404 controller
		if(fileExists(expandPath(local.cfcPath) & "/404.cfc")){
			local.cfcDotPath = replaceNoCase(local.cfcPath, "/", ".") & ".404";
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.requestHandler, variables.FireBolt);
			if(containsFunction(local.cfc, "get", 0, false)){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
				local.ret.method = "get";
				arguments.requestHandler.getResponse().setStatus(arguments.requestHandler.getResponse().codes.NOTFOUND);
			}
		}

		return local.ret;
	}


	/**
	* @hint returns our request method: GET, POST, PUT, DELETE, etc
	* **/
	public string function requestMethod(){
		return getHTTPRequestData().method;
	}

	/**
	* @hint returns true if a given cfc contains a function with a given name, matching verb and a given number of arguments
	* **/
	public boolean function containsFunction(required any cfc, required string func, numeric maxArgs=0, boolean checkVerb=true){
		var meta = getMetaData(arguments.cfc);
		var i = 1;
		if(structKeyExists(meta, "functions")){
			for(i=1; i<=arrayLen(meta.functions); i++){
				if((NOT arguments.checkVerb OR isVerbValid(meta.functions[i]))
					AND (meta.functions[i].name IS arguments.func)
					AND (arrayLen(meta.functions[i].parameters) GTE arguments.maxArgs)){
					return true;
				}
			}
		}
		return false;
	}

	/**
	* @hint returns true if a given function is set to accept a given verb
	* **/
	public boolean function isVerbValid(struct functionMetaData, string verb=requestMethod()){
		if(arguments.functionMetaData.name IS arguments.verb
			OR (structKeyExists(arguments.functionMetaData, "verbs")
					AND (listFindNoCase(arguments.functionMetaData.verbs, requestMethod()) 
						OR (arguments.functionMetaData.verbs IS "*")))){
			return true;
		}
		return false;

	}

}