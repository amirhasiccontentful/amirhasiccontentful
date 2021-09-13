global class AccountDateMQL_Lead_Batchable implements Database.Batchable<sObject> {
	global final String query;
	
   	global AccountDateMQL_Lead_Batchable() {
        query = 'SELECT LeanData__Reporting_Matched_Account__c, Date_MQL__c FROM Lead WHERE Date_MQL__c != null AND LeanData__Reporting_Matched_Account__c != null';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Lead> scope) {
       	
        Set<Id> scopedAccountIds = new Set<Id>();
  		
        for(Lead ld : scope){
           	scopedAccountIds.add(ld.LeanData__Reporting_Matched_Account__c);
        }
        
        List<AggregateResult> scopedLeads = [SELECT LeanData__Reporting_Matched_Account__c acc, min(Date_mql__c) minmql
               									FROM Lead WHERE LeanData__Reporting_Matched_Account__c != null 
                                             	AND Date_mql__c != null
               									GROUP BY LeanData__Reporting_Matched_Account__c];
     	
        if(!scopedAccountIds.isEmpty()){
            new AccountDateMQL().earliestAccountMQLdate(scopedAccountIds, scopedLeads);
        }
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}