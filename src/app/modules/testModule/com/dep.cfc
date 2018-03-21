component accessors="true"{

	property sampleDep inject="testModule.sampleModule";

	/**
	* @hint constructor
	*/
	public dep function init(){
		return this;
	}

	
	public string function hello(){
		return "from dependancy";
	}

	public any function world(){
		return getSampleDep().world();
	}


	public function anotherAspect(string objectName, string methodName, struct methodArgs, any methodResult, numeric methodTimer){
		arguments.methodResult = arguments.methodResult & " HELLO again FROM AFTER " & arguments.methodTimer;
		writeLog(
			text: "testAfterConcern() - called - #arguments.methodResult#",
			type: "information",
			file: "AOP");
		return arguments.methodResult;
	}


}