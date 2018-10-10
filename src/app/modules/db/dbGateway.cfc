component accessors="true"{

	property name="FB" inject="framework";
	property name="dsn" inject="setting:modules.db.dsn";

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
		for(local.col in getConfig().cols){
			getConfig().colList = listAppend(getConfig().colList, local.col.name);
			if(structKeyExists(local.col, "pk") AND local.col.pk){
				getConfig().pk = local.col;
				getConfig().hasPK = true;
			}
		}
	}

	public any function getConfig(){
		return variables.configObject.definition;
	}


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

	public query function get(any pkValue){
		return from()
			.where(getConfig().pk.name & "= :pk")
			.withParams({
				pk: {
					value: arguments.pkValue,
					cfsqltype: getConfig().pk.cfsqlDataType
				}
			})
			.get(options:{datasource:getDSN()});
	}

	public query function getAll(){
		return from().get(options:{datasource:getDSN()});
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
				dsn: variables.dsn,
				cacheFor: 0
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
				declaration.q.dsn = arguments.dsn;
				return declaration;
			},
			cacheFor: function(numeric cacheLength){
				declaration.q.cacheFor = arguments.cacheLength;
				return declaration;
			},
			get: function(string cols="", struct options={}){
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
		local.q = queryExecute(local.sql, arguments.declaration.q.params, {
			datasource: variables.dsn
		});
		return local.q;
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