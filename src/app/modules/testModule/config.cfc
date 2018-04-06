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
			.done();
	
		// aspect concerns
		FB().call("sampleModule@testModule.testBeforeConcern")
			.before(target:"sampleModule@testModule", method:"AOPTestTarget")
			.done();

		FB().call("sampleModule@testModule.testAfterConcern")
			.after(target:"sampleModule@testModule", method:"AOPTestTarget")
			.done();

		FB().call("dep@testModule.anotherAspect")
			.after(target:"sampleModule@testModule", method:"AOPTestTarget")
			.done();
	}
	
}