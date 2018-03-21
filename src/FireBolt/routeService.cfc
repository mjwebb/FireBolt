component accessors="true"{

	property FireBolt;

	variables.routes = {};	
	variables.controllerPath = "/app/controllers/";
	variables.routes = {};
	variables.verbs = "POST,GET,PUT,PATCH,DELETE";
	variables.specialMethods = "do404";

	/**
	* @hint constructor
	*/
	public routeService function init(framework FireBolt){
		setFireBolt(arguments.FireBolt);
		variables.controllerPath = getFireBolt().getSetting('paths.controllers');
		scanControllers(variables.controllerPath);
		return this;
	}

	/**
	* @hint scans our controller directory to cache the paths and methods that can form routes
	*/
	public void function scanControllers(string rootPath){
		local.fullPath = expandPath(arguments.rootPath);
		local.dotRoot = getFireBolt().cleanDotPath(arguments.rootPath);


		// NOTE ACF does not accept named arguments for directoryList
		local.cfcs = directoryList(local.fullPath, true, "path", "*.cfc");

		//variables.routes["x"] = local.cfcs;
		//variables.routes["path"] = arguments.rootPath;

		for(local.cfc in local.cfcs){
			// convert to dot notation
			local.cfcPath = replaceNoCase(local.cfc, local.fullPath, "");
			local.cfcDotPath = getFireBolt().cleanDotPath(local.cfcPath);
			local.cfcRootDotPath = getFireBolt().cleanDotPath(local.dotRoot & "." & local.cfcPath);

			local.ctrl = createObject("component", local.cfcRootDotPath);
			local.meta = getMetaData(local.ctrl);

			local.methods = {};

			//variables.routes[local.cfcDotPath] = local.meta;

			for(local.fnc in local.meta.functions){
				if(listFindNoCase(variables.verbs, local.fnc.name) 
					OR listFindNoCase(variables.specialMethods, local.fnc.name)
					OR structKeyExists(local.fnc, "verbs")){
					local.verbs = "";
					if(structKeyExists(local.fnc, "verbs")){
						local.verbs = local.fnc.verbs;
					}
					if(listFindNoCase(variables.verbs, local.fnc.name)){
						local.verbs = local.fnc.name;
					}
					variables.routes[local.cfcDotPath & "." & local.fnc.name] = {
						cfcPath: local.cfcRootDotPath,
						controllerPath: local.cfcDotPath,
						functionName: local.fnc.name,
						argLength: arrayLen(local.fnc.parameters),
						verbs: local.verbs
					};
				}
			}

		}
	}

	public struct function getControllerRoutes(){
		return variables.routes;
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
			return invoke(local.c.cfc, local.c.method, local.c.args);
		}else{
			/*savecontent variable="local.err"{
				writeDump(local.c);
			}
			arguments.req.getResponse().setBody(local.err);*/
			arguments.req.getResponse().setStatus(arguments.req.getResponse().codes.NOTFOUND);
			return "";
		}
	}

	/**
	* @hint attempt to find and run a route for a given request
	*/
	public struct function getRoute(requestHandler req){
		local.path = listToArray(arguments.req.getContext().path, "/");
		//return walkPath(path: local.path, req: arguments.req);
		return walkRoute(path: local.path, req: arguments.req);
	}

	/**
	* @hint defines a route manually
	*/
	public struct function defineRoute(requestHandler req, string cfcPath, string method, struct args={}){
		local.cfcDotPath = getFireBolt().cleanDotPath(variables.controllerPath & "." & arguments.cfcPath);
		local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, getFireBolt());
		return {
			cfc: local.cfc,
			isValid: true,
			method: arguments.method,
			args: arguments.args
		};
	}

	/**
	* @hint attempt to find a route for a given path by using our cached routes
	*/
	public struct function walkRoute(
		array path, 
		string method="index", 
		array args=[], 
		array history=[],
		requestHandler req){

		if(arguments.method IS "index") arguments.method = arguments.req.requestMethod();

		arrayAppend(arguments.history, arguments);

		local.cfcPath = variables.controllerPath & arrayTolist(arguments.path, "/");
		local.cfcDotPath = getFireBolt().cleanDotPath(arrayTolist(arguments.path, "."));

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
		if(structKeyExists(variables.routes, local.cfcDotPath & "." & arguments.method)){
			local.fnc = variables.routes[local.cfcDotPath & "." & arguments.method];
			if(listFindNoCase(local.fnc.verbs, arguments.req.requestMethod())
				AND local.fnc.argLength GTE arrayLen(arguments.args)){
				local.ret.cfc = getFireBolt().getController(local.fnc.controllerPath, arguments.req, getFireBolt());
				local.ret.isValid = true;
			}
		}

		// check for our index cfc
		local.indexDotPath = getFireBolt().cleanDotPath(local.cfcDotPath & ".index." & arguments.method);
		if(!local.ret.isValid 
			AND structKeyExists(variables.routes, local.indexDotPath)){
			local.fnc = variables.routes[local.indexDotPath];
			if(listFindNoCase(local.fnc.verbs, arguments.req.requestMethod())
				AND local.fnc.argLength GTE arrayLen(arguments.args)){
				local.ret.cfc = getFireBolt().getController(local.fnc.controllerPath, arguments.req, getFireBolt());
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
				arrayPrepend(arguments.args, arguments.method);
				return walkRoute(arguments.path, "index", arguments.args, arguments.history, arguments.req);
			}else{
				// check for a 404 method - if found, this stops our walk...
				if(structKeyExists(variables.routes, local.cfcDotPath & ".do404")){
				//if(containsFunction(local.cfc, "do404")){
					local.fnc = variables.routes[local.cfcDotPath & ".do404"];
					local.ret.cfc = getFireBolt().getController(local.fnc.controllerPath, arguments.req, getFireBolt());
					local.ret.isValid = true;
					local.ret.method = "do404";
					arguments.req.getResponse().setStatus(arguments.req.getResponse().codes.NOTFOUND);
					return local.ret;
				}
				// move up our path
				local.nextMethod = arguments.path[arrayLen(arguments.path)];
				arrayDeleteAt(arguments.path, arrayLen(arguments.path));
				return walkRoute(arguments.path, local.nextMethod, arguments.args, arguments.history, arguments.req);
			}

		}else if(arguments.method != "index"
			AND arguments.method != arguments.req.requestMethod()){
			arrayPrepend(arguments.args, arguments.method);
			return walkRoute(arguments.path, "index", arguments.args, arguments.history, arguments.req);
		}

		// if we get here and have not found a valid route, look for a 404 controller
		if(fileExists(expandPath(local.cfcPath) & "/404.cfc")){
			local.cfc = getFireBolt().getController(local.cfcDotPath & ".404", arguments.req, getFireBolt());
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
	* @hint attempt to find a route for a given path
	*/
	public struct function ___walkPath(
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
			local.cfcDotPath = getFireBolt().cleanDotPath(local.cfcPath);
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, getFireBolt());
			if(containsFunction(local.cfc, arguments.method, arrayLen(arguments.args), arguments.req.requestMethod())){
				local.ret.cfc = local.cfc;
				local.ret.isValid = true;
			}
		}

		// check for our index cfc
		if(!local.ret.isValid AND fileExists(expandPath(local.cfcPath) & "/index.cfc")){
			local.cfcDotPath = getFireBolt().cleanDotPath(local.cfcPath & ".index");
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, getFireBolt());
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
			local.cfcDotPath = getFireBolt().cleanDotPath(local.cfcPath & ".404");
			local.cfc = createObject("component", local.cfcDotPath).init(arguments.req, getFireBolt());
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