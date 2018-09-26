component accessors="true"{

	property name="dsn" inject="setting:modules.db.dsn";

	/**
	* @hint constructor
	*/
	public function init(string dsn){
		variables.dsn = arguments.dsn
		return this;
	}


}