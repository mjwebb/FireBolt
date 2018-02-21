component output="false" extends="FireBolt.controller" {

	/**
	* **/
	public function get(){
		setResponseBody({
			"api": "response"
		});
	}

	/**
	* **/
	public function do404(){
		setResponseBody({
			"error": "method not found"
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
	

	/**
	* @verbs GET
	* @permissions adminUser
	* **/
	public function secure(){
		setResponseBody({
			"api": "response",
			"method": "secure"
		});
	}
}