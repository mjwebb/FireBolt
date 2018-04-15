component output="false" extends="FireBolt.controller" {

	/**
	*/
	public function get(){
		respondWith({
			"api": "response"
		});
	}

	/**
	*/
	public function do404(){
		respondWith({
			"error": "method not found"
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
	

	/**
	* @verbs GET
	* @permissions adminUser
	*/
	public function secure(){
		respondWith({
			"api": "response",
			"method": "secure"
		});
	}
}