// Zendesk is always creating contacts for a new ticket, we don't want that so we just delete them again
global class CF_ContactCleanupZendeskBatchable implements Database.Batchable<sObject> {
	global final String query;
	
   	global CF_ContactCleanupZendeskBatchable() {
    	query = 'SELECT id, Zendesk__zendesk_id__c FROM Contact WHERE Zendesk__zendesk_id__c != null AND AccountId = null AND CF_User__c = null';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
       List<Contact> contactsToDelete = new List<Contact>();
              
       for(sObject s : scope) {
       		Contact contact = (Contact)s;
       		
       		System.debug('Deleting contact which was created from Zendesk: ' + contact.id);
       		contactsToDelete.add(contact);
       }
                  
       delete contactsToDelete;
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