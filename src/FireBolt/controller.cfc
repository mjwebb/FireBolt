component transient accessors="true"{
	
	//property name="FB" inject="framework";
	property FireBolt;
	property requestHandler;
	
	
	/**
	* @hint constructor
	*/
	public controller function init(requestHandler req, framework FireBolt inject){
		setRequestHandler(arguments.req);
		setFireBolt(arguments.FireBolt);
		setOutputProxyMethods();
		return this;
	}

	/**
	* @hint framework shortcut
	*/
	public framework function FB(){
		return getFireBolt();
	}

	/**
	* @hint request context shortcut
	*/
	public struct function rc(){
		return getRequestHandler().getContext();
	}


	/**
	* @hint write a var dump out as a string
	*/
	public string function stringDump(any var){
		savecontent variable="local.content"{
			writeDump(arguments.var);
		}
		return local.content;
	}

	/**
	* @hint helper to call dynamic functions
	*/
	public function callFunction(required string fnc, args={}){
		//return this[arguments.fnc](argumentCollection=arguments.args);
		var callMe = this[arguments.fnc];
		return callMe(argumentCollection=arguments.args);
	}



	/**
	* @hint helper for our request response
	*/
	public function response(){
		return getRequestHandler().getResponse();
	}

	/**
	* @hint helper for setting our request response body
	*/
	public function setResponseBody(any body){
		return response().setBody(arguments.body);
	}

	/**
	* @hint call our response for our request handler
	*/
	public function respond(){
		return getRequestHandler().respond();
	}


	/**
	* @hint helper for our view
	*/
	public any function view(string viewFile, any viewData={}, string contentRegion="", string root=FB().getSetting('paths.views')){
		if(isStruct(arguments.viewData)){
			structAppend(arguments.viewData, {controller:this});
		}
		return output().view(argumentCollection:arguments);
	}

	/**
	* @hint render a view and add it by default to the default content region
	*/
	public any function addView(string viewFile, any viewData={}, string contentRegion="default", string root=FB().getSetting('paths.views')){
		return view(argumentCollection:arguments);
	}


	/**
	* @hint render a given output
	*/
	public any function layout(string templateName="default"){
		local.output = output().layout(argumentCollection:arguments);
		response().setBody(local.output);
		return local.output;
	}

	/**
	* @hint returns our response output service
	*/
	public responseOutputService function output(){
		return getRequestHandler().output();
	}

	/**
	* @hint creates proxy methods to our response output service methods
	*/
	public void function setOutputProxyMethods(){
		local.outputService = output();
		for(local.key in local.outputService){
			//FB().inject(this, local.key, local.outputService[local.key], true);
			
			if(!structKeyExists(this, local.key)){
				this[local.key] = this.outputProxyMethod;
				if(!structKeyExists(variables, local.key)){
					variables[local.key] = this.outputProxyMethod;
				}
			}
		}
	}

	/**
	* @hint this gets called by our proxied response output service methods and makes the call back to itself
	*/
	public any function outputProxyMethod(){
		return invoke(output(), getFunctionCalledName(), arguments);
	}

	
}