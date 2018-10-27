component accessors="true"{

	property name="FB" inject="framework";
	
	/**
	* @hint constructor
	*/
	public function init(){
		return this;
	}

	/**
	* @hint returns the gateway object for our root
	*/
	public any function getGateway(){
		if(!structKeyExists(variables, "Gateway")){
			variables.Gateway = getFB().getObject(rootName() & "Gateway");
		}
		return variables.Gateway;
	}

	/**
	* @hint determines our root name from our metadata name
	*/
	public string function rootName(){
		local.root = listLast(getMetaData(this).name, ".");
		if(right(local.root, 4) IS "Bean"){
			local.root = mid(local.root, 1, len(local.root) - 4);
		}else{
			local.r7 = right(local.root, 7);
			if(local.r7 IS "Gateway" OR local.r7 IS "Service"){
				local.root = mid(local.root, 1, len(local.root) - 7);
			}
		}
		return local.root;
	}


	/**
	* @hint save our given bean
	*/
	public any function save(any bean){

		local.config = getGateway().getConfig();

		if(arguments.bean.getID()){
			// UPDATE
			local.dec = getGateway().update();
			for(local.col in local.config.cols){
				if(!structKeyExists(local.col, "pk") OR !local.col.pk){
					local.dec.set(local.col.name, arguments.bean.get(local.col.name));
				}
			}

			local.dec.where(local.config.pk.name & "= :pk")
				.withParam("pk", arguments.bean.getID())
				.go();

		}else{
			// INSERT
			local.dec = getGateway().insert();
			for(local.col in local.config.cols){
				if(!structKeyExists(local.col, "pk") OR !local.col.pk){
					local.dec.set(local.col.name, arguments.bean.get(local.col.name));
				}
			}
			local.result = local.dec.go();

			local.id = getGateway().getInsertID(local.result);
			arguments.bean.setID(local.id);
		}

		return arguments.bean;
	}

	/**
	* @hint delete our given bean
	*/
	public any function delete(any bean){
		
	}
}