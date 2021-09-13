public with sharing class CFUserTriggerHandler extends TriggerHandler {

	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/
	public override void beforeUpdate() {
		CreateLeadFromUser(trigger.new);
		//AddIPLookup(trigger.new, (Map<Id, CF_User__c>)trigger.oldMap);
	}

	public override void beforeInsert() {
		CreateLeadFromUser(trigger.new);
		//AddIPLookup(trigger.new, null);
	}

	public override void afterUpdate() {
		GithubOrGooglePlus(trigger.new);
		
	}

	public override void afterInsert() {
		GithubOrGooglePlus(trigger.new);
	}

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	private void GithubOrGooglePlus(List<CF_User__c> cfUsers) {
		List<Lead> updateLeads = new List<Lead>();
		List<Contact> updateContacts = new List<Contact>();
		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();

		for(CF_User__c cfUser : cfUsers) {
			if(cfUser.Lead__c != null)
				leadIds.add(cfUser.Lead__c);
			if(cfUser.Contact__c != null)
				contactIds.add(cfUser.Contact__c);
		}

		Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Github_User__c, Status FROM Lead WHERE Id IN :leadIds AND Status != 'Disqualified']);
		Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Github_User__c FROM Contact WHERE Id IN :contactIds]);

		for(CF_User__c cfUser : cfUsers) {
			if(cfUser.gk_current_login_provider__c == 'github' || cfUser.gk_last_login_provider__c == 'github'){
				if(cfUser.Lead__c != null) {
					Lead l = leadMap.get(cfUser.Lead__c);
					if(l != null) {
						if(!l.Github_User__c) {
							l.Github_User__c = true;
							updateLeads.add(l);
						}
					}
				}
				if(cfUser.Contact__c != null) {
					Contact c = contactMap.get(cfUser.Contact__c);
					if(!c.Github_User__c) {
						c.Github_User__c = true;
						updateContacts.add(c);
					}
				}
			} 
		}

		if(!updateLeads.isEmpty()) {
			update updateLeads;
		}
		if(!updateContacts.isEmpty()) {
			update updateContacts;
		}
 	}

 	// BULKIFY
 	private void CreateLeadFromUser(List<CF_user__c> cfUsers) {
 		// Trigger creation boilerplate
    	for(CF_User__c user : cfUsers) {
      	   	
    	
	    	if ( 
		      	//if new user and not part of bulk import and not invited by someone 
	    		(Trigger.isInsert && user.gk_imported_at__c == null && user.gk_invitation_created_at__c == null) || 
	    		
		      	// if existing user and not in bulk and a lead was not created 
	    		(Trigger.isUpdate && user.gk_imported_at__c == null && user.gk_lead_created_at__c == null 
	    			// first and last name are set
	    			&& user.gk_first_name__c != null && user.gk_last_name__c != null && user.gk_invitation_created_at__c != null
	    			 ) ) { 
	    			
	    		if (Trigger.isUpdate) {
	    			CF_User.updateOrganizationMemberships(user);
	    		}
	    		
	    		// Delay creation of the lead so that the other related objects will for sure be added in the meantime
	    		try {
	    			CF_UserCreateLeadBatchable batchable = new CF_UserCreateLeadBatchable();
	    			System.scheduleBatch(batchable, 'CF_UserCreateLeadTrigger: ' + user.id, 2, 20);    			
	    		}
	    		catch (System.AsyncException e) {
	    			System.debug('CF_UserCreateLeadTrigger already scheduled');
	    		}
	    	}
	    }
 	}

 	/*private void AddIPLookup(List<CF_User__c> cfUsers, Map<Id, CF_User__c> oldCFUsers) {
 		CF_User__c old;

 		for (CF_User__c user : cfUsers) {
 			if (Trigger.isUpdate == true) {
	        	old = oldCFUsers.get(user.Id);
	      	}
	      	else {
	        	old = user;
	      	}	
      	
      		if ( (Trigger.isInsert && user.gk_current_sign_in_ip__c != null) || 
      			(Trigger.isUpdate && old.gk_current_sign_in_ip__c != user.gk_current_sign_in_ip__c)) {
      				
      				CF_IPLookup__c lu = CF_IPGeocoder.createOrUpdateIPLookup(user.gk_current_sign_in_ip__c, true);
		      		
		      		if (lu != null) {
		      			user.IP_Lookup__c = lu.id;	
		      		}
		    }
      	}
 	}*/
}