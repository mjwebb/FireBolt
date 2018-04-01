component{

	this.config = [
		{
			"event": "test.event",
			"listener": "this.and.that",
			"async": false
		},
		{
			"event": "test.event,another.event",
			"listener": "and.the.other",
			"async": true
		},
		{
			"event": "req.beforeProcessXXX",
			"listener": "testModule.sampleModule.intercept"
		},
		{
			"event": "preQBExecute",
			"listener": "testModule.sampleModule.qbIntercept"
		}
	];

}
