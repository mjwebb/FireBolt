component accessors="true" extends="db.dbService"{

	property name="FB" inject="framework";
	
	
	public function getUser(){
		return getFB().getObject("UserBean");
	}


}