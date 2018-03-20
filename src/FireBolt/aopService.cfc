component accessors="true"{

	property factoryService;

	variables.concerns = {};

	/*
	cache takes the form of:
	name: {
		method: {
			before: [],
			after: []
		}
	}
	*/

	/**
	* @hint constructor
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
	*/
	public void function before(required string target, required string targetMethod, required string concern, boolean async=false){
		local.methods = listToArray(arguments.targetMethod);
		for(local.mthd in local.methods){
			local.methodConcerns = defineMethodConcern(arguments.target, local.mthd);
			if(!hasConcern(arguments.target, local.mthd, arguments.concern, "before")){
				arrayAppend(local.methodConcerns.before, {
					concern: arguments.concern,
					async: arguments.async
				});
				registerIfFactoryCached(arguments.target, arguments.targetMethod);
			}
		}
	}

	/**
	* @hint registers 'after' aspect concern
	*/
	public void function after(required string target, required string targetMethod, required string concern, boolean async=false){
		local.methods = listToArray(arguments.targetMethod);
		for(local.mthd in local.methods){
			local.methodConcerns = defineMethodConcern(arguments.target, local.mthd);
			if(!hasConcern(arguments.target, local.mthd, arguments.concern, "after")){
				arrayAppend(local.methodConcerns.after, {
					concern: arguments.concern,
					async: arguments.async
				});
				registerIfFactoryCached(arguments.target, arguments.targetMethod);
			}
		}
	}

	
	/**
	* @hint define a given object name in our concern struct
	*/
	public struct function defineObject(required string target){
		if(NOT structKeyExists(variables.concerns, arguments.target)){
			variables.concerns[arguments.target] = {};
		}
		return variables.concerns[arguments.target];
	}

	/**
	* @hint define a given object and method in our concern struct
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
	*/
	public string function getObjectName(required any object){
		return getMetaData(arguments.object).name;
	}

	/**
	* @hint returns any registered concerns for a given object name and optional method
	*/
	public struct function getConcerns(required string name, string method=""){
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
	*/
	public boolean function hasConcern(required string name,  required string method, required string concern, string aspect="after"){
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
	*/
	public struct function getAllConcerns(){
		return variables.concerns;
	}


	/**
	* @hint registers an object name for AOP wireup if 
	*/
	public void function registerIfFactoryCached(required string name, required string methodName){
		if(getFactoryService().isCached(arguments.name)){
			local.obj = getFactoryService().getObject(arguments.name);
			attachIntercept(local.obj, arguments.methodName);
		}
	}

	/**
	* @hint registers a given object for AOP wireup
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
	* @hint attaches our AOP intercept method to a given object
	*/
	public any function attachIntercept(required any object, required string methodName){
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
		arguments.object["OnMissingMethod"] = this.onMissingMethodIntercept;

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
	* @hint this is the proxy method that gets called before a method gets called
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
	* @hint this is the proxy method that gets called after a method gets called
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
	* @hint call a concern method
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