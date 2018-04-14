component accessors="true"{

	property FireBolt;
	property AOPService;

	variables.cache = {};
	variables.aspectConcerns = {};
	variables.moduleMappings = {};

	variables.metaKeys = {
		TRANSIENT: "transient",
		SINGLETON: "singleton",
		INJECT: "inject",
		SETTING: "setting:"
	};

	/**
	* @hint constructor
	*/
	public factoryService function init(framework FireBolt){
		setFireBolt(arguments.FireBolt);
		getFireBolt().registerMethods("getObject,getController,registerMapping,getMapping,register,before,after,removeBefore,removeAfter,getConcerns,getAllConcerns", this);
		autoRegisterModules();
		setAOPService(new aopService(this));
		getFireBolt().registerMethods("call", getAOPService());
		configureModules();
		return this;
	}

	/*
	register modules
	================================ */
	/**
	* @hint scan our modules and models directory and create mappings components within
	*/
	public void function autoRegisterModules(){
		// get our module paths
		local.modulePaths = getModulePaths();
		// add our mappings
		addCFMappings(local.modulePaths);
		// read any config files
		for(local.modulePath in local.modulePaths){
			//readModuleConfig(local.modulePath);
			createMappings(local.modulePath);
		}
		// register our models
		createMappings(expandPath(getModelsPath()), false);
	}

	/**
	* @hint scan our modules directory for configuration files
	*/
	public void function configureModules(){
		// get our module paths
		local.modulePaths = getModulePaths();
		// read any config files
		for(local.modulePath in local.modulePaths){
			moduleConfig(local.modulePath);
		}
	}

	/**
	* @hint scan our modules directory for configuration files for registering OP concerns
	*/
	/*public void function registerAOPConfig(){
		// get our module paths
		local.modulePaths = getModulePaths();
		// read any config files
		for(local.modulePath in local.modulePaths){
			moduleConfig(local.modulePath);
		}
	}*/

	/**
	* @hint adds a mapping for each module sub-directory and our models directory - this needs to be done every request
	*/
	public void function addCFMappings(array modulePaths=getModulePaths()){
		for(local.modulePath in arguments.modulePaths){
			getFireBolt().addCFMapping("/" & listLast(local.modulePath, "\"), local.modulePath);
		}
		getFireBolt().addCFMapping("/models", expandPath(getModelsPath()));
	}

	/**
	* @hint looks for a module config within a given module path
	*/
	/*
	public void function readModuleConfig(string modulePath){
		if(fileExists(arguments.modulePath & "\config.cfc")){
			local.mapping = listLast(arguments.modulePath, "\");
			local.moduleConfig = getConfigComponent(arguments.modulePath);
			if(structKeyExists(local.moduleConfig, "config")){
				getFireBolt().mergeSetting("modules.#local.mapping#", local.moduleConfig.config);
			}
			if(structKeyExists(local.moduleConfig, "listeners")){
				getFireBolt().addListeners(local.moduleConfig.listeners);
			}
			local.moduleConfig.configure();
		}
	}
	*/
	/**
	* @hint looks for a module config within a given module path
	*/
	/*
	public void function readModuleAOPConfig(string modulePath){
		if(fileExists(arguments.modulePath & "\config.cfc")){
			local.moduleConfig = getConfigComponent(arguments.modulePath);
			if(structKeyExists(local.moduleConfig, "aspectConcerns")){
				local.before = [];
				if(structKeyExists(local.moduleConfig.aspectConcerns, "before")) local.before = local.moduleConfig.aspectConcerns.before;
				local.after = [];
				if(structKeyExists(local.moduleConfig.aspectConcerns, "after")) local.after = local.moduleConfig.aspectConcerns.after;
				getAOPService().addConcerns(local.before, local.after);
			}
			local.moduleConfig.registerConcerns();
		}
	}
	*/
	/**
	* @hint looks for a module config within a given module path
	*/
	public void function moduleConfig(string modulePath){
		if(fileExists(arguments.modulePath & "\config.cfc")){
			local.mapping = listLast(arguments.modulePath, "\");
			local.moduleConfig = getConfigComponent(arguments.modulePath);
			if(structKeyExists(local.moduleConfig, "config")){
				getFireBolt().mergeSetting("modules.#local.mapping#", local.moduleConfig.config);
			}
			if(structKeyExists(local.moduleConfig, "listeners")){
				getFireBolt().addListeners(local.moduleConfig.listeners);
			}
			if(structKeyExists(local.moduleConfig, "aspectConcerns")){
				local.before = [];
				if(structKeyExists(local.moduleConfig.aspectConcerns, "before")) local.before = local.moduleConfig.aspectConcerns.before;
				local.after = [];
				if(structKeyExists(local.moduleConfig.aspectConcerns, "after")) local.after = local.moduleConfig.aspectConcerns.after;
				getAOPService().addConcerns(local.before, local.after);
			}
			local.moduleConfig.configure();
		}
	}

	/**
	* @hint get config component
	*/
	public any function getConfigComponent(string modulePath){
		local.mapping = listLast(arguments.modulePath, "\");
		local.moduleConfig = createObject("component", local.mapping & ".config");
		getFireBolt().injectFramework(local.moduleConfig);
		if(!structKeyExists(local.moduleConfig, "configure")){
			local.moduleConfig["configure"] = function(){};
		}
		if(!structKeyExists(local.moduleConfig, "registerConcerns")){
			local.moduleConfig["registerConcerns"] = function(){};
		}
		return local.moduleConfig;
	}

	
	/**
	* @hint scans a given directrory for cfc's and generates aliases for each one
	*/
	public void function createMappings(string modulePath, boolean includeRootAlias=true){
		local.moduleRoot = listLast(arguments.modulePath, "\");

		local.cfcs = listComponents(arguments.modulePath);

		for(local.cfc in local.cfcs){
			
			local.cfcDotPath = getFireBolt().cleanDotPath(replaceNoCase(local.cfc, arguments.modulePath, ""));

			// add our module root back into the path
			local.cfcDotPath = local.moduleRoot & "." & local.cfcDotPath;
			// form an alias based on the cfc name and the module root

			local.alias = listLast(local.cfcDotPath, ".");
			if(arguments.includeRootAlias){
				local.alias = local.alias & "@" & local.moduleRoot;
			}
			
			registerMapping(local.cfcDotPath, local.alias);
		}
	}


	/**
	* @hint scans a given directrory for cfc's
	*/
	public array function listComponents(string modulePath){
		// NOTE ACF does not accept named arguments for directoryList
		return directoryList(arguments.modulePath, true, "path", "*.cfc");
	}
	
	

	/**
	* @hint adds an alias for a module path
	*/
	public void function registerMapping(string modulePath, string alias, array initArgs=[], array properties=[], boolean singleton=true){
		variables.moduleMappings[arguments.alias] = {
			name: arguments.modulePath,
			initArgs: arguments.initArgs, // { name: "", value | ref }
			properties: arguments.properties, // { name: "", value | ref }
			singleton: arguments.singleton
		};
	}

	/**
	* @hint searches our aliases for a given key
	*/
	public struct function getMapping(string alias=""){
		if(len(arguments.alias) AND structKeyExists(variables.moduleMappings, arguments.alias)){
			return variables.moduleMappings[arguments.alias];
		}
		return {
			name: "",
			initArgs: [],
			properties: [],
			singleton: false
		};
	}

	/**
	* @hint returns all registered aliases
	*/
	public struct function getMappings(){
		return variables.moduleMappings;
	}
	
	/**
	* @hint returns an array of directories within our modules path
	*/
	public array function getModulePaths(){
		return directoryList(expandPath(getModulePath()));
	}



	/**
	* @hint syntax to register a component
	*/
	public struct function register(string dotPath){
		var mapping = {
			definition: {
				alias: "",
				modulePath: arguments.dotPath,
				initArgs: [],
				properties: [],
				singleton: true
			}
		};

		structAppend(mapping, {
			as: function(string alias){
				mapping.definition.alias = arguments.alias;
				registerMapping(argumentCollection:mapping.definition);
				return mapping;
			},
			withInitArg: function(string name, any value, string ref){
				var m = getMapping(mapping.definition.alias);
				if(isNull(arguments.value)){
					structDelete(arguments, "value");
				}
				if(isNull(arguments.ref)){
					structDelete(arguments, "ref");
				}
				arrayAppend(m.initArgs, arguments);
				return mapping;
			},
			withProperty: function(string name, any value, string ref){
				var m = getMapping(mapping.definition.alias);
				if(isNull(arguments.value)){
					structDelete(arguments, "value");
				}
				if(isNull(arguments.ref)){
					structDelete(arguments, "ref");
				}
				arrayAppend(m.properties, arguments);
				return mapping;
			},
			asSingleton: function(){
				var m = getMapping(mapping.definition.alias);
				m.singleton = true;
				return mapping;
			},
			asTransient: function(){
				var m = getMapping(mapping.definition.alias);
				m.singleton = false;
				return mapping;
			}
		});

		return mapping;
	}

	/*
	get object helpers
	================================ */
	
	/**
	* @hint return our module path as dotnotation or directly as it is defined in the config
	*/
	public any function getModulePath(boolean dotNotation=false){
		local.path = getFireBolt().getSetting('paths.modules');
		if(arguments.dotNotation){
			local.path = getFireBolt().cleanDotPath(local.path);
		}
		return local.path;
	}

	/**
	* @hint return our models path as dotnotation or directly as it is defined in the config
	*/
	public any function getModelsPath(boolean dotNotation=false){
		local.path = getFireBolt().getSetting('paths.models');
		if(arguments.dotNotation){
			local.path = getFireBolt().cleanDotPath(local.path);
		}
		return local.path;
	}


	/*
	our main invoker
	================================ */

	/**
	* @hint get an controller
	*/
	public any function getController(string controller="", requestHandler req=request.FireBoltReq, framework FireBolt){
		if(!len(arguments.controller)){
			// returns a base controller
			return getObject("FireBolt.controller", {req: request.FireBoltReq}, false);
		}else{
			// returns a controller based on our given path
			local.controllerRoot = getFireBolt().cleanDotPath(getFireBolt().getSetting('paths.controllers'));
			return getObject(local.controllerRoot & "." & arguments.controller, arguments, false);
		}
	}

	/**
	* @hint proxy for getObject
	*/
	public any function getBean(
		required string name, 
		struct args={}, 
		boolean singleton=true){
		return getObject(argumentCollection:arguments);
	}

	/**
	* @hint get an object
	*/
	public any function getObject(
		required string name, 
		struct args={}, 
		boolean singleton=true){

		local.aliasInitArgs = [];
		local.aliasProperties = [];

		// check for an alias
		local.aliasResult = getMapping(arguments.name);
		if(len(local.aliasResult.name)){
			arguments.name = local.aliasResult.name;
			local.aliasInitArgs = local.aliasResult.initArgs;
			local.aliasProperties = local.aliasResult.properties;
			//structAppend(local.aliasResults.initArgs, arguments.args);
			if(!local.aliasResult.singleton){
				arguments.singleton = false;
			}
		}

		// if we have a 'bean' treat it as transient
		if(right(arguments.name, 4) IS "bean"){
			arguments.singleton = false;
		}


		// if this is a singleton, it might already be cached
		if(arguments.singleton){
			local.cacheResult = checkCache(arguments.name);
			if(!isBoolean(local.cacheResult)){
				// return our cached object
				return local.cacheResult;
			}
		}

		// check individual constructor arguments for injection and create our object
		local.object = createObject("component", arguments.name);
		structAppend(arguments.args, getMethodDependencies(local.object), false);
		if(structKeyExists(local.object, "init")){
			// process any init args
			for(local.ia in local.aliasInitArgs){
				if(!structKeyExists(arguments.args, local.ia.name)){
					if(structKeyExists(local.ia, "value")){
						arguments.args[local.ia.name] = local.ia.value;
					}else if(structKeyExists(local.ia, "ref")){
						arguments.args[local.ia.name] = getDepenency(local.ia.ref);
					}
				}
			}

			// call our init method with our arguments
			local.object.init(argumentCollection:arguments.args);
		}

		// check for properties
		for(local.prop in local.aliasProperties){
			local.propertyValue = "";
			if(structKeyExists(local.prop, "value")){
				local.propertyValue  = local.prop.value;
			}else if(structKeyExists(local.prop, "ref")){
				local.propertyValue  = getDepenency(local.prop.ref);
			}
			invoke(local.object, "set#local.prop.name#", [local.propertyValue]);
		}
		

				
		// if this is a singleton and we have a valid object, cache it
		if(arguments.singleton 
			AND ! isBoolean(local.object)){
			local.md = getMetaData(local.object);
			// check for a transient flag in the metadata of our object
			if(!structKeyExists(local.md, variables.metaKeys.TRANSIENT)){
				// we are OK to cache this object
				addToCache(arguments.name, local.object);
			}
		}

		// wire up any dependencies
		injectDependencies(local.object);

		// register with our AOP service
		getAOPService().registerObject(local.object);

		// return our object
		return local.object;
	}

	/*
	dependency injection
	================================ */

	/**
	* @hint returns a struct of arguments with injection flags for a given object method
	*/
	public struct function getMethodDependencies(any obj, string fnc="init"){
		local.dep = {};

		if(structKeyExists(arguments.obj, arguments.fnc)){
			local.md = getMetadata(arguments.obj[arguments.fnc]);
			for(local.param in local.md.parameters){
				if(structKeyExists(local.param, variables.metaKeys.INJECT)){
					local.singleton = true;
					if(structKeyExists(local.param, variables.metaKeys.TRANSIENT)){
						local.singleton = false;
					}
					local.dependency = getDepenency(local.param.type);
					local.dep[local.param.name] = local.dependency;
				}
			}
		}

		return local.dep;
	}
	

	/**
	* @hint searches a given object for methods requesting a dependency injection
	*/
	public void function injectDependencies(required any object){
		// get our object meta data
		local.md = getMetadata(arguments.object);
		// check each function within it
		for(local.f in local.md.functions){
			// look for our dependency injection meta data flag and a single parameter when the method name starts with 'set'
			if(structKeyExists(local.f, variables.metaKeys.INJECT)
				AND arrayLen(local.f.parameters) EQ 1
				AND left(local.f.name, 3) IS "set"){
				// our parameter type needs to be a FireBolt factory object
				local.injectType = local.f.parameters[1].type;
				// be default, we assume this is a singleton
				local.singleton = true;
				// adding a transient meta data flag to the function lets us use transient objects
				if(structKeyExists(local.f, variables.metaKeys.TRANSIENT)){
					local.singleton = false;
				}
				doInject(arguments.object, local.f.name, local.injectType, local.singleton);
			}
			/*for(local.p in local.f.parameters){
				if(structKeyExists(local.p, variables.metaKeys.INJECT) AND structKeyExists(local.p, "type")){
					local.injectType = local.p.type;
					local.singleton = true;
					if(structKeyExists(local.p, variables.metaKeys.TRANSIENT)){
						local.singleton = false;
					}
					doInject(arguments.object, local.f.name, local.injectType, local.singleton);
				}
			}*/
		}
		if(structKeyExists(local.md, "properties")){
			for(local.p in local.md.properties){
				if(structKeyExists(local.p, variables.metaKeys.INJECT)){
					// our parameter type needs to be a FireBolt factory object
					local.injectType = local.p[variables.metaKeys.INJECT];
					// by default, we assume this is a singleton
					local.singleton = true;
					// adding a transient meta data flag to the function lets us use transient objects
					if(structKeyExists(local.p, variables.metaKeys.TRANSIENT)){
						local.singleton = false;
					}
					doInject(arguments.object, "set" & local.p.name, local.injectType, local.singleton);
				}
			}
		}
	}

	public void function doInject(required any object, required string functionName, required string dependencyName, required boolean singleton){
		if(len(arguments.dependencyName)){
			local.dependency = getDepenency(arguments.dependencyName);
			// call our setter method
			//arguments.object[arguments.functionName](local.dependency);
			invoke(arguments.object, arguments.functionName, [local.dependency]);
		}
	}

	public any function getDepenency(required string dependencyName){
		if(left(arguments.dependencyName, 8) IS variables.metaKeys.SETTING){
			local.settingName = replace(arguments.dependencyName, variables.metaKeys.SETTING, "");
			return getFireBolt().getSetting(local.settingName);
		}else{
			// get our dependency object
			if(arguments.dependencyName IS "FireBolt.framework"
				OR arguments.dependencyName IS "framework"){
				return getFireBolt();
			}else{
				// lets test our dependency path
				return getObject(name:arguments.dependencyName);
			}
		}
		return "";
	}

	/*
	AOP
	================================ */

	
	/**
	* @hint registers a'before' aspect concern
	*/
	public void function before(required string target, required string targetMethod, required string concern, boolean async=false){
		getAOPService().before(argumentCollection: arguments);
	}

	/**
	* @hint registers 'after' aspect concern
	*/
	public void function after(required string target, required string targetMethod, required string concern, boolean async=false){
		getAOPService().after(argumentCollection: arguments);
	}

	/**
	* @hint returns any registered concerns for a given object name and optional method
	*/
	public struct function getConcerns(required string name, string method=""){
		return getAOPService().getConcerns(argumentCollection: arguments);
	}

	/**
	* @hint returns all our registered concerns
	*/
	public struct function getAllConcerns(){
		return getAOPService().getAllConcerns();
	}

	/*
	cache methods
	================================ */

	/**
	* @hint converts a dot notation to underscore for use as a cache key
	*/
	public struct function getCache(){
		return variables.cache;
	}

	/**
	* @hint converts a dot notation to underscore for use as a cache key
	*/
	public string function getCacheKey(required string name){
		return replaceNoCase(arguments.name, ".", "_", "ALL");
	}

	/**
	* @hint check cache for an object
	*/
	public any function checkCache(required string name){
		local.key = getCacheKey(arguments.name);
		if(structKeyExists(variables.cache, local.key)){
			return variables.cache[local.key];
		}
		return false;
	}

	/**
	* @hint adds an object to our cache
	*/
	public void function addToCache(
		required string name, 
		required any object){
		local.key = getCacheKey(arguments.name);
		variables.cache[local.key] = arguments.object;
	}

	/**
	* @hint returns true if a given object name is cached
	*/
	public boolean function isCached(required string name){
		local.cacheResult = checkCache(arguments.name);
		if(!isBoolean(local.cacheResult)){
			return true;
		}
		// also check an alias value
		local.aliasResult = getMapping(arguments.name);
		if(len(local.aliasResult.name)){
			local.cacheResult = checkCache(local.aliasResult.name);
			if(!isBoolean(local.cacheResult)){
				return true;
			}
		}
		return false;
	}

}