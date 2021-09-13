global class CF_IPGeocoderBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
	global final String query;
	
   	global CF_IPGeocoderBatchable() {
    	//query = 'SELECT id, gk_current_sign_in_ip__c, IP_Lookup__c FROM CF_User__c WHERE IP_Lookup__c = null AND gk_current_sign_in_ip__c != null';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	//return Database.getQueryLocator(query);
      return null;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
       /*List<CF_User__c> usersToUpdate = new List<CF_User__c>();
       List<CF_IPLookup__c> lookupsToInsert = new List<CF_IPLookup__c>();
       Set<String> ips = new Set<String>();
       
       // Create accounts for organizations
       for(sObject s : scope) {
       		CF_User__c user = (CF_User__c)s; 
       		ips.add(user.gk_current_sign_in_ip__c);
       }
       	
       List<CF_IPLookup__c> lookups = [SELECT id, ip__c FROM CF_IPLookup__c WHERE ip__c IN :ips];	
       
  	   Map<String, CF_IPLookup__c> ipToLookup = new Map<String, CF_IPLookup__c>();
	   
	   for (CF_IPLookup__c l : lookups) {
	    	ipToLookup.put(l.ip__c, l); 
	   }       
       
       Set<String>lookedUpIps = new Set<String>();
       
       for(sObject s : scope) {		
       		CF_User__c user = (CF_User__c)s; 
       		CF_IPLookup__c lu = ipToLookup.get(user.gk_current_sign_in_ip__c);
       		
       		if (lu == null && lookedUpIps.contains(user.gk_current_sign_in_ip__c) == false) {
       			lu = new CF_IPLookup__c();
	       		lu.name = user.gk_current_sign_in_ip__c;
	    		lu.ip__c = user.gk_current_sign_in_ip__c;
	    		CF_IPGeocoder.loadAndUpdateLookup(user.gk_current_sign_in_ip__c, lu);
	    		lookupsToInsert.add(lu); 
	    		lookedUpIps.add(lu.ip__c);      			
       		}
       		
       		usersToUpdate.add(user);
       }  
     	
       insert lookupsToInsert;
       
	   for (CF_IPLookup__c  l : lookupsToInsert) {
	    	ipToLookup.put(l.ip__c, l); 
	   }          
       
       
       for (CF_User__c user : usersToUpdate) {
       		user.IP_Lookup__c = ipToLookup.get(user.gk_current_sign_in_ip__c).id;
       }
       
       update usersToUpdate;
       */
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	//AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
 
	}
}