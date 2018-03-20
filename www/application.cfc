component{

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

	// application mappings
	this.mappings["/FireBolt"] = getDirectoryFromPath(getCurrentTemplatePath()) & "..\src\FireBolt";
	this.mappings["/app"] = getDirectoryFromPath(getCurrentTemplatePath()) & "..\src\app";

	// Java Integration
	/*this.javaSettings = { 
		loadPaths = [ ".\lib" ], 
		loadColdFusionClassPath = true, 
		reloadOnChange= false 
	};*/
	

	public function getFireBolt(){
		if(!structKeyExists(application, "FireBolt")){
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
		getFireBolt().onRequestStart(arguments.targetPage);
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


}