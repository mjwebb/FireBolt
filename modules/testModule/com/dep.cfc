component{

	
	variables.sapleDep;

	/**
	* @hint constructor
	* **/
	public dep function init(){
		return this;
	}

	/**
	* @FB:inject true
	* **/
	public void function circularDep(required testModule.sampleModule dep){
		variables.sapleDep = arguments.dep;
	}
	
	public string function hello(){
		return "from dependancy";
	}

	public any function world(){
		return variables.sapleDep;
	}


}