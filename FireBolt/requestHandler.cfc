/**
* @FB:transient true
* **/
component{ // transient request handler

	variables.FireBolt;
	variables.context = {
		requestData: getHttpRequestData(false),
		startTime: getTickCount(),
		path: "",
		form: {},
		url: {},
		contentType: cgi.content_type,
		verb: ""
	};
	variables.route;
	variables.outputService;
	variables.reqData = {};

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
		variables.context.verb = determinRequestMethod();
		variables.context.args = arguments;
		variables.FireBolt = arguments.FireBolt;
		variables.response = new response(variables.FireBolt);
		variables.outputService = newOutput();
		return this;
	}

	/**
	* @hint determines our HTTP verb by scanning headers for an override before using our request method
	* **/
	public string function determinRequestMethod(){
		// before we return this, we scan our request headers for an override
		if(structKeyExists(variables.context.requestData.headers, "X-HTTP-METHOD-OVERRIDE")){
			local.override = variables.context.requestData.headers["X-HTTP-METHOD-OVERRIDE"];
			if(listFindNoCase("POST,GET,PUT,PATCH,DELETE", local.override)){
				return uCase(local.override);
			}
		}
		return variables.context.requestData.method;
	}

	/**
	* @hint sets our request data variable
	* **/
	public void function setRequestData(any data){
		variables.reqData = arguments.data;
	}

	/**
	* @hint sets our request data variable
	* **/
	public any function getRequestData(){
		return variables.reqData;
	}

	/**
	* @hint returns our request method: GET, POST, PUT, DELETE, etc
	* **/
	public string function requestMethod(){
		return variables.context.verb;
	}

	/**
	* @hint returns the body content of the request
	* **/
	public any function requestBody(){
		if(structKeyExists(variables.context.requestData, "content")){
			return variables.context.requestData.content;	
		}
		return "";
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
	public void function setRoute(struct routeData){
		variables.route = arguments.routeData;
	}

	/**
	* @hint sets our route data
	* **/
	public void function defineRoute(string path, string method, struct args={}){
		local.r = FB().getRouteService().defineRoute(
			this, 
			arguments.path, 
			arguments.method,
			arguments.args);
		setRoute(local.r);
	}

	/**
	* @hint sets a route and precosess it
	* **/
	public any function processRoute(string path, string method, struct args={}, boolean setHeaders=true, boolean triggerEvents=true){
		defineRoute(
			arguments.path, 
			arguments.method,
			arguments.args);
		return process(arguments.setHeaders, arguments.triggerEvents);
	}



	/**
	* @hint process our request
	* **/
	public any function process(boolean setHeaders=true, boolean triggerEvents=true){

		// start by determining a valid route
		if(!isStruct(variables.route)){
			setRoute(FB().getRouteService().getRoute(this));
		}

		// trigger event before we process our request
		if(arguments.triggerEvents){
			FB().trigger(
				"req.beforeProcess", 
				{
					requestHandler:this, 
					response:getResponse()
				}
			);
		}
		
		//if(getResponse().getStatus() EQ getResponse().codes.OK){
			// ==========================
			
			local.r = FB().getRouteService().runRoute(this);

			// ==========================
			
			// trigger event after we have processed our request
			if(arguments.triggerEvents){
				FB().trigger(
					"req.afterProcess", 
					{
						requestHandler:this, 
						response:getResponse()
					}
				);
			}
		//}

		// return our output
		return respond(arguments.setHeaders);
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
	public any function respond(boolean setHeaders=true){
		if(!len(variables.response.getStatusText())) variables.response.autoStatusText();
		if(arguments.setHeaders){
			header statusCode=variables.response.getStatus() statusText=variables.response.getStatusText();
			header name="Content-Length" value=variables.response.getLength();
			content type="#variables.response.getType()#; charset=#variables.response.getEncoding()#";
		}
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