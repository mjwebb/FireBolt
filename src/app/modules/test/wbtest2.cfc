component singleton{

	variables.req = "";
	variables.startTime = now();
	
	/**
	* @hint constructor
	*/
	public function init(req){
		variables.req = arguments.req;
		return this;
	}

	
	public any function hello(){
		return variables.startTime;
	}



}