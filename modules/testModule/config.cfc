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
				"concern": "testModule.sampleModule.testBeforeConcern",
				"async": false
			}
		],
		"after": [
			{
				"target": "testModule.sampleModule",
				"method": "AOPTestTarget",
				"concern": "testModule.sampleModule.testAfterConcern",
				"async": false
			}
		]
	};


	function init(){
		
	}

	
}