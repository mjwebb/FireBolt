component output="false" extends="FireBolt.controller" {

	/**
	*/
	public function get(){
		return {
			"api": "response"
		};
		/*respondWith({
			"api": "response"
		});*/
	}

	/**
	*/
	public function do404(){
		return {
			"error": "method not found"
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
	

	/**
	* @verbs GET
	* @permissions adminUser
	*/
	public function secure(){
		return {
			"api": "response",
			"method": "secure"
		};
	}
}