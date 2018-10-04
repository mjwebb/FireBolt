component{

	this.title = "testModule";
	this.author = "Martin Webb";
	this.webURL = "";
	this.description = "Test module";
	this.version = "1.0.0";

	this.config = {
		setting: "setting value"
	};

	this.listeners = [
		{
			"event": "req.beforeProcess",
			"listener": "sampleModule@testModule.intercept"
		}
	];

	this.aspectConcerns = {
		"before": [
			{
				"target": "XXtestModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "sampleModule@testModule.testBeforeConcern",
				"async": false
			}
		],
		"after": [
			{
				"target": "XXXtestModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "sampleModule@testModule.testAfterConcern",
				"async": false
			},
			{
				"target": "XXtestModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "dep@testModule.anotherAspect",
				"async": false
			}
		]
	};


	function configure(){
		// listeners
		FB().listenFor("waggawagga")
			.with("testModule.sampleModule.qbIntercept")
			.async();
			
		// aspect concerns
		FB().call("sampleModule@testModule.testBeforeConcern")
			.before(target:"sampleModule@testModule", method:"AOPTestTarget");
			//.async();

		FB().call("sampleModule@testModule.testAfterConcern")
			.after(target:"sampleModule@testModule", method:"AOPTestTarget");
			
		FB().call("dep@testModule.anotherAspect")
			.after(target:"sampleModule@testModule", method:"AOPTestTarget");

		// AOP closure
		FB().call(function(string objectName, string methodName, struct methodArgs, any methodResult, numeric methodTimer){
			arguments.methodResult = arguments.methodResult & " HELLO FROM CLOSURE " & arguments.methodTimer;
			writeLog(
				text: "testAfterConcern() - called - #arguments.methodResult#",
				type: "information",
				file: "AOP");
			return arguments.methodResult;
		}).after(target:"sampleModule@testModule", method:"AOPTestTarget");
			
	}
	
}