/**
* Reads and handles FireBolt configuration files
*/
component{

	variables.FireBolt = "";
	variables.configObject = "";
	variables.config = {};
	variables.environmentPrefix = "env:";

	/**
	* @hint constructor
	*/
	public configService function init(string type, any FireBolt=""){
		variables.FireBolt = arguments.FireBolt;
		if(len(arguments.type)){
			readConfig(arguments.type);
		}
		return this;
	}


	/**
	* @hint reads config settings
	*/
	public any function readConfig(string type="FireBolt"){
		local.configPath = "app.config.#arguments.type#";
		variables.configObject = new "#local.configPath#"();
		if(! isSimpleValue(variables.FireBolt)){
			variables.FireBolt.injectFramework(variables.configObject);
		}
		variables.config = variables.configObject.config;
		parseConfig(variables.config);
	}

	/**
	* @hint walks our config struct to search for dynamic variables
	*/
	public any function parseConfig(any node){
		if(isSimpleValue(arguments.node)){
			if(left(arguments.node, 4) IS variables.environmentPrefix){
				local.key = replaceNoCase(arguments.node, variables.environmentPrefix, "");
				return getSystemProperty(local.key, arguments.node);
			}
		}else if(isArray(arguments.node)){
			for(local.item in arguments.node){
				local.item = parseConfig(local.item);
			}
		}else if(isStruct(arguments.node)){
			for(local.key in arguments.node){
				arguments.node[local.key] = parseConfig(arguments.node[local.key]);
			}
		}
		return arguments.node;
	}

	/**
	* @hint returns our config object
	*/
	public any function getConfigObject(){
		return variables.configObject;
	}

	/**
	* @hint returns our config struct
	* @FireBoltMethod
	*/
	public any function getConfig(){
		return variables.config;
	}

	/**
	* @hint gets a config setting
	* @FireBoltMethod
	*/
	public any function getSetting(string keyChain){
		arguments.keyChain = listToArray(arguments.keyChain, ".");
		local.v = variables.config;
		for(local.key in arguments.keyChain){
			//if(structKeyExists(local.v, local.key)){
				local.v = local.v[local.key];
			//}else{
				// key is missing
				//return "";
			//}
		}
		return local.v;
	}

	/**
	* @hint sets a config key value
	* @FireBoltMethod
	*/
	public void function setSetting(string key, any value){
		evaluate("variables.config.#arguments.key# = arguments.value");
	}

	/**
	* @hint merges a setting key struct with a given struct
	* @FireBoltMethod
	*/
	public void function mergeSetting(string key, struct value){
		if(evaluate("structKeyExists(variables.config, '#arguments.key#') AND isStruct(variables.config.#arguments.key#)")){
			structAppend(evaluate("variables.config.#arguments.key#"), arguments.value);
		}else{
			setSetting(arguments.key, arguments.value);
		}
	}

	/**
	* @hint reads a JVM environment variable / system property
	*/
	public string function getSystemProperty(string key, string defaultValue){
		local.system = CreateObject("java", "java.lang.System");
		return system.getProperty(arguments.key, arguments.defaultValue);
	}
}