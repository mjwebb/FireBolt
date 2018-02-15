component output="false" extends="FireBolt.controller" {

	
	/**
	* @verbs GET
	* **/
	public function get(string name){
		setResponseBody({
			"api": "sub-response",
			"name": arguments.name
		});
	}

	/**
	* @verbs GET
	* **/
	public function test(){
		setResponseBody({
			"api": "response",
			"method": "test"
		});
	}
	
}