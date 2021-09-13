public with sharing class CF_UrlLookup {	
    public static CF_UrlLookup__c createOrUpdateUrlLookup(String url, Boolean inTrigger) {
    	if (url == null) {
    		return null;
    	} 
    	
    	String checksum = CF_UrlLookup.checksumForUrl(url);
    	
    	List<CF_UrlLookup__c> results = [SELECT id, name, url__c, url_checksum__c FROM CF_UrlLookup__c  WHERE url_checksum__c = :checksum LIMIT 1];
    	CF_UrlLookup__c lu = null;
    	 
    	if (results.size() > 0) {
    		lu = results[0];
    	}
    	else {
    		lu = new CF_UrlLookup__c();
    	}	
    	
    	CF_UrlLookup.initLookup(lu, url);
    	
    	if (inTrigger == false) {
    		Boolean result = CF_UrlLookup.loadAndUpdateLookup(url, lu);
    		
    		if (result == false) {
    			return null;
    		}	
    	}
    	
    	upsert lu;
    	
    	if (inTrigger == true) {
    		if ( lu.Referer_Last_Refreshed_At__c == null || (lu.Referer_Last_Refreshed_At__c != null && lu.Referer_Last_Refreshed_At__c < DateTime.now().addDays(-1) ) ) {
    			CF_UrlLookup.loadAndUpdateLookupFuture(url);	
    		}	
    	}
    	
    	return lu;
    }
    
    public static void initLookup(CF_UrlLookup__c lu, String url) {
    	String checksum = CF_UrlLookup.checksumForUrl(url);
    	 
    	lu.name = url.left(79);
    	lu.url__c = url;
    	lu.url_checksum__c = checksum;
    	lu.domain__c = CF_UrlLookup.domainForUrl(url);
    	CF_UrlLookup.setCampaignFields(url, lu);    	
    }
    
    public static void setCampaignFields(String url, CF_UrlLookup__c lu) { 
    	URL ux = new System.URL(url);  
    	String query = ux.getQuery();
    	
		System.PageReference pageReference = new System.PageReference('/?' + query);
		Map<String,String> parameters = pageReference.getParameters();
		
		// http://www.test.de/path?utm_source=campaign_source&utm_medium=campaign_medium&utm_term=campaign_term&utm_content=campaign_content&utm_campaign=campaign_name
		
		lu.campaign_source__c = parameters.get('utm_source');
		lu.campaign_medium__c = parameters.get('utm_medium');
		lu.campaign_term__c = parameters.get('utm_term');
		lu.campaign_content__c = parameters.get('utm_content');
		lu.campaign_name__c = parameters.get('utm_campaign');		
    }

    public static String checksumForUrl(String url) { // URLs are longer than 255 chars and cannot search for them directly
    	String checksum = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(url)));
		return checksum;
    }
    
    public static String domainForUrl(String u) { 
    	URL ux = new System.URL(u);
    	return ux.getHost().removeStart('www.'); 
    }    
    
    @future(callout=true)
    public static void loadAndUpdateLookupFuture(String url) {
    	CF_UrlLookup.createOrUpdateUrlLookup(url, false);
    }
    
    public static Boolean loadAndUpdateLookup(String url, CF_UrlLookup__c lookup) {
		if (Test.isRunningTest()) {
			return true;
		}    	
    	
       String endpoint = 'https://referer-parser-server.appspot.com/?token=SDFzxvcWERlkjjlkjkh234&url=' + EncodingUtil.urlEncode(url,'UTF-8');
       
       HttpRequest req= new HttpRequest();
       Http http = new Http();
       HttpResponse res = new HttpResponse();
       
       req.setMethod('GET');
       
       req.setEndpoint(endpoint);
       
       try {
		  res = http.send(req);
	   } catch(System.CalloutException e) {
	     System.debug('Callout error: '+ e);
	     return false;
	   }		
		

       Map<String, Object> j = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
       updateLookupWithJson(j, lookup);
       return true;
    }
    
   public static void updateLookupWithJson(Map<String, Object> resp, CF_UrlLookup__c l) {
   	   l.referer_medium__c = (String)resp.get('medium');
   	   l.referer_search_parameter__c = (String)resp.get('search_parameter');
   	   l.referer_search_term__c = (String)resp.get('search_term');
   	   l.referer_source__c = (String)resp.get('referer');
   	   l.referer_known__c = (Boolean)resp.get('known');
   	   
	   l.Referer_Last_Refreshed_At__c = DateTime.now();
   }    
	
}