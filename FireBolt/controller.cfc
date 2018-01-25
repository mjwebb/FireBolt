component{
	
	variables.FireBolt;
	variables.req;

	variables.tpl;
	
	
	/**
	* @hint constructor
	* **/
	public controller function init(requestHandler req, framework FireBolt=application.FireBolt){
		variables.req = arguments.req;
		variables.FireBolt = arguments.FireBolt;
		variables.tpl = newTemplate();
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
		return variables.req.getRequest();
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
	* @hint helper for our view
	* **/
	public any function view(string viewFile, any data={}, string contentRegion="", string root=FB().getSetting('paths.views')){
		if(isStruct(arguments.data)){
			structAppend(arguments.data, {controller:this});
		}
		return variables.tpl.view(argumentCollection:arguments);
	}

	/**
	* @hint render a view and add it by default to the default content region
	* **/
	public any function addView(string viewFile, any data={}, string contentRegion="default", string root=FB().getSetting('paths.views')){
		return view(argumentCollection:arguments);
	}


	/**
	* @hint render a given template
	* **/
	public any function layout(string templateName="default"){
		local.output = variables.tpl.layout(argumentCollection:arguments);
		response().setBody(local.output);
		return local.output;
	}

	/**
	* @hint create a template for this request
	* **/
	public template function newTemplate(){
		return new template(requestHandler());
	}

	/**
	* @hint returns our request template
	* **/
	public template function template(){
		return variables.tpl;
	}
}