/**
* @FB:transient true
* **/
component{ // transient request handler

	variables.FireBolt;
	variables.context = {
		startTime: getTickCount(),
		path: "",
		form: form,
		url: url,
		verb: requestMethod()
	};
	variables.route;
	variables.outputService;

	/**
	* @hint constructor
	* **/
	public requestHandler function init(
		string path=cgi.path_info,
		struct formScope=form,
		struct urlScope=url,
		framework FireBolt=application.FireBolt){
		variables.context.path = arguments.path;
		variables.context.form = arguments.formScope;
		variables.context.url = arguments.urlScope;
		variables.FireBolt = arguments.FireBolt;
		variables.response = new response(variables.FireBolt);
		variables.outputService = newOutput();
		return this;
	}

	/**
	* @hint returns our request method: GET, POST, PUT, DELETE, etc
	* **/
	public string function requestMethod(){
		return getHTTPRequestData().method;
	}

	/**
	* @hint returns our request context data struct
	* **/
	public struct function getContext(){
		return variables.context;
	}

	/**
	* @hint returns our route data
	* **/
	public any function getRoute(){
		return variables.route;
	}

	/**
	* @hint sets our route data
	* **/
	public any function setRoute(struct routeData){
		variables.route = arguments.routeData;
	}

	/**
	* @hint process our request
	* **/
	public string function process(){

		// start by determining a valid route
		setRoute(FB().getRouteService().getRoute(this));


		// trigger event before we process our request
		FB().trigger(
			"req.beforeProcess", 
			{
				requestHandler:this, 
				response:getResponse()
			});

		// ==========================
		// testing...
		//FB().removeListener("test.event");
		//local.r = FB().getListeners();
		//return FB().trigger("Test.Event.Proxy");
		//local.t = FB().getModule("testModule.transientWithArg", {req:this});
		//local.t = FB().getModule("testModule.sampleModule");
		//local.c = FB().getFactoryService().getCache();

		local.r = FB().getRouteService().runRoute(this);

		//local.c = FB().stringDump(getMetaDAta(FB().getEventService()));
		//getResponse().setBody(FB().stringDump(local.r));
		// ==========================

		
		// trigger event after we have processed our request
		FB().trigger(
			"req.afterProcess", 
			{
				requestHandler:this, 
				response:getResponse()
			});
		
		// return our output
		return respond();
		//return FB().stringDump(local.t.getDep().hello());
	}

	
	/**
	* @hint get our response object
	* **/
	public response function getResponse(){
		return variables.response;
	}


	/**
	* @hint return a response
	* **/
	public any function respond(){
		if(!len(variables.response.getStatusText())) variables.response.autoStatusText();
		header statusCode=variables.response.getStatus() statusText=variables.response.getStatusText();
		header name="Content-Length" value=variables.response.getLength();
		content type="#variables.response.getType()#; charset=#variables.response.getEncoding()#";
		return variables.response.getBody();
	}
	
	/**
	* @hint returns the current duration of the request
	* **/
	public numeric function duration(){
		return getTickCount() - variables.context.startTime;
	}

	
	/**
	* @hint framework shortcut
	* **/
	public framework function FB(){
		return variables.FireBolt;
	}

	/**
	* @hint create a requestOutputService for this request
	* **/
	public requestOutputService function newOutput(){
		return new requestOutputService(this);
	}

	/**
	* @hint returns our request output service
	* **/
	public requestOutputService function output(){
		return variables.outputService;
	}

}