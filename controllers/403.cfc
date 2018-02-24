component output="false" extends="FireBolt.controller" {

	/**	
	* **/
	public function get(){
		//addContent("<p>FORBIDDEN</p>");
		//layout();

		setResponseBody("<h1>Forbidden</h1>");
		response().setStatus(response().codes.FORBIDDEN);
	}

	
}