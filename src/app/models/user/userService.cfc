component accessors="true" extends="db.dbService"{

		
	public function getUser(){
		return getFB().getObject("UserBean");
	}


}