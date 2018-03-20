component accessors="true"{

	property name="sampleDep" inject="testModule.sampleModule";

	/**
	* @hint constructor
	*/
	public dep function init(){
		return this;
	}

	
	public string function hello(){
		return "from dependancy";
	}

	public any function world(){
		return getSampleDep().world();
	}


}