/**
* Sample application.cfc showing framewok bootstraping
*
*/
component ouptut="false"{

	// application name
	this.name = "FireBolt_" & hash(getCurrentTemplatePath());

	// Life span, as a real number of days, of the application, including all Application scope variables.
	this.applicationTimeout = createTimeSpan(0, 1, 0, 0);
	this.clientManagement = false;
	this.sessionManagement = false;
	this.sessionTimeout = createTimeSpan(0, 0, 30, 0);

	// Whether to send CFID and CFTOKEN cookies to the client browser.
	//this.setClientCookies = false;

	// Whether to set CFID and CFTOKEN cookies for a domain (not just a host).
	//this.setDomainCookies = false;

	// Whether to protect variables from cross-site scripting attacks.
	//this.scriptProtect = false;

	// A struct that contains the following values: server, username, and password.If no value is specified, takes the value in the administrator.
	//this.smtpServersettings = {};

	// Request timeout. Overrides the default administrator settings.
	this.timeout = 30; // seconds

	// Overrides the default administrator settings. It does not report compile-time exceptions.
	//this.enablerobustexception = false;


	// Java Integration
	/*this.javaSettings = { 
		loadPaths = [ ".\lib" ], 
		loadColdFusionClassPath = true, 
		reloadOnChange= false 
	};*/

	// application mappings
	this.mappings["/app"] = getDirectoryFromPath(getCurrentTemplatePath()) & "..\src\app";
	this.mappings["/FireBolt"] = getDirectoryFromPath(getCurrentTemplatePath()) & "..\src\FireBolt";
	this.mappings["/wirebox"] = getDirectoryFromPath(getCurrentTemplatePath()) & "..\src\wirebox";

	// =====================================
	// application configuration include
	//include "../src/FireBolt/bootstrap.cfm";

	// OR define application event handlers manually

	// =====================================
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
	
 

}