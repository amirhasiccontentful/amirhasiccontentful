public with sharing class CF_Organization {
	public static Account accountFromOrganization(CF_Organization__c org) {
   		Account account = new Account();	
   		       		           	
       	account.name = org.gk_name__c; 
       	account.Auto_Created_By_Self_Service_Upgrade__c = true;      		
  		// disable CF_OrganizationPayingTrigger
  		
  		return account;		
	}
		
	public static List<Account> createAccountsAndContactsForOrganizations(List<CF_Organization__c> organizations, Boolean updateOrganizations) {
		Database.DMLOptions dml = new Database.DMLOptions(); 
	    dml.DuplicateRuleHeader.AllowSave = true;
	    		
		List<Account> accountsToInsert = new List<Account>();
		List<Contact> contactsToInsert = new List<Contact>();
		List<CF_Organization__c> organizationsToUpdate = new List<CF_Organization__c>();
		
		Map<Id, Account> orgToAccountMap = new Map<Id, Account>();
		Map<Id, Contact> userToContactMap = new Map<Id, Contact>(); 
		
  	   	Set<Id> allOrganizationIds = new Set<Id>();
             	
		for (CF_Organization__c org : organizations) {
			allOrganizationIds.add(org.id);  
			Account account = CF_Organization.accountFromOrganization(org);
			
			accountsToInsert.add(account);
			organizationsToUpdate.add(org);
           	           	
           	orgToAccountMap.put(org.id, account);
		}

		Database.insert(accountsToInsert, dml);
	 	
       	List<CF_Organization_Membership__c> organizationMemberships = [SELECT Id, gk_user__c, gk_user__r.Lead__c, 
                                                                       gk_user__r.Lead__r.Subscription_Blog_digest__c, 
                                                                       gk_user__r.Lead__r.Subscription_Events__c, 
                                                                       gk_user__r.Lead__r.Subscription_Informational_Updates__c, 
                                                                       gk_user__r.Lead__r.Subscription_Newsletter__c, 
                                                                       gk_user__r.Lead__r.Subscription_Product_updates__c, 
                                                                       gk_user__r.Lead__r.Subscription_Webinars__c, 
                                                                       gk_organization__c, 
                                                                       gk_user__r.id, 
                                                                       gk_user__r.gk_first_name__c, 
                                                                       gk_user__r.gk_last_name__c, 
                                                                       gk_user__r.gk_email__c 
                                                                       FROM CF_Organization_Membership__c WHERE gk_organization__c IN :allOrganizationIds]; //  AND gk_role__c = 'owner'
        
       	for(CF_Organization_Membership__c om : organizationMemberships) {
       		Contact contact = CF_User.contactFromUser(om.gk_user__r);
       		
            if(om.gk_user__r.Lead__c != null){
                contact.Subscription_Blog_digest__c = om.gk_user__r.Lead__r.Subscription_Blog_digest__c;
                contact.Subscription_Events__c = om.gk_user__r.Lead__r.Subscription_Events__c;
                contact.Subscription_Informational_Updates__c = om.gk_user__r.Lead__r.Subscription_Informational_Updates__c;
                contact.Subscription_Newsletter__c = om.gk_user__r.Lead__r.Subscription_Newsletter__c;
                contact.Subscription_Product_updates__c = om.gk_user__r.Lead__r.Subscription_Product_updates__c;
                contact.Subscription_Webinars__c = om.gk_user__r.Lead__r.Subscription_Webinars__c;
            }
       		contact.AccountId = orgToAccountMap.get(om.gk_organization__c).id;
       		contactsToInsert.add(contact);
       		
       		userToContactMap.put(om.gk_user__c, contact); 	       		
       	}   		
		
			 	
	 	for (CF_Organization__c org : organizations) {
	 		org.Account__c = orgToAccountMap.get(org.id).id;
	 	}
	 	
	 	if (updateOrganizations == true) { // not from before update trigger
	 		Database.update(organizationsToUpdate, dml);	
	 	}
	 	  	
	 	Database.insert(contactsToInsert, dml);
	 	
	 	// convert leads
	 	
	 	List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
	 	List<Lead> leads = [SELECT id, CF_Organization__c, CF_User__c FROM Lead WHERE CF_Organization__c IN :allOrganizationIds AND IsConverted = false];
		 	
       	for(Lead lead : leads) {
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(lead.id);
			lc.setDoNotCreateOpportunity(True);
			
			Account account = orgToAccountMap.get(lead.CF_Organization__c);
			lc.setAccountId(account.id);
			
			Contact contact = userToContactMap.get(lead.CF_User__c);
			if (contact != null) {
				lc.setContactId(contact.id);	
			}
			
			// Converted Status Change
			lc.setConvertedStatus('Converted');
			lc.setSendNotificationEmail(true);
			lc.setOwnerId(UserInfo.getUserId());
			
			leadsToConvert.add(lc); 	       			
       	} 		

	 	
	 	Database.convertLead(leadsToConvert, dml);	
	 	
	 	return accountsToInsert;	
	}
}