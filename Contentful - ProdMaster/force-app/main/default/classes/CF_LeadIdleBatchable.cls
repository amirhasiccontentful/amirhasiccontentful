global class CF_LeadIdleBatchable implements Database.Batchable<sObject> {  
	global final String query;
	
   	global CF_LeadIdleBatchable() {
   		// do not count changes to the lead itself, or it will never be idle (totango updates etc.)   		
    	// query = 'SELECT id, status, Idle_Reason__c FROM Lead WHERE IsConverted = false AND status IN (\'Open\', \'Contacted\', \'Conversation\', \'Qualified\', \'Accepted\') AND (LastModifiedDate < N_DAYS_AGO:30 AND (LastActivityDate = null OR LastActivityDate < N_DAYS_AGO:30))';
    	query = 'SELECT id, status, Idle_Reason__c FROM Lead WHERE IsConverted = false AND status IN (\'Open\', \'Contacted\', \'Conversation\', \'Qualified\', \'Accepted\') AND ( (LastActivityDate != null AND LastActivityDate < N_DAYS_AGO:30) OR (LastActivityDate = null AND CreatedDate < N_DAYS_AGO:30) )';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
    /*   List<Lead> leadsToUpdate = new List<Lead>();
              
       for(sObject s : scope) {
       		Lead lead = (Lead)s;
       		
       		System.debug('Archiving lead: ' + lead.id);
       		lead.status = 'Idle';
       		lead.Idle_Reason__c = '30 day inactivity';
       		
       		leadsToUpdate.add(lead);
       }
                  
       update leadsToUpdate;*/
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