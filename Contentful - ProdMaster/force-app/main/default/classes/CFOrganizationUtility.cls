public class CFOrganizationUtility { 

	// Name: RelationshipBetweenCFOrgAndLeadOrAccount
	// Description: Creates relationship on CF_Organization to Lead or Account
	//Faruk : potentially causing the issue where account lookup on CF Organization is being changed
	public static void RelationshipBetweenCFOrgAndLeadOrAccount(List<sObject> records) {
		Set<Id> recordIds = new Set<Id>();
		Map<Id, sObject> recordsMap = new Map<Id, sObject>();
		List<CF_Organization__c> updateCFOrgs = new List<CF_Organization__c>();

		for(sObject record : records) {
			if(String.isNotBlank(String.valueOf(record.get('CF_Organization__c')))){
				recordIds.add(String.valueOf(record.get('CF_Organization__c')));
				recordsMap.put(String.valueOf(record.get('CF_Organization__c')), record);
			}
		}

		if(!recordIds.isEmpty()) {
			for(CF_Organization__c cfOrg : [SELECT Id, Lead__c, Account__c FROM CF_Organization__c WHERE Id IN :recordIds]) {
				sObject record = recordsMap.get(cfOrg.Id);
				String sObjectType = record.getSObjectType().getDescribe().getName();
				if(record != null) {
					if(String.isNotBlank(String.valueOf(record.get('MasterRecordId')))) {
						if(sObjectType == 'Lead'){
							cfOrg.Lead__c = String.valueOf(record.get('MasterRecordId'));
						}
						else if(cfOrg.Account__c == null){
							cfOrg.Account__c = String.valueOf(record.get('MasterRecordId'));
						}
					} else {
						if(sObjectType == 'Lead'){
							cfOrg.Lead__c = String.valueOf(record.get('Id'));
						}
						else if(cfOrg.Account__c == null){
							cfOrg.Account__c = String.valueOf(record.get('Id'));
						}
					}
					updateCFOrgs.add(cfOrg);
				}
			}
		
			if(!updateCFOrgs.isEmpty()) {
				Database.update(updateCFOrgs, false);
			}
		}
	}

	// Name: RelationshipBetweenCFOrgAndAccountAfterLeadConversion
	// Description: Moves relationship on CF Organization from Lead to Account after Lead conversion
	//Faruk : potentially causing the issue where account lookup on CF Organization is being changed
	public static void RelationshipBetweenCFOrgAndAccountAfterLeadConversion(List<sObject> records) {
		Set<Id> recordIds = new Set<Id>();
		Map<Id, sObject> recordsMap = new Map<Id, sObject>();
		List<CF_Organization__c> updateCFOrgs = new List<CF_Organization__c>();

		for(sObject record : records) {
			if(String.isNotBlank(String.valueOf(record.get('CF_Organization__c')))){
				if((Boolean)record.get('IsConverted')) {
					recordIds.add(String.valueOf(record.get('Id')));
					recordsMap.put(String.valueOf(record.get('Id')), record);
				}
			}
		}

		if(!recordIds.isEmpty()) {
			for(CF_Organization__c cfOrg : [SELECT Id, Lead__c, Account__c FROM CF_Organization__c WHERE Lead__c IN :recordIds]) {
				sObject record = recordsMap.get(cfOrg.Lead__c);
				if(record != null) {
					cfOrg.Lead__c = null;
					if(cfOrg.Account__c == null){
						cfOrg.Account__c = String.valueOf(record.get('ConvertedAccountId'));
					}
					
					updateCFOrgs.add(cfOrg);
				}
			}
			if(!updateCFOrgs.isEmpty()) {
				Database.update(updateCFOrgs, false);
			}
		}
	}
}