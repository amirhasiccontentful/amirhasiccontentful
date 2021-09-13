global class ContentfulCertifiedProfessionals implements Database.Batchable<sObject> {
	global final String query;
	global List<Account> lstAccounts;
    global Integer scopedNumberOfDays;
   	global ContentfulCertifiedProfessionals() {
        scopedNumberOfDays = Integer.valueOf(Label.Contentful_Certified_Professionals_CCP);
        query = 'SELECT Id, AccountId, Certified__c FROM Contact WHERE Certified__c = TRUE AND LastModifiedDate = LAST_N_DAYS:' + scopedNumberOfDays + ' ORDER BY AccountId';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Contact> scope) {
       	
        lstAccounts = new List<Account>();
        Set<Id> scopedAccounts = new Set<Id>();
        
        for(Contact c : scope){
            scopedAccounts.add(c.AccountId);
        }
        
        for(Account acc : [SELECT Id, (SELECT Id FROM Contacts WHERE Certified__c = TRUE) FROM Account WHERE Id IN :scopedAccounts OR Contentful_Certified_Professionals_CCP__c > 0]){
           	
            acc.Contentful_Certified_Professionals_CCP__c = 0;
            acc.Certified__c = FALSE;
            
            if(!acc.Contacts.isEmpty()){
                Integer certifiedCount = 0;
                
                for (Contact c : acc.Contacts) {
                    certifiedCount++;
                }
                acc.Contentful_Certified_Professionals_CCP__c = certifiedCount;
                acc.Certified__c = TRUE;
                lstAccounts.add(acc);
            }
        }
        
        if(!lstAccounts.isEmpty()) update lstAccounts;
        
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}