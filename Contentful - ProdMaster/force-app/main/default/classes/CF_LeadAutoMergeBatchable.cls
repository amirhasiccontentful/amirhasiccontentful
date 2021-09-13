global class CF_LeadAutoMergeBatchable implements Database.Batchable<sObject>  {
	global final String query;


   	global CF_LeadAutoMergeBatchable() {
  		//query = 'SELECT id, firstname, lastname, leadSource, email, CF_Organization__c, CF_Organization__r.Account__c, CF_Organization__r.Account__r.ownerid FROM Lead WHERE LeadSource = \'App - Invited\' AND CF_Organization__r.Account__c != null AND isConverted = false';	
  		query = 'SELECT id, firstname, lastname, Lead_Source_Detail__c, leadSource, email, CF_Organization__c, CF_Organization__r.Account__c, CF_Organization__r.gk_revenued_at__c, CF_Organization__r.MRR_0__c, CF_Organization__r.Account__r.ownerid FROM Lead WHERE Lead_Source_Detail__c = \'App - Invited\' AND CF_Organization__r.Account__c != null AND (CF_Organization__r.gk_revenued_at__c != null OR CF_Organization__r.MRR_0__c = true) AND isConverted = false';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		// If the duplicate rule is an alert rule, we can try to bypass it
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        
        // Auto-merge invited users into existing accounts

        List<Contact> contacts = new List<Contact>();
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        
  	   	Set<Id> allAccountIds = new Set<Id>();
      
		for(sObject l : scope) {
			Lead lead = (Lead)l;
       		if (lead.CF_Organization__c != null && lead.CF_Organization__r.Account__c != null) {
       			allAccountIds.add(lead.CF_Organization__r.Account__c);	
       		} 
       	}            
        
        contacts = [SELECT id, name, firstname, lastname, email, accountid FROM Contact WHERE AccountId IN :allAccountIds];
        
        for (sObject l : scope) {
        	Lead lead = (Lead)l;
        	if (CF_Lead.shouldAutoMergeLead(lead) == true) {
        		// merge into account
        		Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(lead.id);
				lc.setDoNotCreateOpportunity(True);
				lc.setAccountId(lead.CF_Organization__r.Account__c);
				
				for (Contact contact : contacts) { 
					if (contact.accountid == lead.CF_Organization__r.Account__c && CF_Lead.shouldMergeLeadWithContact(lead, contact) ) {
						lc.setContactId(contact.id);	
					}
				}
				// Converted Status Chnage
				String convertedStatus = 'Converted';
				
				lc.setConvertedStatus(convertedStatus);
				lc.setSendNotificationEmail(false);
				lc.setOwnerId(lead.CF_Organization__r.Account__r.ownerid);
				
				leadsToConvert.add(lc); 
        	}
        }
        
		List<Database.LeadConvertResult> r = Database.convertLead(leadsToConvert, dml);
    	
    	for (Database.LeadConvertResult sr : r) {
	    	if(!sr.isSuccess()){
				for(Database.Error duplicateError : sr.getErrors()){
	  				System.debug('Error when auto-merging lead: ' + duplicateError.getMessage());
				}
	    	}        		
    	}
    
	}	
	
	global void finish(Database.BatchableContext BC) {
    	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
	}	
}