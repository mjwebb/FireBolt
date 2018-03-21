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
		modules: {},

		test: "this is a test setting",
		struct: {
			nested: "value"
		}
	};

}
