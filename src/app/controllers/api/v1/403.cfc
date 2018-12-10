component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function index(){
		response().setStatus(response().codes.FORBIDDEN);
		return {
			"error": "forbidden"
		};
	}

}