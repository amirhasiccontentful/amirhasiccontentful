// Database.executeBatch(new CF_UrlLookupBatchable());

global class CF_UrlLookupBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
	global final String query;
	 
   	global CF_UrlLookupBatchable() { 
    	query = 'SELECT id, gk_first_visit_url__c, gk_first_visit_referer__c, gk_last_visit_url__c, gk_last_visit_referer__c FROM CF_Organization__c';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query); 
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	   List<String> urlFields = new List<String>{'gk_first_visit_url__c', 'gk_first_visit_referer__c', 'gk_last_visit_url__c', 'gk_last_visit_referer__c'};
       Set<CF_Organization__c> organizationsToUpdate = new Set<CF_Organization__c>();
       List<CF_UrlLookup__c> lookupsToInsert = new List<CF_UrlLookup__c>();
       Map<String, CF_UrlLookup__c> lookupsToInsertMap = new Map<String, CF_UrlLookup__c>();
       Set<String> urlChecksums = new Set<String>();
       
       for(sObject s : scope) {
       		CF_Organization__c org = (CF_Organization__c)s; 
       		
       		for (String field : urlFields) {
       			String value = (String)org.get(field);
       			if (value != null && string.isBlank(value) != true) {
       				urlChecksums.add(CF_UrlLookup.checksumForUrl(value));	
       			}
       		}
       }
       	
       List<CF_UrlLookup__c> lookups = [SELECT id, name, url__c, url_checksum__c FROM CF_UrlLookup__c WHERE url_checksum__c IN :urlChecksums];	
       
  	   Map<String, CF_UrlLookup__c> urlChecksumToLookup = new Map<String, CF_UrlLookup__c>();
	   
	   for (CF_UrlLookup__c l : lookups) {
	    	urlChecksumToLookup.put(l.url_checksum__c, l); 
	   }       
       
       Set<String>lookedUpUrls = new Set<String>();
       
       for(sObject s : scope) {		
       		CF_Organization__c org = (CF_Organization__c)s; 
       		
       		for (String field : urlFields) {
	       		String url = (String)org.get(field);
	       		
	       		if (url != null && string.isBlank(url) != true  && 
	       			(url.startsWith('http:') || url.startsWith('https:'))) // only http(s), avoid app urls) 
	       		{
		       		CF_UrlLookup__c lu = urlChecksumToLookup.get(url);
		       		
		       		if (lu == null && lookedUpUrls.contains(url) == false) {
		       			lu = new CF_UrlLookup__c();
		       			
		       			CF_UrlLookup.initLookup(lu, url);
			    		CF_UrlLookup.loadAndUpdateLookup(url, lu);
			    		
			    		//lookupsToInsert.add(lu); 
			    		lookupsToInsertMap.put(lu.url_checksum__c, lu);
			    		lookedUpUrls.add(url);  
		       		}	
		       		
		       		organizationsToUpdate.add(org);       			
	       		}	       		       			
       		}
       }  

       lookupsToInsert.addAll(lookupsToInsertMap.values());
	 	
	   upsert lookupsToInsert url_checksum__c; 
     	
       //upsert lookupsToInsert url_checksum__c; 
       
	   for (CF_UrlLookup__c  l : lookupsToInsert) {
	    	urlChecksumToLookup.put(l.url_checksum__c, l); 
	   }          
       
       
       for (CF_Organization__c org : organizationsToUpdate) {
       		for (String field : urlFields) {
       			String value = (String)org.get(field);
       			if (value != null && string.isBlank(value) != true) {
	       			String checksum = CF_UrlLookup.checksumForUrl(value);
	       			CF_UrlLookup__c l = urlChecksumToLookup.get(checksum);
	       			
	       			if (l != null) {
	       				String key = field.remove('gk_').remove('__c') + '_lookup__c';
	       				org.put(key, l.id);  
	       			}       				
       			}
       		}   		
       }
       
       List<CF_Organization__c> orgs = new List<CF_Organization__c>(organizationsToUpdate);
       update orgs;
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
 
	}
}