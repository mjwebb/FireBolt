component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function get(){
		respondWith({
			"error": "not found"
		}).setStatus(response().codes.NOTFOUND);
	}

}