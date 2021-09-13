public with sharing class CF_IPGeocoder { 
    /*public static CF_IPLookup__c createOrUpdateIPLookup(String ipAddress, Boolean inTrigger) {
      if (ipAddress == null) {
        return null;
      }
      
      List<CF_IPLookup__c> results = [SELECT id, name, ip__c, country_code__c, country_name__c, region_code__c, region_name__c, city__c, zip_code__c, time_zone__c, metro_code__c, location__latitude__s, location__longitude__s, Last_Refreshed_At__c FROM CF_IPLookup__c WHERE ip__c = :ipAddress LIMIT 1];
      CF_IPLookup__c lu = null;
       
      if (results.size() > 0) {
        lu = results[0];
      }
      else {
        lu = new CF_IPLookup__c();
      } 
      
      lu.name = ipAddress;
      lu.ip__c = ipAddress;
      
      if (inTrigger == false) {
        Boolean result = CF_IPGeocoder.loadAndUpdateLookup(ipAddress, lu);
        
        if (result == false) {
          return null;
        } 
      }
      
      upsert lu;
      
      if (inTrigger == true) {
        if ( lu.Last_Refreshed_At__c == null || (lu.Last_Refreshed_At__c != null && lu.Last_Refreshed_At__c < DateTime.now().addDays(-1) ) ) {
          CF_IPGeocoder.loadAndUpdateLookupFuture(ipAddress); 
        }
          
      }
      
      return lu;
    }
    
    @future(callout=true)
    public static void loadAndUpdateLookupFuture(String ipAddress) {
      CF_IPGeocoder.createOrUpdateIPLookup(ipAddress, false);
    }
    
    public static Boolean loadAndUpdateLookup(String ipAddress, CF_IPLookup__c lookup) {
    if (Test.isRunningTest()) {
      return true;
    }     
      
       String url = 'https://freegeoip.net/json/' + EncodingUtil.urlEncode(ipAddress,'UTF-8');
       
       HttpRequest req= new HttpRequest();
       Http http = new Http();
       HttpResponse res = new HttpResponse();
       
       req.setMethod('GET');
       
       req.setEndpoint(url);
       
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
    
   public static void updateLookupWithJson(Map<String, Object> resp, CF_IPLookup__c l) {
       l.country_code__c = (String)resp.get('country_code');
       l.country_name__c = (String)resp.get('country_name');
       l.region_code__c = (String)resp.get('region_code');
       l.region_name__c = (String)resp.get('region_name');
       l.city__c = (String)resp.get('city');
       l.zip_code__c = (String)resp.get('zip_code');
       l.time_zone__c = (String)resp.get('time_zone');
       l.metro_code__c = (Double)resp.get('metro_code');       
       
       l.latitude__c = (Double)resp.get('latitude');
       l.longitude__c = (Double)resp.get('longitude');
     
     l.location__latitude__s  = l.latitude__c;
     l.location__longitude__s = l.longitude__c;
     
     l.Last_Refreshed_At__c = DateTime.now();
   }    
  */
}