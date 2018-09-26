component accessors="true"{

	property string emailAddress;
	property string foreName;
	property string surName;
	
		
	public string function getFullName(){
		return trim(getForeName() & " " & getSurname());
	}


}