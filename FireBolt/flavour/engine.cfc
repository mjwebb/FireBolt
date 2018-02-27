component{


	/**
	* @hint constructor
	*/
	public any function init(){
		
		if(server.coldfusion.productname IS "Lucee"){
			return new engineHelperLucee();
		}else{
			return new engineHelperACF();
		}

	}


	
}