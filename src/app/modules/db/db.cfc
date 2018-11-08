component accessors="true"{

	property name="FB" inject="framework";
	property name="settings" inject="setting:modules.db";
	

	/**
	* @hint constructor
	*/
	public function init(){
		return this;
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
		return getFB().getObject("#local.model.name#Gateway@#local.model.namespace#");
	}

	/**
	* @hint returns a service object
	*/
	public any function service(string model){
		local.model = parseModelNamespace(arguments.model);
		return getFB().getObject("#local.model.name#Service@#local.model.namespace#");
	}

	/**
	* @hint returns a bean object
	*/
	public any function bean(string model, any pkValue=0){
		local.model = parseModelNamespace(arguments.model);
		local.bean = getFB().getObject("#local.model.name#Bean@#local.model.namespace#", {service: service(arguments.model)});
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