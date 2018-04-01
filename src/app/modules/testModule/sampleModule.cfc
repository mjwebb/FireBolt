component accessors="true"{

	property FB inject="framework";
	property testSetting inject="setting:modules.testModule.setting";
	property sampleDep inject="dep@testModule";

	
	//variables.FB;
	variables.startTime = now();
	variables.t = "";
	

	/**
	* @hint constructor
	*/
	public sampleModule function init(){
		return this;
	}


	/**
	* 
	*/
	//public void function setFB(framework FB){
	//	variables.FB = arguments.FB;
	//}

	public string function hello(req){
		return "world " & variables.startTime & arguments.req.output().view(
			viewFile: "test",
			root: "/testModule/views/");
	}

	public string function world(){
		return "hello";
	}

	
	public string function AOPTestTarget(string t=""){
		return "[AOP TEST]#arguments.t#";
	}

	
	public function testBeforeConcern(string objectName, string methodName, struct methodArgs){
		arguments.methodArgs.t = " altered argument from before concern";
		writeLog(
			text: "testBeforeConcern() - called",
			type: "information",
			file: "AOP");
		return true;
	}

	public function testAfterConcern(string objectName, string methodName, struct methodArgs, any methodResult, numeric methodTimer){
		arguments.methodResult = arguments.methodResult & " HELLO FROM AFTER " & arguments.methodTimer;
		writeLog(
			text: "testAfterConcern() - called - #arguments.methodResult#",
			type: "information",
			file: "AOP");
		return arguments.methodResult;
	}


	public void function intercept(req, res){

		local.route = arguments.req.getRoute();

		if(local.route.isValid){

			local.permissions = "";

			local.meta = getMetaData(local.route.cfc);
			if(structKeyExists(local.meta, "functions")){
				for(local.i=1; local.i<=arrayLen(local.meta.functions); local.i++){
					local.functionMetaData = local.meta.functions[local.i];
					if(local.functionMetaData.name IS local.route.method){
						if(structKeyExists(local.functionMetaData, "permissions")){
							local.permissions = local.functionMetaData.permissions;
						}
						break;
					}
				}
			}

			if(len(local.permissions)){

				//arguments.response.setStatus(arguments.response.codes.FORBIDDEN);

				local.interceptPath = ["403"];
				if(arrayLen(local.route.path) AND local.route.path[1] IS "api"){
					arrayPrepend(local.interceptPath, "api.v1");
				}

				arguments.req.defineRoute(
					arrayToList(local.interceptPath, "."), 
					"get");

			}
		}

	}

	public any function qbIntercept(sql, bindings, options){

		writeLog(
			text: "QB CALLED: #arguments.sql#",
			type: "information",
			file: "QB");
		//writeDump(data);
	}

}