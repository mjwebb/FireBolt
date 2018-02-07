component{
	
	variables.FireBolt;
	variables.req;

	
	
	/**
	* @hint constructor
	* **/
	public controller function init(requestHandler req, framework FireBolt=application.FireBolt){
		variables.req = arguments.req;
		variables.FireBolt = arguments.FireBolt;
		setOutputProxyMethods();
		return this;
	}

	/**
	* @hint framework shortcut
	* **/
	public framework function FB(){
		return variables.FireBolt;
	}

	/**
	* @hint request context shortcut
	* **/
	public struct function rc(){
		return variables.req.getContext();
	}

	/**
	* @hint write a var dump out as a string
	* **/
	public string function stringDump(any var){
		savecontent variable="local.content"{
			writeDump(arguments.var);
		}
		return local.content;
	}

	/**
	* @hint helper to call dynamic functions
	* **/
	public function callFunction(required string fnc, args={}){
		//return this[arguments.fnc](argumentCollection=arguments.args);
		var callMe = this[arguments.fnc];
		return callMe(argumentCollection=arguments.args);
	}


	/**
	* @hint helper for our request henlder
	* **/
	public function requestHandler(){
		return variables.req;
	}

	/**
	* @hint helper for our request response
	* **/
	public function response(){
		return requestHandler().getResponse();
	}

	/**
	* @hint helper for setting our request response body
	* **/
	public function setResponseBody(any body){
		return response().setBody(arguments.body);
	}


	/**
	* @hint helper for our view
	* **/
	public any function view(string viewFile, any data={}, string contentRegion="", string root=FB().getSetting('paths.views')){
		if(isStruct(arguments.data)){
			structAppend(arguments.data, {controller:this});
		}
		return output().view(argumentCollection:arguments);
	}

	/**
	* @hint render a view and add it by default to the default content region
	* **/
	public any function addView(string viewFile, any data={}, string contentRegion="default", string root=FB().getSetting('paths.views')){
		return view(argumentCollection:arguments);
	}


	/**
	* @hint render a given output
	* **/
	public any function layout(string templateName="default"){
		local.output = output().layout(argumentCollection:arguments);
		response().setBody(local.output);
		return local.output;
	}

	/**
	* @hint returns our request output service
	* **/
	public requestOutputService function output(){
		return variables.req.output();
	}

	/**
	* @hint creates proxy methods to our request output service methods
	* **/
	public void function setOutputProxyMethods(){
		for(var key in output()){
			if(!structKeyExists(variables, key)){
				variables[key] = this.outputProxyMethod;
			}
		}
	}

	/**
	* @hint this gets called by our proxied requestion output serice methods and makes the call back to the service
	* **/
	private any function outputProxyMethod(){
		return output()[getFunctionCalledName()](argumentCollection:arguments)
	}

	
}