component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function get(){
		respondWith({
			"error": "forbidden"
		}).setStatus(response().codes.FORBIDDEN);
	}

}