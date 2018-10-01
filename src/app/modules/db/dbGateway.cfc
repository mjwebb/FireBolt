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

	public function qb(){
		return getFB().getObject("QueryBuilder@qb");
	}

	public void function readConfig(){
		local.configName = "_" & replace(listLast(getMetaData(this).name, "."), "Gateway", "") & "Config";
		variables.configObject = new "#local.configName#"();
	}

	public any function getConfig(){
		return variables.configObject.definition;
	}

	public query function getAll(){
		return qb()
			.from(getConfig().table)
			.get(options:{datasource:getDSN()});
	}

	public query function get(any pkValue){
		return qb()
			.from(getConfig().table)
			.where(getConfig().pk, "=", arguments.pkValue)
			.get(options:{datasource:getDSN()});
	}

	/**
	* @hint query syntax DSL
	*/
	public struct function from(string tableName){
		var declaration = {
			q: {
				tableName: arguments.tableName,
				where: "",
				params: [],
				joins: [],
				cols: "*",
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
			whereLike: function(string col, string term){

			},
			withParams: function(array params){
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
			}
		});

		return declaration;
	}

	/**
	* @hint convet a DSL struct to an SQL string
	*/
	public string function toSQL(struct q){
		local.qData = arguments.q.q;
		savecontent variable="local.sql"{
			writeOutput("SELECT #local.qData.cols# FROM #local.qData.tableName#");
			if(len(local.qData.where)){
				writeOutput(" WHERE #local.qData.where#");
			}
			if(len(local.qData.orderBy)){
				writeOutput(" ORDER BY #local.qData.orderBy#");
			}
		}

		return local.sql;
	}

}