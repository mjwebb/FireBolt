// GENERATED FILE DO NOT EDIT
component{
	this.config = {
		dsn:"test",
		flavour:"MSSQL",
		schemaName:"default",
		version:"Microsoft SQL Server",
		tables: {
			tbl_relation: {
				table:"tbl_relation",
				pk:"relation_id",
				cols:[
					{
						default:0,
						size:10,
						isNullable:0,
						name:"relation_id",
						cfDataType:"numeric",
						type:"int",
						pk:true,
						cfSQLDataType:"cf_sql_integer"
					},
					{
						default:"",
						size:50,
						isNullable:1,
						name:"relationName",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					},
					{
						default:"",
						size:2147483647,
						isNullable:1,
						name:"relationBody",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					}
				]
			},
			tbl_test: {
				table:"tbl_test",
				pk:"test_id",
				cols:[
					{
						default:0,
						size:10,
						isNullable:0,
						name:"test_id",
						cfDataType:"numeric",
						type:"int",
						pk:true,
						cfSQLDataType:"cf_sql_integer"
					},
					{
						default:"",
						size:50,
						isNullable:1,
						name:"name",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					},
					{
						default:false,
						size:1,
						isNullable:1,
						name:"bool",
						cfDataType:"boolean",
						type:"bit",
						cfSQLDataType:"cf_sql_bit"
					},
					{
						default:now(),
						size:23,
						isNullable:1,
						name:"startDate",
						cfDataType:"date",
						type:"datetime",
						cfSQLDataType:"cf_sql_timestamp"
					},
					{
						default:"",
						size:2147483647,
						isNullable:1,
						name:"notes",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					},
					{
						default:0,
						size:10,
						isNullable:1,
						name:"relationID",
						cfDataType:"numeric",
						type:"int",
						cfSQLDataType:"cf_sql_integer"
					}
				]
			},
			rel_category_in_test: {
				table:"rel_category_in_test",
				pk:"",
				cols:[
					{
						default:0,
						size:10,
						isNullable:1,
						name:"testID",
						cfDataType:"numeric",
						type:"int",
						cfSQLDataType:"cf_sql_integer"
					},
					{
						default:0,
						size:10,
						isNullable:1,
						name:"categoryID",
						cfDataType:"numeric",
						type:"int",
						cfSQLDataType:"cf_sql_integer"
					}
				]
			},
			rel_category_in_relation: {
				table:"rel_category_in_relation",
				pk:"",
				cols:[
					{
						default:0,
						size:10,
						isNullable:1,
						name:"relationID",
						cfDataType:"numeric",
						type:"int",
						cfSQLDataType:"cf_sql_integer"
					},
					{
						default:0,
						size:10,
						isNullable:1,
						name:"catgoryID",
						cfDataType:"numeric",
						type:"int",
						cfSQLDataType:"cf_sql_integer"
					}
				]
			},
			tbl_category: {
				table:"tbl_category",
				pk:"category_id",
				cols:[
					{
						default:0,
						size:10,
						isNullable:0,
						name:"category_id",
						cfDataType:"numeric",
						type:"int",
						pk:true,
						cfSQLDataType:"cf_sql_integer"
					},
					{
						default:"",
						size:50,
						isNullable:1,
						name:"categoryTitle",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					},
					{
						default:"",
						size:50,
						isNullable:1,
						name:"categoryAlias",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					},
					{
						default:"",
						size:200,
						isNullable:1,
						name:"categoryValue",
						cfDataType:"string",
						type:"nvarchar",
						cfSQLDataType:"cf_sql_varchar"
					},
					{
						default:0,
						size:10,
						isNullable:1,
						name:"categoryOrderKey",
						cfDataType:"numeric",
						type:"int",
						cfSQLDataType:"cf_sql_integer"
					}
				]
			}
		}
	};
}