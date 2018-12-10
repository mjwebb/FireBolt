component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function index(){
		response().setStatus(response().codes.NOTFOUND);
		return {
			"error": "not found"
		};
	}

}