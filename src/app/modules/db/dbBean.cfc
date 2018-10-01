component accessors="true"{


	variables.instance = {};
	variables.instancePrev = {};
	variables.isDirty = false;
	variables.definition = {
		pk: "",
		cols: ""
	};
	variables.configObject = "";


	/**
	* @hint constructor
	*/
	public function init(){
		//buildInstance();
		readConfig();
		return this;
	}

	public void function readConfig(){
		local.configName = "_" & replace(listLast(getMetaData(this).name, "."), "Bean", "") & "Config";
		variables.configObject = new "#local.configName#"();
	}

	public any function getConfig(){
		return variables.configObject;
	}

	/**
	* @hint returns a duplicate of our instance data
	*/
	public struct function getSnapShot(boolean isPrev=false){
		if(arguments.isPrev){
			return duplicate(variables.instancePrev);
		}else{
			return duplicate(variables.instance);
		}
	}

	/**
	* @hint returns our bean definition
	*/
	public string function getDefinition(){
		return variables.definition;
	}

	/**
	* @hint returns our primary key column name
	*/
	public string function getPK(){
		return variables.definition.pk;
	}

	/**
	* @hint returns beans ID using our primary key value
	*/
	public string function getID(){
		return variables.instance[getPK()];
	}
	
	/**
	* @hint sets our beans ID for our primary key column
	*/
	public string function setID(any id){
		return variables.instance[getPK()] = arguments.id;
		setDirty();
	}

	/**
	* @hint returns true if instance data has changed since it was populated
	*/
	public boolean function isDirty(){
		return variables.isDirty;
	}

	/**
	* @hint clears our dirty flag
	*/
	public void function clearDirty(){
		variables.isDirty = false;
	}

	/**
	* @hint sets our dirty flag
	*/
	public void function setDirty(){
		variables.isDirty = true;
	}
		
	/**
	* @hint gets an instance value
	*/
	public any function get(string key, boolean isPrev=false){
		
		local.variableName = "instance";
		if(arguments.isPrev){
			local.variableName = "instancePrev";
		}

		if(structKeyExists(variables[local.variableName], arguments.key)){
			return variables[local.variableName][arguments.key];
		}

		return null;
	}
	
	/**
	* @hint sets an instance value
	*/
	public void function set(string key, any value){
		
		if(structKeyExists(variables.instance, arguments.key)){
			variables.instance[arguments.key] = arguments.value;
			setDirty();
		}else{
			throw(message="Key name '#arguments.key#' is not defined in this instance", type="DB Bean");
		}
	}
	

	/**
	* @hint used to capture get and set methods
	*/
	public any function onMissingMethod(string missingMethodName, struct missingMethodArguments){

		if(len(arguments.missingMethodName) GTE 4){
			local.param = mid(arguments.missingMethodName, 4, len(arguments.missingMethodName));
			local.fnc = left(arguments.missingMethodName, 3);
			switch(local.fnc){
				case "get":
					return get(local.param);
					break;
				case "set":
					return set(local.param, arguments.missingMethodArguments.1);
					break;
			}
		}
		
		throw(message="Method name '#arguments.missingMethodName#' is not defined", type="DB Bean");
	}

	/**
	* @hint populate an instance from either a query or a struct
	*/
	public void function popInstance(any data, numeric row=1){
		if(isStruct(arguments.data)){
			for(local.col in arguments.data){
				set(local.col, arguments.data[local.col]);
			}
		}else if(isQuery(arguments.data)){
			local.dataColumns = listToArray(arguments.data.columnList);
			for(local.col in local.dataColumns){
				set(local.col, arguments.data[local.col][arguments.row]);
			}
		}
		variables.instancePrev = duplicate(variables.instance);
		clearDirty();
	}

}