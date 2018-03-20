component{


	/**
	* @hint constructor
	*/
	public any function init(){
		return this;
	}


	/**
	* @hint adds a mapping to our application
	*/
	public string function addMapping(required string name, required string path){
		local.appMD = getApplicationMetadata();
		local.appMD.mappings[arguments.name] = arguments.path;
	}

	
}