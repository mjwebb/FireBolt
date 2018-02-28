component{

	variables.FireBolt = "";
	variables.routes = {};	
	variables.controllerPath = "/controllers/";

	/**
	* @hint constructor
	*/
	public routeService function init(framework FireBolt){
		variables.FireBolt = arguments.FireBolt;
		//variables.FireBolt.registerMethods("getObject,getModule,getService,getGateway,getBean", this);
		variables.controllerPath = variables.FireBolt.getSetting('paths.controllers');
		return this;
	}

	/**
	* @hint attempt to find and run a route for a given request
	*/
	public any function runRoute(requestHandler req){
		local.c = arguments.req.getRoute();

		if(!isStruct(local.c)){
			local.c = getRoute(arguments.req);
		}
		
		if(local.c.isValid){
			arguments.req.setRoute(local.c);
			//return local.c.cfc[local.c.method](argumentCollection:local.c.args);
			return invoke(local.c.cfc, local.c.method, local.c.args);
			//return local.c.cfc.callFunction(local.c.method, local.c.args);
		}else{
			//return local.c;
			arguments.req.getResponse().setStatus(arguments.req.getResponse().codes.NOTFOUND);
			return "";
		}
	}

	/**
	* @hint attempt to find and run a route for a given request
	*/
	public struct function getRoute(requestHandler req){
		local.path = listToArray(arguments.req.getContext().path, "/");
		return walkPath(path: local.path, req: arguments.req);
	}

	/**
	* @hint defines a route manually
	*/
	public struct function defineRoute(requestHandler req, string cfcPath, string method, struct args={}){
		local.cfcDotPath = replace(variables.controllerPath, "/", "", "ALL") & "." & arguments.cfcPath;
		local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, variables.FireBolt);
		return {
			cfc: local.cfc,
			isValid: true,
			method: arguments.method,
			args: arguments.args
		};
	}

	/**
	* @hint attempt to find a route for a given path
	*/
	public struct function walkPath(
		array path, 
		string method="index", 
		array args=[], 
		array history=[],
		requestHandler req){

		if(arguments.method IS "index") arguments.method = arguments.req.requestMethod();

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
			local.cfcDotPath = cleanDotPath(local.cfcPath);
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, variables.FireBolt);
			if(containsFunction(local.cfc, arguments.method, arrayLen(arguments.args), arguments.req.requestMethod())){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
			}
		}

		// check for our index cfc
		if(!local.ret.isValid AND fileExists(expandPath(local.cfcPath) & "/index.cfc")){
			local.cfcDotPath = cleanDotPath(local.cfcPath & ".index");
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, variables.FireBolt);
			if(containsFunction(local.cfc, arguments.method, arrayLen(arguments.args), arguments.req.requestMethod())){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
			}
		}

		// return from here if we have found a route
		if(local.ret.isValid) return local.ret;

		// if we get here, we check for making a recursive call
		if(arrayLen(arguments.path)){
			if(arguments.method != "index"
				AND arguments.method != arguments.req.requestMethod()){
				// try our index method
				//arrayAppend(arguments.args, arguments.path[arrayLen(arguments.path)]);
				arrayPrepend(arguments.args, arguments.method);
				//arrayDeleteAt(arguments.path, arrayLen(arguments.path));
				return walkPath(arguments.path, "index", arguments.args, arguments.history, arguments.req);
			}else{
				// check for a 404 method - if found, this stops our walk...
				if(containsFunction(local.cfc, "do404")){
					local.ret.cfc = local.cfc;
					local.ret.isValid = true;
					local.ret.method = "do404";
					arguments.req.getResponse().setStatus(arguments.req.getResponse().codes.NOTFOUND);
					return local.ret;
				}
				// move up our path
				local.nextMethod = arguments.path[arrayLen(arguments.path)];
				arrayDeleteAt(arguments.path, arrayLen(arguments.path));
				return walkPath(arguments.path, local.nextMethod, arguments.args, arguments.history, arguments.req);
			}

		}else if(arguments.method != "index"
			AND arguments.method != arguments.req.requestMethod()){
			arrayPrepend(arguments.args, arguments.method);
			return walkPath(arguments.path, "index", arguments.args, arguments.history, arguments.req);
		}

		// if we get here and have not found a valid route, look for a 404 controller
		if(fileExists(expandPath(local.cfcPath) & "/404.cfc")){
			local.cfcDotPath = cleanDotPath(local.cfcPath & ".404");
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, variables.FireBolt);
			if(containsFunction(local.cfc, "do404")){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
				local.ret.method = "do404";
				arguments.req.getResponse().setStatus(arguments.req.getResponse().codes.NOTFOUND);
			}
		}

		return local.ret;
	}


	/**
	* @hint cleans a path 
	*/
	public string function cleanDotPath(string path){
		local.cfcDotPath = replaceNoCase(arguments.path, "/", ".", "ALL");
		local.cfcDotPath = replaceNoCase(local.cfcDotPath, "..", ".", "ALL");
		if(left(local.cfcDotPath, 1) IS "."){
			local.cfcDotPath = mid(local.cfcDotPath, 2, len(local.cfcDotPath));
		}
		return local.cfcDotPath;
	}

	/**
	* @hint returns true if a given cfc contains a function with a given name, matching verb and a given number of arguments
	*/
	public boolean function containsFunction(required any cfc, required string func, numeric maxArgs=0, string verb=""){
		var meta = getMetaData(arguments.cfc);
		var i = 1;
		if(structKeyExists(meta, "functions")){
			for(i=1; i<=arrayLen(meta.functions); i++){
				if((NOT len(arguments.verb) OR isVerbValid(meta.functions[i], arguments.verb))
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
	*/
	public boolean function isVerbValid(struct functionMetaData, string verb){
		if(arguments.functionMetaData.name IS arguments.verb
			OR (structKeyExists(arguments.functionMetaData, "verbs")
				AND (listFindNoCase(arguments.functionMetaData.verbs, arguments.verb) 
					OR (arguments.functionMetaData.verbs IS "*")))){
			return true;
		}
		return false;

	}

}