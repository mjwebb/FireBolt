component output="false" accessors="true" extends="FireBolt.controller" {


	/**	
	*/
	public function get(){
		
		var data = {
			
		};

		addView("db.test", data);


		layout();
	}

	

	/**
	* @verbs GET
	*/
	public function builder(string models=""){

		if(len(arguments.models)){
			// build models

		}else{
			// list models

			addContent("DB Builder");
			addContent(dump(cgi));

		}

		layout();
	}
	




}