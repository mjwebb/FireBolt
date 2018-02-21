component accessors="true"{

	variables.sapleDep;
	//variables.FB;
	variables.startTime = now();
	variables.t;

	property name="FB" FB:inject="FireBolt.framework";

	/**
	* @hint constructor
	* **/
	public sampleModule function init(){
		return this;
	}

	/**
	* @FB:inject true
	* **/
	public void function setSampleDep(required testModule.com.dep dep){
		variables.sapleDep = arguments.dep;
	}

	/**
	* 
	* **/
	public void function setFB(framework FB required:true){
		variables.FB = arguments.FB;
	}

	public string function hello(requestHandler req){
		return "world " & variables.startTime & arguments.req.output().view(
			viewFile: "test",
			root: "/testModule/views/");
	}

	public any function getDep(){
		return variables.sapleDep;
	}

	public string function AOPTestTarget(){
		return "AOP TEST";
	}

	
	public function testBeforeConcern(string objectName, string methodName, struct methodArgs){
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


	public void function intercept(requestHandler, response){

		local.route = arguments.requestHandler.getRoute();

		if(local.route.isValid){

			local.permissions = "";

			local.meta = getMetaData(local.route.cfc);
			if(structKeyExists(local.meta, "functions")){
				for(i=1; i<=arrayLen(local.meta.functions); i++){
					local.functionMetaData = local.meta.functions[i];
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
					arrayPrepend(local.interceptPath, "api");
				}

				arguments.requestHandler.defineRoute(
					arrayToList(local.interceptPath, "."), 
					"get");

				/*local.r = arguments.requestHandler.FB().getRouteService().walkPath(
					path: local.interceptPath,
					req: arguments.requestHandler);
				
				arguments.requestHandler.setRoute(local.r);
				*/
			}
		}

	}

}