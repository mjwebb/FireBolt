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
	public function get404(){
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
	
}