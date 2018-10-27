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
	* @hint returns a gateway object
	*/
	public any function gateway(string model){
		return getFB().getObject("#arguments.model#Gateway");
	}

	/**
	* @hint returns a service object
	*/
	public any function service(string model){
		return getFB().getObject("#arguments.model#Service");
	}

	/**
	* @hint returns a bean object
	*/
	public any function bean(string model, any pkValue=0){
		local.bean = getFB().getObject("#arguments.model#Bean", {service: service(arguments.model)});
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