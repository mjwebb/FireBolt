component output="false" accessors="true" extends="FireBolt.controller" {

	property name="db" inject="db@db";

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

			addContent("DB Builder<br />");
			addContent("DSNs: " & arrayToList(db.datasourceManager().getDSNNames()));

		}

		layout();
	}
	




}