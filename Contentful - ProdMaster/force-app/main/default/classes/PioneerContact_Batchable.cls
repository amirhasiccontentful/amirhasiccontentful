global class PioneerContact_Batchable implements Database.Batchable<sObject> {
	global final String query;
	
   	global PioneerContact_Batchable() {
    	query = 'SELECT Id, Name, Pioneer_CF_User__c, Pioneer_Contact__c, (SELECT Id, Account__c, gk_created_at__c, gk_created_by_id__c FROM CF_Organizations__r WHERE gk_created_at__c != NULL AND gk_created_by_id__c != \'\' ORDER BY gk_created_at__c ASC LIMIT 1) FROM Account WHERE Id IN (SELECT Account__c FROM CF_Organization__c WHERE Account__c != null and gk_created_at__c != NULL AND gk_created_by_id__c != \'\')';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {

       //List<Account> accounts = new List<Account>();
       List<CF_Organization__c> scopedCFOrg = new List<CF_Organization__c>();
       Set<Decimal> createdByIds = new Set<Decimal>();
       
       for(sObject s : scope) {
       		Account acc = (Account)s; 
       		if(!acc.CF_Organizations__r.isEmpty()){
       			//accounts.add(acc);
       			scopedCFOrg.add(acc.CF_Organizations__r[0]);
            createdByIds.add(Decimal.valueof(acc.CF_Organizations__r[0].gk_created_by_id__c));
       		}
        }  

        if(!scopedCFOrg.isEmpty()){
        	FindPioneerContact.accountsPioneerContact(scopedCFOrg, createdByIds);
        }
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}