component{



	/**
	* @hint constructor
	*/
	public any function init(any config){
		variables.config = arguments.config;
		return this;
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