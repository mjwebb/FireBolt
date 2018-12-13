component{

	variables.configPath = "app.config";
	variables.datasources = {};

	/**
	* @hint constructor
	*/
	public function init(){
		return this;
	}

	/**
	* @hint returns a database schema for a given schema alias name
	*/
	public any function getSchema(string schemaName="default"){
		if(structKeyExists(variables.datasources, arguments.schemaName)){
			return variables.datasources[arguments.schemaName];
		}else{
			if(readConfig(arguments.schemaName)){
				return variables.datasources[arguments.schemaName];
			}else{
				// attempt to build a default schema
				local.dsns = getDSNNames();
				if(arrayLen(local.dsns)){
					local.dsn = local.dsns[1];
					if(len(local.dsn)){
						buildConfig(local.dsn, arguments.schemaName);
						if(readConfig(arguments.schemaName)){
							return variables.datasources[arguments.schemaName];
						}else{
							throw("Schema '#arguments.schemaName#' not defined and could not be built", "db");
						}
					}			
				}

				throw("Schema '#arguments.schemaName#' not defined", "db");
			}
		}
	}

	/**
	* @hint returns a application defined datasources
	*/
	public struct function getDatasources(){
		local.app = getApplicationMetadata();
		if(structKeyExists(local.app, "datasources")){
			return local.app.datasources;
		}
		return {};
	}

	/**
	* @hint returns an array of application defined datasource names
	*/
	public array function getDSNNames(){
		return structKeyArray(getDatasources());
	}

	/**
	* @hint builds a configuration file for a given DSN and schema alias name
	*/
	public function buildConfig(string dsn, string schemaName="default"){
		local.inspector = new dbInspector();
		local.schema = local.inspector.buildSchema(arguments.dsn, arguments.schemaName);
		local.configName = "#variables.configPath#.db-#arguments.schemaName#";
		fileWrite(expandPath("/" & replaceNoCase(local.configName, ".", "/", "ALL")) & ".cfc", local.schema);
	}


	/**
	* @hint reads a schema configuration file and adds it to our local cache for a given schema alias name
	*/
	public boolean function readConfig(string schemaName="default"){
		local.configName = "#variables.configPath#.db-#arguments.schemaName#";
		if(fileExists(expandPath("/" & replaceNoCase(local.configName, ".", "/", "ALL") & ".cfc"))){
			variables.datasources[arguments.schemaName] = new "#local.configName#"().config;
			variables.datasources[arguments.schemaName].path = local.configName;
			variables.datasources[arguments.schemaName].fullPath = expandPath("/" & replaceNoCase(local.configName, ".", "/", "ALL") & ".cfc");
			return true;
		}
		return false;
	}

}