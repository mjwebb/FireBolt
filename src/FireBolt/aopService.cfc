/**
* Service for aspect orientated programming to handle adding concerns for methods and injecting the inteceptor to
* the parent component. 
* <p>
* Concerns are cached in the form of:
	name: {
		method: {
			before: [],
			after: []
		}
	}
*
*/
component accessors="true"{

	property factoryService;

	variables.concerns = {};

	
	/**
	* @hint constructor
	* @param factory 	framework factoryService instance
	*/
	public aopService function init(required factory){
		setFactoryService(arguments.factory);
		variables.aopConfig = new configService("aspectConcerns");
		addConfigConcerns();
		return this;
	}

	/**
	* @hint add concerns from our configuration
	*/
	public void function addConfigConcerns(){
		local.beforeConcerns = variables.aopConfig.getSetting("before");
		local.afterConcerns = variables.aopConfig.getSetting("after");
		addConcerns(local.beforeConcerns, local.afterConcerns);
	}

	/**
	* @hint add concerns from given arrays of concerns
	* @param beforeConcerns	array of 'before' config structs
	* @param afterConcerns	array of 'after' config structs
	*/
	public void function addConcerns(array beforeConcerns=[], array afterConcerns=[]){
		for(local.concern in arguments.beforeConcerns){
			if(! structKeyExists(local.concern, "async")){
				local.concern.async = false;
			}
			before(local.concern.target, local.concern.method, local.concern.concern, local.concern.async);
		}
		for(local.concern in arguments.afterConcerns){
			if(! structKeyExists(local.concern, "async")){
				local.concern.async = false;
			}
			after(local.concern.target, local.concern.method, local.concern.concern, local.concern.async);
		}
	}

	/**
	* @hint registers a'before' aspect concern
	* @param target 		the name of the component that we are targeting
	* @param targetMethod	the name of the method that we are targeting. Multiple methods can be separated with a comma
	* @param concern 		the path to the concern method 
	* @param async 			if true, the concern will be registered to run asynchronously
	* @return array of added concern definitions
	*/
	public array function before(required string target, required string targetMethod, required string concern, boolean async=false){
		local.aliasResult = getFactoryService().getMapping(arguments.target);
		if(len(local.aliasResult.name)){
			arguments.target = local.aliasResult.name;
		}
		local.methods = listToArray(arguments.targetMethod);
		local.added = [];
		for(local.mthd in local.methods){
			local.methodConcerns = defineMethodConcern(arguments.target, local.mthd);
			if(!hasConcern(arguments.target, local.mthd, arguments.concern, "before")){
				local.concernDef = {
					concern: arguments.concern,
					async: arguments.async,
					method: local.mthd
				};
				arrayAppend(local.methodConcerns.before, local.concernDef);
				arrayAppend(local.added, local.concernDef);
				registerIfFactoryCached(arguments.target, arguments.targetMethod);
			}
		}
		return local.added;
	}

	/**
	* @hint registers 'after' aspect concern
	* @param target 		the name of the component that we are targeting
	* @param targetMethod	the name of the method that we are targeting. Multiple methods can be separated with a comma
	* @param concern 		the path to the concern method 
	* @param async 			if true, the concern will be registered to run asynchronously
	* @return array of added concern definitions
	*/
	public array function after(required string target, required string targetMethod, required string concern, boolean async=false){
		local.aliasResult = getFactoryService().getMapping(arguments.target);
		if(len(local.aliasResult.name)){
			arguments.target = local.aliasResult.name;
		}
		local.methods = listToArray(arguments.targetMethod);
		local.added = [];
		for(local.mthd in local.methods){
			local.methodConcerns = defineMethodConcern(arguments.target, local.mthd);
			if(!hasConcern(arguments.target, local.mthd, arguments.concern, "after")){
				local.concernDef = {
					concern: arguments.concern,
					async: arguments.async,
					method: local.mthd
				};
				arrayAppend(local.methodConcerns.after, local.concernDef);
				arrayAppend(local.added, local.concernDef);
				registerIfFactoryCached(arguments.target, arguments.targetMethod);
			}
		}
		return local.added;
	}

	/**
	* @hint adds a concern via a declaration syntax
	* @param concern 	the path to the concern method
	* @FireBoltMethod
	*/
	public struct function call(string concern){
		var declaration = {
			type: "",
			definition: {
				concern: arguments.concern,
				target: "",
				taretMethod: "",
				async: false
			}
		};

		structAppend(declaration, {
			/**
			* @hint adds our concern to a 'before' target
			* @param target 	the name of the component that we are targeting
			* @param method		the name of the method that we are targeting
			*/
			before: function(string target, string method){
				declaration.type = "before";
				declaration.definition.target = arguments.target;
				declaration.definition.targetMethod = arguments.method;
				local.added = before(argumentCollection:declaration.definition);
				declaration.definition = local.added[1];
				return declaration;
			},
			/**
			* @hint adds our concern to a 'after' target
			* @param target 	the name of the component that we are targeting
			* @param method		the name of the method that we are targeting
			*/
			after: function(string target, string method){
				declaration.type = "after";
				declaration.definition.target = arguments.target;
				declaration.definition.targetMethod = arguments.method;
				local.added = after(argumentCollection:declaration.definition);
				declaration.definition = local.added[1];
				return declaration;
			},
			/**
			* @hint defines our concern as asynchronous
			*/
			async: function(){
				declaration.definition.async = true;
				return declaration;
			}
		});

		return declaration;
	}



	
	/**
	* @hint define a given object name in our concern struct
	* @param target 	defines a new AOP target in our cache and retunrs it
	* @return cached AOP target struct
	*/
	public struct function defineObject(required string target){
		if(NOT structKeyExists(variables.concerns, arguments.target)){
			variables.concerns[arguments.target] = {};
		}
		return variables.concerns[arguments.target];
	}

	/**
	* @hint define a given object and method in our concern struct
	* @param target 		the name of the target object for which we are defining a concern
	* @param targetMethod 	the method name for which we are defining a concern
	* @return the concern definition struct for the target method
	*/
	public struct function defineMethodConcern(required string target, required string targetMethod){
		local.objConcern = defineObject(arguments.target);
		if(NOT structKeyExists(local.objConcern, arguments.targetMethod)){
			local.objConcern[arguments.targetMethod] = {
				"before": [],
				"after": []
			};
		}
		return local.objConcern[arguments.targetMethod];
	}


	/**
	* @hint returns a given objects name from its meta data
	* @param object the object instance for which we want the name
	* @return the name of the object
	*/
	public string function getObjectName(required any object){
		return getMetaData(arguments.object).name;
	}

	/**
	* @hint returns any registered concerns for a given object name and optional method
	* @param name 	the target component to check
	* @param method options name of the method to check. If no method is passed in, all concerns for the matched 'name' argument are returned 
	* @return the struct representing the concens defined
	*/
	public struct function getConcerns(required string name, string method=""){
		local.aliasResult = getFactoryService().getMapping(arguments.name);
		if(len(local.aliasResult.name)){
			arguments.name = local.aliasResult.name;
		}
		if(structKeyExists(variables.concerns, arguments.name)){
			local.ret = variables.concerns[arguments.name];
			if(len(arguments.method)){
				if(structKeyExists(local.ret, arguments.method)){
					return local.ret[arguments.method];
				}
			}else{
				return local.ret;
			}
		}
		// nothing registered
		return {};
	}

	/**
	* @hint returns true if concerns are defined for a given object name and method
	* @param name 	the target component to check
	* @param method the name of the method to check 
	* @return true if the given taret has concerns defined
	*/
	public boolean function hasConcerns(required string name,  string method=""){
		local.concerns = getConcerns(arguments.name, arguments.method);
		if(len(structKeyList(local.concerns))){
			return true;
		}
		return false;
	}

	/**
	* @hint returns true if a specific concern is already defined for a given object name and method
	* @param name 			the name of the object we want to check for a concern
	* @param methodName 	the name of the method that we checking
	* @param concern 		the name of the concern that we are checking for
	* @param aspect 		defaults to 'after' - after | before
	* @return true if the concern exists
	*/
	public boolean function hasConcern(required string name, required string method, required string concern, string aspect="after"){
		local.concerns = getConcerns(arguments.name, arguments.method);
		if(structKeyExists(local.concerns, arguments.aspect)){
			for(local.registeredConcern in local.concerns[arguments.aspect]){
				if(local.registeredConcern.concern IS arguments.concern){
					return true;
				}
			}
		}
		return false;
	}

	/**
	* @hint returns all our registered concerns
	* @return struct of our concern definitions
	*/
	public struct function getAllConcerns(){
		return variables.concerns;
	}


	/**
	* @hint attaches the AOP intercept methods to an object if it is already cached in the factory service
	* @param name 			the name of the object we want to attach the intercept to
	* @param methodName 	the name of the method that we are intercepting
	*/
	public void function registerIfFactoryCached(required string name, required string methodName){
		if(getFactoryService().isCached(arguments.name)){
			local.obj = getFactoryService().getObject(arguments.name);
			attachIntercept(local.obj, arguments.methodName);
		}
	}

	/**
	* @hint attaches the AOP intercpet method to a given object if it has concerns registerd against it
	* @param object the object that we are registering
	*/
	public void function registerObject(required any object){
		local.name = getObjectName(arguments.object);
		/*writeLog(
			text:local.name & " - " & hasConcerns(local.name),
			type: "information",
			file: "AOP");*/
		if(hasConcerns(local.name)){
			local.concerns = getConcerns(local.name);
			local.methods = structKeyArray(local.concerns);
			for(local.methodName in local.methods){
				attachIntercept(arguments.object, local.methodName);
			}
		}
	}


	/**
	* performs the attachement of the AOP intercept method to a given object. This re-names the target method using
	* an 'aop_' prefix, renames any pre-exisiting onMissingMethod method, deletes the original target method and then
	* injects our own onMissingMethod to act as the intercept.
	* @param object 		the object that we are attaching the intercept to
	* @param methodName 	the method that is being intercepted
	*/
	public void function attachIntercept(required any object, required string methodName){
		// copy our original method
		if(structKeyExists(arguments.object, arguments.methodName)){
			arguments.object["aop_" & arguments.methodName] = duplicate(arguments.object[arguments.methodName]);
		}

		// rename any exising OnMissingMethod
		if(structKeyExists(arguments.object, "OnMissingMethod")
			AND NOT arguments.object.OnMissingMethod.Equals(this.onMissingMethodIntercept)
			AND NOT structKeyExists(arguments.object, "aop_OnMissingMethod")){
			arguments.object["aop_OnMissingMethod"] = duplicate(arguments.object.OnMissingMethod);
		}

		// remove our original method
		if(structKeyExists(arguments.object, arguments.methodName)){
			structDelete(arguments.object, arguments.methodName);
		}

		// attach our intercept method to OnMissingMethod
		getFactoryService().getFireBolt().inject(arguments.object, "OnMissingMethod", this.onMissingMethodIntercept, true);

		writeLog(
			text: getObjectName(arguments.object) & "." & arguments.methodName & "() - attached",
			type: "information",
			file: "AOP");
	}



	/**
	* @hint this gets injected into target objects to replace any existing onMissingMethod functions. This is used to intercept any methods with listeners attached.
	*/
	public any function onMissingMethodIntercept(required string MissingMethodName, required struct MissingMethodArguments){
		local.meta = getMetaData();
		if(application.FireBolt.getAOPService().hasConcerns(local.meta.name, arguments.MissingMethodName)){
			if(application.FireBolt.getAOPService().beforeAdvice(local.meta.name, arguments.MissingMethodName, arguments.MissingMethodArguments)){
				local.methodTimer = getTickCount();
				//local.methodResult = this["aop_#arguments.MissingMethodName#"](argumentCollection: arguments.MissingMethodArguments);
				local.methodResult = invoke(this, "aop_#arguments.MissingMethodName#", arguments.MissingMethodArguments);
				if(!isDefined("local.methodResult")){
					local.methodResult = "";
				}
				local.methodResult = application.FireBolt.getAOPService().afterAdvice(local.meta.name, arguments.MissingMethodName, arguments.MissingMethodArguments, local.methodResult, getTickCount()-local.methodTimer);
				return local.methodResult;
			}else{
				return;
			}
		}else{
			// no concerns, check for our default missing method function
			if(structKeyExists(this, "aop_OnMissingMethod")){
				return this.aop_OnMissingMethod(arguments.MissingMethodName, arguments.MissingMethodArguments);
			}
		}

		// not found..
		throw("Method '#encodeForHTML(arguments.missingMethodName)#' does not exist in #local.meta.name#");
	}
	

	/**
	* @hint this is the proxy method that gets called before a method gets called. This calls any 'before' concerns for the given object and method
	*/
	public boolean function beforeAdvice(
		required string objectName, 
		required string methodName, 
		required struct methodArgs){
		local.result = true;

		// get our registered concerns
		local.concerns = getConcerns(arguments.objectName, arguments.methodName);

		for(local.concern in local.concerns.before){
			if(local.concern.async){
				thread action="run" name="AOP_before_#local.concern.concern#" concern="#local.concern#" args="#arguments#"{
					callConcern(attributes.concern, attributes.args.objectName, attributes.args.methodName, attributes.args.methodArgs);
				}
			}else{
				local.concernResult = callConcern(local.concern, arguments.objectName, arguments.methodName, arguments.methodArgs);
				if(isDefined("local.concernResult") AND NOT local.concernResult){
					local.result = false; // this will prevent the target method from actually being called
				}
			}
		}
		return local.result;
	}

	/**
	* @hint this is the proxy method that gets called after a method gets called. This calls any 'after' concerns for the given object and method
	*/
	public any function afterAdvice(
		required string objectName, 
		required string methodName, 
		required struct methodArgs,
		any methodResult="",
		numeric methodTimer=0){
		
		// get our registered concerns
		local.concerns = getConcerns(arguments.objectName, arguments.methodName);

		for(local.concern in local.concerns.after){
			if(local.concern.async){
				thread action="run" name="AOP_after_#local.concern.concern#" concern="#local.concern#" args="#arguments#"{
					callConcern(attributes.concern, attributes.args.objectName, attributes.args.methodName, attributes.args.methodArgs, attributes.args.methodResult, attributes.args.methodTimer);
				}
			}else{
				local.concernResult = callConcern(local.concern, arguments.objectName, arguments.methodName, arguments.methodArgs, arguments.methodResult, arguments.methodTimer);
				if(isDefined("local.concernResult")){
					arguments.methodResult = local.concernResult;
				}
			}
		}
		return arguments.methodResult;
	}
	

	/**
	* @hint responsible for actually calling the target concern method. This will be called from the beforeAdvice or afterAdvice methods
	*/
	public any function callConcern(
		required struct concern,
		required string objectName, 
		required string methodName, 
		required struct methodArgs,
		any methodResult="",
		numeric methodTimer=0){
		
		// get our method
		local.concernMethod = listLast(arguments.concern.concern, ".");
		// get our concern object name
		local.concernName = left(arguments.concern.concern, len(arguments.concern.concern) - len(local.concernMethod) - 1);
		// get our concer objet from our factory
		local.concernObject = getFactoryService().getObject(local.concernName);

		// call our concern
		local.concernArgs = {
			objectName: arguments.objectName,
			methodName: arguments.methodName,
			methodArgs: arguments.methodArgs,
			methodResult: arguments.methodResult,
			methodTimer: arguments.methodTimer
		};		
		//return local.concernObject[local.concernMethod](argumentCollection:local.concernArgs);
		return invoke(local.concernObject, local.concernMethod, local.concernArgs);
	}
	
}