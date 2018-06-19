component{

	
	this.config = {
		sessionLength: createTimespan(0,0,5,0),
		isLazy: true
	};

	/*this.listeners = [
		{
			"event": "req.start",
			"listener": "sessionService@common.keepAlive"
		}
	];*/

	function configure(){

		var initWith = duplicate(this.config);
		var appConfig = FB().getConfig();
		
		if(structKeyExists(appConfig, "session") AND isStruct(appConfig.session)){
			structAppend(initWith, appConfig.session);
		}

		FB().register("common.sessionService")
			.as("sessionService@common")
			.withInitArg(name:"sessionLength", value:initWith.sessionLength)
			.withInitArg(name:"isLazy", value:initWith.isLazy);
	
		FB().listenFor("req.start")
			.with("common.sessionService.keepAlive");		
	}
	
}