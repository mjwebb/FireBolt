component{

	
	this.config = {
		dsn: {
			name: "test",
			flavour: "MSSQL"
		},
		dsn2: {
			name: "test2",
			flavour: "MSSQL"
		}
	};

	
	function configure(){

		FB().listenFor("req.start")
			.with(function(){
				FB().engine().addCFDatasource("test", {
					class: 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
					bundleName: 'mssqljdbc4',
					bundleVersion: '4.0.2206.100',
					connectionString: 'jdbc:sqlserver://localhost:1433;DATABASENAME=testData;sendStringParametersAsUnicode=true;SelectMethod=direct',
					username: 'sa',
					password: "4Adg6x12",
					connectionLimit: 100 // default:-1
				});
			});

	}
	
}