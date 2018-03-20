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
				"target": "testModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "sampleModule@testModule.testBeforeConcern",
				"async": false
			}
		],
		"after": [
			{
				"target": "testModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "sampleModule@testModule.testAfterConcern",
				"async": false
			},
			{
				"target": "testModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "dep@testModule.anotherAspect",
				"async": false
			}
		]
	};


	function init(){
		
	}

	
}