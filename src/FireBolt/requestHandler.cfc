/**
* Manages a request lifecylce by determining the require route, calling the route and responding with the output from the routes controller
*/
component transient accessors="true"{ // transient request handler

	property FireBolt;

	variables.context = {
		requestData: {},
		startTime: getTickCount(),
		path: "",
		form: {},
		url: {},
		mixed: {},
		contentType: cgi.content_type,
		verb: ""
	};
	variables.route = "";
	variables.reqData = {};

	/**
	* @hint constructor
	*/
	public requestHandler function init(
		string path=cgi.path_info,
		struct formScope=form,
		struct urlScope=url,
		framework FireBolt){
		variables.context.requestData = getHttpRequestData();
		variables.context.path = arguments.path;
		variables.context.form = arguments.formScope;
		variables.context.url = arguments.urlScope;
		variables.context.mixed = duplicate(arguments.urlScope);
		structAppend(variables.context.mixed, arguments.formScope);
		variables.context.verb = determinRequestMethod();
		variables.context.args = arguments;
		setFireBolt(arguments.FireBolt);
		variables.response = new response();
		return this;
	}

	/**
	* @hint determines our HTTP verb by scanning headers for an override before using our request method
	*/
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
	* @hint sets a request data variable
	*/
	public void function setData(string key, any data){
		variables.reqData[arguments.key] = arguments.data;
	}

	/**
	* @hint gets a request data variable
	*/
	public any function getData(string key){
		return variables.reqData[arguments.key];
	}

	/**
	* @hint returns our request method: GET, POST, PUT, DELETE, etc
	*/
	public string function requestMethod(){
		return variables.context.verb;
	}

	/**
	* @hint returns the body content of the request
	*/
	public any function requestBody(){
		if(structKeyExists(variables.context.requestData, "content")){
			return variables.context.requestData.content;	
		}
		return "";
	}

	/**
	* @hint returns our request context data struct
	*/
	public struct function getContext(){
		return variables.context;
	}

	/**
	* @hint returns our route data
	*/
	public any function getRoute(){
		return variables.route;
	}

	/**
	* @hint sets our route data
	*/
	public void function setRoute(struct routeData){
		variables.route = arguments.routeData;
	}

	/**
	* @hint sets our route data
	*/
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
	*/
	public any function processRoute(string path, string method, struct args={}, boolean setHeaders=true, boolean triggerEvents=true){
		defineRoute(
			arguments.path, 
			arguments.method,
			arguments.args);
		return process(arguments.setHeaders, arguments.triggerEvents);
	}



	/**
	* @hint process our request
	*/
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
					req:this, 
					res:getResponse()
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
						req:this, 
						res:getResponse()
					}
				);
			}
		//}

		// return our output
		return respond(arguments.setHeaders);
	}

	
	/**
	* @hint get our response object
	*/
	public response function getResponse(){
		return variables.response;
	}

	/**
	* @hint set response header
	*/
	public void function setResponseHeader(string name, string value){
		//local.pc = getpagecontext().getresponse();
		//local.pc.setHeader(arguments.name, arguments.value);
		cfheader(name=arguments.name, value=arguments.value);
	}

	/**
	* @hint set response status
	*/
	public void function setResponseStatus(string statusCode, string statusText=""){
		//local.pc = getpagecontext().getresponse();
		//local.pc.getresponse().setstatus(arguments.statusCode, arguments.statusText);
		cfheader(statuscode=arguments.statusCode, statustext=arguments.statusText);
	}

	/**
	* @hint set response content type
	*/
	public void function setResponseContentType(string type){
		//local.pc = getpagecontext().getresponse();
		//local.pc.getresponse().setcontenttype(arguments.type);
		cfcontent(type=arguments.type);
	}


	/**
	* @hint return a response
	*/
	public any function respond(boolean setHeaders=true){
		if(!len(variables.response.getStatusText())) variables.response.autoStatusText();
		if(arguments.setHeaders){
			setResponseStatus(
				statusCode=variables.response.getStatus(),
				statusText=variables.response.getStatusText());
			if(structKeyExists(variables.context.url, "timerHeader")){
				setResponseHeader(
					name="ServerTimer", 
					value=duration());
			}
			if(isBinary(variables.response.getBody())){
				setResponseHeader(
					name="Content-Length", 
					value=variables.response.getLength());
			}
			setResponseContentType(
				type="#variables.response.getType()#; charset=#variables.response.getEncoding()#");
		}
		return variables.response.getBody();
	}
	
	/**
	* @hint returns the current duration of the request
	*/
	public numeric function duration(){
		return getTickCount() - variables.context.startTime;
	}

	
	/**
	* @hint framework shortcut
	*/
	public framework function FB(){
		return getFireBolt();
	}

	
}