component{

	this.config = {
		paths: {
			views: "/app/views/",
			templates: "/app/templates/",
			controllers: "/app/controllers/",
			modules: "/app/modules/",
			models: "/app/models/"
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

		FB().listenFor("preQBExecute")
			.with("testModule.sampleModule.qbIntercept");
		
	}


	public void function onSessionStart(){
		
	}


	public void function onRequestStart(){
		
	}

}
