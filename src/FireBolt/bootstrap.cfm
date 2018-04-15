<cfscript>
	// bootstratp for use as an include in an application.cfc

	public function getFireBolt(boolean reload=false){
		if(!structKeyExists(application, "FireBolt") OR arguments.reload){
			application.FireBolt = new FireBolt.framework();
		}
		return application.FireBolt;
	}


	// application start
	public boolean function onApplicationStart(){
		getFireBolt().onApplicationStart();
		return true;
	}

	// application end
	/*public void function onApplicationEnd(struct appScope){
		arguments.appScope.FireBolt.onApplicationEnd(arguments.appScope);
	}*/

	// request start
	public boolean function onRequestStart(string targetPage){
		request.startTime = getTickCount();
		getFireBolt(structKeyExists(url, "reload")).onRequestStart(arguments.targetPage);
		return true;
	}

	// session start
	public void function onSessionStart(){
		getFireBolt().onSessionStart();
	}

	// session end
	/*public void function onSessionEnd(struct sessionScope, struct appScope){
		arguments.appScope.FireBolt.onSessionEnd(argumentCollection:arguments);
	}*/

	
	// error
	/**
	* @output=true
	*/
	public void function onError(any exception, string eventName=""){
		try{
			writeOutput(getFireBolt().onError(argumentCollection:arguments));
		}catch(any e){
			writeDump(var:arguments, label:"Error", format:"text");
			//rethrow;
		}
		
		return;
	}

	

</cfscript>