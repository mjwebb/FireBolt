component output="false" extends="FireBolt.controller" {

	/**
	* **/
	public function get(){
		response().setBody({
			"api": "response"
		});
	}

	/**
	* **/
	public function get404(){
		response().setBody({
			"error": "method not found"
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