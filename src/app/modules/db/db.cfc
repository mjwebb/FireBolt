component accessors="true"{

	property name="FB" inject="framework";
	property name="settings" inject="setting:modules.db";
	


	/**
	* @hint constructor
	*/
	public function init(){
		variables.datasourceManager = new dbDatasourceManager();
		return this;
	}

	/**
	* @hint returns a schema definition if it exists
	*/
	public any function getSchema(string schemaName="default"){
		return variables.datasourceManager.getSchema(arguments.schemaName);
	}

	/**
	* @hint returns a table schema definition if it exists
	*/
	public any function getTableSchema(string table, string schemaName="default"){
		return getSchema(arguments.schemaName).tables[arguments.table];
	}

	/**
	* @hint generates a schema file and saves it to disk
	*/
	public any function buildSchema(string dsn, string schemaName="default"){
		return variables.datasourceManager.buildConfig(arguments.dsn, arguments.schemaName);
	}

	/**
	* @hint parses a model string to split into the model name and its namespace
	*/
	public struct function parseModelNamespace(string model){
		local.model = {
			name: listFirst(arguments.model, "@"),
			namespace: "model"
		}
		if(listLen(arguments.model, "@") GT 1){
			local.model.namespace = listLast(arguments.model, "@");
		}
		return local.model;
	}


	/**
	* @hint returns a gateway object
	*/
	public any function gateway(string model){
		local.model = parseModelNamespace(arguments.model);
		return getFB().getObject("#local.model.name#Gateway@#local.model.namespace#", {db:this});
	}

	/**
	* @hint returns a service object
	*/
	public any function service(string model){
		local.model = parseModelNamespace(arguments.model);
		return getFB().getObject("#local.model.name#Service@#local.model.namespace#", {db:this});
	}

	/**
	* @hint returns a bean object
	*/
	public any function bean(string model, any pkValue=0){
		local.model = parseModelNamespace(arguments.model);
		local.bean = getFB().getObject("#local.model.name#Bean@#local.model.namespace#", {service: service(arguments.model)}, false);
		// set our service and gateway for our bean

		if(arguments.pkValue NEQ 0){
			local.qData = gateway(arguments.model).get(arguments.pkValue);
			if(local.qData.recordCount){
				local.bean.pop(local.qData);
			}
		}
		return local.bean;
	}

	/**
	* @hint proxy for our service save method
	*/
	public any function save(any bean){
		return service(arguments.bean.rootName()).save(arguments.bean);
	}

	/**
	* @hint proxy for our service delete method
	*/
	public any function delete(any bean){
		return service(arguments.bean.rootName()).delete(arguments.bean);	
	}

	

}