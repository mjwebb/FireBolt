component accessors="true"{

	property name="dsn" inject="setting:modules.db.dsn";

	/**
	* @hint constructor
	*/
	public function init(string dsn){
		variables.dsn = arguments.dsn
		return this;
	}


	/**
	* @hint query syntax DSL
	*/
	public struct function selectFrom(string tableName){
		var declaration = {
			q: {
				tableName: arguments.tableName,
				where: "",
				params: [],
				cols: "*",
				orderBy: "",
				dsn: variables.dsn,
				cacheFor: 0
			}
		};

		structAppend(declaration, {
			cols: function(string cols){
				declaration.q.cols = arguments.cols;
				return declaration;
			},
			where: function(string whereClause){
				declaration.q.where = arguments.whereClause;
				return declaration;
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