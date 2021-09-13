public with sharing class ContactTriggerHandler extends TriggerHandler {
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	//To uncomment if needed
	// public override void beforeDelete() {
		
	// }

	public override void beforeInsert() {
		contactDefaultOwner(trigger.new);
		new PersonaTitleMapping().assignPersonaTitleMapping('Contact', Trigger.new, Trigger.oldMap);
		emailOptOutField((Map<Id, Contact>)trigger.oldMap, Trigger.new);	
        assignContactOwnerifMatchedAccountDetailsExists(trigger.new, (Map<Id, Contact>)trigger.oldMap);
		AssignSDRtoCustomField(trigger.new);
	}

	public override void beforeUpdate() {
		new PersonaTitleMapping().assignPersonaTitleMapping('Contact', Trigger.new, Trigger.oldMap);
		emailOptOutField((Map<Id, Contact>)trigger.oldMap, Trigger.new);
        assignContactOwnerifMatchedAccountDetailsExists(trigger.new, (Map<Id, Contact>)trigger.oldMap);
		AssignSDRtoCustomField(trigger.new);
	}

	public override void afterUpdate() {
		CFUserUtility.RelationshipBetweenCFUserAndLeadOrContact(trigger.new);
	}

	public override void afterInsert() {
		CFUserUtility.RelationshipBetweenCFUserAndLeadOrContact(trigger.new);
	}

	public override void afterDelete() {
		CFUserUtility.RelationshipBetweenCFUserAndLeadOrContact(trigger.old);
	}

	//To uncomment if needed
	// public override void afterUndelete() {	
		
	// }

	/****************************************************/
	/* HELPER METHODS									*/
	/****************************************************/ 
	private void assignContactOwnerifMatchedAccountDetailsExists(List<Contact> newContacts, Map<Id, Contact> oldContactsMap) {
        
        Set<Id> matchedAccountsIds = new Set<Id>();

        for(Contact cont : newContacts) {
                
            //Check if Revenue Cycle Stage is MQL
            if(Trigger.isUpdate) {
                Contact oldContact = oldContactsMap.get(cont.Id); 

                if(cont.AccountId != null && cont.Revenue_Cycle_Stage__c == 'MQL' && oldContact.Revenue_Cycle_Stage__c != 'MQL'){
                    matchedAccountsIds.add(cont.AccountId);
                }
            } 

            //Pre-MQL routing. No check for Revenue Cycle Stage if MQL
            if(Trigger.isInsert && cont.AccountId != null){
                matchedAccountsIds.add(cont.AccountId);
            } 
        }         

        if(matchedAccountsIds.size() > 0) {
            for(Account matchedAccount : [SELECT Id, OwnerId, Owner.UserRole.Name
                                          FROM Account 
                                          WHERE Id IN: matchedAccountsIds AND Owner.UserRole.Name LIKE '%Partner%'
                                          ]) {

                for(Contact cont : newContacts) {   
                    if(matchedAccount.Id == cont.AccountId && matchedAccount.OwnerId != null &&
					   matchedAccount.Owner.UserRoleId != null && matchedAccount.Owner.UserRole.Name.contains('Partner')) {
                        cont.OwnerId = matchedAccount.OwnerId; 
                    }
                }
            }
        }
    } 

	public void AssignSDRtoCustomField(List<Contact> contacts) {
		Set<Id> ownerIds = new Set<Id>();

		for (Contact contact : contacts) {
			ownerIds.add(contact.OwnerId);
		}

		Map<Id, User> usersMap = new Map<Id, User>([SELECT UserRole.Name FROM User WHERE Id IN :ownerIds]);
		
		if(usersMap != null) {
			for (Contact contact : contacts) {
				User owner = usersMap.get(contact.OwnerId);
				if(owner != null && owner.UserRole != null && owner.UserRole.Name == 'SDR') {
					contact.SDR__c = contact.OwnerId;					
				}	
			}
		}
	}

	private void emailOptOutField(Map<Id, Contact> oldContactValues, List<Contact> newContacts){

		List<EmailOptOutDefinitions__c> lstOfDefinedValuesForOptOut = [SELECT Id, Name, Value__c FROM EmailOptOutDefinitions__c];
		
		if(lstOfDefinedValuesForOptOut.size() == 0) return;

		List<Contact> scopedRecordsForProcessing = new List<Contact>();

		for(Contact c : newContacts){
			if ((Trigger.isUpdate && c.Email != oldContactValues.get(c.Id).get('Email'))) {
		        scopedRecordsForProcessing.add(c);      
		    } else if (Trigger.isInsert){
		    	scopedRecordsForProcessing.add(c);
		    }
		}

		for(Contact con : scopedRecordsForProcessing){
			if(String.isNotBlank(con.Email)){
				for(EmailOptOutDefinitions__c definition : lstOfDefinedValuesForOptOut){
					if(con.Email.containsIgnoreCase(definition.Value__c)){
						con.HasOptedOutOfEmail = true;
					}
				}
			}
		}
	}

	private void contactDefaultOwner(List<Contact> newContacts){

		Set<Id> scopedAccountIds = new Set<Id>();
		List<Contact> scopedContacts = new List<Contact>();

		for(Contact con : newContacts){
			if(con.Revenue_Cycle_Stage__c != 'MQL' && con.Owner_is_SDR_PDR__c == FALSE){
				scopedAccountIds.add(con.AccountId);
				scopedContacts.add(con);
			}
		}

		if(!scopedAccountIds.isEmpty()){

			Map<Id,Id> mapOfAccountAndOwnerIds = new Map<Id,Id>();

			for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Owner.IsActive = TRUE AND Id IN :scopedAccountIds]){
				mapOfAccountAndOwnerIds.put(acc.Id, acc.OwnerId);
			}

			if(mapOfAccountAndOwnerIds != null){
				for(Contact c : scopedContacts){
					if(mapOfAccountAndOwnerIds.get(c.AccountId) != null){
						c.OwnerId = mapOfAccountAndOwnerIds.get(c.AccountId);
					}
				}
			}
		}
	}
}