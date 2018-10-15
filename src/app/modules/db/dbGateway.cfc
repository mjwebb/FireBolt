component accessors="true"{

	property name="FB" inject="framework";
	property name="dsn" inject="setting:modules.db.dsn.name";
	property name="flavour" inject="setting:modules.db.dsn.flavour";

	/**
	* @hint constructor
	*/
	public function init(string dsn){
		variables.dsn = arguments.dsn;
		variables.config = new db.dbConfigReader(getMetaData(this).name);
		return this;
	}

	public any function getConfig(){
		return variables.config.getConfig();
	}

	public any function getSQLWriter(){
		if(!structKeyExists(variables, "SQLWriter")){
			local.type = "baseSQL";
			if(len(getFlavour())){
				local.type = getFlavour();
			}
			variables.SQLWriter = createObject("component", "flavour.#local.type#").init(variables.config);
		}
		return variables.SQLWriter;
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
		local.sql = getSQLWriter().toSQL(arguments.declaration);
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
					if(variables.config.isColumnDefined(local.key)){
						if(isStruct(local.value)){
							arguments.params[local.key].cfsqltype = variables.config.getColumn(local.key).cfSQLDataType;
						}else{
							arguments.params[local.key] = {
								value: local.value,
								cfsqltype: variables.config.getColumn(local.key).cfSQLDataType
							};
						}
					}else if(local.key IS "pk"){
						if(isStruct(local.value)){
							arguments.params[local.key].cfsqltype = variables.config.getConfig().pk.cfSQLDataType;
						}else{
							arguments.params[local.key] = {
								value: local.value,
								cfsqltype: variables.config.getConfig().pk.cfSQLDataType
							};
						}
					}
				}
			}
		}
		return arguments.params;
	}

	

}
