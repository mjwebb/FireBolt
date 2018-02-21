component{

	this.config = {
		paths: {
			views: "/views/",
			templates: "/templates/",
			controllers: "/controllers/",
			modules: "/modules/"
		},

		env:{
			test: "env:DB_TEST",
			invalid: "env:DOESNOTEXIST"
		},

		siteName: "FireBolt",
		modules: {},

		test = "this is a test setting",
		struct = {
			nested = "value"
		}
	}

}
