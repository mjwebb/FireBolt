component output="false" extends="FireBolt.controller" {

	
	/**
	* @verbs GET
	*/
	public function get(string name="NOT SET"){
		respondWith({
			"api": "sub-response",
			"name": arguments.name
		});
	}

	/**
	* @verbs GET
	*/
	public function test(){
		respondWith({
			"api": "response",
			"method": "test"
		});
	}
	
}