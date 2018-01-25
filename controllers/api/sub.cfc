component output="false" extends="FireBolt.controller" {

	
	/**
	* @verbs GET
	* **/
	public function get(string name){
		response().setBody({
			"api": "sub-response",
			"name": arguments.name
		});
	}

	/**
	* @verbs GET
	* **/
	public function test(){
		response().setBody({
			"api": "response",
			"method": "test"
		});
	}
	
}