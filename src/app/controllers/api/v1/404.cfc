component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function get(){
		setResponseBody({
			"error": "not found"
		}).setStatus(response().codes.NOTFOUND);
	}

}