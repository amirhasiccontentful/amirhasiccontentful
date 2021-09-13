global class OrganizationIsRevenued_Batchable implements Database.Batchable<sObject> {
	global final String query;
	
   	global OrganizationIsRevenued_Batchable() {
        
    	query = 'SELECT Id, Billing_Account_Organization_Key__c FROM Zuora__Subscription__c WHERE Zuora__Status__c = \'Active\' AND Zuora__MRR__c > 0';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
       	
        Set<String> scopedOrgkeys = new Set<String>();
        
        for(Zuora__Subscription__c sub : scope){
            if(sub.Billing_Account_Organization_Key__c != null){
                scopedOrgkeys.add(sub.Billing_Account_Organization_Key__c);
            }
        }
     	
        if(!scopedOrgkeys.isEmpty()){
            new OrganizationIsRevenued().setOfRevenuedOrgKeys(scopedOrgkeys);
        }
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}