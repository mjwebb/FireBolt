component{

	variables.configPath = "app.config";
	variables.datasources = {};

	/**
	* @hint constructor
	*/
	public function init(){
		return this;
	}


	public any function getSchema(string schemaName="default"){
		if(structKeyExists(variables.datasources, arguments.schemaName)){
			return variables.datasources[arguments.schemaName];
		}else{
			if(readConfig(arguments.schemaName)){
				return variables.datasources[arguments.schemaName];
			}else{
				// attempt to build a default schema
				local.app = getApplicationMetadata();
				if(structKeyExists(local.app, "datasources")){
					local.dsn = listFirst(structKeyList(local.app.datasources));
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

	public function buildConfig(string dsn, string schemaName="default"){
		local.inspector = new dbInspector();
		local.schema = local.inspector.buildSchema(arguments.dsn, arguments.schemaName);
		local.configName = "#variables.configPath#.db-#arguments.schemaName#";
		fileWrite(expandPath("/" & replaceNoCase(local.configName, ".", "/", "ALL")) & ".cfc", local.schema);
	}


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