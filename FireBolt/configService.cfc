component{

	variables.FireBolt;
	variables.config = {};

	/**
	* @hint constructor
	* **/
	public configService function init(string type, framework FireBolt){
		variables.FireBolt = arguments.FireBolt;
		if(! isNull(variables.FireBolt)){
			variables.FireBolt.registerMethods("getConfig,getSetting", this);
		}
		if(len(arguments.type)){
			readConfig(arguments.type);
		}
		return this;
	}

	
	/**
	* @hint reads config settings
	* **/
	public any function readConfig(string type="FireBolt"){
		local.configPath = "config.#arguments.type#";
		variables.config = new "#local.configPath#"().config;
	}

	/**
	* @hint returns our config struct
	* **/
	public any function getConfig(){
		return variables.config;
	}

	/**
	* @hint gets a config setting
	* **/
	public any function getSetting(string keyChain){
		arguments.keyChain = listToArray(arguments.keyChain, ".");
		local.v = variables.config;
		for(local.key in arguments.keyChain){
			if(structKeyExists(local.v, local.key)){
				local.v = local.v[local.key];
			}else{
				// key is missing
				return "";
			}
		}
		return local.v;
	}

	

}