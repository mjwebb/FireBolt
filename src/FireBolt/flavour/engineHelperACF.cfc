component extends="engineShared"{

	/**
	* @hint constructor
	*/
	public any function init(){
		return this;
	}


	/**
	* @hint adds a mapping to our application
	*/
	public string function addCFMapping(required string name, required string path){
		local.appMD = getApplicationMetadata();
		local.appMD.mappings[arguments.name] = arguments.path;
	}

	/**
	* @hint adds a datasource to our application
	*/
	public string function addCFDatasource(required string name, required struct config){
		local.appMD = getApplicationMetadata();
		local.appMD.datasources[arguments.name] = arguments.config;
	}

	
}