public with sharing class CFUserUtility { 

	// Name: RelationshipBetweenCFUserAndLeadOrContact
	// Description: Creates relationship on CF_User to Lead or Contact
	public static void RelationshipBetweenCFUserAndLeadOrContact(List<sObject> records) {
		Set<Id> recordIds = new Set<Id>();
		Map<Id, sObject> recordsMap = new Map<Id, sObject>();
		List<CF_User__c> updateCFUsers = new List<CF_User__c>();

		for(sObject record : records) {
			if(String.isNotBlank(String.valueOf(record.get('CF_User__c')))){
				recordIds.add(String.valueOf(record.get('CF_User__c')));
				recordsMap.put(String.valueOf(record.get('CF_User__c')), record);
			}
		}

		if(!recordIds.isEmpty()) {
			for(CF_User__c cfUser : [SELECT Lead__c FROM CF_User__c WHERE Id IN :recordIds]) {
				sObject record = recordsMap.get(cfUser.Id);
				String sObjectType = record.getSObjectType().getDescribe().getName();
				if(record != null) {
					if(String.isNotBlank(String.valueOf(record.get('MasterRecordId')))) {
						if(sObjectType == 'Lead')
							cfUser.Lead__c = String.valueOf(record.get('MasterRecordId'));
						else
							cfUser.Contact__c = String.valueOf(record.get('MasterRecordId'));
					} else {
						if(sObjectType == 'Lead')
							cfUser.Lead__c = String.valueOf(record.get('Id'));
						else
							cfUser.Contact__c = String.valueOf(record.get('Id'));
					}
					updateCFUsers.add(cfUser);
				}
			}
		
			if(!updateCFUsers.isEmpty()) {
				Database.update(updateCFUsers, false);
			}
		}
	}	

	// Name: RelationshipBetweenCFUserAndContactAfterLeadConversion
	// Description: Moves relationship on CF User from Lead to Contact after Lead conversion
	public static void RelationshipBetweenCFUserAndContactAfterLeadConversion(List<sObject> records) {
		Set<Id> recordIds = new Set<Id>();
		Map<Id, sObject> recordsMap = new Map<Id, sObject>();
		List<CF_User__c> updateCFUsers = new List<CF_User__c>();

		for(sObject record : records) {
			if(String.isNotBlank(String.valueOf(record.get('CF_User__c')))){
				if((Boolean)record.get('IsConverted')) {
					recordIds.add(String.valueOf(record.get('Id')));
					recordsMap.put(String.valueOf(record.get('Id')), record);
				}
			}
		}

		if(!recordIds.isEmpty()) {
			for(CF_User__c cfUser : [SELECT Lead__c, Contact__c FROM CF_User__c WHERE Lead__c IN :recordIds]) {
				sObject record = recordsMap.get(cfUser.Lead__c);
				if(record != null) {
					cfUser.Lead__c = null;
					cfUser.Contact__c = String.valueOf(record.get('ConvertedContactId'));
					updateCFUsers.add(cfUser);
				}
			}
			if(!updateCFUsers.isEmpty()) {
				Database.update(updateCFUsers, false);
			}
		}
	}
}