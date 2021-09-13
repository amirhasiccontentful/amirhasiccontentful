global class AccountDateMQL_Contact_Batchable implements Database.Batchable<sObject> {
	global final String query;
	
   	global AccountDateMQL_Contact_Batchable() {
        
    	query = 'SELECT AccountId, Date_MQL__c FROM Contact WHERE Date_MQL__c != null';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Contact> scope) {
       	
        Set<Id> scopedAccountIds = new Set<Id>();
  		
        for(Contact con : scope){
           	scopedAccountIds.add(con.AccountId);
        }
        
        List<AggregateResult> scopedContacts = [SELECT AccountId acc, min(Date_mql__c) minmql
               									FROM Contact WHERE Date_mql__c != null
               									group by AccountId];
     	
        if(!scopedAccountIds.isEmpty()){
            new AccountDateMQL().earliestAccountMQLdate(scopedAccountIds, scopedContacts);
        }
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}