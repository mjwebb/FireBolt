component output="false" accessors="true" extends="FireBolt.controller" {


	property name="sessionService" inject="sessionService@common";

	/**	
	*/
	public function get(){
		
		var data = {
			session: getSessionService()
		};

		addView("session.test", data);


		layout();
	}

	
	public string function getSessionID(){

	}


	public void function setSessionID(){

	}
	




}