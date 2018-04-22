﻿<cfscript>
	/**
	* Bootstrap for the FireBolt framework that can be used as an include in an application.cfc 
	*/

	/**
	* Returns our FireBolt instance
	* @param reload		if set to true, the framework is reloaded before it is returned
	* @return 			FireBolt framework
	*/
	public function getFireBolt(boolean reload=false){
		if(!structKeyExists(application, "FireBolt") OR arguments.reload){
			application.FireBolt = new FireBolt.framework();
		}
		return application.FireBolt;
	}

	/**
	* onApplicationStart event handler
	*/
	public boolean function onApplicationStart(){
		getFireBolt().onApplicationStart();
		return true;
	}

	/**
	* onApplicationEnd event handler
	*/
	/*public void function onApplicationEnd(struct appScope){
		getFireBolt().onApplicationEnd(arguments.appScope);
	}*/

	/**
	* onRequestStart event handler
	*/
	public boolean function onRequestStart(string targetPage){
		request.startTime = getTickCount();
		getFireBolt(structKeyExists(url, "reload")).onRequestStart(arguments.targetPage);
		return true;
	}

	/**
	* onSessionStart event handler
	*/
	public void function onSessionStart(){
		getFireBolt().onSessionStart();
	}

	/**
	* onSessionEnd event handler
	*/
	/*public void function onSessionEnd(struct sessionScope, struct appScope){
		getFireBolt().onSessionEnd(argumentCollection:arguments);
	}*/
	
	/**
	* onError event handler
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