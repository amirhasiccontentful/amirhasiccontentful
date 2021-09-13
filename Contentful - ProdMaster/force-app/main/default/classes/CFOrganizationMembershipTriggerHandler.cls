public with sharing class CFOrganizationMembershipTriggerHandler extends TriggerHandler {
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeUpdate() {
		SetCFOrganizationMembershipName(trigger.new);
	}

	public override void beforeInsert() {
		SetCFOrganizationMembershipName(trigger.new);
	}

	public override void afterInsert() {
		//cfOrganizationMemberships(trigger.new, (Map<Id, CF_Organization_Membership__c>)trigger.oldMap);
		//cFUserActivatedAt(trigger.new, (Map<Id, CF_Organization_Membership__c>)trigger.oldMap);
	}

	public override void afterUpdate() {
		//cfOrganizationMemberships(trigger.new, (Map<Id, CF_Organization_Membership__c>)trigger.oldMap);
		//cFUserActivatedAt(trigger.new, (Map<Id, CF_Organization_Membership__c>)trigger.oldMap);
	}
	

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	private void SetCFOrganizationMembershipName(List<CF_Organization_Membership__c> cfOrgMemberships) {

	  	Set<Decimal> allOrgIds = new Set<Decimal>();
	  	Set<Decimal> allUserIds = new Set<Decimal>();
	  	
	  	for (CF_Organization_Membership__c om : cfOrgMemberships) {
	      	allOrgIds.add(om.gk_organization_id__c);    
	      	allUserIds.add(om.gk_user_id__c);    
	  	}
	  	
	  	List<CF_Organization__c> potentialOrganizations = [SELECT Name, gk_id__c FROM CF_Organization__c WHERE gk_id__c IN :allOrgIds];
		List<CF_User__c> potentialUsers = [SELECT Name, gk_id__c FROM CF_User__c WHERE gk_id__c = :allUserIds];
		
	  
	  	Map<Decimal, CF_Organization__c> idToOrgMap = new Map<Decimal, CF_Organization__c>();
	  	for (CF_Organization__c u : potentialOrganizations) {
	    	idToOrgMap.put(u.gk_id__c, u); 
		}
		
	  	Map<Decimal, CF_User__c> idToUserMap = new Map<Decimal, CF_User__c>();
	  	for (CF_User__c u : potentialUsers) {
	    	idToUserMap.put(u.gk_id__c, u);
		}	
	  
	  	
	  	for (CF_Organization_Membership__c om : cfOrgMemberships) {
	    	
	  		CF_User__c user = idToUserMap.get(om.gk_user_id__c);
	  		CF_Organization__c org = idToOrgMap.get(om.gk_organization_id__c);
		
	  		String name = '';
	  		
			if (org != null && org.Name != null) {
				om.gk_organization__c = org.Id;
				name = name + org.Name;	
			}
			
			if (user != null && user.Name != null) {
				om.gk_user__c = user.id;
				name = name + ' / ' + user.Name;	
			}
			
			if (om != null && om.gk_role__c != null) {
				name = name + ' (' + om.gk_role__c + ')';
			}
			
			if (name.length() == 0) {
				name = 'Unkown';
			}
			
			if (name.length() > 70) { // threw errors otherwise
				name = name.substring(0, 70) + '...';
			}
			
			om.Name = name;						      		      	
	    }

	}

	/*private void cfOrganizationMemberships(List<CF_Organization_Membership__c> newOrganizationMembershipRecords, Map<Id, CF_Organization_Membership__c> oldMapRecords){

		System.debug('entered:cfOrganizationMemberships:---- ');

		Set<Id> cfOrganizationIds = new Set<Id>();

		Boolean executeFromCustomSetting = false;
		Boolean executeLogic = true;

		ExecuteSetting__c zuoraCFMembershipRollupSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('CF Organization Membership Rollup');

		if(zuoraCFMembershipRollupSetting != null){

			if(zuoraCFMembershipRollupSetting.Active__c == false){
				executeLogic = false;
			}

			if(zuoraCFMembershipRollupSetting.Execute__c == true){
				executeFromCustomSetting = true;
			}
		}

		if(executeLogic == false) return;

		for(CF_Organization_Membership__c orgMembership : newOrganizationMembershipRecords){

			CF_Organization_Membership__c oldRecord;

			if(oldMapRecords != null){
				oldRecord = oldMapRecords.get(orgMembership.Id);
			}

			if(oldRecord == null){
				cfOrganizationIds.add(orgMembership.gk_organization__c);
			} else if(oldRecord != null && 
				(orgMembership.gk_organization__c != oldRecord.get('gk_organization__c') || 
				 executeFromCustomSetting
				)){
				cfOrganizationIds.add(orgMembership.gk_organization__c);
			}
		}

		List<CF_Organization__c> cfOrgsForUpdate = new List<CF_Organization__c>();

		for(AggregateResult ag : [SELECT gk_organization__c cfOrg, count(Id) total 
									FROM CF_Organization_Membership__c WHERE gk_organization__c IN :cfOrganizationIds  
									GROUP BY gk_organization__c]){

			if(ag.get('cfOrg') != null){
				CF_Organization__c org = new CF_Organization__c(Id = (Id)ag.get('cfOrg'));
				org.cf_user_count__c = (Integer)ag.get('total');
				cfOrgsForUpdate.add(org);
			}
		}

		System.debug('entered:cfOrganizationMemberships:cfOrgsForUpdate---- ' + cfOrgsForUpdate);

		if(!cfOrgsForUpdate.isEmpty()){
			try{
				update cfOrgsForUpdate;
			}catch(Exception e){
				System.debug('CFOrganizationMembershipTriggerHandler:cfOrganizationMemberships:FAILED:-- ' + e);
			}
			
		}
	}

	private void cFUserActivatedAt(List<CF_Organization_Membership__c> newOrganizationMembershipRecords, Map<Id, CF_Organization_Membership__c> oldMapRecords){

		System.debug('entered:cFUserActivatedAt:---- ');

		Boolean executeFromCustomSetting = false;
		Boolean executeLogic = true;

		ExecuteSetting__c zuoraCFMembershipRollupSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('CF Organization Membership Rollup');

		if(zuoraCFMembershipRollupSetting != null){

			if(zuoraCFMembershipRollupSetting.Active__c == false){
				executeLogic = false;
			}

			if(zuoraCFMembershipRollupSetting.Execute__c == true){
				executeFromCustomSetting = true;
			}
		}

		if(executeLogic == false) return;

		Set<Id> cfUserIds = new Set<Id>();

		for(CF_Organization_Membership__c orgMembership : newOrganizationMembershipRecords){

			CF_Organization_Membership__c oldRecord;

			if(oldMapRecords != null){
				oldRecord = oldMapRecords.get(orgMembership.Id);
			}

			if(oldRecord == null && orgMembership.gk_user__c != null){
				cfUserIds.add(orgMembership.gk_user__c);
			} else if(oldRecord != null && 
				(orgMembership.gk_user__c != oldRecord.get('gk_user__c') || 
				 orgMembership.gk_organization__c != oldRecord.get('gk_organization__c') || 
				 executeFromCustomSetting
				)){

				if(orgMembership.gk_user__c != null){
					cfUserIds.add(orgMembership.gk_user__c);
				}
				
				if((Id)oldRecord.get('gk_user__c') != null){
					cfUserIds.add((Id)oldRecord.get('gk_user__c'));
				}
			}
		}

		System.debug('entered:cFUserActivatedAt:cfUserIds---- ' + cfUserIds);

		if(!cfUserIds.isEmpty() && !System.isBatch()){
			cFUserActivatedAtFuture(cfUserIds);
		} 
	}

	@future
	private static void cFUserActivatedAtFuture(Set<Id> cfUserIds){

		List<CF_User__c> cfUsersForUpdate = new List<CF_User__c>();

		for(CF_User__c cfU : [SELECT Id, BI_User_Activated_At__c, Organization_Count__c, 
								(SELECT Id, Activated_At__c, gk_organization__c FROM CF_Organization_Memberships__r ORDER BY Activated_At__c ASC NULLS LAST)
									FROM CF_User__c WHERE Id IN :cfUserIds]){

			cfU.Organization_Count__c = 0;
			cfU.BI_User_Activated_At__c = cfU.CF_Organization_Memberships__r[0].Activated_At__c;

			for(CF_Organization_Membership__c orgM : cfU.CF_Organization_Memberships__r){
				if(orgM.gk_organization__c != null){
					cfU.Organization_Count__c += 1;
				}
			}

			cfUsersForUpdate.add(cfU);
		}

		if(cfUsersForUpdate.size() > 0) {
			try{
				update cfUsersForUpdate;
			}catch(Exception e){
				System.debug('CFOrganizationMembershipTriggerHandler:cFUserActivatedAt:FAILED:-- ' + e);
			}
		}
	}*/
}