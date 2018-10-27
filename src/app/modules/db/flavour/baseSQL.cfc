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
		switch(local.declaration.type){
			case "SELECT":
				savecontent variable="local.sql"{
					writeOutput("SELECT #local.declaration.cols# FROM #local.declaration.tableName#");
					if(len(local.declaration.where)){
						writeOutput(" WHERE #local.declaration.where#");
					}
					if(len(local.declaration.orderBy)){
						writeOutput(" ORDER BY #local.declaration.orderBy#");
					}
				}
				break;
			case "UPDATE":
				savecontent variable="local.sql"{
					writeOutput("UPDATE #local.declaration.tableName# SET ");
					local.setter = [];
					for(local.col in local.declaration.cols){
						arrayAppend(local.setter, local.col.name & " = :" & local.col.name);
					}
					writeOutput(arrayToList(local.setter, ", "));
					if(len(local.declaration.where)){
						writeOutput(" WHERE #local.declaration.where#");
					}
				}
				break;
			case "INSERT": 
				savecontent variable="local.sql"{
					writeOutput("INSERT INTO #local.declaration.tableName# (");

					local.setter = [];
					local.values = [];
					for(local.col in local.declaration.cols){
						arrayAppend(local.setter, local.col.name);
						arrayAppend(local.values, ":" & local.col.name);
					}
					writeOutput(arrayToList(local.setter, ", ") & ") VALUES (" & arrayToList(local.values, ", ") & ")");
				}
				break;
		}
		

		return local.sql;
	}
	
}