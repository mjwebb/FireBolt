component output="false" accessors="true" extends="FireBolt.controller" {


	property name="session" inject="sessionService@common";

	/**	
	*/
	public function get(){
		
		var data = {
			session: getSession()
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