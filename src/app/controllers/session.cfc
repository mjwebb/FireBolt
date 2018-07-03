component output="false" accessors="true" extends="FireBolt.controller" {


	property name="sessionService" inject="sessionService@common";
	property name="securityService" inject="securityService@common";

	/**	
	*/
	public function get(){
		
		var data = {
			session: sessionService
		};

		addView("session.test", data);


		layout();
	}

	public function post(){
		get();
	}

	
	public string function getSessionID(){

	}


	public void function setSessionID(){

	}
	




}