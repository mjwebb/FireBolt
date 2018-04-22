/**
* Configures wirebox for use within FireBolt
* <p>
* Within the FireBolt onApplicationStart wirebox can be defined as follows:
* <p>
* FB()["wirebox"] = new wirebox.system.ioc.Injector("app.config.wirebox");
*/

component extends="wirebox.system.ioc.config.Binder"{

	function configure(){
		wireBox = {
			scanLocations = ["app.models", "app.modules"]
		};

		mapFireBoltAliases();
	}


	function mapFireBoltAliases(){
		local.factory = application.FireBolt.getFactoryService();
		local.aliases = local.factory.getAliases();
		for(local.alias in local.aliases){
			map(local.alias).to(local.aliases[local.alias]);
		}

		map("framework").toProvider(function(){
			return application.FireBolt;
		});
	}

}
