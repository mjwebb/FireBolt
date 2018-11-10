<cfscript>
	// GENERATED FILE DO NOT EDIT
	this.definition = {
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
	};
</cfscript>