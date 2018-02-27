component{

	variables.FireBolt = "";
	variables.aop = "";
	variables.cache = {};
	variables.aspectConcerns = {};
	variables.moduleAliases = {};

	/**
	* @hint constructor
	*/
	public factoryService function init(framework FireBolt){
		variables.FireBolt = arguments.FireBolt;
		variables.FireBolt.registerMethods("getObject,registerAlias,before,after,removeBefore,removeAfter,getConcerns,getAllConcerns", this);
		registerModules();
		variables.aop = new aopService(this);
		registerAOPConfig();
		return this;
	}

	/*
	register modules
	================================ */
	/**
	* @hint scan our modules directory for configuration files
	*/
	public void function registerModules(){
		// get our module paths
		local.modulePaths = getModulePaths();
		// add our mappings
		addModuleMappings(local.modulePaths);
		// read any config files
		for(local.modulePath in local.modulePaths){
			readModuleConfig(local.modulePath);
			createModuleAliases(local.modulePath);
		}
	}

	/**
	* @hint scan our modules directory for configuration files
	*/
	public void function registerAOPConfig(){
		// get our module paths
		local.modulePaths = getModulePaths();
		// read any config files
		for(local.modulePath in local.modulePaths){
			readModuleAOPConfig(local.modulePath);
		}
	}

	/**
	* @hint adds a mapping for each module directory
	*/
	public void function addModuleMappings(array modulePaths=getModulePaths()){
		for(local.modulePath in arguments.modulePaths){
			variables.FireBolt.addMapping("/" & listLast(local.modulePath, "\"), local.modulePath);
		}
	}

	/**
	* @hint looks for a module config within a given module path
	*/
	public void function readModuleConfig(string modulePath){
		if(fileExists(arguments.modulePath & "\config.cfc")){
			local.mapping = listLast(arguments.modulePath, "\");
			local.moduleConfig = createObject("component", local.mapping & ".config");
			if(structKeyExists(local.moduleConfig, "config")){
				variables.FireBolt.mergeSetting("modules.#local.mapping#", local.moduleConfig.config);
			}
			if(structKeyExists(local.moduleConfig, "listeners")){
				variables.FireBolt.addListeners(local.moduleConfig.listeners);
			}
		}
	}

	/**
	* @hint looks for a module config within a given module path
	*/
	public void function readModuleAOPConfig(string modulePath){
		if(fileExists(arguments.modulePath & "\config.cfc")){
			local.mapping = listLast(arguments.modulePath, "\");
			local.moduleConfig = createObject("component", local.mapping & ".config");
			if(structKeyExists(local.moduleConfig, "aspectConcerns")){
				local.before = [];
				if(structKeyExists(local.moduleConfig.aspectConcerns, "before")) local.before = local.moduleConfig.aspectConcerns.before;
				local.after = [];
				if(structKeyExists(local.moduleConfig.aspectConcerns, "after")) local.after = local.moduleConfig.aspectConcerns.after;
				variables.aop.addConcerns(local.before, local.after);
			}
		}
	}

	/**
	* @hint scans a given directrory for cfc's and generates aliases for each one
	*/
	public void function createModuleAliases(string modulePath){
		local.moduleRoot = listLast(arguments.modulePath, "\");

		// NOTE ACF does not accept named arguments for directoryList
		local.cfcs = directoryList(arguments.modulePath, true, "path", "*.cfc");

		for(local.cfc in local.cfcs){
			// strip .cfc from file path
			if(right(local.cfc, 4) IS ".cfc"){
				local.cfc = mid(local.cfc, 1, len(local.cfc)-4);
			}
			// convert to dot notation
			local.cfcDotPath = replace(replaceNoCase(local.cfc, arguments.modulePath, ""), "\", ".", "ALL");
			if(left(local.cfcDotPath, 1) IS "."){
				local.cfcDotPath = mid(local.cfcDotPath, 2, len(local.cfcDotPath));
			}
			if(right(local.cfcDotPath, 1) IS "."){
				local.cfcDotPath = mid(local.cfcDotPath, 1, len(local.cfcDotPath)-1);
			}
			// add our module root back into the path
			local.cfcDotPath = local.moduleRoot & "." & local.cfcDotPath;
			// form an alias based on the cfc name and the module root
			local.alias = listLast(local.cfcDotPath, ".") & "@" & local.moduleRoot;
			registerAlias(local.cfcDotPath, local.alias);
		}
	}

	/**
	* @hint adds an alias for a module path
	*/
	public void function registerAlias(string modulePath, string alias){
		variables.moduleAliases[arguments.alias] = arguments.modulePath;
	}

	/**
	* @hint searches our aliases for a given key
	*/
	public string function getAlias(string alias){
		if(structKeyExists(variables.moduleAliases, arguments.alias)){
			return variables.moduleAliases[arguments.alias];
		}
		return "";
	}

	/**
	* @hint returns all registered aliases
	*/
	public struct function getAliases(){
		return variables.moduleAliases;
	}
	
	/**
	* @hint returns an array of directories within our modules path
	*/
	public array function getModulePaths(){
		return directoryList(expandPath(getModulePath()));
	}

	/*
	get object helpers
	================================ */
	
	/**
	* @hint return our module path as dotnotation or directly as it is defined in the config
	*/
	public any function getModulePath(boolean dotNotation=false){
		local.path = variables.FireBolt.getSetting('paths.modules');
		if(arguments.dotNotation){
			local.path = replace(local.path, "/", ".", "ALL");
			if(left(local.path, 1) IS "."){
				local.path = mid(local.path, 2, len(local.path));
			}
			if(right(local.path, 1) IS "."){
				local.path = mid(local.path, 1, len(local.path)-1);
			}
		}
		return local.path;
	}


	/*
	our main invoker
	================================ */

	/**
	* @hint get an object
	*/
	public any function getObject(
		required string name, 
		struct args={}, 
		boolean singleton=true){

		local.aliasResult = getAlias(arguments.name);
		if(len(local.aliasResult)){
			arguments.name = local.aliasResult;
		}


		// if this is a singleton, it might already be cached
		if(arguments.singleton){
			local.cacheResult = checkCache(arguments.name);
			if(!isBoolean(local.cacheResult)){
				// return our cached object
				return local.cacheResult;
			}
		}

		// create a new instance of our object
		local.object = new "#arguments.name#"(argumentCollection:arguments.args);
		
		// if this is a singleton and we have a valid object, cache it
		if(arguments.singleton 
			AND ! isBoolean(local.object)){
			local.md = getMetaData(local.object);
			// check for a transient flag in the metadata of our object
			if(!structKeyExists(local.md, "FB:transient")){
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
	* @hint searches a given object for methods requesting a dependency injection
	*/
	public void function injectDependencies(required any object){
		// get our object meta data
		local.md = getMetadata(arguments.object);
		// check each function within it
		for(local.f in local.md.functions){
			// look for our dependency injection meta data and a single parameter
			if(structKeyExists(local.f, "FB:inject")
				AND arrayLen(local.f.parameters) EQ 1){
				// our parameter type needs to be a FireBolt factory object
				local.injectType = local.f.parameters[1].type;
				// be default, we assume this is a singleton
				local.singleton = true;
				// adding a transient meta data flag to the function lets us use transient objects
				if(structKeyExists(local.f, "FB:transient")){
					local.singleton = false;
				}
				doInject(arguments.object, local.f.name, local.injectType, local.singleton);
			}
			for(local.p in local.f.parameters){
				if(structKeyExists(local.p, "inject") AND structKeyExiss(local.p, "type")){
					local.injectType = local.p.type;
					local.singleton = true;
					if(structKeyExists(local.p, "transient")){
						local.singleton = false;
					}
					doInject(arguments.object, local.f.name, local.injectType, local.singleton);
				}
			}
		}
		if(structKeyExists(local.md, "properties")){
			for(local.p in local.md.properties){
				if(structKeyExists(local.p, "FB:inject")){
					// our parameter type needs to be a FireBolt factory object
					local.injectType = local.p["FB:inject"];
					// by default, we assume this is a singleton
					local.singleton = true;
					// adding a transient meta data flag to the function lets us use transient objects
					if(structKeyExists(local.p, "FB:transient")){
						local.singleton = false;
					}
					doInject(arguments.object, "set" & local.p.name, local.injectType, local.singleton);
				}
			}
		}
	}

	public void function doInject(required any object, required string functionName, required string dependancyName, required boolean singleton){
		if(len(arguments.dependancyName)){
			// get our dependency object
			if(arguments.dependancyName IS "FireBolt.framework"
				OR arguments.dependancyName IS "framework"){
				local.dependency = variables.FireBolt;
			}else{
				// lets test our dependancy path
				local.dependency = getObject(name:arguments.dependancyName, singleton:arguments.singleton);
			}
			// call our setter method
			//arguments.object[arguments.functionName](local.dependency);
			invoke(arguments.object, arguments.functionName, [local.dependency]);
		}
	}

	/*
	AOP
	================================ */

	/**
	* @hint returns our AOP service
	*/
	public aopService function getAOPService(){
		return variables.aop;
	}
	
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
		local.aliasResult = getAlias(arguments.name);
		if(len(local.aliasResult)){
			local.cacheResult = checkCache(local.aliasResult);
			if(!isBoolean(local.cacheResult)){
				return true;
			}
		}
		return false;
	}

}