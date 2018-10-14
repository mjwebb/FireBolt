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
		local.bean = getFB().getObject("#arguments.model#Bean");
		if(arguments.pkValue NEQ 0){
			local.qData = gateway(arguments.model).get(arguments.pkValue);
			if(local.qData.recordCount){
				local.bean.pop(local.qData);
			}
		}
		return local.bean;
	}

}