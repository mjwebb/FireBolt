component extends="db.dbBean"{

	variables.instance = {
		"test": ""
	};
		
	public string function getFullName(){
		return trim(getForeName() & " " & getSurname());
	}


}