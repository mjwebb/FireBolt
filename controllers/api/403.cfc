component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function get(){
		setResponseBody({
			"error": "forbidden"
		}).setStatus(response().codes.FORBIDDEN);
	}



	
}