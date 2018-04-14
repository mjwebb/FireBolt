component accessors="true"{

	property name="FB" inject="framework";
	
	/**
	* @hint constructor
	*/
	public function init(){
		return this;	
	}

	
	public function getUser(){
		return getFB().getObject("UserBean");
	}


}