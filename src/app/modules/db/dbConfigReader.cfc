component{


	/**
	* @hint constructor
	*/
	public function init(string parentName, any db){
		variables.db = arguments.db;
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

		// set our default schema if one is not defined
		if(!structKeyExists(variables.config, "schema")){
			variables.config.schema = "default";	
		}

		// set our default table if one is not defined
		if(!structKeyExists(variables.config, "table")){
			variables.config.table = "tbl_#local.root#";
		}
		
		// find our table columns and flavour and dsn from our schema definition
		local.table = db.getTableSchema(variables.config.table, variables.config.schema);
		local.schema = db.getSchema(variables.config.schema);
		
		structAppend(variables.config, local.table);
		variables.config.dsn = local.schema.dsn;
		variables.config.flavour = local.schema.flavour;

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
			// check for default date value
			if(isDate(local.col.default) AND local.col.cfDataType IS "date"){
				local.inst[local.col.name] = now();
			}
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
		if(len(variables.config.joinColList)){
			return listAppend(variables.config.colList, variables.config.joinColList);
		}
		return variables.config.colList;
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

	public any function manyToMany(){
		if(structKeyExists(variables.config, "manyTomany")){
			return variables.config.manyTomany;
		}
		return [];
	}

	public any function getManyToMany(string name){
		local.def = manyToMany();
		for(local.manyInfo in local.def){
			if(local.manyInfo.name IS arguments.name){
				return local.manyInfo;
			}
		}
		return false;
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