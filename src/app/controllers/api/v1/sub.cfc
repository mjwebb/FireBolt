component output="false" extends="FireBolt.controller" {

	
	/**
	* @verbs GET
	*/
	public function get(string name="NOT SET"){
		return {
			"api": "sub-response",
			"name": arguments.name
		};
	}

	/**
	* @verbs GET
	*/
	public function test(){
		return {
			"api": "response",
			"method": "test"
		};
	}
	
}