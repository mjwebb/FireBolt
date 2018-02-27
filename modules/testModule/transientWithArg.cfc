/**
* @FB:transient true
*/
component{

	variables.req = "";
	
	/**
	* @hint constructor
	*/
	public function init(req){
		variables.req = arguments.req;
		return this;
	}

	
	public any function hello(){
		return variables.req.duration();
	}



}