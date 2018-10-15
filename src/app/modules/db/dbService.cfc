component accessors="true"{

	property name="FB" inject="framework";
	
	/**
	* @hint constructor
	*/
	public function init(){
		return this;
	}

	public any function getGateway(){
		if(!structKeyExists(variables, "Gateway")){
			variables.Gateway = getFB().getObject(rootName() & "Gateway");
		}
		return variables.Gateway;
	}

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



}