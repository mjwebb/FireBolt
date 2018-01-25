component ouptut="false"{

	// application nae
	this.name = "FireBolt_" & hash(getCurrentTemplatePath());

	// application configuration include
	include "config/appSettings.cfm";

	// this is our root path
	this.rootPath = getDirectoryFromPath(getCurrentTemplatePath());
	
	// application start
	public boolean function onApplicationStart(){
		application.FireBolt = new FireBolt.framework(this.rootPath);
		request.applicationStarted = true;
		return true;
	}

	// application end
	public void function onApplicationEnd(struct appScope){
		arguments.appScope.FireBolt.onApplicationEnd(arguments.appScope);
	}

	// request start
	public boolean function onRequestStart(string targetPage){
		request.startTime = getTickCount();
		if((
				isDefined("url.recycleApplication") 
				AND isBoolean(url.recycleApplication) 
				AND url.recycleApplication
			)
				AND NOT isDefined("request.applicationStarted")
			){
			OnApplicationStart();
		}
		application.FireBolt.onRequestStart(arguments.targetPage);
		return true;
	}

	// session start
	public void function onSessionStart(){
		application.FireBolt.onSessionStart();
	}

	// session end
	public void function onSessionEnd(struct sessionScope, struct appScope){
		arguments.appScope.FireBolt.onSessionEnd(argumentCollection:arguments);
	}

	// missing template
	public boolean function onMissingTemplate(template){
		return application.FireBolt.onMissingTemplate(argumentCollection:arguments);
	}

}