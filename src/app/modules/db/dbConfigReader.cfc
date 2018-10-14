component accessors="true"{


	/**
	* @hint constructor
	*/
	public function init(string parentName){
		readConfig(arguments.parentName);
		return this;
	}

	public void function readConfig(string parentName){
		local.root = arguments.parentName;
		if(right(local.root, 4) IS "Bean"){
			local.root = mid(local.root, 1, len(local.root) - 4);
		}else{
			local.r7 = right(local.root, 7);
			if(local.r7 IS "Gateway" OR local.r7 IS "Service"){
				local.root = mid(local.root, 1, len(local.root) - 7);
			}
		}

		local.configName = local.root & "Config";
		variables.configObject = new "#local.configName#"();
		variables.config = variables.configObject.definition;
		variables.config.colList = "";
		variables.config.hasPK = false;
		variables.config.colHash = {};
		for(local.col in variables.config.cols){
			variables.config.colList = listAppend(variables.config.colList, local.col.name);
			variables.config.colHash[local.col.name] = local.col;
			if(structKeyExists(local.col, "pk") AND local.col.pk){
				variables.config.pk = local.col;
				variables.config.hasPK = true;
			}
		}
	}

	public struct function buildInstance(){
		local.inst = {};
		for(local.col in variables.config.cols){
			local.inst[local.col.name] = local.col.default;
		}
		return local.inst;
	}

	public any function getConfig(){
		return variables.config;
	}

	public any function columns(){
		return variables.config.cols;
	}

	public struct function getColumn(string colName){
		return variables.config.colHash[arguments.colName]
	}

	public boolean function isColumnDefined(string colName){
		return structKeyExists(variables.config.colHash, arguments.colName);
	}

	public string function getPK(){
		if(variables.config.hasPK){
			return variables.config.pk.name
		}
		return "";
	}

}