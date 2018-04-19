component{

	/*
	Aspect concerns can be defined here for either 'before' or 'after'. 
	They are configured in the form of:
	{
		"target": 	string - describing the path of module that we are adding the concerns to either
				 	as dot notation (modulePath.moduleName) or an alias path (moduleName@modulePath)
		"method":	string - listing one or methods within the target that trigger the concers
		"concern":	string - describing the concern that will be called as either 
					as dot notation (modulePath.moduleName.methodName) or an alias path (moduleName@modulePath.methodName)
		"async":	boolean (defaults to false) - flag as to whether or not the concern runs asynchronously or not
	}

	if a 'before' concern returns 'false', the target method is not called.


	Example:

	after: [
		{
			"target": "testModule.sampleModule",
			"method": "AOPTrigger",
			"concern": "sampleModule@testModule.testAfterConcern",
			"async": false
		}
	]

	These can also be defined in the FireBolt onApplicationStart handler using a DSL syntax.
	They can also be defined within module config.cfc as either JSON syntax or DSL syntax within the configure() method.

	*/


	this.config = {
		"before": [],
		"after": []
	};


}
