component accessors="true"{

	property name="FB" inject="framework";
	property name="dsn" inject="setting:modules.db.dsn.name";
	property name="flavour" inject="setting:modules.db.dsn.flavour";

	/**
	* @hint constructor
	*/
	public function init(string dsn){
		variables.dsn = arguments.dsn;
		readConfig();
		return this;
	}

	

	public void function readConfig(){
		local.configName = "_" & replace(listLast(getMetaData(this).name, "."), "Gateway", "") & "Config";
		variables.configObject = new "#local.configName#"();
		getConfig().colList = "";
		getConfig().hasPK = false;
		getConfig().colHash = {};
		for(local.col in getConfig().cols){
			getConfig().colList = listAppend(getConfig().colList, local.col.name);
			getConfig().colHash[local.col.name] = local.col;
			if(structKeyExists(local.col, "pk") AND local.col.pk){
				getConfig().pk = local.col;
				getConfig().hasPK = true;
			}
		}
	}

	public any function getConfig(){
		return variables.configObject.definition;
	}

	public struct function getColumn(string colName){
		return getConfig().colHash[arguments.colName]
	}

	public boolean function isColumnDefined(string colName){
		return structKeyExists(getConfig().colHash, arguments.colName);
	}


	/* =================================== */
	public function qb(){
		return getFB().getObject("QueryBuilder@qb");
	}

	public query function getAllQB(){
		return qb()
			.from(getConfig().table)
			.get(options:{datasource:getDSN()});
	}

	public query function getQB(any pkValue){
		return qb()
			.from(getConfig().table)
			.where(getConfig().pk, "=", arguments.pkValue)
			.get(options:{datasource:getDSN()});
	}

	public any function executeQB(any qb, struct options={}){
		local.options = {datasource:getDSN()};
		structAppend(local.options, arguments.options);
		return arguments.qb.get(options:local.options);
	}
	/* =================================== */

	public query function get(any pkValue){
		return from()
			.where(getConfig().pk.name & "= :pk")
			.withParams({
				pk: arguments.pkValue
			})
			.get(options:{datasource:getDSN()});
	}

	public query function getAll(){
		return from().get();
	}

	/**
	* @hint our default columns
	*/	
	public string function cols(){
		return getConfig().colList;
	}

	/**
	* @hint query syntax DSL
	*/
	public struct function from(string tableName=getConfig().table){
		var declaration = {
			q: {
				tableName: arguments.tableName,
				where: "",
				params: {},
				joins: [],
				cols: cols(),
				orderBy: "",
				options: {
					dsn: getDSN()
				}
			}
		};

		structAppend(declaration, {
			select: function(string cols){
				declaration.q.cols = arguments.cols;
				return declaration;
			},
			where: function(string whereClause){
				declaration.q.where = arguments.whereClause;
				return declaration;
			},
			withParams: function(any params){
				declaration.q.params = arguments.params;
				return declaration;
			},
			orderBy: function(string orderBy){
				declaration.q.orderBy = arguments.orderBy;
				return declaration;
			},
			using: function(string dsn){
				declaration.q.options.datasource = arguments.dsn;
				return declaration;
			},
			cacheFor: function(numeric cacheLength){
				declaration.q.options.cachedWithin = arguments.cacheLength;
				return declaration;
			},
			get: function(string cols="", struct options={}){
				structAppend(declaration.q.options, arguments.options);
				if(len(arguments.cols)){
					declaration.q.cols = arguments.cols;
				}
				return execute(declaration);
			}
		});

		return declaration;
	}

	/**
	* @hint executes an query from a DSL declaration
	*/
	public any function execute(struct declaration){
		local.sql = toSQL(arguments.declaration);
		local.params = processParams(arguments.declaration.q.params);
		local.q = runQuery(local.sql, arguments.declaration.q.params, arguments.declaration.q.options);
		return local.q;
	}

	/**
	* @hint executes an query from a DSL declaration
	*/
	public any function runQuery(string sql, any params, struct options={}){
		if(!structKeyExists(arguments.options, "datasource")){
			arguments.options.datasource = getDSN();
		}
		return queryExecute(arguments.sql, arguments.params, arguments.options);
	}
	
	/**
	* @hint checks parameters for sql types
	*/
	public any function processParams(any params){
		if(isStruct(arguments.params)){
			for(local.key in arguments.params){
				local.value = arguments.params[local.key];
				if((isStruct(local.value) AND NOT structKeyExists(local.value, "cfsqltype")) OR isSimpleValue(local.value)){
					if(isColumnDefined(local.key)){
						if(isStruct(local.value)){
							arguments.params[local.key].cfsqltype = getColumn(local.key).cfSQLDataType;
						}else{
							arguments.params[local.key] = {
								value: local.value,
								cfsqltype: getColumn(local.key).cfSQLDataType
							};
						}
					}else if(local.key IS "pk"){
						if(isStruct(local.value)){
							arguments.params[local.key].cfsqltype = getConfig().pk.cfSQLDataType;
						}else{
							arguments.params[local.key] = {
								value: local.value,
								cfsqltype: getConfig().pk.cfSQLDataType
							};
						}
					}
				}
			}
		}
		return arguments.params;
	}

	/**
	* @hint convet a DSL struct to an SQL string
	*/
	public string function toSQL(struct declaration){
		local.declaration = arguments.declaration.q;
		savecontent variable="local.sql"{
			writeOutput("SELECT #local.declaration.cols# FROM #local.declaration.tableName#");
			if(len(local.declaration.where)){
				writeOutput(" WHERE #local.declaration.where#");
			}
			if(len(local.declaration.orderBy)){
				writeOutput(" ORDER BY #local.declaration.orderBy#");
			}
		}

		return local.sql;
	}

}
