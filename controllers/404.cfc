component output="false" extends="FireBolt.controller" {

	/**	
	* **/
	public function do404(){
		addContent("<p>PAGE NOT FOUND</p>");
		layout();
	}

	
}