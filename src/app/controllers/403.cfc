component output="false" extends="FireBolt.controller" {

	/**
	* @verbs *
	*/
	public function index(){
		//addContent("<p>FORBIDDEN</p>");
		//layout();

		respondWith("<h1>Forbidden</h1>").setStatus(response().codes.FORBIDDEN);
	}

	
}