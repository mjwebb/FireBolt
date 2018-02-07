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

}