component accessors="true"{

	property name="FB" inject="framework";
	property name="dsn" inject="setting:modules.db.dsn";

	/**
	* @hint constructor
	*/
	public function init(){
		return this;
	}




}