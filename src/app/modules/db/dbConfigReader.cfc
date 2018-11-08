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

		// joins
		variables.config.joinColList = "";
		variables.config.joinCols = [];
		if(structKeyExists(variables.config, "joins")){
			for(local.join in variables.config.joins){
				variables.config.joinColList = listAppend(variables.config.joinColList, local.join.cols);
			}
			local.tempJoinCols = listToArray(variables.config.joinColList);
			for(local.joinCol in local.tempJoinCols){
				local.joinCol = replaceNoCase(local.joinCol, " AS ", "~");
				local.joinCol = trim(listLast(local.joinCol, "~"));
				arrayAppend(variables.config.joinCols, local.joinCol);
				variables.config.colHash[local.joinCol] = "JOIN";
			}
		}
	}

	public struct function buildInstance(){
		local.inst = {};
		for(local.col in variables.config.cols){
			local.inst[local.col.name] = local.col.default;
		}
		for(local.joinCol in variables.config.joinCols){
			local.inst[local.joinCol] = "";
		}
		return local.inst;
	}

	public any function getConfig(){
		return variables.config;
	}

	public any function columnList(){
		return listAppend(variables.config.colList, variables.config.joinColList);
	}

	public any function columns(){
		return variables.config.cols;
	}

	public any function joins(){
		if(structKeyExists(variables.config, "joins")){
			return variables.config.joins;
		}
		return [];
	}

	public any function table(){
		return variables.config.table;
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