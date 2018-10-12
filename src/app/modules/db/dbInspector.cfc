component accessors="true"{

	/**
	* @hint constructor
	*/
	public function init(){
		return this;
	}

	/**
	* @hint inspects a database table
	*/
	public struct function inspectTable(string dsn, string tableName){

		cfdbinfo(
			datasource=arguments.dsn,
			type="columns",
			table=arguments.tableName,
			name="local.qTable");

		local.schema = {
			"cols": [],
			"pk": "",
			"table": arguments.tableName
		};

		for(local.col in local.qTable){
			
		
			local.colData = {
				"name": local.col.column_name,
				"type": listFirst(local.col.type_name, " "),
				"size": local.col.column_size,
				"isNullable": local.col.nullable,
				"cfSQLDataType": getCFSQLDataType(local.col.type_name),
				"cfDataType": getCFDataType(local.col.type_name),
				"default": getDefaultForDataType(getCFDataType(local.col.type_name))
			};

			if(local.col.is_primaryKey){
				local.schema.pk = local.col.column_name;
				local.colData["pk"] = true;
			}

			arrayAppend(local.schema.cols, local.colData);
		}

		return local.schema;
	}


	/**
	* @hint returns the mapped CFSQLDatatype for a given column data type
	*/
	public string function getCFSQLDataType(string datatype){

		arguments.datatype = listFirst(arguments.datatype, " ");

		switch(arguments.datatype){
			case "bigint":
				return "cf_sql_bigint";
			case "binary":
				return "cf_sql_binary";
			case "bit":
				return "cf_sql_bit";
			case "char":
				return "cf_sql_char";
			case "datetime":
				return "cf_sql_timestamp";
			case "decimal": case "double":
				return "cf_sql_decimal";
			case "float":
				return "cf_sql_float";
			case "image":
				return "cf_sql_longvarbinary";
			case "int": case "counter": case "integer":
				return "cf_sql_integer";
			case "money":
				return "cf_sql_money";
			case "nchar":
				return "cf_sql_char";
			case "ntext": case "longchar":
				return "cf_sql_clob";
			case "numeric":
				return "cf_sql_varchar";
			case "nvarchar": case "guid":
				return "cf_sql_varchar";
			case "real":
				return "cf_sql_real";
			case "smalldatetime":
				return "cf_sql_timestamp";
			case "smallint":
				return "cf_sql_smallint";
			case "smallmoney":
				return "cf_sql_decimal";
			case "sysname":
				return "cf_sql_varchar";
			case "text":
				return "cf_sql_clob";
			case "timestamp":
				return "cf_sql_timestamp";
			case "tinyint":
				return "cf_sql_tinyint";
			case "uniqueidentifier":
				return "cf_sql_char";
			case "varbinary":
				return "cf_sql_varbinary";
			case "varchar":
				return "cf_sql_varchar";
			case "xml":
				return "cf_sql_clob";
		}

		return arguments.datatype;
	}


	/**
	* @hint returns a CF datatype for a given column dataType
	*/
	public string function getCFDataType(string datatype){

		arguments.datatype = listFirst(arguments.datatype, " ");

		switch(arguments.datatype){
			case "bigint":
				return "numeric";
			case "binary":
				return "binary";
			case "bit":
				return "boolean";
			case "char":
				return "string";
			case "datetime":
				return "date";
			case "decimal": case "double":
				return "numeric";
			case "float":
				return "numeric";
			case "image":
				return "binary";
			case "int": case "counter": case "integer":
				return "numeric";
			case "money":
				return "numeric";
			case "nchar":
				return "string";
			case "ntext": case "longchar":
				return "string";
			case "numeric":
				return "numeric";
			case "nvarchar": case "guid":
				return "string";
			case "real":
				return "numeric";
			case "smalldatetime":
				return "date";
			case "smallint":
				return "numeric";
			case "smallmoney":
				return "numeric";
			case "text":
				return "string";
			case "timestamp":
				return "numeric";
			case "tinyint":
				return "numeric";
			case "uniqueidentifier":
				return "string";
			case "varbinary":
				return "binary";
			case "varchar":
				return "string";
		}

		return arguments.datatype;
	}


	public any function getDefaultForDataType(string CFDataType){
		switch(arguments.CFDataType){
			case "string":
				return """""";
			case "numeric":
				return 0;
			case "boolean":
				return false;
			case "date":
				return "now()";
		}

		return """""";
	}

	
}