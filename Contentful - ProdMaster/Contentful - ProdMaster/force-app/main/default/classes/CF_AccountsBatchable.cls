// Create SFDC Accounts for all paying CF-Organizations

// Use Execute Anonymous in Eclipse to start the batch job:
// CF_AccountsBatchable batchable = new CF_AccountsBatchable();
// ID batchprocessid = Database.executeBatch(batchable);

global class CF_AccountsBatchable implements Database.Batchable<sObject> {
	global final String query;
	
   	global CF_AccountsBatchable() {
    	query = 'SELECT id, gk_name__c, Account__c FROM CF_Organization__c WHERE (gk_revenued_at__c != null OR mrr_0__c = true) AND Account__c = null';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
       List<CF_Organization__c> organizations = new List<CF_Organization__c>();
       List<Contact> contactsToCreate = new List<Contact>();
       
       // Create accounts for organizations
       for(sObject s : scope) {
       		CF_Organization__c org = (CF_Organization__c)s; 
       		organizations.add(org);
       }  
     
       CF_Organization.createAccountsAndContactsForOrganizations(organizations, true);
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    	
		// Send an email to the Apex job's submitter
		//   notifying of job completion.
		//Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//String[] toAddresses = new String[] {a.CreatedBy.Email};
		//mail.setToAddresses(toAddresses);
		//mail.setSubject('Paid Account Creation Status: ' + a.Status);
		//mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
		//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}