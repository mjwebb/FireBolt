/**
* This is the main configuration file for the FireBolt framework
* Configuration options get added to the main config struct. 
* The only required items are the paths with the paths key - views, templates, controllers, modules and models
* If environment variables are used, they can be included in this using the prefix env: - eg, env:DSN
* <p>
* Application lifecycle event handlers are also included here - onApplicationStart, onSessionStart, onRequestStart
*/

component{

	this.config = {
		paths: {
			views: "/app/views/",
			templates: "/app/templates/",
			controllers: "/app/controllers/",
			modules: "/app/modules/",
			models: "/app/models/"
		},

		session: {
			sessionLength: createTimeSpan(0,0,2,0),
			isLazy: true
		},

		env:{
			test: "env:DB_TEST",
			invalid: "env:DOESNOTEXIST"
		},

		siteName: "FireBolt",
		modules: {}, // 

		test: "this is a test setting",
		struct: {
			nested: "value"
		}
	};

	/**
	* Runs when the application starts and can be used to configure modules, event listeners and aspect concerns using
	* their respective DSL syntaxes
	*/
	public void function onApplicationStart(){
		//this.FireBolt["wirebox"] = new wirebox.system.ioc.Injector("app.config.wirebox");

		// define query builder manually
		//local.qbGrammar = this.FireBolt.getObject("MSSQLGrammar@qb");
		//local.qbGrammar.setInterceptorService(this.FireBolt.getEventService());
		//local.qb = this.FireBolt.getObject("QueryBuilder@qb", {grammar: local.qbGrammar});

		/*
		this.FireBolt.registerMapping("qb.models.Grammars.MSSQLGrammar", "MSSQLGrammar@qb", [], [{
			name: "InterceptorService",
			ref: "framework"
		}]);

		local.qbInitArgs = [
			{
				name: "grammar",
				ref: "MSSQLGrammar@qb"
			}
		];

		this.FireBolt.registerMapping("qb.models.Query.QueryBuilder", "QueryBuilder@qb", local.qbInitArgs, [], false);
		*/

		// register QueryBuilder using DSL syntax
		FB().register("qb.models.Grammars.MSSQLGrammar")
			.as("MSSQLGrammar@qb")
			.withProperty(name:"InterceptorService", ref:"framework");

		FB().register("qb.models.Query.QueryBuilder")
			.as("QueryBuilder@qb")
			.withInitArg(name:"grammar", ref:"MSSQLGrammar@qb")
			.asTransient();

		FB().register("qb.models.Schema.SchemaBuilder")
			.as("SchemaBuilder@qb")
			.withInitArg(name:"grammar", ref:"MSSQLGrammar@qb")
			.asTransient();

		FB().listenFor("preQBExecute")
			.with("testModule.sampleModule.qbIntercept");


		
		
	}

	/**
	* Called at the start of a user session
	*/
	public void function onSessionStart(){
		
	}

	/**
	* Called at the start of every request
	*/ 
	public void function onRequestStart(){
		
		/*FB().engine().addCFDatasource("test", {
			class: 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
			bundleName: 'mssqljdbc4',
			bundleVersion: '4.0.2206.100',
			connectionString: 'jdbc:sqlserver://localhost:1433;DATABASENAME=testData;sendStringParametersAsUnicode=true;SelectMethod=direct',
			username: 'sa',
			password: "4Adg6x12",
			connectionLimit: 100 // default:-1
		});*/

	}

}
